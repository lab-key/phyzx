const std = @import("std");
const phyzx = @import("zmujoco");
const c = phyzx.c;
const mjtNum = phyzx.mjtNum;

pub const Vfs = struct {
    ptr: *c.mjVFS,
    allocator: std.mem.Allocator,

    pub fn init(allocator: std.mem.Allocator) !*Vfs {
        const vfs_ptr = try allocator.create(c.mjVFS);
        c.mj_defaultVFS(vfs_ptr);
        const self = try allocator.create(Vfs);
        self.* = .{ .ptr = vfs_ptr, .allocator = allocator };
        return self;
    }

    pub fn deinit(self: *Vfs) void {
        c.mj_deleteVFS(self.ptr);
        self.allocator.destroy(self);
    }

    pub fn addFile(self: *Vfs, path: []const u8, filename: []const u8) !void {
        const file = try std.fs.cwd().openFile(path, .{});
        defer file.close();

        const file_size = try file.getEndPos();
        const buffer = try self.allocator.alloc(u8, file_size);
        errdefer self.allocator.free(buffer);

        _ = try file.read(buffer);

        const res = c.mj_addBufferVFS(self.ptr, filename.ptr, buffer.ptr, @intCast(file_size));
        if (res != 0) return error.VfsAddFileFailed;
    }
};

pub const PhyzxError = error{
    ModelLoadFailed,
    DataCreationFailed,
    SpecLoadFailed,
    SpecCompileFailed,
    ElementNotFound,
    InvalidName,
    OperationFailed,
    XmlSerializationFailed,
    NoXmlFileInZip,
    VfsAddFileFailed,
};

pub const MjsLight = struct {
    ptr: *c.mjsLight,

    pub fn asElement(self: MjsLight) MjsElement {
        return MjsElement{ .ptr = self.ptr.element };
    }

    pub fn getPos(self: MjsLight) [3]mjtNum {
        return self.ptr.pos;
    }

    pub fn setPos(self: MjsLight, pos: [3]mjtNum) void {
        self.ptr.pos = pos;
    }

    pub fn getDir(self: MjsLight) [3]mjtNum {
        return self.ptr.dir;
    }

    pub fn setDir(self: MjsLight, dir: [3]mjtNum) void {
        self.ptr.dir = dir;
    }

    pub fn getDirectional(self: MjsLight) u8 {
        return self.ptr.directional;
    }

    pub fn setDirectional(self: MjsLight, directional: u8) void {
        self.ptr.directional = directional;
    }

    pub fn getCastshadow(self: MjsLight) u8 {
        return self.ptr.castshadow;
    }

    pub fn setCastshadow(self: MjsLight, castshadow: u8) void {
        self.ptr.castshadow = castshadow;
    }

    pub fn getActive(self: MjsLight) u8 {
        return self.ptr.active;
    }

    pub fn setActive(self: MjsLight, active: u8) void {
        self.ptr.active = active;
    }

    pub fn getAmbient(self: MjsLight) [3]f32 {
        return self.ptr.ambient;
    }

    pub fn setAmbient(self: MjsLight, ambient: [3]f32) void {
        self.ptr.ambient = ambient;
    }

    pub fn getDiffuse(self: MjsLight) [3]f32 {
        return self.ptr.diffuse;
    }

    pub fn setDiffuse(self: MjsLight, diffuse: [3]f32) void {
        self.ptr.diffuse = diffuse;
    }

    pub fn getSpecular(self: MjsLight) [3]f32 {
        return self.ptr.specular;
    }

    pub fn setSpecular(self: MjsLight, specular: [3]f32) void {
        self.ptr.specular = specular;
    }
};

pub const MjsFrame = struct {
    ptr: *c.mjsFrame,

    pub fn asElement(self: MjsFrame) MjsElement {
        return MjsElement{ .ptr = self.ptr.element };
    }

    pub fn getPos(self: MjsFrame) [3]mjtNum {
        return self.ptr.pos;
    }

    pub fn setPos(self: MjsFrame, pos: [3]mjtNum) void {
        self.ptr.pos = pos;
    }

    pub fn getQuat(self: MjsFrame) [4]mjtNum {
        return self.ptr.quat;
    }

    pub fn setQuat(self: MjsFrame, quat: [4]mjtNum) void {
        self.ptr.quat = quat;
    }

    pub fn getEuler(self: MjsFrame) [3]mjtNum {
        return self.ptr.euler;
    }

    pub fn setEuler(self: MjsFrame, euler: [3]mjtNum) void {
        self.ptr.euler = euler;
    }

    pub fn attachBody(self: MjsFrame, body: MjsBody, prefix: [*:0]const u8, suffix: [*:0]const u8) ?MjsBody {
        const attached_body_ptr = c.mjs_attach(self.ptr.element, body.ptr.element, prefix, suffix);
        if (attached_body_ptr == null) return null;
        return MjsBody{ .ptr = @ptrCast(attached_body_ptr) };
    }
};

pub const MjsCompiler = struct {
    ptr: *c.mjsCompiler,
};

pub const MjsOption = struct {
    ptr: *c.mjsOption,

    pub fn getTimestep(self: MjsOption) mjtNum {
        return self.ptr.timestep;
    }

    pub fn setTimestep(self: MjsOption, timestep: mjtNum) void {
        self.ptr.timestep = timestep;
    }

    pub fn getGravity(self: MjsOption) [3]mjtNum {
        return self.ptr.gravity;
    }

    pub fn setGravity(self: MjsOption, gravity: [3]mjtNum) void {
        self.ptr.gravity = gravity;
    }

    pub fn getWind(self: MjsOption) [3]mjtNum {
        return self.ptr.wind;
    }

    pub fn setWind(self: MjsOption, wind: [3]mjtNum) void {
        self.ptr.wind = wind;
    }

    pub fn getDensity(self: MjsOption) mjtNum {
        return self.ptr.density;
    }

    pub fn setDensity(self: MjsOption, density: mjtNum) void {
        self.ptr.density = density;
    }

    pub fn getViscosity(self: MjsOption) mjtNum {
        return self.ptr.viscosity;
    }

    pub fn setViscosity(self: MjsOption, viscosity: mjtNum) void {
        self.ptr.viscosity = viscosity;
    }

    pub fn getMargin(self: MjsOption) mjtNum {
        return self.ptr.o_margin;
    }

    pub fn setMargin(self: MjsOption, margin: mjtNum) void {
        self.ptr.o_margin = margin;
    }

    pub fn getImpratio(self: MjsOption) mjtNum {
        return self.ptr.impratio;
    }

    pub fn setImpratio(self: MjsOption, impratio: mjtNum) void {
        self.ptr.impratio = impratio;
    }

    pub fn getCone(self: MjsOption) c.mjtCone {
        return self.ptr.cone;
    }

    pub fn setCone(self: MjsOption, cone: c.mjtCone) void {
        self.ptr.cone = cone;
    }

    pub fn getJacobian(self: MjsOption) c.mjtJacobian {
        return self.ptr.jacobian;
    }

    pub fn setJacobian(self: MjsOption, jacobian: c.mjtJacobian) void {
        self.ptr.jacobian = jacobian;
    }

    pub fn getSolver(self: MjsOption) c.mjtSolver {
        return self.ptr.solver;
    }

    pub fn setSolver(self: MjsOption, solver: c.mjtSolver) void {
        self.ptr.solver = solver;
    }

    pub fn getIterations(self: MjsOption) c_int {
        return self.ptr.iterations;
    }

    pub fn setIterations(self: MjsOption, iterations: c_int) void {
        self.ptr.iterations = iterations;
    }

    pub fn getTolerance(self: MjsOption) mjtNum {
        return self.ptr.tolerance;
    }

    pub fn setTolerance(self: MjsOption, tolerance: mjtNum) void {
        self.ptr.tolerance = tolerance;
    }

    pub fn getNoslipIterations(self: MjsOption) c_int {
        return self.ptr.noslip_iterations;
    }

    pub fn setNoslipIterations(self: MjsOption, iterations: c_int) void {
        self.ptr.noslip_iterations = iterations;
    }

    pub fn getNoslipTolerance(self: MjsOption) mjtNum {
        return self.ptr.noslip_tolerance;
    }

    pub fn setNoslipTolerance(self: MjsOption, tolerance: mjtNum) void {
        self.ptr.noslip_tolerance = tolerance;
    }

    pub fn getWarmstart(self: MjsOption) mjtNum {
        return self.ptr.warmstart;
    }

    pub fn setWarmstart(self: MjsOption, warmstart: mjtNum) void {
        self.ptr.warmstart = warmstart;
    }

    pub fn getNeedfwd(self: MjsOption) u8 {
        return self.ptr.needfwd;
    }

    pub fn setNeedfwd(self: MjsOption, needfwd: u8) void {
        self.ptr.needfwd = needfwd;
    }

    pub fn getDisableflags(self: MjsOption) c_int {
        return self.ptr.disableflags;
    }

    pub fn setDisableflags(self: MjsOption, flags: c_int) void {
        self.ptr.disableflags = flags;
    }

    pub fn getEnableflags(self: MjsOption) c_int {
        return self.ptr.enableflags;
    }

    pub fn setEnableflags(self: MjsOption, flags: c_int) void {
        self.ptr.enableflags = flags;
    }
};

pub const MjsVisual = struct {
    ptr: *c.mjsVisual,
};

pub const MjsNumeric = struct {
    ptr: *c.mjsNumeric,

    pub fn asElement(self: MjsNumeric) MjsElement {
        return MjsElement{ .ptr = self.ptr.element };
    }

    pub fn getName(self: MjsNumeric) []const u8 {
        return c.mjs_getString(&self.ptr.name) orelse "";
    }

    pub fn getSize(self: MjsNumeric) c_int {
        return self.ptr.size;
    }

    pub fn setSize(self: MjsNumeric, size: c_int) void {
        self.ptr.size = size;
    }

    pub fn getData(self: MjsNumeric) []mjtNum {
        var data_size: c_int = 0;
        const ptr = c.mjs_getDouble(&self.ptr.data, &data_size);
        return ptr[0..@intCast(data_size)];
    }

    pub fn setData(self: MjsNumeric, data: []const mjtNum) void {
        c.mjs_setDouble(&self.ptr.data, data.ptr, @intCast(data.len));
    }
};

pub const MjsText = struct {
    ptr: *c.mjsText,

    pub fn asElement(self: MjsText) MjsElement {
        return MjsElement{ .ptr = self.ptr.element };
    }

    pub fn getName(self: MjsText) []const u8 {
        return c.mjs_getString(&self.ptr.name) orelse "";
    }

    pub fn getData(self: MjsText) []const u8 {
        return c.mjs_getString(&self.ptr.data) orelse "";
    }
};

pub const MjsTuple = struct {
    ptr: *c.mjsTuple,

    pub fn asElement(self: MjsTuple) MjsElement {
        return MjsElement{ .ptr = self.ptr.element };
    }

    pub fn getName(self: MjsTuple) []const u8 {
        return c.mjs_getString(&self.ptr.name) orelse "";
    }

    pub fn getObjType(self: MjsTuple) c_int {
        return self.ptr.objtype;
    }

    pub fn setObjType(self: MjsTuple, objtype: c_int) void {
        self.ptr.objtype = objtype;
    }

    pub fn getObjName(self: MjsTuple) []const u8 {
        return c.mjs_getString(&self.ptr.objname) orelse "";
    }

    pub fn getObjId(self: MjsTuple) c_int {
        return self.ptr.objid;
    }

    pub fn setObjId(self: MjsTuple, objid: c_int) void {
        self.ptr.objid = objid;
    }

    pub fn getData(self: MjsTuple) []mjtNum {
        var data_size: c_int = 0;
        const ptr = c.mjs_getDouble(&self.ptr.data, &data_size);
        return ptr[0..@intCast(data_size)];
    }

    pub fn setData(self: MjsTuple, data: []const mjtNum) void {
        c.mjs_setDouble(&self.ptr.data, data.ptr, @intCast(data.len));
    }
};

pub const MjsKey = struct {
    ptr: *c.mjsKey,

    pub fn asElement(self: MjsKey) MjsElement {
        return MjsElement{ .ptr = self.ptr.element };
    }

    pub fn getName(self: MjsKey) []const u8 {
        return c.mjs_getString(&self.ptr.name) orelse "";
    }

    pub fn getQpos(self: MjsKey) []mjtNum {
        var data_size: c_int = 0;
        const ptr = c.mjs_getDouble(&self.ptr.qpos, &data_size);
        return ptr[0..@intCast(data_size)];
    }

    pub fn getQvel(self: MjsKey) []mjtNum {
        var data_size: c_int = 0;
        const ptr = c.mjs_getDouble(&self.ptr.qvel, &data_size);
        return ptr[0..@intCast(data_size)];
    }

    pub fn getAct(self: MjsKey) []mjtNum {
        var data_size: c_int = 0;
        const ptr = c.mjs_getDouble(&self.ptr.act, &data_size);
        return ptr[0..@intCast(data_size)];
    }
};

pub const MjsPlugin = struct {
    ptr: *c.mjsPlugin,

    pub fn asElement(self: MjsPlugin) MjsElement {
        return MjsElement{ .ptr = self.ptr.element };
    }

    pub fn getName(self: MjsPlugin) []const u8 {
        return c.mjs_getString(&self.ptr.name) orelse "";
    }

    pub fn getPlugin(self: MjsPlugin) []const u8 {
        return c.mjs_getString(&self.ptr.plugin) orelse "";
    }

    pub fn getActive(self: MjsPlugin) u8 {
        return self.ptr.active;
    }

    pub fn setActive(self: MjsPlugin, active: u8) void {
        self.ptr.active = active;
    }
};

pub const MjsSkin = struct {
    ptr: *c.mjsSkin,

    pub fn asElement(self: MjsSkin) MjsElement {
        return MjsElement{ .ptr = self.ptr.element };
    }

    pub fn getName(self: MjsSkin) []const u8 {
        return c.mjs_getString(&self.ptr.name) orelse "";
    }

    pub fn getFile(self: MjsSkin) []const u8 {
        return c.mjs_getString(&self.ptr.file) orelse "";
    }

    pub fn getMaterial(self: MjsSkin) []const u8 {
        return c.mjs_getString(&self.ptr.material) orelse "";
    }

    pub fn getRgba(self: MjsSkin) [4]f32 {
        return self.ptr.rgba;
    }

    pub fn setRgba(self: MjsSkin, rgba: [4]f32) void {
        self.ptr.rgba = rgba;
    }

    pub fn getInflate(self: MjsSkin) mjtNum {
        return self.ptr.inflate;
    }

    pub fn setInflate(self: MjsSkin, inflate: mjtNum) void {
        self.ptr.inflate = inflate;
    }

    pub fn getTexcoord(self: MjsSkin) []mjtNum {
        var data_size: c_int = 0;
        const ptr = c.mjs_getDouble(&self.ptr.texcoord, &data_size);
        return ptr[0..@intCast(data_size)];
    }
};

pub const MjsDefault = struct {
    ptr: *c.mjsDefault,
};

pub const MjsStatistic = struct {
    ptr: *c.mjsStatistic,
};

pub const Spec = struct {
    ptr: *c.mjSpec,
    assets: std.StringHashMap([]u8),

    pub fn init(allocator: std.mem.Allocator) !*Spec {
        const s = c.mj_makeSpec();
        if (s == null) {
            return error.SpecCreationFialed;
        }
        const self = try allocator.create(Spec);
        self.* = .{ .ptr = s, .assets = std.StringHashMap([]u8).init(allocator) };
        return self;
    }

    pub fn initFromXmlPath(allocator: std.mem.Allocator, path: [*:0]const u8, vfs: ?*const c.mjVFS, error_buf: []u8) !*Spec {
        const s = c.mj_parseXML(path, vfs, error_buf.ptr, @intCast(error_buf.len));
        if (s == null) {
            return PhyzxError.SpecLoadFailed;
        }

        const self = try allocator.create(Spec);
        self.* = .{ .ptr = s, .assets = std.StringHashMap([]u8).init(allocator) };
        return self;
    }

    pub fn initFromString(allocator: std.mem.Allocator, xmlstring: [*:0]const u8, vfs: ?*const c.mjVFS, error_buf: []u8) !*Spec {
        const s = c.mj_parseXMLString(xmlstring, vfs, error_buf.ptr, @intCast(error_buf.len));
        if (s == null) {
            return PhyzxError.SpecLoadFailed;
        }

        const self = try allocator.create(Spec);
        self.* = .{ .ptr = s, .assets = std.StringHashMap([]u8).init(allocator) };
        return self;
    }

    pub fn deinit(self: *Spec, allocator: std.mem.Allocator) void {
        self.assets.deinit();
        c.mj_deleteSpec(self.ptr);
        allocator.destroy(self);
    }

    pub fn to_xml(self: *Spec, allocator: std.mem.Allocator) ![]u8 {
        var error_buf: [1024]u8 = undefined;
        const xml_sz = c.mj_saveXMLString(self.ptr, null, 0, &error_buf, error_buf.len);
        if (xml_sz <= 0) {
            return error.XmlSerializationFailed;
        }
        const xml = try allocator.alloc(u8, xml_sz);
        const actual_sz = c.mj_saveXMLString(self.ptr, xml.ptr, xml_sz, &error_buf, error_buf.len);
        if (actual_sz <= 0) {
            allocator.free(xml);
            return error.XmlSerializationFailed;
        }
        return xml;
    }

    pub fn from_zip(allocator: std.mem.Allocator, path: [*:0]const u8) !*Spec {
        const file = try std.fs.cwd().openFile(path, .{});
        defer file.close();

        var reader = try std.zip.Reader.init(file.reader(), file.getEndPos());
        defer reader.deinit();

        var xml_string: ?[]u8 = null;
        var assets = std.StringHashMap([]u8).init(allocator);

        while (reader.next()) |entry| {
            const name = entry.name;
            const data = try reader.readCurrentFile(allocator);
            if (std.mem.endsWith(u8, name, ".xml")) {
                xml_string = data;
            } else {
                try assets.put(name, data);
            }
        }

        if (xml_string == null) {
            return error.NoXmlFileInZip;
        }
        defer allocator.free(xml_string.?);

        var error_buf: [1024]u8 = undefined;
        const s = c.mj_parseXMLString(xml_string.?, null, &error_buf, error_buf.len);
        if (s == null) {
            return PhyzxError.SpecLoadFailed;
        }

        const self = try allocator.create(Spec);
        self.* = .{ .ptr = s, .assets = assets };
        return self;
    }

    pub fn to_zip(self: *Spec, allocator: std.mem.Allocator, path: [*:0]const u8) !void {
        const xml = try self.to_xml(allocator);
        defer allocator.free(xml);

        const file = try std.fs.cwd().createFile(path, .{});
        defer file.close();

        var zip = std.zip.Writer.init(file.writer());
        defer zip.finish() catch {};

        try zip.addFile(std.zip.File.CreateOptions{ .name = "model.xml" }, xml);

        var it = self.assets.iterator();
        while (it.next()) |entry| {
            try zip.addFile(std.zip.File.CreateOptions{ .name = entry.key_ptr.* }, entry.value_ptr.*);
        }
    }

    pub fn compile(self: *Spec, allocator: std.mem.Allocator) !*Model {
        const m = c.mj_compile(self.ptr, null);
        if (m == null) {
            return PhyzxError.SpecCompileFailed;
        }
        const model = try allocator.create(Model);
        model.* = .{ .allocator = allocator, .ptr = m };
        return model;
    }

    pub fn recompile(self: *Spec, allocator: std.mem.Allocator, old_model: *Model, old_data: *Data) !*struct { model: *Model, data: *Data } {
        const new_model_ptr: *c.mjModel = old_model.ptr;
        const new_data_ptr: *c.mjData = old_data.ptr;
        const res = c.mj_recompile(self.ptr, null, new_model_ptr, new_data_ptr);
        if (res != 0) {
            return PhyzxError.SpecCompileFailed;
        }

        const new_model = try allocator.create(Model);
        new_model.* = .{ .ptr = new_model_ptr };

        const new_data = try allocator.create(Data);
        new_data.* = .{ .ptr = new_data_ptr };

        return .{ .model = new_model, .data = new_data };
    }

    pub fn delete(self: *Spec, element: MjsElement) !void {
        if (c.mjs_delete(self.ptr, element.ptr) != 0) return PhyzxError.OperationFailed;
    }

    pub fn setDeepCopy(self: *Spec, deepcopy: c_int) !void {
        if (c.mjs_setDeepCopy(self.ptr, deepcopy) != 0) return PhyzxError.OperationFailed;
    }

    pub fn findBody(self: *Spec, name: [*:0]const u8) ?MjsBody {
        const body_ptr = c.mjs_findBody(self.ptr, name);
        if (body_ptr == null) return null;
        return MjsBody{ .ptr = body_ptr };
    }

    pub fn findElement(self: *Spec, obj_type: c_int, name: [*:0]const u8) ?MjsElement {
        const element_ptr = c.mjs_findElement(self.ptr, obj_type, name);
        if (element_ptr == null) return null;
        return MjsElement{ .ptr = element_ptr };
    }

    pub fn default_(self: *Spec) MjsDefault {
        return MjsDefault{ .ptr = self.ptr.default_ };
    }

    pub fn worldbody(self: *Spec) MjsBody {
        return MjsBody{ .ptr = c.mjs_findBody(self.ptr, "world") };
    }

    pub fn compiler(self: *Spec) MjsCompiler {
        return MjsCompiler{ .ptr = self.ptr.compiler };
    }

    pub fn option(self: *Spec) MjsOption {
        return MjsOption{ .ptr = self.ptr.option };
    }

    pub fn visual(self: *Spec) MjsVisual {
        return MjsVisual{ .ptr = self.ptr.visual };
    }

    pub fn statistic(self: *Spec) MjsStatistic {
        return MjsStatistic{ .ptr = self.ptr.statistic };
    }


































};

pub const MjsElement = struct {
    ptr: *c.mjsElement,

    pub fn setName(self: MjsElement, name: [*:0]const u8) !void {
        if (c.mjs_setName(self.ptr, name) != 0) return PhyzxError.InvalidName;
    }

    pub fn getId(self: MjsElement) c_int {
        return c.mjs_getId(self.ptr);
    }
};

pub const MjsBody = struct {
    ptr: *c.mjsBody,

    pub fn asElement(self: MjsBody) MjsElement {
        return MjsElement{ .ptr = self.ptr.element };
    }

    pub fn setName(self: MjsBody, name: [*:0]const u8) !void {
        return self.asElement().setName(name);
    }

    pub fn getPos(self: MjsBody) [3]mjtNum {
        return self.ptr.pos;
    }

    pub fn setPos(self: MjsBody, pos: [3]mjtNum) void {
        self.ptr.pos = pos;
    }

    pub fn getQuat(self: MjsBody) [4]mjtNum {
        return self.ptr.quat;
    }

    pub fn setQuat(self: MjsBody, quat: [4]mjtNum) void {
        self.ptr.quat = quat;
    }

    pub fn getEuler(self: MjsBody) [3]mjtNum {
        return self.ptr.euler;
    }

    pub fn setEuler(self: MjsBody, euler: [3]mjtNum) void {
        self.ptr.euler = euler;
    }

    pub fn addBody(self: MjsBody, name: [*:0]const u8) ?MjsBody {
        const body_ptr = c.mjs_addBody(self.ptr, null);
        if (body_ptr == null) return null;
        const body = MjsBody{ .ptr = body_ptr };
        _ = body.setName(name);
        return body;
    }
};

pub const MjsGeom = struct {
    ptr: *c.mjsGeom,

    pub fn asElement(self: MjsGeom) MjsElement {
        return MjsElement{ .ptr = self.ptr.element };
    }

    pub fn setName(self: MjsGeom, name: [*:0]const u8) !void {
        return self.asElement().setName(name);
    }

    pub fn getType(self: MjsGeom) c.mjtGeom {
        return self.ptr.@"type";
    }

    pub fn setType(self: MjsGeom, geom_type: c.mjtGeom) void {
        self.ptr.@"type" = geom_type;
    }

    pub fn getSize(self: MjsGeom) [3]mjtNum {
        return self.ptr.size;
    }

    pub fn setSize(self: MjsGeom, size: [3]mjtNum) void {
        self.ptr.size = size;
    }

    pub fn getPos(self: MjsGeom) [3]mjtNum {
        return self.ptr.pos;
    }

    pub fn setPos(self: MjsGeom, pos: [3]mjtNum) void {
        self.ptr.pos = pos;
    }

    pub fn getQuat(self: MjsGeom) [4]mjtNum {
        return self.ptr.quat;
    }

    pub fn setQuat(self: MjsGeom, quat: [4]mjtNum) void {
        self.ptr.quat = quat;
    }

    pub fn getRgba(self: MjsGeom) [4]f32 {
        return self.ptr.rgba;
    }

    pub fn setRgba(self: MjsGeom, rgba: [4]f32) void {
        self.ptr.rgba = rgba;
    }
};

pub const MjsJoint = struct {
    ptr: *c.mjsJoint,

    pub fn asElement(self: MjsJoint) MjsElement {
        return MjsElement{ .ptr = self.ptr.element };
    }

    pub fn setName(self: MjsJoint, name: [*:0]const u8) !void {
        return self.asElement().setName(name);
    }

    pub fn getType(self: MjsJoint) c.mjtJoint {
        return self.ptr.@"type";
    }

    pub fn setType(self: MjsJoint, joint_type: c.mjtJoint) void {
        self.ptr.@"type" = joint_type;
    }

    pub fn getAxis(self: MjsJoint) [3]mjtNum {
        return self.ptr.axis;
    }

    pub fn setAxis(self: MjsJoint, axis: [3]mjtNum) void {
        self.ptr.axis = axis;
    }

    pub fn getPos(self: MjsJoint) [3]mjtNum {
        return self.ptr.pos;
    }

    pub fn setPos(self: MjsJoint, pos: [3]mjtNum) void {
        self.ptr.pos = pos;
    }
};

pub const MjsSite = struct {
    ptr: *c.mjsSite,

    pub fn asElement(self: MjsSite) MjsElement {
        return MjsElement{ .ptr = self.ptr.element };
    }

    pub fn getPos(self: MjsSite) [3]mjtNum {
        return self.ptr.pos;
    }

    pub fn setPos(self: MjsSite, pos: [3]mjtNum) void {
        self.ptr.pos = pos;
    }

    pub fn getQuat(self: MjsSite) [4]mjtNum {
        return self.ptr.quat;
    }

    pub fn setQuat(self: MjsSite, quat: [4]mjtNum) void {
        self.ptr.quat = quat;
    }

    pub fn getSize(self: MjsSite) [3]mjtNum {
        return self.ptr.size;
    }

    pub fn setSize(self: MjsSite, size: [3]mjtNum) void {
        self.ptr.size = size;
    }

    pub fn getRgba(self: MjsSite) [4]f32 {
        return self.ptr.rgba;
    }

    pub fn setRgba(self: MjsSite, rgba: [4]f32) void {
        self.ptr.rgba = rgba;
    }
};

pub const MjsMesh = struct {
    ptr: *c.mjsMesh,

    pub fn asElement(self: MjsMesh) MjsElement {
        return MjsElement{ .ptr = self.ptr.element };
    }

    pub fn getName(self: MjsMesh) []const u8 {
        return c.mjs_getString(&self.ptr.name) orelse "";
    }

    pub fn getFile(self: MjsMesh) []const u8 {
        return c.mjs_getString(&self.ptr.file) orelse "";
    }

    pub fn getScale(self: MjsMesh) [3]mjtNum {
        return self.ptr.scale;
    }

    pub fn setScale(self: MjsMesh, scale: [3]mjtNum) void {
        self.ptr.scale = scale;
    }

    pub fn getUserVert(self: MjsMesh) []mjtNum {
        var data_size: c_int = 0;
        const ptr = c.mjs_getDouble(&self.ptr.uservert, &data_size);
        return ptr[0..@intCast(data_size)];
    }

    pub fn getUserNormal(self: MjsMesh) []mjtNum {
        var data_size: c_int = 0;
        const ptr = c.mjs_getDouble(&self.ptr.usernormal, &data_size);
        return ptr[0..@intCast(data_size)];
    }

    pub fn getUserFace(self: MjsMesh) []c_int {
        var data_size: c_int = 0;
        const ptr = c.mjs_getInt(&self.ptr.userface, &data_size);
        return ptr[0..@intCast(data_size)];
    }
};

pub const MjsHField = struct {
    ptr: *c.mjsHField,

    pub fn asElement(self: MjsHField) MjsElement {
        return MjsElement{ .ptr = self.ptr.element };
    }

    pub fn getName(self: MjsHField) []const u8 {
        return c.mjs_getString(&self.ptr.name) orelse "";
    }

    pub fn getFile(self: MjsHField) []const u8 {
        return c.mjs_getString(&self.ptr.file) orelse "";
    }

    pub fn getSize(self: MjsHField) [4]mjtNum {
        return self.ptr.size;
    }

    pub fn setSize(self: MjsHField, size: [4]mjtNum) void {
        self.ptr.size = size;
    }

    pub fn getNrow(self: MjsHField) c_int {
        return self.ptr.nrow;
    }

    pub fn setNrow(self: MjsHField, nrow: c_int) void {
        self.ptr.nrow = nrow;
    }

    pub fn getNcol(self: MjsHField) c_int {
        return self.ptr.ncol;
    }

    pub fn setNcol(self: MjsHField, ncol: c_int) void {
        self.ptr.ncol = ncol;
    }

    pub fn getUserData(self: MjsHField) []mjtNum {
        var data_size: c_int = 0;
        const ptr = c.mjs_getDouble(&self.ptr.userdata, &data_size);
        return ptr[0..@intCast(data_size)];
    }
};

pub const MjsTexture = struct {
    ptr: *c.mjsTexture,

    pub fn asElement(self: MjsTexture) MjsElement {
        return MjsElement{ .ptr = self.ptr.element };
    }

    pub fn getName(self: MjsTexture) []const u8 {
        return c.mjs_getString(&self.ptr.name) orelse "";
    }

    pub fn getType(self: MjsTexture) c.mjtTexture {
        return self.ptr.type_;
    }

    pub fn setType(self: MjsTexture, tex_type: c.mjtTexture) void {
        self.ptr.type_ = tex_type;
    }

    pub fn getFile(self: MjsTexture) []const u8 {
        return c.mjs_getString(&self.ptr.file) orelse "";
    }

    pub fn getWidth(self: MjsTexture) c_int {
        return self.ptr.width;
    }

    pub fn setWidth(self: MjsTexture, width: c_int) void {
        self.ptr.width = width;
    }

    pub fn getHeight(self: MjsTexture) c_int {
        return self.ptr.height;
    }

    pub fn setHeight(self: MjsTexture, height: c_int) void {
        self.ptr.height = height;
    }

    pub fn getRgb1(self: MjsTexture) [3]f32 {
        return self.ptr.rgb1;
    }

    pub fn setRgb1(self: MjsTexture, rgb1: [3]f32) void {
        self.ptr.rgb1 = rgb1;
    }

    pub fn getRgb2(self: MjsTexture) [3]f32 {
        return self.ptr.rgb2;
    }

    pub fn setRgb2(self: MjsTexture, rgb2: [3]f32) void {
        self.ptr.rgb2 = rgb2;
    }

    pub fn getData(self: MjsTexture) []const u8 {
        var data_size: c_int = 0;
        const ptr = c.mjs_getBuffer(&self.ptr.data, &data_size);
        return ptr[0..@intCast(data_size)];
    }
};

pub const MjsMaterial = struct {
    ptr: *c.mjsMaterial,

    pub fn asElement(self: MjsMaterial) MjsElement {
        return MjsElement{ .ptr = self.ptr.element };
    }

    pub fn getName(self: MjsMaterial) []const u8 {
        return c.mjs_getString(&self.ptr.name) orelse "";
    }

    pub fn getTexture(self: MjsMaterial) []const u8 {
        return c.mjs_getString(&self.ptr.texture) orelse "";
    }

    pub fn getTexUniform(self: MjsMaterial) u8 {
        return self.ptr.texuniform;
    }

    pub fn setTexUniform(self: MjsMaterial, texuniform: u8) void {
        self.ptr.texuniform = texuniform;
    }

    pub fn getTexRepeat(self: MjsMaterial) [2]f32 {
        return self.ptr.texrepeat;
    }

    pub fn setTexRepeat(self: MjsMaterial, texrepeat: [2]f32) void {
        self.ptr.texrepeat = texrepeat;
    }

    pub fn getEmission(self: MjsMaterial) mjtNum {
        return self.ptr.emission;
    }

    pub fn setEmission(self: MjsMaterial, emission: mjtNum) void {
        self.ptr.emission = emission;
    }

    pub fn getSpecular(self: MjsMaterial) mjtNum {
        return self.ptr.specular;
    }

    pub fn setSpecular(self: MjsMaterial, specular: mjtNum) void {
        self.ptr.specular = specular;
    }

    pub fn getShininess(self: MjsMaterial) mjtNum {
        return self.ptr.shininess;
    }

    pub fn setShininess(self: MjsMaterial, shininess: mjtNum) void {
        self.ptr.shininess = shininess;
    }

    pub fn getReflectance(self: MjsMaterial) mjtNum {
        return self.ptr.reflectance;
    }

    pub fn setReflectance(self: MjsMaterial, reflectance: mjtNum) void {
        self.ptr.reflectance = reflectance;
    }

    pub fn getRgba(self: MjsMaterial) [4]f32 {
        return self.ptr.rgba;
    }

    pub fn setRgba(self: MjsMaterial, rgba: [4]f32) void {
        self.ptr.rgba = rgba;
    }
};

pub const MjsTendon = struct {
    ptr: *c.mjsTendon,

    pub fn asElement(self: MjsTendon) MjsElement {
        return MjsElement{ .ptr = self.ptr.element };
    }

    pub fn getName(self: MjsTendon) []const u8 {
        return c.mjs_getString(&self.ptr.name) orelse "";
    }

    pub fn getLimited(self: MjsTendon) u8 {
        return self.ptr.limited;
    }

    pub fn setLimited(self: MjsTendon, limited: u8) void {
        self.ptr.limited = limited;
    }

    pub fn getRange(self: MjsTendon) [2]mjtNum {
        return self.ptr.range;
    }

    pub fn setRange(self: MjsTendon, range: [2]mjtNum) void {
        self.ptr.range = range;
    }

    pub fn getWidth(self: MjsTendon) mjtNum {
        return self.ptr.width;
    }

    pub fn setWidth(self: MjsTendon, width: mjtNum) void {
        self.ptr.width = width;
    }

    pub fn getRgba(self: MjsTendon) [4]f32 {
        return self.ptr.rgba;
    }

    pub fn setRgba(self: MjsTendon, rgba: [4]f32) void {
        self.ptr.rgba = rgba;
    }
};

pub const MjsEquality = struct {
    ptr: *c.mjsEquality,

    pub fn asElement(self: MjsEquality) MjsElement {
        return MjsElement{ .ptr = self.ptr.element };
    }

    pub fn getName(self: MjsEquality) []const u8 {
        return c.mjs_getString(&self.ptr.name) orelse "";
    }

    pub fn getType(self: MjsEquality) c.mjtEq {
        return self.ptr.type_;
    }

    pub fn setType(self: MjsEquality, eq_type: c.mjtEq) void {
        self.ptr.type_ = eq_type;
    }

    pub fn getBody1(self: MjsEquality) []const u8 {
        return c.mjs_getString(&self.ptr.body1) orelse "";
    }

    pub fn getBody2(self: MjsEquality) []const u8 {
        return c.mjs_getString(&self.ptr.body2) orelse "";
    }

    pub fn getGeom1(self: MjsEquality) []const u8 {
        return c.mjs_getString(&self.ptr.geom1) orelse "";
    }

    pub fn getGeom2(self: MjsEquality) []const u8 {
        return c.mjs_getString(&self.ptr.geom2) orelse "";
    }

    pub fn getJoint1(self: MjsEquality) []const u8 {
        return c.mjs_getString(&self.ptr.joint1) orelse "";
    }

    pub fn getJoint2(self: MjsEquality) []const u8 {
        return c.mjs_getString(&self.ptr.joint2) orelse "";
    }

    pub fn getActive(self: MjsEquality) u8 {
        return self.ptr.active;
    }

    pub fn setActive(self: MjsEquality, active: u8) void {
        self.ptr.active = active;
    }

    pub fn getSolimp(self: MjsEquality) [5]mjtNum {
        return self.ptr.solimp;
    }

    pub fn setSolimp(self: MjsEquality, solimp: [5]mjtNum) void {
        self.ptr.solimp = solimp;
    }

    pub fn getSolref(self: MjsEquality) [5]mjtNum {
        return self.ptr.solref;
    }

    pub fn setSolref(self: MjsEquality, solref: [5]mjtNum) void {
        self.ptr.solref = solref;
    }

    pub fn getPolycoef(self: MjsEquality) [5]mjtNum {
        return self.ptr.polycoef;
    }

    pub fn setPolycoef(self: MjsEquality, polycoef: [5]mjtNum) void {
        self.ptr.polycoef = polycoef;
    }
};

pub const MjsPair = struct {
    ptr: *c.mjsPair,

    pub fn asElement(self: MjsPair) MjsElement {
        return MjsElement{ .ptr = self.ptr.element };
    }

    pub fn getName(self: MjsPair) []const u8 {
        return c.mjs_getString(&self.ptr.name) orelse "";
    }

    pub fn getGeom1(self: MjsPair) []const u8 {
        return c.mjs_getString(&self.ptr.geom1) orelse "";
    }

    pub fn getGeom2(self: MjsPair) []const u8 {
        return c.mjs_getString(&self.ptr.geom2) orelse "";
    }

    pub fn getBody1(self: MjsPair) []const u8 {
        return c.mjs_getString(&self.ptr.body1) orelse "";
    }

    pub fn getBody2(self: MjsPair) []const u8 {
        return c.mjs_getString(&self.ptr.body2) orelse "";
    }

    pub fn getCondim(self: MjsPair) c_int {
        return self.ptr.condim;
    }

    pub fn setCondim(self: MjsPair, condim: c_int) void {
        self.ptr.condim = condim;
    }

    pub fn getFriction(self: MjsPair) [5]mjtNum {
        return self.ptr.friction;
    }

    pub fn setFriction(self: MjsPair, friction: [5]mjtNum) void {
        self.ptr.friction = friction;
    }

    pub fn getSolimp(self: MjsPair) [5]mjtNum {
        return self.ptr.solimp;
    }

    pub fn setSolimp(self: MjsPair, solimp: [5]mjtNum) void {
        self.ptr.solimp = solimp;
    }

    pub fn getSolref(self: MjsPair) [5]mjtNum {
        return self.ptr.solref;
    }

    pub fn setSolref(self: MjsPair, solref: [5]mjtNum) void {
        self.ptr.solref = solref;
    }
};

pub const MjsFlex = struct {
    ptr: *c.mjsFlex,

    pub fn asElement(self: MjsFlex) MjsElement {
        return MjsElement{ .ptr = self.ptr.element };
    }

    pub fn getName(self: MjsFlex) []const u8 {
        return c.mjs_getString(&self.ptr.name) orelse "";
    }

    pub fn getType(self: MjsFlex) c.mjtFlex {
        return self.ptr.type_;
    }

    pub fn setType(self: MjsFlex, flex_type: c.mjtFlex) void {
        self.ptr.type_ = flex_type;
    }

    pub fn getDim(self: MjsFlex) c_int {
        return self.ptr.dim;
    }

    pub fn setDim(self: MjsFlex, dim: c_int) void {
        self.ptr.dim = dim;
    }

    pub fn getCount(self: MjsFlex) c_int {
        return self.ptr.count;
    }

    pub fn setCount(self: MjsFlex, count: c_int) void {
        self.ptr.count = count;
    }

    pub fn getEdge(self: MjsFlex) []c_int {
        var data_size: c_int = 0;
        const ptr = c.mjs_getInt(&self.ptr.edge, &data_size);
        return ptr[0..@intCast(data_size)];
    }

    pub fn getFace(self: MjsFlex) []c_int {
        var data_size: c_int = 0;
        const ptr = c.mjs_getInt(&self.ptr.face, &data_size);
        return ptr[0..@intCast(data_size)];
    }

    pub fn getVert(self: MjsFlex) []mjtNum {
        var data_size: c_int = 0;
        const ptr = c.mjs_getDouble(&self.ptr.vert, &data_size);
        return ptr[0..@intCast(data_size)];
    }

    pub fn getElem(self: MjsFlex) []c_int {
        var data_size: c_int = 0;
        const ptr = c.mjs_getInt(&self.ptr.elem, &data_size);
        return ptr[0..@intCast(data_size)];
    }

    pub fn getTexcoord(self: MjsFlex) []mjtNum {
        var data_size: c_int = 0;
        const ptr = c.mjs_getDouble(&self.ptr.texcoord, &data_size);
        return ptr[0..@intCast(data_size)];
    }

    pub fn getMaterial(self: MjsFlex) []const u8 {
        return c.mjs_getString(&self.ptr.material) orelse "";
    }

    pub fn getRgba(self: MjsFlex) [4]f32 {
        return self.ptr.rgba;
    }

    pub fn setRgba(self: MjsFlex, rgba: [4]f32) void {
        self.ptr.rgba = rgba;
    }
};


pub const MjsActuator = struct {
    ptr: *c.mjsActuator,

    pub fn asElement(self: MjsActuator) MjsElement {
        return MjsElement{ .ptr = self.ptr.element };
    }

    pub fn getName(self: MjsActuator) []const u8 {
        return c.mjs_getString(&self.ptr.name) orelse "";
    }

    pub fn getType(self: MjsActuator) c.mjtAct {
        return self.ptr.type_;
    }

    pub fn setType(self: MjsActuator, act_type: c.mjtAct) void {
        self.ptr.type_ = act_type;
    }

    pub fn getJoint(self: MjsActuator) []const u8 {
        return c.mjs_getString(&self.ptr.joint) orelse "";
    }

    pub fn getGear(self: MjsActuator) [6]mjtNum {
        return self.ptr.gear;
    }

    pub fn setGear(self: MjsActuator, gear: [6]mjtNum) void {
        self.ptr.gear = gear;
    }

    pub fn getCtrlLimited(self: MjsActuator) u8 {
        return self.ptr.ctrllimited;
    }

    pub fn setCtrlLimited(self: MjsActuator, limited: u8) void {
        self.ptr.ctrllimited = limited;
    }

    pub fn getCtrlRange(self: MjsActuator) [2]mjtNum {
        return self.ptr.ctrlrange;
    }

    pub fn setCtrlRange(self: MjsActuator, ctrlrange: [2]mjtNum) void {
        self.ptr.ctrlrange = ctrlrange;
    }
};

pub const MjsSensor = struct {
    ptr: *c.mjsSensor,

    pub fn asElement(self: MjsSensor) MjsElement {
        return MjsElement{ .ptr = self.ptr.element };
    }

    pub fn getName(self: MjsSensor) []const u8 {
        return c.mjs_getString(&self.ptr.name) orelse "";
    }

    pub fn getType(self: MjsSensor) c.mjtSensor {
        return self.ptr.type_;
    }

    pub fn setType(self: MjsSensor, sensor_type: c.mjtSensor) void {
        self.ptr.type_ = sensor_type;
    }

    pub fn getObjType(self: MjsSensor) c.mjtObj {
        return self.ptr.objtype;
    }

    pub fn setObjType(self: MjsSensor, obj_type: c.mjtObj) void {
        self.ptr.objtype = obj_type;
    }

    pub fn getObjId(self: MjsSensor) c_int {
        return self.ptr.objid;
    }

    pub fn setObjId(self: MjsSensor, objid: c_int) void {
        self.ptr.objid = objid;
    }

    pub fn getRefId(self: MjsSensor) c_int {
        return self.ptr.refid;
    }

    pub fn setRefId(self: MjsSensor, refid: c_int) void {
        self.ptr.refid = refid;
    }

    pub fn getTrnId(self: MjsSensor) c_int {
        return self.ptr.trnid;
    }

    pub fn setTrnId(self: MjsSensor, trnid: c_int) void {
        self.ptr.trnid = trnid;
    }

    pub fn getDim(self: MjsSensor) c_int {
        return self.ptr.dim;
    }

    pub fn setDim(self: MjsSensor, dim: c_int) void {
        self.ptr.dim = dim;
    }
};

pub const Model = struct {
    allocator: std.mem.Allocator,
    ptr: *c.mjModel,
    pub fn initFromXmlPath(allocator: std.mem.Allocator, path: [*:0]const u8, asset_base_path: ?[]const u8) !*Model {
        var vfs: ?*Vfs = null;
        if (asset_base_path) |base_path| {
            vfs = try Vfs.init(allocator);
            errdefer if (vfs) |v| v.deinit();

            var dir = try std.fs.cwd().openDir(base_path, .{ .iterate = true });
            defer dir.close();

            var dir_it = dir.iterate();
            while (try dir_it.next()) |entry| {
                if (entry.kind == std.fs.Dir.Entry.Kind.file) {
                    const file_path = try std.fmt.allocPrint(allocator, "{s}/{s}", .{ base_path, entry.name });
                    defer allocator.free(file_path);

                    const meshdir = std.fs.path.basename(base_path);
                    const vfs_path = try std.fmt.allocPrint(allocator, "{s}/{s}", .{meshdir, entry.name});
                    defer allocator.free(vfs_path);

                    try vfs.?.addFile(file_path, vfs_path);
                }
            }
        }

        var error_buf: [1024]u8 = undefined;
        const m = c.mj_loadXML(path, if (vfs) |v| v.ptr else null, &error_buf, @intCast(error_buf.len));
        if (m == null) {
            std.debug.print("mj_loadXML returned null for path: {s}, error: {s}\n", .{path, error_buf});
            return PhyzxError.ModelLoadFailed;
        }

        const self = try allocator.create(Model);
        self.* = .{ .allocator = allocator, .ptr = m };
        return self;
    }

    pub fn deinit(self: *Model, allocator: std.mem.Allocator) void {
        c.mj_deleteModel(self.ptr);
        allocator.destroy(self);
    }

    pub fn nq(self: *const Model) i32 {
        return self.ptr.nq;
    }

    pub fn nv(self: *const Model) i32 {
        return self.ptr.nv;
    }

    pub fn nu(self: *const Model) i32 {
        return self.ptr.nu;
    }

    pub fn na(self: *const Model) i32 {
        return self.ptr.na;
    }

    pub fn nbody(self: *const Model) i32 {
        return self.ptr.nbody;
    }

    pub fn actuatorJointID(self: *const Model, act_id: c_int) c_int {
        const index: usize = @intCast(act_id);
        return self.ptr.actuator_trnid[index * 2];
    }

    pub fn jointQPosAddress(self: *const Model, joint_id: c_int) c_int {
        const index: usize = @intCast(joint_id);
        return self.ptr.jnt_qposadr[index];
    }

    pub fn jointDoFAddress(self: *const Model, joint_id: c_int) c_int {
        const index: usize = @intCast(joint_id);
        return self.ptr.jnt_dofadr[index];
    }

    // --- New convenience functions for Model ---
    pub fn getBodyId(self: *const Model, name: []const u8) !c_int {
        const id = idFromName(self, @intFromEnum(phyzx.ObjType.body), name) orelse return error.ElementNotFound;
        return id;
    }

    pub fn getJointId(self: *const Model, name: []const u8) !c_int {
        const id = idFromName(self, @intFromEnum(phyzx.ObjType.joint), name) orelse return error.ElementNotFound;
        return id;
    }

    pub fn getGeomId(self: *const Model, name: []const u8) !c_int {
        const id = idFromName(self, @intFromEnum(phyzx.ObjType.geom), name) orelse return error.ElementNotFound;
        return id;
    }

    pub fn getActuatorId(self: *const Model, name: []const u8) !c_int {
        const id = idFromName(self, @intFromEnum(phyzx.ObjType.actuator), name) orelse return error.ElementNotFound;
        return id;
    }
};

pub const Data = struct {
    ptr: *c.mjData,

    pub fn init(allocator: std.mem.Allocator, model: *Model) !*Data {
        const d = c.mj_makeData(model.ptr);
        if (d == null) {
            std.debug.print("mj_makeData returned null for model: {*}\n", .{model.ptr});
            return PhyzxError.DataCreationFailed;
        }

        const self = try allocator.create(Data);
        self.* = .{ .ptr = d };
        return self;
    }

    pub fn deinit(self: *Data, allocator: std.mem.Allocator) void {
        c.mj_deleteData(self.ptr);
        allocator.destroy(self);
    }

    pub fn qpos(self: *Data, model: *const Model) []mjtNum {
        return self.ptr.qpos[0..@intCast(model.ptr.nq)];
    }

    pub fn qvel(self: *Data, model: *const Model) []mjtNum {
        return self.ptr.qvel[0..@intCast(model.ptr.nv)];
    }

    pub fn ctrl(self: *Data, model: *const Model) []mjtNum {
        return self.ptr.ctrl[0..@intCast(model.ptr.nu)];
    }

    pub fn body_xpos(self: *const Data, model: *const Model) []const mjtNum {
        return self.ptr.xpos[0..@intCast(model.ptr.nbody * 3)];
    }

    pub fn time(self: *const Data) mjtNum {
        return self.ptr.time;
    }

    pub fn bodyPosition(self: *const Data, body_id: c_int) *const [3]mjtNum {
        const idx: usize = @intCast(body_id);
        return &self.ptr.xpos[idx * 3];
    }

    pub fn bodyRotationMatrix(self: *const Data, body_id: c_int) *const [9]mjtNum {
        const idx: usize = @intCast(body_id);
        return &self.ptr.xmat[idx * 9];
    }

    // --- New convenience functions for Data ---
    pub fn getJointPosition(self: *Data, model: *const Model, joint_id: c_int) !mjtNum {
        const addr = model.jointQPosAddress(joint_id);
        if (addr < 0 or addr >= model.nq()) return error.ElementNotFound;
        return self.qpos(model)[addr];
    }

    pub fn setJointPosition(self: *Data, model: *const Model, joint_id: c_int, value: mjtNum) !void {
        const addr = model.jointQPosAddress(joint_id);
        if (addr < 0 or addr >= model.nq()) return error.ElementNotFound;
        self.qpos(model)[addr] = value;
    }

    pub fn getJointVelocity(self: *Data, model: *const Model, joint_id: c_int) !mjtNum {
        const addr = model.jointDoFAddress(joint_id);
        if (addr < 0 or addr >= model.nv()) return error.ElementNotFound;
        return self.qvel(model)[addr];
    }

    pub fn setJointVelocity(self: *Data, model: *const Model, joint_id: c_int, value: mjtNum) !void {
        const addr = model.jointDoFAddress(joint_id);
        if (addr < 0 or addr >= model.nv()) return error.ElementNotFound;
        self.qvel(model)[addr] = value;
    }

    pub fn getActuatorControl(self: *Data, model: *const Model, actuator_id: c_int) !mjtNum {
        if (actuator_id < 0 or actuator_id >= model.nu()) return error.ElementNotFound;
        return self.ctrl(model)[actuator_id];
    }

    pub fn setActuatorControl(self: *Data, model: *const Model, actuator_id: c_int, value: mjtNum) !void {
        if (actuator_id < 0 or actuator_id >= model.nu()) return error.ElementNotFound;
        self.ctrl(model)[actuator_id] = value;
    }
};

pub const SpecBuilder = struct {
    allocator: std.mem.Allocator,
    spec: *Spec,

    pub fn init(allocator: std.mem.Allocator) !*SpecBuilder {
        const spec = try Spec.init(allocator);
        const self = try allocator.create(SpecBuilder);
        self.* = .{ .allocator = allocator, .spec = spec };
        return self;
    }

    pub fn addBody(self: *SpecBuilder, name: [*:0]const u8) !MjsBody {
        const body_ptr = c.mjs_addBody(self.spec.worldbody().ptr, null);
        if (body_ptr == null) return PhyzxError.OperationFailed;
        const body = MjsBody{ .ptr = body_ptr };
        try body.setName(name);
        return body;
    }

    pub fn addGeom(self: *SpecBuilder, body: MjsBody, name: [*:0]const u8) !MjsGeom {
        _ = self;
        const geom_ptr = c.mjs_addGeom(body.ptr, null);
        if (geom_ptr == null) return PhyzxError.OperationFailed;
        const geom = MjsGeom{ .ptr = geom_ptr };
        try geom.setName(name);
        return geom;
    }

    pub fn addJoint(self: *SpecBuilder, body: MjsBody, name: [*:0]const u8) !MjsJoint {
        _ = self;
        const joint_ptr = c.mjs_addJoint(body.ptr, null);
        if (joint_ptr == null) return PhyzxError.OperationFailed;
        const joint = MjsJoint{ .ptr = joint_ptr };
        try joint.setName(name);
        return joint;
    }

    pub fn addActuator(self: *SpecBuilder, def: ?*const c.mjsDefault) ?MjsActuator {
        const actuator_ptr = c.mjs_addActuator(self.spec.ptr, def);
        if (actuator_ptr == null) return null;
        return MjsActuator{ .ptr = actuator_ptr };
    }

    pub fn addSensor(self: *SpecBuilder) ?MjsSensor {
        const sensor_ptr = c.mjs_addSensor(self.spec.ptr);
        if (sensor_ptr == null) return null;
        return MjsSensor{ .ptr = sensor_ptr };
    }

    pub fn addFlex(self: *SpecBuilder) ?MjsFlex {
        const flex_ptr = c.mjs_addFlex(self.spec.ptr);
        if (flex_ptr == null) return null;
        return MjsFlex{ .ptr = flex_ptr };
    }

    pub fn addPair(self: *SpecBuilder, def: ?*const c.mjsDefault) ?MjsPair {
        const pair_ptr = c.mjs_addPair(self.spec.ptr, def);
        if (pair_ptr == null) return null;
        return MjsPair{ .ptr = pair_ptr };
    }

    pub fn addEquality(self: *SpecBuilder, def: ?*const c.mjsDefault) ?MjsEquality {
        const equality_ptr = c.mjs_addEquality(self.spec.ptr, def);
        if (equality_ptr == null) return null;
        return MjsEquality{ .ptr = equality_ptr };
    }

    pub fn addTendon(self: *SpecBuilder, def: ?*const c.mjsDefault) ?MjsTendon {
        const tendon_ptr = c.mjs_addTendon(self.spec.ptr, def);
        if (tendon_ptr == null) return null;
        return MjsTendon{ .ptr = tendon_ptr };
    }

    pub fn addNumeric(self: *SpecBuilder) ?MjsNumeric {
        const numeric_ptr = c.mjs_addNumeric(self.spec.ptr);
        if (numeric_ptr == null) return null;
        return MjsNumeric{ .ptr = numeric_ptr };
    }

    pub fn addText(self: *SpecBuilder) ?MjsText {
        const text_ptr = c.mjs_addText(self.spec.ptr);
        if (text_ptr == null) return null;
        return MjsText{ .ptr = text_ptr };
    }

    pub fn addTuple(self: *SpecBuilder) ?MjsTuple {
        const tuple_ptr = c.mjs_addTuple(self.spec.ptr);
        if (tuple_ptr == null) return null;
        return MjsTuple{ .ptr = tuple_ptr };
    }

    pub fn addKey(self: *SpecBuilder) ?MjsKey {
        const key_ptr = c.mjs_addKey(self.spec.ptr);
        if (key_ptr == null) return null;
        return MjsKey{ .ptr = key_ptr };
    }

    pub fn addPlugin(self: *SpecBuilder) ?MjsPlugin {
        const plugin_ptr = c.mjs_addPlugin(self.spec.ptr);
        if (plugin_ptr == null) return null;
        return MjsPlugin{ .ptr = plugin_ptr };
    }

    pub fn addDefault(self: *SpecBuilder, classname: ?[*:0]const u8, parent: ?*const c.mjsDefault) ?MjsDefault {
        const default_ptr = c.mjs_addDefault(self.spec.ptr, classname, parent);
        if (default_ptr == null) return null;
        return MjsDefault{ .ptr = default_ptr };
    }

    pub fn addMesh(self: *SpecBuilder, def: ?*const c.mjsDefault) ?MjsMesh {
        const mesh_ptr = c.mjs_addMesh(self.spec.ptr, def);
        if (mesh_ptr == null) return null;
        return MjsMesh{ .ptr = mesh_ptr };
    }

    pub fn addHField(self: *SpecBuilder) ?MjsHField {
        const hfield_ptr = c.mjs_addHField(self.spec.ptr);
        if (hfield_ptr == null) return null;
        return MjsHField{ .ptr = hfield_ptr };
    }

    pub fn addSkin(self: *SpecBuilder) ?MjsSkin {
        const skin_ptr = c.mjs_addSkin(self.spec.ptr);
        if (skin_ptr == null) return null;
        return MjsSkin{ .ptr = skin_ptr };
    }

    pub fn addTexture(self: *SpecBuilder) ?MjsTexture {
        const texture_ptr = c.mjs_addTexture(self.spec.ptr);
        if (texture_ptr == null) return null;
        return MjsTexture{ .ptr = texture_ptr };
    }

    pub fn addMaterial(self: *SpecBuilder, def: ?*const c.mjsDefault) ?MjsMaterial {
        const material_ptr = c.mjs_addMaterial(self.spec.ptr, def);
        if (material_ptr == null) return null;
        return MjsMaterial{ .ptr = material_ptr };
    }

    pub fn deinit(self: *SpecBuilder, allocator: std.mem.Allocator) void {
        self.spec.deinit(allocator);
        allocator.destroy(self);
    }
};

pub const Simulation = struct {
    allocator: std.mem.Allocator,
    model: *Model,
    data: *Data,

    pub fn init(allocator: std.mem.Allocator, model_path: [*:0]const u8, asset_base_path: ?[]const u8) !*Simulation {
        const self = try allocator.create(Simulation);
        errdefer allocator.destroy(self);

        const model = try Model.initFromXmlPath(allocator, model_path, asset_base_path);
        errdefer model.deinit(allocator);

        const data = try Data.init(allocator, model);

        self.* = .{
            .allocator = allocator,
            .model = model,
            .data = data,
        };
        return self;
    }

    pub fn init_from_model_and_data(allocator: std.mem.Allocator, model: *Model, data: *Data) !*Simulation {
        const self = try allocator.create(Simulation);
        self.* = .{
            .allocator = allocator,
            .model = model,
            .data = data,
        };
        return self;
    }

    pub fn deinit(self: *Simulation) void {
        self.data.deinit(self.allocator);
        self.model.deinit(self.allocator);
        self.allocator.destroy(self);
    }

    pub fn step(self: *Simulation) void {
        c.mj_step(self.model.ptr, self.data.ptr);
    }

    pub fn reset(self: *Simulation) void {
        c.mj_resetData(self.model.ptr, self.data.ptr);
    }

    pub fn forward(self: *Simulation) void {
        c.mj_forward(self.model.ptr, self.data.ptr);
    }

    pub fn applyForce(self: *Simulation, body_id: c_int, force: [3]mjtNum, point: [3]mjtNum) void {
        c.mj_applyFT(self.model.ptr, self.data.ptr, &force, null, &point, body_id, self.data.ptr.qfrc_applied);
    }
};

pub fn idFromName(model: *const Model, obj_type: c_uint, name: []const u8) !?c_int {
    const c_name = try model.allocator.allocSentinel(u8, name.len, 0);
    defer model.allocator.free(c_name);
    @memcpy(c_name, name);

    const id = phyzx.c.mj_name2id(model.ptr, @intCast(obj_type), c_name.ptr);
    if (id < 0) return null;
    return id;
}
