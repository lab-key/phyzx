const std = @import("std");
pub const phyzx = @import("zmujoco");
pub const glfw = phyzx.glfw;
pub const c = phyzx.c;

pub const ObjType = c.mjtObj;
const sim = @import("phyzx-sim");
const renderer = @import("phyzx-render");
const viewer = @import("phyzx-viewer");
const rollout = @import("phyzx-rollout");
const math = @import("phyzx-math");
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

pub fn launch_viewer(allocator: std.mem.Allocator, model: *Model) !void {
    const sim_instance = try Simulation.init_from_model_and_data(allocator, model, try Data.init(allocator, model));
    defer sim_instance.deinit();

    const viewer_instance = try Viewer.init(allocator, sim_instance);
    defer viewer_instance.deinit(allocator);

    while (!viewer_instance.windowShouldClose()) {
        if (!viewer_instance.paused) {
            // advance simulation
            sim_instance.step();
        }

        viewer_instance.renderFrame();
    }
}

