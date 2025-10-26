const std = @import("std");
const phyzx = @import("zmujoco");
const glfw = @import("zmujoco").glfw;
const c = phyzx.c;
const simulation = @import("phyzx-sim");
const renderer = @import("phyzx-render");
const viewer_ui = @import("phyzx-viewui");

fn onPauseResumeClick(context: ?*anyopaque) void {
    if (context) |viewer_ptr| {
        const viewer: *Viewer = @ptrCast(@alignCast(viewer_ptr));
        viewer.paused = !viewer.paused;
    }
}

pub const KeyCallbackFn = fn(
    context: ?*anyopaque,
    key: glfw.Key,
    scancode: c_int,
    action: glfw.Action,
    mods: glfw.Mods,
) void;

fn glfwMouseButtonCallback(window: *glfw.Window, button: glfw.MouseButton, action: glfw.Action, mods: glfw.Mods) callconv(.c) void {
    _ = mods;
    const viewer: *Viewer = @ptrCast(@alignCast(glfw.getWindowUserPointer(window, Viewer).?));

    var handled_by_ui = false;
    for (0..viewer.buttons.items.len) |i| {
        var ui_button_ptr = &viewer.buttons.items[i];
        var xpos: f64 = undefined;
        var ypos: f64 = undefined;
        glfw.getCursorPos(window, &xpos, &ypos);

        if (xpos >= @as(f64, @floatFromInt(ui_button_ptr.rect.left)) and
            xpos <= @as(f64, @floatFromInt(ui_button_ptr.rect.left + ui_button_ptr.rect.width)) and
            ypos >= @as(f64, @floatFromInt(ui_button_ptr.rect.bottom)) and
            ypos <= @as(f64, @floatFromInt(ui_button_ptr.rect.bottom + ui_button_ptr.rect.height)))
        {
            ui_button_ptr.handleMouseClick(xpos, ypos, @as(glfw.Action, action));
            handled_by_ui = true;
        }
    }

    if (!handled_by_ui) {
        if (button == glfw.MouseButton.left) {
            viewer.button_left = (action == glfw.Action.press);
        } else if (button == glfw.MouseButton.right) {
            viewer.button_right = (action == glfw.Action.press);
        } else if (button == glfw.MouseButton.middle) {
            viewer.button_middle = (action == glfw.Action.press);
            if (action == glfw.Action.press) {
                c.mjv_initPerturb(viewer.sim.model.ptr, viewer.sim.data.ptr, &viewer.renderer.scene, &viewer.renderer.pert);
                viewer.renderer.pert.select = 1;
            } else if (action == glfw.Action.release) {
                viewer.renderer.pert.select = 0;
            }
        }
    }
}

fn glfwCursorPosCallback(window: *glfw.Window, xpos: f64, ypos: f64) callconv(.c) void {
    const viewer: *Viewer = @ptrCast(@alignCast(glfw.getWindowUserPointer(window, Viewer).?));
    const reldx = xpos - viewer.last_x;
    const reldy = ypos - viewer.last_y;
    viewer.last_x = xpos;
    viewer.last_y = ypos;

    var width: c_int = 0;
    var height: c_int = 0;
    glfw.getWindowSize(window, &width, &height);

    const normalized_reldx = reldx / @as(f64, @floatFromInt(width));
    const normalized_reldy = reldy / @as(f64, @floatFromInt(height));

    for (0..viewer.buttons.items.len) |i| {
        var button_ptr = &viewer.buttons.items[i];
        button_ptr.handleMouseMove(xpos, ypos);
    }

    if (viewer.button_left) {
        viewer.renderer.moveCamera(c.mjMOUSE_ROTATE_H, normalized_reldx, normalized_reldy);
    } else if (viewer.button_right) {
        viewer.renderer.moveCamera(c.mjMOUSE_MOVE_H, normalized_reldx, normalized_reldy);
    } else if (viewer.button_middle) {
        if (viewer.renderer.pert.select > 0) {
            c.mjv_movePerturb(viewer.sim.model.ptr, viewer.sim.data.ptr, c.mjMOUSE_MOVE_V, normalized_reldx, normalized_reldy, &viewer.renderer.scene, &viewer.renderer.pert);
            viewer.renderer.applyPerturb();
        }
    }
}

fn glfwScrollCallback(window: *glfw.Window, xoffset: f64, yoffset: f64) callconv(.c) void {
    _ = xoffset;
    const viewer: *Viewer = @ptrCast(@alignCast(glfw.getWindowUserPointer(window, Viewer).?));
    viewer.renderer.moveCamera(c.mjMOUSE_ZOOM, 0.0, yoffset);
}

fn defaultKeyCallback(context: ?*anyopaque, key: glfw.Key, scancode: c_int, action: glfw.Action, mods: glfw.Mods) void {
    _ = scancode;
    _ = mods;
    if (context) |ctx| {
        const viewer: *Viewer = @ptrCast(@alignCast(ctx));
        if (action == glfw.Action.press) {
            switch (key) {
                glfw.Key.space => viewer.paused = !viewer.paused,
                glfw.Key.backspace => viewer.sim.reset(),
                else => {},
            }
        }
    }
}

fn glfwKeyCallback(window: *glfw.Window, key: glfw.Key, scancode: c_int, action: glfw.Action, mods: glfw.Mods) callconv(.c) void {
    const viewer: *Viewer = @ptrCast(@alignCast(glfw.getWindowUserPointer(window, Viewer).?));
    if (viewer.key_callback) |cb| {
        cb(viewer.key_callback_context, key, scancode, @as(glfw.Action, action), mods);
    }
}

pub const Viewer = struct {
    sim: *simulation.Simulation,
    renderer: *renderer.Renderer,
    window: ?*glfw.Window,
    key_callback: ?*const KeyCallbackFn,
    key_callback_context: ?*anyopaque,
    paused: bool = false,
    last_x: f64 = 0.0,
    last_y: f64 = 0.0,
    button_left: bool = false,
    button_right: bool = false,
    button_middle: bool = false,
    buttons: std.array_list.Managed(viewer_ui.Button),
    text_labels: std.array_list.Managed(viewer_ui.TextLabel),
    time_label_buffer: [128]u8 = undefined,
    overlay_text: [1024]u8 = std.mem.zeroes([1024]u8),

    pub fn setKeyCallback(self: *Viewer, callback: ?*const KeyCallbackFn, context: ?*anyopaque) void {
        self.key_callback = callback;
        self.key_callback_context = context;
    }

    pub fn setOverlay(self: *Viewer, text: []const u8) void {
        const len = @min(text.len, self.overlay_text.len - 1);
        @memcpy(self.overlay_text[0..len], text);
        self.overlay_text[len] = 0;
    }

    pub fn getTime(self: *const Viewer) f64 {
        _ = self;
        return glfw.getTime();
    }

    pub fn init(allocator: std.mem.Allocator, sim: *simulation.Simulation) !*Viewer {
        const self = try allocator.create(Viewer);
        errdefer allocator.destroy(self);

        try glfw.init();

        const monitor = glfw.getPrimaryMonitor();
        const mode = if (monitor) |m| try glfw.getVideoMode(m) else null;

        const window_width = if (mode) |m| @as(i32, @intCast(m.width)) else 800;
        const window_height = if (mode) |m| @as(i32, @intCast(m.height)) else 600;

        const window = try glfw.createWindow(window_width, window_height, "Phyzx Viewer", null);
        errdefer glfw.destroyWindow(window);

        glfw.makeContextCurrent(window);
        glfw.swapInterval(1);

        var width: c_int = undefined;
        var height: c_int = undefined;
        glfw.getFramebufferSize(window, &width, &height);

        const viewer_renderer = try renderer.Renderer.init(allocator, sim, @as(i32, @intCast(height)), @as(i32, @intCast(width)));

        self.* = .{
            .sim = sim,
            .renderer = viewer_renderer,
            .window = window,
            .key_callback = null,
            .key_callback_context = null,
            .paused = false,
            .last_x = 0.0,
            .last_y = 0.0,
            .button_left = false,
            .button_right = false,
            .button_middle = false,
            .buttons = std.array_list.Managed(viewer_ui.Button).init(allocator),
            .text_labels = std.array_list.Managed(viewer_ui.TextLabel).init(allocator),
        };

        const pause_button_rect = c.mjrRect{
            .left = 10,
            .bottom = 50,
            .width = 100,
            .height = 30,
        };
        const pause_button = viewer_ui.Button.init(
            pause_button_rect,
            "Pause/Resume",
            .{ 0.2, 0.2, 0.2, 1.0 },
            .{ 0.3, 0.3, 0.3, 1.0 },
            .{ 0.1, 0.1, 0.1, 1.0 },
            onPauseResumeClick,
            self,
        );
        try self.buttons.append(pause_button);

        const status_label_rect = c.mjrRect{
            .left = 10,
            .bottom = 10,
            .width = 150,
            .height = 30,
        };
        const status_label = viewer_ui.TextLabel.init(
            status_label_rect,
            "Status: Running",
            .{ 1.0, 1.0, 1.0, 1.0 },
        );
        try self.text_labels.append(status_label);

        const time_label_rect = c.mjrRect{
            .left = 10,
            .bottom = 30,
            .width = 150,
            .height = 30,
        };
        const time_label = viewer_ui.TextLabel.init(
            time_label_rect,
            "Time: 0.00s",
            .{ 1.0, 1.0, 1.0, 1.0 },
        );
        try self.text_labels.append(time_label);

        glfw.setWindowUserPointer(window, self);
        _ = glfw.setKeyCallback(window, glfwKeyCallback);
        _ = glfw.setMouseButtonCallback(window, glfwMouseButtonCallback);
        _ = glfw.setCursorPosCallback(window, glfwCursorPosCallback);
        _ = glfw.setScrollCallback(window, glfwScrollCallback);
        self.setKeyCallback(&defaultKeyCallback, self);

        return self;
    }

    pub fn deinit(self: *Viewer, allocator: std.mem.Allocator) void {
        self.renderer.deinit(allocator);
        if (self.window) |w| {
            glfw.destroyWindow(w);
        }
        glfw.terminate();
        self.buttons.deinit();
        self.text_labels.deinit();
        allocator.destroy(self);
    }

    pub fn windowShouldClose(self: *Viewer) bool {
        return glfw.windowShouldClose(self.window.?);
    }

    pub fn renderFrame(self: *Viewer) void {
        glfw.makeContextCurrent(self.window.?);

        self.renderer.updateScene();

        var width: c_int = 0;
        var height: c_int = 0;
        glfw.getFramebufferSize(self.window.?, &width, &height);

        const viewport = c.mjrRect{
            .left = 0,
            .bottom = 0,
            .width = width,
            .height = height,
        };
        c.mjr_setBuffer(c.mjFB_WINDOW, &self.renderer.context);
        c.mjr_render(viewport, &self.renderer.scene, &self.renderer.context);

        for (self.buttons.items) |button_ptr| {
            button_ptr.draw(&self.renderer.context);
        }

        if (self.paused) {
            self.text_labels.items[0].text = "Status: Paused";
        } else {
            self.text_labels.items[0].text = "Status: Running";
        }

        const time_text = std.fmt.bufPrint(&self.time_label_buffer, "Time: {d:.2}s", .{self.sim.data.time()}) catch "Time: Error";
        self.text_labels.items[1].text = time_text;

        for (self.text_labels.items) |*text_label| {
            text_label.draw(&self.renderer.context);
        }

        if (self.overlay_text[0] != 0) {
            c.mjr_overlay(c.mjFONT_NORMAL, c.mjGRID_TOPLEFT, viewport, &self.overlay_text[0], null, &self.renderer.context);
        }

        glfw.swapBuffers(self.window.?);
        glfw.pollEvents();
    }
};