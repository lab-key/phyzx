const std = @import("std");
pub const phyzx = @import("zmujoco");
pub const glfw = phyzx.glfw;
pub const c = phyzx.c;
pub const c_constants = phyzx.c;


pub const ObjType = enum(c.mjtObj) {
    unknown = c.mjOBJ_UNKNOWN,
    body = c.mjOBJ_BODY,
    xbody = c.mjOBJ_XBODY,
    joint = c.mjOBJ_JOINT,
    dof = c.mjOBJ_DOF,
    geom = c.mjOBJ_GEOM,
    site = c.mjOBJ_SITE,
    camera = c.mjOBJ_CAMERA,
    light = c.mjOBJ_LIGHT,
    flex = c.mjOBJ_FLEX,
    mesh = c.mjOBJ_MESH,
    skin = c.mjOBJ_SKIN,
    hfield = c.mjOBJ_HFIELD,
    texture = c.mjOBJ_TEXTURE,
    material = c.mjOBJ_MATERIAL,
    pair = c.mjOBJ_PAIR,
    exclude = c.mjOBJ_EXCLUDE,
    equality = c.mjOBJ_EQUALITY,
    tendon = c.mjOBJ_TENDON,
    actuator = c.mjOBJ_ACTUATOR,
    sensor = c.mjOBJ_SENSOR,
    numeric = c.mjOBJ_NUMERIC,
    text = c.mjOBJ_TEXT,
    tuple = c.mjOBJ_TUPLE,
    key = c.mjOBJ_KEY,
    plugin = c.mjOBJ_PLUGIN,
};

pub fn idFromName(model: *Model, obj_type: ObjType, name: []const u8) !?c_int {

    return sim.idFromName(model, @intFromEnum(obj_type), name);

}

pub const sim = @import("phyzx-sim");
pub const renderer = @import("phyzx-render");
pub const viewer = @import("phyzx-viewer");
pub const rollout = @import("phyzx-rollout");
pub const math = @import("phyzx-math");
//const minimize = @import("phyzx-minimize");

//==============================================================================
// Re-Exports of Existing Structs
//==============================================================================

pub const Vec3 = math.Vec3;
pub const SpecBuilder = sim.SpecBuilder;


pub const Simulation = sim.Simulation;
pub const Spec = sim.Spec;
pub const Model = sim.Model;
pub const Data = sim.Data;
pub const Renderer = renderer.Renderer;
pub const Viewer = viewer.Viewer;
pub const Rollout = rollout.Rollout;

pub fn applyForce(simulation_instance: *Simulation, body_id: c_int, force: [3]phyzx.mjtNum, point: [3]phyzx.mjtNum) void {
    simulation_instance.applyForce(body_id, force, point);
}

// --- High-level name-based accessors ---
pub fn get_body_id(model: *Model, name: []const u8) !c_int {
    return model.getBodyId(name);
}

pub fn get_joint_id(model: *Model, name: []const u8) !c_int {
    return model.getJointId(name);
}

pub fn get_geom_id(model: *Model, name: []const u8) !c_int {
    return model.getGeomId(name);
}

pub fn get_actuator_id(model: *Model, name: []const u8) !c_int {
    return model.getActuatorId(name);
}

pub fn get_joint_qpos(data: *Data, model: *Model, joint_name: []const u8) !phyzx.mjtNum {
    const joint_id = try get_joint_id(model, joint_name);
    return data.getJointPosition(model, joint_id);
}

pub fn set_joint_qpos(data: *Data, model: *Model, joint_name: []const u8, value: phyzx.mjtNum) !void {
    const joint_id = try get_joint_id(model, joint_name);
    return data.setJointPosition(model, joint_id, value);
}

pub fn get_joint_qvel(data: *Data, model: *Model, joint_name: []const u8) !phyzx.mjtNum {
    const joint_id = try get_joint_id(model, joint_name);
    return data.getJointVelocity(model, joint_id);
}

pub fn set_joint_qvel(data: *Data, model: *Model, joint_name: []const u8, value: phyzx.mjtNum) !void {
    const joint_id = try get_joint_id(model, joint_name);
    return data.setJointVelocity(model, joint_id, value);
}

pub fn get_actuator_ctrl(data: *Data, model: *Model, actuator_name: []const u8) !phyzx.mjtNum {
    const actuator_id = try get_actuator_id(model, actuator_name);
    return data.getActuatorControl(model, actuator_id);
}

pub fn set_actuator_ctrl(data: *Data, model: *Model, actuator_name: []const u8, value: phyzx.mjtNum) !void {
    const actuator_id = try get_actuator_id(model, actuator_name);
    return data.setActuatorControl(model, actuator_id, value);
}
//pub const least_squares = minimize.least_squares;

// --- Re-export Mjs* structs for type safety ---
pub const MjsBody = sim.MjsBody;
pub const MjsGeom = sim.MjsGeom;
pub const MjsJoint = sim.MjsJoint;
pub const MjsSite = sim.MjsSite;
pub const MjsLight = sim.MjsLight;
pub const MjsFrame = sim.MjsFrame;
pub const MjsCompiler = sim.MjsCompiler;
pub const MjsOption = sim.MjsOption;
pub const MjsVisual = sim.MjsVisual;
pub const MjsNumeric = sim.MjsNumeric;
pub const MjsText = sim.MjsText;
pub const MjsTuple = sim.MjsTuple;
pub const MjsKey = sim.MjsKey;
pub const MjsPlugin = sim.MjsPlugin;
pub const MjsSkin = sim.MjsSkin;
pub const MjsDefault = sim.MjsDefault;
pub const MjsStatistic = sim.MjsStatistic;
pub const MjsMesh = sim.MjsMesh;
pub const MjsHField = sim.MjsHField;
pub const MjsTexture = sim.MjsTexture;
pub const MjsMaterial = sim.MjsMaterial;
pub const MjsTendon = sim.MjsTendon;
pub const MjsEquality = sim.MjsEquality;
pub const MjsPair = sim.MjsPair;
pub const MjsFlex = sim.MjsFlex;
pub const MjsActuator = sim.MjsActuator;
pub const MjsSensor = sim.MjsSensor;


pub const OnStepFn = *const fn (sim_instance: *Simulation, viewer_instance: *Viewer, is_paused: bool) void;
pub const GetOverlayTextFn = *const fn (sim_instance: *Simulation, viewer_instance: *Viewer, is_paused: bool) []const u8;
pub const OnResetFn = *const fn (sim_instance: *Simulation) void;

// Context for the custom key callback in launch_viewer
pub const LaunchViewerContext = struct {
    sim_instance: *Simulation,
    viewer_instance: *Viewer,
    on_reset_cb: ?OnResetFn,
    user_context: ?*anyopaque, // New field for generic user context
};

// Custom key callback for launch_viewer
fn phyzx_launch_viewer_key_callback(
    context: ?*anyopaque,
    key: glfw.Key,
    scancode: c_int,
    action: glfw.Action,
    mods: glfw.Mods,
) void {
    _ = scancode;
    _ = mods;

    const ctx: *LaunchViewerContext = @ptrCast(@alignCast(context.?));

    if (action == glfw.Action.press) {
        switch (key) {
            .space => {
                ctx.viewer_instance.paused = !ctx.viewer_instance.paused;
            },
            .backspace => {
                ctx.sim_instance.reset();
                if (ctx.on_reset_cb) |cb| {
                    cb(ctx.sim_instance);
                }
            },
            else => {},
        }
    }
}

// Default on_step callback (does nothing)
fn defaultOnStepImpl(sim_instance: *Simulation, viewer_instance: *Viewer, is_paused: bool) void {
    _ = sim_instance;
    _ = viewer_instance;
    _ = is_paused;
}
const defaultOnStep = &defaultOnStepImpl;

// Default overlay text provider
fn defaultGetOverlayTextImpl(sim_instance: *Simulation, viewer_instance: *Viewer, is_paused: bool) []const u8 {
    _ = sim_instance;
    _ = viewer_instance;
    if (is_paused) {
        return "Paused: Yes";
    } else {
        return "Paused: No";
    }
}
const defaultGetOverlayText = &defaultGetOverlayTextImpl;

pub fn launch_viewer(
    allocator: std.mem.Allocator,
    model: *Model,
    on_step: ?OnStepFn,
    get_overlay_text: ?GetOverlayTextFn,
    on_reset: ?OnResetFn, // Re-introduced parameter
    user_context: ?*anyopaque, // New parameter for generic user context
) !void {
    const sim_instance = try Simulation.init_from_model_and_data(allocator, model, try Data.init(allocator, model));
    defer sim_instance.deinit();

    const viewer_instance = try Viewer.init(allocator, sim_instance);
    defer viewer_instance.deinit(allocator);

    // Create and set the LaunchViewerContext for the key callback
    var lv_ctx = LaunchViewerContext{
        .sim_instance = sim_instance,
        .viewer_instance = viewer_instance,
        .on_reset_cb = on_reset,
        .user_context = user_context, // Pass the generic user context
    };
    viewer_instance.setKeyCallback(phyzx_launch_viewer_key_callback, &lv_ctx);

    while (!viewer_instance.windowShouldClose()) {
        const on_step_cb = on_step orelse defaultOnStep;
        on_step_cb(sim_instance, viewer_instance, viewer_instance.paused);

        const simstart = viewer_instance.getTime();

        if (!viewer_instance.paused) {
            sim_instance.step();
        }

        // Handle overlay text
        var overlay_buf: [256]u8 = undefined; // Internal buffer for overlay text
        const text_provider = get_overlay_text orelse defaultGetOverlayText;
        const text_slice = text_provider(sim_instance, viewer_instance, viewer_instance.paused);
        const len = @min(text_slice.len, overlay_buf.len - 1);
        @memcpy(overlay_buf[0..len], text_slice);
        overlay_buf[len] = 0;
        viewer_instance.setOverlay(overlay_buf[0..len]); // Assuming setOverlay takes a slice

        viewer_instance.renderFrame();

        // Sleep to maintain simulation speed
        const simend = viewer_instance.getTime();
        const looptime = simend - simstart;
        const sleeptime = sim_instance.model.ptr.opt.timestep - looptime;
        if (sleeptime > 0) {
            std.Thread.sleep(@as(u64, @intFromFloat(sleeptime * 1e9)));
        }
    }
}
