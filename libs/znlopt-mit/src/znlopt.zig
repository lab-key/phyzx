const std = @import("std");
const lib_nlopt = @import("lib_nlopt");
pub const c = lib_nlopt.nlopt;

pub const Error = error{
    Failure,
    InvalidArgs,
    OutOfMemory,
    RoundoffLimited,
    ForcedStop,
};

pub const Algorithm = enum {
    GN_DIRECT,
    GN_DIRECT_L,
    GN_DIRECT_L_RAND,
    GN_DIRECT_NOSCAL,
    GN_DIRECT_L_NOSCAL,
    GN_DIRECT_L_RAND_NOSCAL,
    GN_ORIG_DIRECT,
    GN_ORIG_DIRECT_L,
    GD_STOGO,
    GD_STOGO_RAND,
    LD_LBFGS_NOCEDAL,
    LD_LBFGS,
    LN_PRAXIS,
    LD_VAR1,
    LD_VAR2,
    LD_TNEWTON,
    LD_TNEWTON_RESTART,
    LD_TNEWTON_PRECOND,
    LD_TNEWTON_PRECOND_RESTART,
    GN_CRS2_LM,
    GN_MLSL,
    GD_MLSL,
    GN_MLSL_LDS,
    GD_MLSL_LDS,
    LD_MMA,
    LN_COBYLA,
    LN_NEWUOA,
    LN_NEWUOA_BOUND,
    LN_NELDERMEAD,
    LN_SBPLX,
    LN_AUGLAG,
    LD_AUGLAG,
    LN_AUGLAG_EQ,
    LD_AUGLAG_EQ,
    LN_BOBYQA,
    GN_ISRES,
    AUGLAG,
    AUGLAG_EQ,
    G_MLSL,
    G_MLSL_LDS,
    LD_SLSQP,
    LD_CCSAQ,
    GN_ESCH,
    GN_AGS,

    pub fn toC(self: Algorithm) c.nlopt_algorithm {
        return switch (self) {
            .GN_DIRECT => c.NLOPT_GN_DIRECT,
            .GN_DIRECT_L => c.NLOPT_GN_DIRECT_L,
            .GN_DIRECT_L_RAND => c.NLOPT_GN_DIRECT_L_RAND,
            .GN_DIRECT_NOSCAL => c.NLOPT_GN_DIRECT_NOSCAL,
            .GN_DIRECT_L_NOSCAL => c.NLOPT_GN_DIRECT_L_NOSCAL,
            .GN_DIRECT_L_RAND_NOSCAL => c.NLOPT_GN_DIRECT_L_RAND_NOSCAL,
            .GN_ORIG_DIRECT => c.NLOPT_GN_ORIG_DIRECT,
            .GN_ORIG_DIRECT_L => c.NLOPT_GN_ORIG_DIRECT_L,
            .GD_STOGO => c.NLOPT_GD_STOGO,
            .GD_STOGO_RAND => c.NLOPT_GD_STOGO_RAND,
            .LD_LBFGS_NOCEDAL => c.NLOPT_LD_LBFGS_NOCEDAL,
            .LD_LBFGS => c.NLOPT_LD_LBFGS,
            .LN_PRAXIS => c.NLOPT_LN_PRAXIS,
            .LD_VAR1 => c.NLOPT_LD_VAR1,
            .LD_VAR2 => c.NLOPT_LD_VAR2,
            .LD_TNEWTON => c.NLOPT_LD_TNEWTON,
            .LD_TNEWTON_RESTART => c.NLOPT_LD_TNEWTON_RESTART,
            .LD_TNEWTON_PRECOND => c.NLOPT_LD_TNEWTON_PRECOND,
            .LD_TNEWTON_PRECOND_RESTART => c.NLOPT_LD_TNEWTON_PRECOND_RESTART,
            .GN_CRS2_LM => c.NLOPT_GN_CRS2_LM,
            .GN_MLSL => c.NLOPT_GN_MLSL,
            .GD_MLSL => c.NLOPT_GD_MLSL,
            .GN_MLSL_LDS => c.NLOPT_GN_MLSL_LDS,
            .GD_MLSL_LDS => c.NLOPT_GD_MLSL_LDS,
            .LD_MMA => c.NLOPT_LD_MMA,
            .LN_COBYLA => c.NLOPT_LN_COBYLA,
            .LN_NEWUOA => c.NLOPT_LN_NEWUOA,
            .LN_NEWUOA_BOUND => c.NLOPT_LN_NEWUOA_BOUND,
            .LN_NELDERMEAD => c.NLOPT_LN_NELDERMEAD,
            .LN_SBPLX => c.NLOPT_LN_SBPLX,
            .LN_AUGLAG => c.NLOPT_LN_AUGLAG,
            .LD_AUGLAG => c.NLOPT_LD_AUGLAG,
            .LN_AUGLAG_EQ => c.NLOPT_LN_AUGLAG_EQ,
            .LD_AUGLAG_EQ => c.NLOPT_LD_AUGLAG_EQ,
            .LN_BOBYQA => c.NLOPT_LN_BOBYQA,
            .GN_ISRES => c.NLOPT_GN_ISRES,
            .AUGLAG => c.NLOPT_AUGLAG,
            .AUGLAG_EQ => c.NLOPT_AUGLAG_EQ,
            .G_MLSL => c.NLOPT_G_MLSL,
            .G_MLSL_LDS => c.NLOPT_G_MLSL_LDS,
            .LD_SLSQP => c.NLOPT_LD_SLSQP,
            .LD_CCSAQ => c.NLOPT_LD_CCSAQ,
            .GN_ESCH => c.NLOPT_GN_ESCH,
            .GN_AGS => c.NLOPT_GN_AGS,
        };
    }
};

pub const Result = enum {
    Failure,
    InvalidArgs,
    OutOfMemory,
    RoundoffLimited,
    ForcedStop,
    Success,
    StopvalReached,
    FtolReached,
    XtolReached,
    MaxevalReached,
    MaxtimeReached,

    pub fn fromC(c_result: c.nlopt_result) Result {
        return switch (c_result) {
            c.NLOPT_FAILURE => .Failure,
            c.NLOPT_INVALID_ARGS => .InvalidArgs,
            c.NLOPT_OUT_OF_MEMORY => .OutOfMemory,
            c.NLOPT_ROUNDOFF_LIMITED => .RoundoffLimited,
            c.NLOPT_FORCED_STOP => .ForcedStop,
            c.NLOPT_SUCCESS => .Success,
            c.NLOPT_STOPVAL_REACHED => .StopvalReached,
            c.NLOPT_FTOL_REACHED => .FtolReached,
            c.NLOPT_XTOL_REACHED => .XtolReached,
            c.NLOPT_MAXEVAL_REACHED => .MaxevalReached,
            c.NLOPT_MAXTIME_REACHED => .MaxtimeReached,
            else => unreachable,
        };
    }

    pub fn toError(self: Result) Error {
        return switch (self) {
            .Failure => error.Failure,
            .InvalidArgs => error.InvalidArgs,
            .OutOfMemory => error.OutOfMemory,
            .RoundoffLimited => error.RoundoffLimited,
            .ForcedStop => error.ForcedStop,
            else => unreachable,
        };
    }
    
    pub fn isSuccess(self: Result) bool {
        return switch (self) {
            .Success, .StopvalReached, .FtolReached, .XtolReached, .MaxevalReached, .MaxtimeReached => true,
            else => false,
        };
    }
};

pub const OptimizeResult = struct {
    x: []f64,
    value: f64,
    result: Result,
};

pub const Opt = struct {
    ctx: c.nlopt_opt,
    allocator: std.mem.Allocator,
    n: u32,

    pub fn init(allocator: std.mem.Allocator, algorithm: Algorithm, n: u32) !*Opt {
        const opt = try allocator.create(Opt);
        opt.ctx = c.nlopt_create(algorithm.toC(), n) orelse {
            allocator.destroy(opt);
            return error.OutOfMemory;
        };
        opt.allocator = allocator;
        opt.n = n;
        return opt;
    }

    pub fn deinit(self: *Opt) void {
        c.nlopt_destroy(self.ctx);
        self.allocator.destroy(self);
    }

    // Objective functions
    pub fn setMinObjective(self: *Opt, comptime F: type, context: *F, func: fn(ctx: *F, x: []const f64, grad: ?[]f64) f64) !void {
        const trampoline = struct {
            fn c_callback(n: c_uint, x: [*c]const f64, grad: [*c]f64, data: ?*anyopaque) callconv(.c) f64 {
                const x_slice = x[0..n];
                var grad_slice: ?[]f64 = null;
                if (grad != null) {
                    grad_slice = grad[0..n];
                }
                const typed_context: *F = @ptrCast(@alignCast(data.?));
                return func(typed_context, x_slice, grad_slice);
            }
        }.c_callback;

        if (c.nlopt_set_min_objective(self.ctx, trampoline, context) != 0) {
            return error.SetMinObjectiveFailed;
        }
    }

    pub fn setMaxObjective(self: *Opt, comptime F: type, context: *F, 
        func: fn (ctx: *F, x: []const f64, grad: ?[]f64) f64) !void {
        const Trampoline = struct {
            fn callback(n: c_uint, x: [*c]const f64, grad: [*c]f64, data: ?*anyopaque) callconv(.c) f64 {
                const x_slice = x[0..n];
                const grad_slice: ?[]f64 = if (grad) |g| g[0..n] else null;
                const typed_context: *F = @ptrCast(@alignCast(data.?));
                return func(typed_context, x_slice, grad_slice);
            }
        };
        
        const res = Result.fromC(c.nlopt_set_max_objective(self.ctx, Trampoline.callback, context));
        if (res != .Success) return res.toError();
    }

    // Bounds
    pub fn setLowerBounds(self: *Opt, lb: []const f64) !void {
        std.debug.assert(lb.len == self.n);
        const res = Result.fromC(c.nlopt_set_lower_bounds(self.ctx, lb.ptr));
        if (res != .Success) return res.toError();
    }

    pub fn setUpperBounds(self: *Opt, ub: []const f64) !void {
        std.debug.assert(ub.len == self.n);
        const res = Result.fromC(c.nlopt_set_upper_bounds(self.ctx, ub.ptr));
        if (res != .Success) return res.toError();
    }

    pub fn setLowerBounds1(self: *Opt, lb: f64) !void {
        const res = Result.fromC(c.nlopt_set_lower_bounds1(self.ctx, lb));
        if (res != .Success) return res.toError();
    }

    pub fn setUpperBounds1(self: *Opt, ub: f64) !void {
        const res = Result.fromC(c.nlopt_set_upper_bounds1(self.ctx, ub));
        if (res != .Success) return res.toError();
    }

    pub fn getLowerBounds(self: *Opt, lb: []f64) !void {
        std.debug.assert(lb.len == self.n);
        const res = Result.fromC(c.nlopt_get_lower_bounds(self.ctx, lb.ptr));
        if (res != .Success) return res.toError();
    }

    pub fn getUpperBounds(self: *Opt, ub: []f64) !void {
        std.debug.assert(ub.len == self.n);
        const res = Result.fromC(c.nlopt_get_upper_bounds(self.ctx, ub.ptr));
        if (res != .Success) return res.toError();
    }

    // Constraints
    pub fn removeInequalityConstraints(self: *Opt) !void {
        const res = Result.fromC(c.nlopt_remove_inequality_constraints(self.ctx));
        if (res != .Success) return res.toError();
    }

    pub fn addInequalityConstraint(self: *Opt, comptime F: type, context: *F,
        func: fn (ctx: *F, x: []const f64, grad: ?[]f64) f64, tol: f64) !void {
        const Trampoline = struct {
            fn callback(n: c_uint, x: [*c]const f64, grad: [*c]f64, data: ?*anyopaque) callconv(.c) f64 {
                const x_slice = x[0..n];
                const grad_slice: ?[]f64 = if (grad) |g| g[0..n] else null;
                const typed_context: *F = @ptrCast(@alignCast(data.?));
                return func(typed_context, x_slice, grad_slice);
            }
        };
        
        const res = Result.fromC(c.nlopt_add_inequality_constraint(self.ctx, Trampoline.callback, context, tol));
        if (res != .Success) return res.toError();
    }

    pub fn removeEqualityConstraints(self: *Opt) !void {
        const res = Result.fromC(c.nlopt_remove_equality_constraints(self.ctx));
        if (res != .Success) return res.toError();
    }

    pub fn addEqualityConstraint(self: *Opt, comptime F: type, context: *F,
        func: fn (ctx: *F, x: []const f64, grad: ?[]f64) f64, tol: f64) !void {
        const Trampoline = struct {
            fn callback(n: c_uint, x: [*c]const f64, grad: [*c]f64, data: ?*anyopaque) callconv(.c) f64 {
                const x_slice = x[0..n];
                const grad_slice: ?[]f64 = if (grad) |g| g[0..n] else null;
                const typed_context: *F = @ptrCast(@alignCast(data.?));
                return func(typed_context, x_slice, grad_slice);
            }
        };
        
        const res = Result.fromC(c.nlopt_add_equality_constraint(self.ctx, Trampoline.callback, context, tol));
        if (res != .Success) return res.toError();
    }

    // Stopping criteria
    pub fn setStopval(self: *Opt, stopval: f64) !void {
        const res = Result.fromC(c.nlopt_set_stopval(self.ctx, stopval));
        if (res != .Success) return res.toError();
    }

    pub fn getStopval(self: *Opt) f64 {
        return c.nlopt_get_stopval(self.ctx);
    }

    pub fn setFtolRel(self: *Opt, tol: f64) !void {
        const res = Result.fromC(c.nlopt_set_ftol_rel(self.ctx, tol));
        if (res != .Success) return res.toError();
    }

    pub fn getFtolRel(self: *Opt) f64 {
        return c.nlopt_get_ftol_rel(self.ctx);
    }

    pub fn setFtolAbs(self: *Opt, tol: f64) !void {
        const res = Result.fromC(c.nlopt_set_ftol_abs(self.ctx, tol));
        if (res != .Success) return res.toError();
    }

    pub fn getFtolAbs(self: *Opt) f64 {
        return c.nlopt_get_ftol_abs(self.ctx);
    }

    pub fn setXtolRel(self: *Opt, tol: f64) !void {
        const res = Result.fromC(c.nlopt_set_xtol_rel(self.ctx, tol));
        if (res != .Success) return res.toError();
    }

    pub fn getXtolRel(self: *Opt) f64 {
        return c.nlopt_get_xtol_rel(self.ctx);
    }

    pub fn setXtolAbs(self: *Opt, tol: []const f64) !void {
        std.debug.assert(tol.len == self.n);
        const res = Result.fromC(c.nlopt_set_xtol_abs(self.ctx, tol.ptr));
        if (res != .Success) return res.toError();
    }

    pub fn setXtolAbs1(self: *Opt, tol: f64) !void {
        const res = Result.fromC(c.nlopt_set_xtol_abs1(self.ctx, tol));
        if (res != .Success) return res.toError();
    }

    pub fn getXtolAbs(self: *Opt, tol: []f64) !void {
        std.debug.assert(tol.len == self.n);
        const res = Result.fromC(c.nlopt_get_xtol_abs(self.ctx, tol.ptr));
        if (res != .Success) return res.toError();
    }

    pub fn setMaxeval(self: *Opt, maxeval: c_int) !void {
        const res = Result.fromC(c.nlopt_set_maxeval(self.ctx, maxeval));
        if (res != .Success) return res.toError();
    }

    pub fn getMaxeval(self: *Opt) c_int {
        return c.nlopt_get_maxeval(self.ctx);
    }

    pub fn getNumevals(self: *Opt) c_int {
        return c.nlopt_get_numevals(self.ctx);
    }

    pub fn setMaxtime(self: *Opt, maxtime: f64) !void {
        const res = Result.fromC(c.nlopt_set_maxtime(self.ctx, maxtime));
        if (res != .Success) return res.toError();
    }

    pub fn getMaxtime(self: *Opt) f64 {
        return c.nlopt_get_maxtime(self.ctx);
    }

    pub fn forceStop(self: *Opt) !void {
        const res = Result.fromC(c.nlopt_force_stop(self.ctx));
        if (res != .Success) return res.toError();
    }

    pub fn setForceStop(self: *Opt, val: c_int) !void {
        const res = Result.fromC(c.nlopt_set_force_stop(self.ctx, val));
        if (res != .Success) return res.toError();
    }

    pub fn getForceStop(self: *Opt) c_int {
        return c.nlopt_get_force_stop(self.ctx);
    }

    // Algorithm-specific parameters
    pub fn setLocalOptimizer(self: *Opt, local_opt: *const Opt) !void {
        const res = Result.fromC(c.nlopt_set_local_optimizer(self.ctx, local_opt.ctx));
        if (res != .Success) return res.toError();
    }

    pub fn setPopulation(self: *Opt, pop: c_uint) !void {
        const res = Result.fromC(c.nlopt_set_population(self.ctx, pop));
        if (res != .Success) return res.toError();
    }

    pub fn getPopulation(self: *Opt) c_uint {
        return c.nlopt_get_population(self.ctx);
    }

    pub fn setVectorStorage(self: *Opt, dim: c_uint) !void {
        const res = Result.fromC(c.nlopt_set_vector_storage(self.ctx, dim));
        if (res != .Success) return res.toError();
    }

    pub fn getVectorStorage(self: *Opt) c_uint {
        return c.nlopt_get_vector_storage(self.ctx);
    }

    pub fn setInitialStep(self: *Opt, dx: []const f64) !void {
        std.debug.assert(dx.len == self.n);
        const res = Result.fromC(c.nlopt_set_initial_step(self.ctx, dx.ptr));
        if (res != .Success) return res.toError();
    }

    pub fn setInitialStep1(self: *Opt, dx: f64) !void {
        const res = Result.fromC(c.nlopt_set_initial_step1(self.ctx, dx));
        if (res != .Success) return res.toError();
    }

    pub fn getInitialStep(self: *Opt, x: []const f64, dx: []f64) !void {
        std.debug.assert(x.len == self.n);
        std.debug.assert(dx.len == self.n);
        const res = Result.fromC(c.nlopt_get_initial_step(self.ctx, x.ptr, dx.ptr));
        if (res != .Success) return res.toError();
    }

    // Query functions
    pub fn getAlgorithm(self: *Opt) c.nlopt_algorithm {
        return c.nlopt_get_algorithm(self.ctx);
    }

    pub fn getDimension(self: *Opt) c_uint {
        return c.nlopt_get_dimension(self.ctx);
    }

    pub fn getErrmsg(self: *Opt) ?[*:0]const u8 {
        return c.nlopt_get_errmsg(self.ctx);
    }

    // Main optimization function
    pub fn optimize(self: *Opt, x: []f64) !OptimizeResult {
        std.debug.assert(x.len == self.n);
        var opt_f: f64 = undefined;
        const res = Result.fromC(c.nlopt_optimize(self.ctx, x.ptr, &opt_f));
        
        if (!res.isSuccess()) {
            return res.toError();
        }
        
        return OptimizeResult{
            .x = x,
            .value = opt_f,
            .result = res,
        };
    }
};

// Utility functions
pub fn algorithmName(a: Algorithm) [*:0]const u8 {
    return c.nlopt_algorithm_name(a.toC());
}

pub fn version() struct { major: c_int, minor: c_int, bugfix: c_int } {
    var major: c_int = undefined;
    var minor: c_int = undefined;
    var bugfix: c_int = undefined;
    c.nlopt_version(&major, &minor, &bugfix);
    return .{ .major = major, .minor = minor, .bugfix = bugfix };
}

pub fn srand(seed: c_ulong) void {
    c.nlopt_srand(seed);
}

pub fn srandTime() void {
    c.nlopt_srand_time();
}
