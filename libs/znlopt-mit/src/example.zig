const std = @import("std");
const znlopt = @import("znlopt-mit");

const RosenbrockData = struct {
    a: f64,
    b: f64,
};

fn rosenbrock(data: *RosenbrockData, x: []const f64, grad: ?[]f64) f64 {
    const a = data.a;
    const b = data.b;
    const t1 = a - x[0];
    const t2 = x[1] - x[0] * x[0];
    if (grad) |g| {
        g[0] = -2.0 * t1 - 4.0 * b * t2 * x[0];
        g[1] = 2.0 * b * t2;
    }
    return t1 * t1 + b * t2 * t2;
}

pub fn main() !void {
    const allocator = std.heap.page_allocator;

    var opt = try znlopt.Opt.init(allocator, .LN_NELDERMEAD, 2);
    defer opt.deinit();

    var data = RosenbrockData{ .a = 1.0, .b = 100.0 };
    try opt.setMinObjective(RosenbrockData, &data, rosenbrock);

    var lb = [_]f64{ -1.5, -1.5 };
    try opt.setLowerBounds(&lb);

    var x = [_]f64{ 0.0, 0.0 };
    const result = try opt.optimize(&x);

    std.debug.print("found minimum at f({d}, {d}) = {d}\n", .{ x[0], x[1], result.value });
}
