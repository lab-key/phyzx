const std = @import("std");
const znlopt = @import("znlopt-mit");

pub const Optimizer = struct {
    allocator: std.mem.Allocator,
    opt: *znlopt.Opt,

    pub fn init(allocator: std.mem.Allocator, algorithm: znlopt.Algorithm, n: u32, comptime F: type, context: *F, objective_func: fn (ctx: *F, x: []const f64, grad: ?[]f64) f64) !*Optimizer {
        const self = try allocator.create(Optimizer);
        self.allocator = allocator;
        self.opt = try znlopt.Opt.init(allocator, algorithm, n);

        try self.opt.setMinObjective(F, context, objective_func);

        return self;
    }

    pub fn deinit(self: *Optimizer) void {
        self.opt.deinit();
        self.allocator.destroy(self);
    }

    pub fn optimize(self: *Optimizer, x: []f64) !znlopt.OptimizeResult {
        return self.opt.optimize(x);
    }
};

// Example usage:
const testing = std.testing;

fn objective(context: *void, x: []const f64, grad: ?[]f64) f64 {
    _ = context;
    _ = grad;
    const x1 = x[0];
    const x2 = x[1];
    return (x1 - 2.0) * (x1 - 2.0) + (x2 - 3.0) * (x2 - 3.0);
}

test "optimize example" {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();

    var optimizer = try Optimizer.init(allocator, .LN_NELDERMEAD, 2, void, &struct{}{}, objective);
    defer optimizer.deinit();

    var x = try allocator.alloc(f64, 2);
    defer allocator.free(x);
    x[0] = 0.0;
    x[1] = 0.0;

    const result = try optimizer.optimize(x);

    try testing.expect(std.math.approxEqAbs(result.value, 0.0, 1e-6));
    try testing.expect(std.math.approxEqAbs(result.x[0], 2.0, 1e-6));
    try testing.expect(std.math.approxEqAbs(result.x[1], 3.0, 1e-6));
}