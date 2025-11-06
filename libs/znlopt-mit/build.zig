const std = @import("std");

pub fn build(b: *std.Build) !void {
    const optimize = b.standardOptimizeOption(.{});
    const target = b.standardTargetOptions(.{});

    const lib_nlopt_dep = b.dependency("lib_znlopt_mit", .{
        .target = target,
        .optimize = optimize,
    });

    const lib_nlopt_module = lib_nlopt_dep.module("lib_znlopt_mit");

    // Create the znlopt wrapper module
    const znlopt_mit_module = b.createModule(.{
        .root_source_file = b.path("src/znlopt.zig"),
        .target = target,
        .optimize = optimize,
        .imports = &.{
            .{ .name = "lib_nlopt", .module = lib_nlopt_module },
        },
    });

    // Export the znlopt module so other packages can import it
    b.modules.put("znlopt-mit", znlopt_mit_module) catch @panic("failed to register znlopt module");

    // --- Build an example executable --- 
    const example_exe = b.addExecutable(.{
        .name = "znlopt_example",
        .root_module = b.createModule(.{
            .root_source_file = b.path("src/example.zig"),
            .target = target,
            .optimize = optimize,
            .imports = &.{ 
                .{ .name = "znlopt-mit", .module = znlopt_mit_module },
            },
        }),
    });

    b.installArtifact(example_exe);

    const run_example_step = b.addRunArtifact(example_exe);
    const run_step = b.step("run", "Run the nlopt example");
    run_step.dependOn(&run_example_step.step);
}
