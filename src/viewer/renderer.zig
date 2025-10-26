const std = @import("std");
const phyzx = @import("zmujoco");
const c = phyzx.c;
const mjtNum = phyzx.mjtNum;
const simulation = @import("phyzx-sim");

extern "c" fn lodepng_encode_memory(
    out: *?*u8,
    outsize: *usize,
    image: [*c]const u8,
    w: c_uint,
    h: c_uint,
    colortype: c_int,
    bitdepth: c_uint
) c_uint;

pub const Renderer = struct {
    sim: *simulation.Simulation,
    scene: c.mjvScene,
    context: c.mjrContext,
    width: i32,
    height: i32,
    camera: c.mjvCamera,
    vopt: c.mjvOption,
    pert: c.mjvPerturb,

    pub fn init(allocator: std.mem.Allocator, sim: *simulation.Simulation, height: i32, width: i32) !*Renderer {
        sim.model.ptr.vis.global.offwidth = width;
        sim.model.ptr.vis.global.offheight = height;
        
        var self = try allocator.create(Renderer);
        self.* = .{
            .sim = sim,
            .scene = .{},
            .context = .{},
            .width = width,
            .height = height,
            .camera = .{},
            .vopt = .{},
            .pert = .{},
        };

        // Initialize in the correct order
        c.mjv_defaultCamera(&self.camera);
        self.camera.distance = 3.0;
        
        c.mjv_defaultOption(&self.vopt);
        c.mjv_defaultPerturb(&self.pert);
        
        // Create scene and context
        c.mjv_defaultScene(&self.scene);
        c.mjr_defaultContext(&self.context);
        
        // Make scene with the model (this allocates geometry buffers)
        c.mjv_makeScene(sim.model.ptr, &self.scene, 10000);
        
        // Make rendering context
        c.mjr_makeContext(sim.model.ptr, &self.context, c.mjFONTSCALE_150);
        
        // Set to offscreen rendering
        c.mjr_setBuffer(c.mjFB_OFFSCREEN, &self.context);
        
        // Initial scene update to populate geometry
        c.mjv_updateScene(sim.model.ptr, sim.data.ptr, &self.vopt, &self.pert, &self.camera, c.mjCAT_ALL, &self.scene);
        
        return self;
    }

    pub fn deinit(self: *Renderer, allocator: std.mem.Allocator) void {
        c.mjv_freeScene(&self.scene);
        c.mjr_freeContext(&self.context);
        allocator.destroy(self);
    }

    pub fn getCamera(self: *Renderer) *c.mjvCamera {
        return &self.camera;
    }

    pub fn setCamera(self: *Renderer, camera: *const c.mjvCamera) void {
        self.camera = camera.*;
    }

    pub fn moveCamera(self: *Renderer, action: c_int, reldx: mjtNum, reldy: mjtNum) void {
        c.mjv_moveCamera(self.sim.model.ptr, action, reldx, reldy, &self.scene, &self.camera);
    }

    pub fn applyPerturb(self: *Renderer) void {
        c.mjv_applyPerturbPose(self.sim.model.ptr, self.sim.data.ptr, &self.pert, 1);
        c.mjv_applyPerturbForce(self.sim.model.ptr, self.sim.data.ptr, &self.pert);
    }

    pub fn updateScene(self: *Renderer) void {
        c.mjv_updateScene(self.sim.model.ptr, self.sim.data.ptr, &self.vopt, &self.pert, &self.camera, c.mjCAT_ALL, &self.scene);
    }

    pub fn render(self: *Renderer, allocator: std.mem.Allocator) ![]u8 {
        const viewport = c.mjrRect{
            .left = 0,
            .bottom = 0,
            .width = self.width,
            .height = self.height,
        };
        c.mjr_render(viewport, &self.scene, &self.context);
        const image_size = @as(usize, @intCast(self.width * self.height * 3));
        var image = try allocator.alloc(u8, image_size);
        
        c.mjr_readPixels(image.ptr, null, viewport, &self.context);
        
        // Flip image vertically
        const row_size = @as(usize, @intCast(self.width * 3));
        const temp_row = try allocator.alloc(u8, row_size);
        defer allocator.free(temp_row);
        var i: usize = 0;
        while (i < @divTrunc(self.height, 2)) : (i += 1) {
            const top_row_start = i * row_size;
            const height_as_usize: usize = @intCast(self.height);
            const bottom_row_start = (height_as_usize - 1 - i) * row_size;
            for (temp_row, image[top_row_start..top_row_start+row_size]) |*d, s| d.* = s;
            for (image[top_row_start..top_row_start+row_size], image[bottom_row_start..bottom_row_start+row_size]) |*d, s| d.* = s;
            for (image[bottom_row_start..bottom_row_start+row_size], temp_row) |*d, s| d.* = s;
        }
        return image;
    }

    pub fn saveImage(self: *Renderer, allocator: std.mem.Allocator, path: []const u8) !void {
        const image_buffer = try self.render(allocator);
        defer allocator.free(image_buffer);

        var png_buffer: ?*u8 = null;
        var png_size: usize = 0;

        // LCT_RGB = 2
        const err = lodepng_encode_memory(&png_buffer, &png_size, image_buffer.ptr, @intCast(self.width), @intCast(self.height), 2, 8);

        if (err != 0) {
            return error.PngEncodingFailed;
        }
        defer std.heap.c_allocator.free(png_buffer.?[0..png_size]);

        const file = try std.fs.cwd().createFile(path, .{});
        defer file.close();

        try file.writer().writeAll(png_buffer.?[0..png_size]);
    }
};
