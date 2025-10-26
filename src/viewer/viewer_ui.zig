const std = @import("std");
const c = @import("zmujoco").c;
const glfw = @import("zmujoco").glfw;

// Define states for UI elements
pub const UIState = enum {
    Normal,
    Hovered,
    Pressed,
};

fn dummyOnClick(context: ?*anyopaque) void { _ = context; }

// Button struct
pub const Button = struct {
    rect: c.mjrRect,
    text: []const u8,
    normal_color: [4]f32,
    hover_color: [4]f32,
    press_color: [4]f32,
    current_state: UIState,
    on_click: *const fn (context: ?*anyopaque) void,
    context: ?*anyopaque,

    pub fn init(
        rect: c.mjrRect,
        text: []const u8,
        normal_color: [4]f32,
        hover_color: [4]f32,
        press_color: [4]f32,
        on_click: ?*const fn (context: ?*anyopaque) void,
        context: ?*anyopaque,
    ) Button {
        return .{
            .rect = rect,
            .text = text,
            .normal_color = normal_color,
            .hover_color = hover_color,
            .press_color = press_color,
            .current_state = .Normal,
            .on_click = on_click orelse dummyOnClick,
            .context = context,
        };
    }

    pub fn draw(self: *const Button, context: *c.mjrContext) void {
        var color: [4]f32 = undefined;
        switch (self.current_state) {
            .Normal => color = self.normal_color,
            .Hovered => color = self.hover_color,
            .Pressed => color = self.press_color,
        }
        c.mjr_rectangle(self.rect, color[0], color[1], color[2], color[3]);

        // Create a null-terminated copy of the text
        var text_c: [128]u8 = undefined; // Assuming max text length of 127 characters
        const text_len = @min(self.text.len, text_c.len - 1);
        @memcpy(text_c[0..text_len], self.text[0..text_len]);
        text_c[text_len] = 0;

        c.mjr_overlay(c.mjFONT_NORMAL, c.mjGRID_TOPLEFT, self.rect, &text_c[0], null, context);
    }

    pub fn handleMouseMove(self: *Button, mouse_x: f64, mouse_y: f64) void {
        if (mouse_x >= @as(f64, @floatFromInt(self.rect.left)) and
            mouse_x <= @as(f64, @floatFromInt(self.rect.left + self.rect.width)) and
            mouse_y >= @as(f64, @floatFromInt(self.rect.bottom)) and
            mouse_y <= @as(f64, @floatFromInt(self.rect.bottom + self.rect.height)))
        {
            if (self.current_state == .Normal) {
                self.current_state = .Hovered;
            }
        } else {
            self.current_state = .Normal;
        }
    }

    pub fn handleMouseClick(self: *Button, mouse_x: f64, mouse_y: f64, action: glfw.Action) void {
        if (mouse_x >= @as(f64, @floatFromInt(self.rect.left)) and
            mouse_x <= @as(f64, @floatFromInt(self.rect.left + self.rect.width)) and
            mouse_y >= @as(f64, @floatFromInt(self.rect.bottom)) and
            mouse_y <= @as(f64, @floatFromInt(self.rect.bottom + self.rect.height)))
        {
            if (action == glfw.Action.press) {
                self.current_state = .Pressed;
            } else if (action == glfw.Action.release and self.current_state == .Pressed) {
                self.on_click(self.context);
                self.current_state = .Hovered; // Return to hovered after click
            }
        } else {
            self.current_state = .Normal;
        }
    }
};

// TextLabel struct
pub const TextLabel = struct {
    rect: c.mjrRect,
    text: []const u8,
    color: [4]f32,

    pub fn init(rect: c.mjrRect, text: []const u8, color: [4]f32) TextLabel {
        return .{
            .rect = rect,
            .text = text,
            .color = color,
        };
    }

    pub fn draw(self: *const TextLabel, context: *c.mjrContext) void {
        // Create a null-terminated copy of the text
        var text_c: [128]u8 = undefined; // Assuming max text length of 127 characters
        const text_len = @min(self.text.len, text_c.len - 1);
        @memcpy(text_c[0..text_len], self.text[0..text_len]);
        text_c[text_len] = 0;

        c.mjr_overlay(c.mjFONT_NORMAL, c.mjGRID_TOPLEFT, self.rect, &text_c[0], null, context);
    }
};
