const std = @import("std");
const phyzx = @import("phyzx");

const AppState = struct {
    sim: *phyzx.Simulation,
    viewer: *phyzx.Viewer,

    // Control state
    control_mode: enum { JointControl, Preset, Reaching, Wave } = .JointControl,
    target_pos: [2]f64 = .{ 0.5, 0.3 },
    time: f64 = 0.0,

    // Joint control targets
    target_shoulder_angle: f64 = 0.0,
    target_elbow_angle: f64 = 0.0,

    // Manual muscle activations
    manual_activations: [6]f64 = [_]f64{0.0} ** 6,

    // Presets
    current_preset: usize = 0,

    // Saved poses
    saved_poses: [5]?Pose = [_]?Pose{null} ** 5,
};

const Pose = struct {
    name: []const u8,
    shoulder_angle: f64,
    elbow_angle: f64,
};

const presets = [_]Pose{
    .{ .name = "Rest", .shoulder_angle = 0.0, .elbow_angle = 0.0 },
    .{ .name = "Reach Forward", .shoulder_angle = std.math.pi / 4.0, .elbow_angle = 0.0 },
    .{ .name = "Reach Up", .shoulder_angle = std.math.pi / 2.0, .elbow_angle = 0.0 },
    .{ .name = "Bent Elbow", .shoulder_angle = std.math.pi / 4.0, .elbow_angle = std.math.pi / 3.0 },
    .{ .name = "Wave Position", .shoulder_angle = std.math.pi / 2.0, .elbow_angle = std.math.pi / 2.0 },
};

// --- Controller Logic ---

fn applyPreset(app: *AppState, pose: Pose) void {
    app.target_shoulder_angle = pose.shoulder_angle;
    app.target_elbow_angle = pose.elbow_angle;
    std.log.info("Applied preset: {s}", .{pose.name});
}

fn saveCustomPose(app: *AppState, slot: usize) void {
    const d = app.sim.data.ptr;
    const current_shoulder = d.qpos[0];
    const current_elbow = d.qpos[1];

    var name_buf: [32]u8 = undefined;
    const name = std.fmt.bufPrint(&name_buf, "Custom {d}", .{ slot + 1 }) catch "Custom";

    app.saved_poses[slot] = Pose{
        .name = name,
        .shoulder_angle = current_shoulder,
        .elbow_angle = current_elbow,
    };
    std.log.info("Saved pose to slot {d}: shoulder={e:.2}, elbow={e:.2}", .{ slot + 1, current_shoulder, current_elbow });
}

fn loadCustomPose(app: *AppState, slot: usize) void {
    if (app.saved_poses[slot]) |pose| {
        applyPreset(app, pose);
        std.log.info("Loaded custom pose {d}", .{slot + 1});
    } else {
        std.log.info("No pose saved in slot {d}", .{slot + 1});
    }
}

fn getEndEffectorPos(d: *phyzx.Data) [2]f64 {
    const shoulder_angle = d.ptr.qpos[0];
    const elbow_angle = d.ptr.qpos[1];

    const upper_len = 0.5;
    const fore_len = 0.5;

    const x = upper_len * @cos(shoulder_angle) + fore_len * @cos(shoulder_angle + elbow_angle);
    const y = upper_len * @sin(shoulder_angle) + fore_len * @sin(shoulder_angle + elbow_angle);

    return .{ x, y };
}

fn jointPDController(app: *AppState) void {
    const d = app.sim.data.ptr;
    const current_shoulder = d.qpos[0];
    const current_elbow = d.qpos[1];

    const shoulder_error = app.target_shoulder_angle - current_shoulder;
    const elbow_error = app.target_elbow_angle - current_elbow;

    const kp = 5.0;
    const kd = 0.5;

    const shoulder_vel = d.qvel[0];
    const elbow_vel = d.qvel[1];

    for (&app.manual_activations) |*act| {
        act.* = 0.0;
    }

    const shoulder_control = kp * shoulder_error - kd * shoulder_vel;
    if (shoulder_control > 0) {
        app.manual_activations[0] = @min(1.0, shoulder_control);
    } else {
        app.manual_activations[1] = @min(1.0, -shoulder_control);
    }

    const elbow_control = kp * elbow_error - kd * elbow_vel;
    if (elbow_control > 0) {
        app.manual_activations[2] = @min(1.0, elbow_control);
    } else {
        app.manual_activations[3] = @min(1.0, -elbow_control);
    }
}

fn reachingController(app: *AppState) void {
    const end_pos = getEndEffectorPos(app.sim.data);
    const error_x = app.target_pos[0] - end_pos[0];
    const error_y = app.target_pos[1] - end_pos[1];

    const kp = 2.0;

    for (&app.manual_activations) |*act| {
        act.* = 0.0;
    }

    if (error_x > 0.05) {
        app.manual_activations[0] = @min(1.0, kp * error_x);
    } else if (error_x < -0.05) {
        app.manual_activations[1] = @min(1.0, -kp * error_x);
    }

    if (error_y > 0.05) {
        app.manual_activations[2] = @min(1.0, kp * error_y);
    } else if (error_y < -0.05) {
        app.manual_activations[3] = @min(1.0, -kp * error_y);
    }
}

fn waveController(app: *AppState) void {
    const freq = 1.0;
    const phase = 2.0 * std.math.pi * freq * app.time;

    app.manual_activations[0] = 0.3 + 0.3 * @sin(phase);
    app.manual_activations[1] = 0.3 - 0.3 * @sin(phase);
    app.manual_activations[2] = 0.3 + 0.3 * @sin(phase + std.math.pi / 2.0);
    app.manual_activations[3] = 0.3 - 0.3 * @sin(phase + std.math.pi / 2.0);
    app.manual_activations[4] = 0.2;
    app.manual_activations[5] = 0.2;
}

fn applyControl(app: *AppState) void {
    switch (app.control_mode) {
        .JointControl, .Preset => jointPDController(app),
        .Reaching => reachingController(app),
        .Wave => waveController(app),
    }

    const d = app.sim.data.ptr;
    for (app.manual_activations, 0..) |activation, i| {
        d.ctrl[i] = activation;
    }
}

fn keyboard(context: ?*anyopaque, key: phyzx.glfw.Key, scancode: c_int, act: phyzx.glfw.Action, mods: phyzx.glfw.Mods) void {
    _ = scancode;
    const app: *AppState = @ptrCast(@alignCast(context.?));

    if (act == phyzx.glfw.Action.press) {
        switch (key) {
            phyzx.glfw.Key.space => app.viewer.paused = !app.viewer.paused,
            phyzx.glfw.Key.backspace => {
                app.sim.reset();
                app.sim.forward();
                app.time = 0.0;
                app.target_shoulder_angle = 0.0;
                app.target_elbow_angle = 0.0;
            },
            phyzx.glfw.Key.one => app.control_mode = .JointControl,
            phyzx.glfw.Key.two => app.control_mode = .Preset,
            phyzx.glfw.Key.three => app.control_mode = .Reaching,
            phyzx.glfw.Key.four => app.control_mode = .Wave,
            phyzx.glfw.Key.w => {
                if (app.control_mode == .JointControl) app.target_shoulder_angle += 0.1;
            },
            phyzx.glfw.Key.s => {
                if (app.control_mode == .JointControl) app.target_shoulder_angle -= 0.1;
            },
            phyzx.glfw.Key.up => {
                if (app.control_mode == .JointControl) app.target_elbow_angle += 0.1;
            },
            phyzx.glfw.Key.down => {
                if (app.control_mode == .JointControl) app.target_elbow_angle -= 0.1;
            },
            phyzx.glfw.Key.left => {
                if (app.control_mode == .Preset) {
                    if (app.current_preset > 0) {
                        app.current_preset -= 1;
                    } else {
                        app.current_preset = presets.len - 1;
                    }
                    applyPreset(app, presets[app.current_preset]);
                }
            },
            phyzx.glfw.Key.right => {
                if (app.control_mode == .Preset) {
                    app.current_preset = (app.current_preset + 1) % presets.len;
                    applyPreset(app, presets[app.current_preset]);
                }
            },
            phyzx.glfw.Key.five => {
                if (mods.shift) saveCustomPose(app, 0) else if (app.control_mode == .Preset) loadCustomPose(app, 0);
            },
            phyzx.glfw.Key.six => {
                if (mods.shift) saveCustomPose(app, 1) else if (app.control_mode == .Preset) loadCustomPose(app, 1);
            },
            phyzx.glfw.Key.seven => {
                if (mods.shift) saveCustomPose(app, 2) else if (app.control_mode == .Preset) loadCustomPose(app, 2);
            },
            phyzx.glfw.Key.eight => {
                if (mods.shift) saveCustomPose(app, 3) else if (app.control_mode == .Preset) loadCustomPose(app, 3);
            },
            phyzx.glfw.Key.nine => {
                if (mods.shift) saveCustomPose(app, 4) else if (app.control_mode == .Preset) loadCustomPose(app, 4);
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

    // Customize camera and visual options
    viewer.renderer.camera.azimuth = 90.0;
    viewer.renderer.camera.elevation = -20.0;
    viewer.renderer.camera.distance = 2.5;
    viewer.renderer.camera.lookat[0] = 0.5;
    viewer.renderer.vopt.flags[phyzx.c.mjVIS_TENDON] = 1;

    var app_state = AppState{
        .sim = sim,
        .viewer = viewer,
    };

    viewer.setKeyCallback(&keyboard, &app_state);

    std.log.info("=== Arm Controller [phyzx] ===", .{});
    std.log.info("Controls are identical to the zmujoco example.", .{});

    while (!viewer.windowShouldClose()) {
        const simstart = viewer.getTime();

        if (!viewer.paused) {
            applyControl(&app_state);
            sim.step();
            app_state.time += sim.model.ptr.opt.timestep;
        }

        viewer.renderFrame();

        // Set the custom overlay text for the viewer to render
        var overlay_buf: [512]u8 = undefined;
        const mode_str = switch (app_state.control_mode) {
            .JointControl => "JOINT CONTROL",
            .Preset => "PRESET",
            .Reaching => "REACHING",
            .Wave => "WAVE",
        };

        const overlay_text = if (app_state.control_mode == .Preset) blk: {
            break :blk std.fmt.bufPrintZ(&overlay_buf, 
                "Mode: {s}\nPreset: {s}\nShoulder: {e:.2} rad\nElbow: {e:.2} rad\nMuscles: SF={e:.2} SE={e:.2} EF={e:.2} EE={e:.2}", 
                .{ mode_str, presets[app_state.current_preset].name, sim.data.ptr.qpos[0], sim.data.ptr.qpos[1], 
                   app_state.manual_activations[0], app_state.manual_activations[1], app_state.manual_activations[2], app_state.manual_activations[3] }
            ) catch "Error";
        } else blk: {
            break :blk std.fmt.bufPrintZ(&overlay_buf, 
                "Mode: {s}\nTarget Shoulder: {e:.2} rad\nTarget Elbow: {e:.2} rad\nActual: S={e:.2} E={e:.2}\nMuscles: SF={e:.2} SE={e:.2} EF={e:.2} EE={e:.2}", 
                .{ mode_str, app_state.target_shoulder_angle, app_state.target_elbow_angle, sim.data.ptr.qpos[0], sim.data.ptr.qpos[1],
                   app_state.manual_activations[0], app_state.manual_activations[1], app_state.manual_activations[2], app_state.manual_activations[3] }
            ) catch "Error";
        };
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
