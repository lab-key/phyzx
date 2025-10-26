const std = @import("std");
const phyzx = @import("phyzx");

const AppState = struct {
    sim: *phyzx.Simulation,
    viewer: *phyzx.Viewer,
    paused: bool = false,
};

// GLFW callbacks
fn keyboard(context: ?*anyopaque, key: phyzx.glfw.Key, scancode: c_int, act: phyzx.glfw.Action, mods: phyzx.glfw.Mods) void {
    _ = scancode;
    _ = mods;
    const app: *AppState = @ptrCast(@alignCast(context.?));

    if (act == phyzx.glfw.Action.press) {
        switch (key) {
            phyzx.glfw.Key.space => app.paused = !app.paused,
            phyzx.glfw.Key.backspace => {
                app.sim.reset();
                app.sim.forward();
            },
            else => {},
        }
    }
}

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();
    defer _ = gpa.deinit();

    const model_path = "libs/zmujoco/libs/mujoco/model/tendon_arm/arm26.xml";
    const sim = try phyzx.Simulation.init(allocator, model_path, null);
    defer sim.deinit();

    const viewer = try phyzx.Viewer.init(allocator, sim);
    defer viewer.deinit(allocator);

    var app_state = AppState{
        .sim = sim,
        .viewer = viewer,
    };

    viewer.setKeyCallback(&keyboard, &app_state);

    std.log.info("=== Model Loader [phyzx] ===", .{});

    while (!viewer.windowShouldClose()) {
        const simstart = viewer.getTime();

        if (!app_state.paused) {
            sim.step();
        }

        viewer.renderFrame();

        // Set the custom overlay text for the viewer to render
        var overlay_buf: [256]u8 = undefined;
        const overlay_text = std.fmt.bufPrintZ(&overlay_buf, "Paused: {s}", .{if (app_state.paused) "Yes" else "No"}) catch "Error";
        viewer.setOverlay(overlay_text);

        // Sleep to maintain simulation speed
        const simend = viewer.getTime();
        const looptime = simend - simstart;
        const sleeptime = sim.model.ptr.opt.timestep - looptime;
        if (sleeptime > 0) {
            std.Thread.sleep(@as(u64, @intFromFloat(sleeptime * 1e9)));
        }
    }
}
