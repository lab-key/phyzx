const std = @import("std");

pub fn build(b: *std.Build) !void {
    const optimize = b.standardOptimizeOption(.{});
    const target = b.standardTargetOptions(.{});

    const zmujoco_dep = b.dependency("zmujoco", .{
        .target = target,
        .optimize = optimize,
    });
    const zmujoco_module = zmujoco_dep.module("zmujoco");

    const znlopt_mit_dep = b.dependency("znlopt_mit", .{
        .target = target,
        .optimize = optimize,
    });
    const znlopt_mit_module = znlopt_mit_dep.module("znlopt-mit");

    // --- All other modules (no library artifacts) ---
    const phyzx_simulation_module = b.createModule(.{
        .root_source_file = b.path("src/viewer/simulation.zig"),
        .target = target,
        .optimize = optimize,
        .imports = &.{
            .{ .name = "zmujoco", .module = zmujoco_module },
        },
    });

    const phyzx_renderer_module = b.createModule(.{
        .root_source_file = b.path("src/viewer/renderer.zig"),
        .target = target,
        .optimize = optimize,
        .imports = &.{
            .{ .name = "zmujoco", .module = zmujoco_module },
            .{ .name = "phyzx-sim", .module = phyzx_simulation_module },
        },
    });

    const phyzx_viewer_ui_module = b.createModule(.{
        .root_source_file = b.path("src/viewer/viewer_ui.zig"),
        .target = target,
        .optimize = optimize,
        .imports = &.{
            .{ .name = "zmujoco", .module = zmujoco_module },
        },
    });

    const phyzx_viewer_module = b.createModule(.{
        .root_source_file = b.path("src/viewer/viewer.zig"),
        .target = target,
        .optimize = optimize,
        .imports = &.{
            .{ .name = "zmujoco", .module = zmujoco_module },
            .{ .name = "phyzx-sim", .module = phyzx_simulation_module },
            .{ .name = "phyzx-render", .module = phyzx_renderer_module },
            .{ .name = "phyzx-viewui", .module = phyzx_viewer_ui_module },
        },
    });

    const phyzx_rollout_module = b.createModule(.{
        .root_source_file = b.path("src/control/rollout.zig"),
        .target = target,
        .optimize = optimize,
        .imports = &.{
            .{ .name = "zmujoco", .module = zmujoco_module },
            .{ .name = "phyzx-sim", .module = phyzx_simulation_module },
        },
    });

    const phyzx_optimizer_module = b.createModule(.{
        .root_source_file = b.path("src/phyzx-znlopt/optimizer.zig"),
        .target = target,
        .optimize = optimize,
        .imports = &.{
            .{ .name = "znlopt-mit", .module = znlopt_mit_module },
        },
    });

    const phyzx_module = b.createModule(.{
        .root_source_file = b.path("src/phyzx.zig"),
        .target = target,
        .optimize = optimize,
        .imports = &.{
            .{ .name = "zmujoco", .module = zmujoco_module },
            .{ .name = "phyzx-sim", .module = phyzx_simulation_module },
            .{ .name = "phyzx-render", .module = phyzx_renderer_module },
            .{ .name = "phyzx-viewer", .module = phyzx_viewer_module },
            .{ .name = "phyzx-rollout", .module = phyzx_rollout_module },
            .{ .name = "phyzx-optimizer", .module = phyzx_optimizer_module },
        },
    });

    // --- Examples ---
    const examples_dir_path = "examples";
    var examples_dir = std.fs.cwd().openDir(examples_dir_path, .{ .iterate = true }) catch |err| {
        if (err == error.FileNotFound) return;
        return err;
    };
    defer examples_dir.close();

    var dir_iter = examples_dir.iterate();
    while (try dir_iter.next()) |entry| {
        if (entry.kind != std.fs.Dir.Entry.Kind.file or !std.mem.endsWith(u8, entry.name, ".zig")) {
            continue;
        }

        const exe_name = std.fs.path.stem(entry.name);
        const root_source_path = b.path(b.fmt("examples/{s}", .{entry.name}));

        const example_module = b.createModule(.{
            .root_source_file = root_source_path,
            .target = target,
            .optimize = optimize,
            .imports = &.{
                .{ .name = "phyzx", .module = phyzx_module },
            },
        });

        const exe = b.addExecutable(.{
            .name = exe_name,
            .root_module = example_module,
        });

        b.installArtifact(exe);

        const run_exe_step = b.addRunArtifact(exe);
        const run_step_name = b.fmt("run-{s}", .{exe_name});
        const run_step_desc = b.fmt("Run the {s} example", .{exe_name});
        const run_step = b.step(run_step_name, run_step_desc);
        run_step.dependOn(&run_exe_step.step);
    }
}
