const std = @import("std");
const phyzx = @import("zmujoco");
const simulation = @import("phyzx-sim");
const mjtNum = phyzx.mjtNum;

pub const Rollout = struct {
    sim: *simulation.Simulation,
    qpos: []mjtNum,
    qvel: []mjtNum,
    sensordata: []mjtNum,
    steps: usize,
    nbatch: usize,

    pub const Error = error{
        ControlLengthMismatch,
        InitialStatesLengthMismatch,
    };

    pub fn init(allocator: std.mem.Allocator, sim: *simulation.Simulation, steps: usize, nbatch: usize) !*Rollout {
        const self = try allocator.create(Rollout);
        errdefer allocator.destroy(self);

        const nq: usize = @intCast(sim.model.nq());
        const nv: usize = @intCast(sim.model.nv());
        const nsensor: usize = @intCast(sim.model.ptr.nsensordata);

        const qpos = try allocator.alloc(mjtNum, nbatch * steps * nq);
        errdefer allocator.free(qpos);

        const qvel = try allocator.alloc(mjtNum, nbatch * steps * nv);
        errdefer allocator.free(qvel);

        const sensordata = try allocator.alloc(mjtNum, nbatch * steps * nsensor);

        self.* = .{
            .sim = sim,
            .qpos = qpos,
            .qvel = qvel,
            .sensordata = sensordata,
            .steps = steps,
            .nbatch = nbatch,
        };

        return self;
    }

    pub fn deinit(self: *Rollout, allocator: std.mem.Allocator) void {
        allocator.free(self.qpos);
        allocator.free(self.qvel);
        allocator.free(self.sensordata);
        allocator.destroy(self);
    }

    pub fn run(self: *Rollout, policy: ?*const fn (sim: *simulation.Simulation, allocator: std.mem.Allocator) anyerror![]const mjtNum) !void {
        const nq: usize = @intCast(self.sim.model.nq());
        const nv: usize = @intCast(self.sim.model.nv());
        const nsensor: usize = @intCast(self.sim.model.ptr.nsensordata);

        for (0..self.steps) |s| {
            if (policy) |p| {
                const ctrl = try p(self.sim, self.sim.allocator);
                defer self.sim.allocator.free(ctrl);
                @memcpy(self.sim.data.ptr.ctrl[0..self.sim.model.nu()], ctrl);
            }
            self.sim.step();
            const qp = self.sim.data.qpos(self.sim.model);
            const qv = self.sim.data.qvel(self.sim.model);
            const sd = self.sim.data.ptr.sensordata[0..nsensor];

            @memcpy(self.qpos[s * nq .. (s + 1) * nq], qp);
            @memcpy(self.qvel[s * nv .. (s + 1) * nv], qv);
            @memcpy(self.sensordata[s * nsensor .. (s + 1) * nsensor], sd);
        }
    }

    pub fn run_batch(self: *Rollout, initial_states: []const mjtNum, control: ?[]const mjtNum) !void {
        const nq: usize = @intCast(self.sim.model.nq());
        const nv: usize = @intCast(self.sim.model.nv());
        const nsensor: usize = @intCast(self.sim.model.ptr.nsensordata);
        const nu: usize = @intCast(self.sim.model.nu());
        const nbatch = self.nbatch;

        if (initial_states.len != nbatch * nq) {
            return error.InitialStatesLengthMismatch;
        }

        if (control) |ctrl_arr| {
            if (ctrl_arr.len != nbatch * self.steps * nu) {
                return error.ControlLengthMismatch;
            }
        }

        for (0..nbatch) |b| {
            // Set initial state
            const initial_qpos = initial_states[b * nq .. (b + 1) * nq];
            @memcpy(self.sim.data.qpos(self.sim.model), initial_qpos);
            self.sim.reset();

            for (0..self.steps) |s| {
                if (control) |ctrl_arr| {
                    const ctrl_offset = (b * self.steps + s) * nu;
                    @memcpy(self.sim.data.ptr.ctrl[0..nu], ctrl_arr[ctrl_offset .. ctrl_offset + nu]);
                }
                self.sim.step();
                const qp = self.sim.data.qpos(self.sim.model);
                const qv = self.sim.data.qvel(self.sim.model);
                const sd = self.sim.data.ptr.sensordata[0..nsensor];

                const offset = (b * self.steps + s);
                @memcpy(self.qpos[offset * nq .. (offset + 1) * nq], qp);
                @memcpy(self.qvel[offset * nv .. (offset + 1) * nv], qv);
                @memcpy(self.sensordata[offset * nsensor .. (offset + 1) * nsensor], sd);
            }
        }
    }

    pub fn exportToCSV(self: *Rollout, path: []const u8) !void {
        const file = try std.fs.cwd().createFile(path, .{});
        defer file.close();

        var buffered_writer = std.io.bufferedWriter(file.writer());
        const writer = buffered_writer.writer();

        const nq: usize = @intCast(self.sim.model.nq());
        const nv: usize = @intCast(self.sim.model.nv());
        const nsensor: usize = @intCast(self.sim.model.ptr.nsensordata);

        // Write header
        try writer.print("batch,step", .{});
        for (0..nq) |i| {
            try writer.print(",qpos_{d}", .{i});
        }
        for (0..nv) |i| {
            try writer.print(",qvel_{d}", .{i});
        }
        for (0..nsensor) |i| {
            try writer.print(",sensordata_{d}", .{i});
        }
        try writer.writeAll("\n");

        // Write data
        for (0..self.nbatch) |b| {
            for (0..self.steps) |s| {
                try writer.print("{d},{d}", .{ b, s });

                const offset = (b * self.steps + s);
                const qp_start = offset * nq;
                const qv_start = offset * nv;
                const sd_start = offset * nsensor;

                for (self.qpos[qp_start .. qp_start + nq]) |val| {
                    try writer.print(",{d}", .{val});
                }
                for (self.qvel[qv_start .. qv_start + nv]) |val| {
                    try writer.print(",{d}", .{val});
                }
                for (self.sensordata[sd_start .. sd_start + nsensor]) |val| {
                    try writer.print(",{d}", .{val});
                }
                try writer.writeAll("\n");
            }
        }

        try buffered_writer.flush();
    }
};
