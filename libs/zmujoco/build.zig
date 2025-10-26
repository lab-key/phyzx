const std = @import("std");

pub fn build(b: *std.Build) !void {
    const optimize = b.standardOptimizeOption(.{});
    const target = b.standardTargetOptions(.{});

    const lib_zmujoco_dep = b.dependency("lib_zmujoco", .{
        .target = target,
        .optimize = optimize,
    });

    const lib_zmujoco_module = lib_zmujoco_dep.module("lib_zmujoco");

    const options = .{
        .use_single_precision = b.option(
            bool,
            "use_single_precision",
            "Use single precision (float) for mjtNum instead of double",
        ) orelse false,
    };

    const options_step = b.addOptions();
    inline for (std.meta.fields(@TypeOf(options))) |field| {
        options_step.addOption(field.type, field.name, @field(options, field.name));
    }
    const options_module = options_step.createModule();

    // Create the zmujoco wrapper module
    const zmujoco_module = b.createModule(.{
        .root_source_file = b.path("src/zmujoco.zig"),
        .target = target,
        .optimize = optimize,
        .imports = &.{
            .{ .name = "zmujoco_options", .module = options_module },
            .{ .name = "lib_zmujoco", .module = lib_zmujoco_module },
        },
    });

    // Export the zmujoco module so other packages can import it
    b.modules.put("zmujoco", zmujoco_module) catch @panic("failed to register zmujoco module");

    // Iterate through examples directory for easier testing
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
                .{ .name = "zmujoco", .module = zmujoco_module },
            },
        });

        const exe = b.addExecutable(.{
            .name = exe_name,
            .root_module = example_module,
        });

        b.installArtifact(exe);

        // Create a run step for each example
        const run_artifact = b.addRunArtifact(exe);
        const run_step_name = b.fmt("run-{s}", .{exe_name});
        const run_step = b.step(run_step_name, b.fmt("Run {s} example", .{exe_name}));
        run_step.dependOn(&run_artifact.step);
    }
}
