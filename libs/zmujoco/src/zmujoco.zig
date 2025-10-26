const std = @import("std");
const zmj_options = @import("zmujoco_options");
const lib_zmujoco = @import("lib_zmujoco");
pub const glfw = lib_zmujoco.glfw;
pub const c = lib_zmujoco.c;

pub const mjVERSION_HEADER = 337;

// user error and memory handlers
pub extern var mju_user_error: ?fn (msg: [*:0]const u8) callconv(.C) void;
pub extern var mju_user_warning: ?fn (msg: [*:0]const u8) callconv(.C) void;
pub extern var mju_user_malloc: ?fn (size: usize) callconv(.C) ?*anyopaque;
pub extern var mju_user_free: ?fn (ptr: ?*anyopaque) callconv(.C) void;

// callbacks extending computation pipeline
pub extern var mjcb_passive: ?c.mjfGeneric;
pub extern var mjcb_control: ?c.mjfGeneric;
pub extern var mjcb_contactfilter: ?c.mjfConFilt;
pub extern var mjcb_sensor: ?c.mjfSensor;
pub extern var mjcb_time: ?c.mjfTime;
pub extern var mjcb_act_dyn: ?c.mjfAct;
pub extern var mjcb_act_gain: ?c.mjfAct;
pub extern var mjcb_act_bias: ?c.mjfAct;

// collision function table
pub extern var mjCOLLISIONFUNC: [c.mjNGEOMTYPES][c.mjNGEOMTYPES]?c.mjfCollision;

// string names
pub extern var mjDISABLESTRING: [c.mjNDISABLE][*:0]const u8;
pub extern var mjENABLESTRING: [c.mjNENABLE][*:0]const u8;
pub extern var mjTIMERSTRING: [c.mjNTIMER][*:0]const u8;
pub extern var mjLABELSTRING: [c.mjNLABEL][*:0]const u8;
pub extern var mjFRAMESTRING: [c.mjNFRAME][*:0]const u8;
pub extern var mjVISSTRING: [c.mjNVISFLAG][3][*:0]const u8;
pub extern var mjRNDSTRING: [c.mjNRNDFLAG][3][*:0]const u8;

pub const mjtNum = if (zmj_options.use_single_precision) f32 else f64;

pub const PhyzxError = error{
    ModelLoadFailed,
    DataCreationFailed,
    SpecLoadFailed,
    SpecCompileFailed,
    InvalidMuFactor,
    InvalidBoundsSize,
    InvalidBoundsRange,
    JacobianMismatch,
    HessianNotSymmetric,
};

pub fn defaultOption(opt: *c.mjOption) void {
    c.mj_defaultOption(opt);
}

pub fn defaultLROpt(opt: *c.mjLROpt) void {
    c.mj_defaultLROpt(opt);
}
pub fn defaultSolRefImp(solref: ?*mjtNum, solimp: ?*mjtNum) void {
    c.mj_defaultSolRefImp(solref, solimp);
}
pub fn defaultVisual(vis: *c.mjVisual) void {
    c.mj_defaultVisual(vis);
}
pub fn copyData(dest: ?*c.mjData, m: *const c.mjModel, src: *const c.mjData) ?*c.mjData {
    return c.mj_copyData(dest, m, src);
}
pub fn v_copyData(dest: ?*c.mjData, m: *const c.mjModel, src: *const c.mjData) ?*c.mjData {
    return c.mjv_copyData(dest, m, src);
}

pub fn makeData(m: *const c.mjModel) ?*c.mjData {
    return c.mj_makeData(m);
}

pub fn deleteData(d: *c.mjData) void {
    c.mj_deleteData(d);
}

pub fn resetData(m: *const c.mjModel, d: *c.mjData) void {
    c.mj_resetData(m, d);
}

pub fn resetDataDebug(m: *const c.mjModel, d: *c.mjData, debug_value: u8) void {
    c.mj_resetDataDebug(m, d, debug_value);
}

pub fn resetDataKeyframe(m: *const c.mjModel, d: *c.mjData, key: c_int) void {
    c.mj_resetDataKeyframe(m, d, key);
}

pub fn stackAllocNum(d: *c.mjData, size: usize) ?[*]mjtNum {
    return c.mj_stackAllocNum(d, size);
}

pub fn stackAllocInt(d: *c.mjData, size: usize) ?[*]c_int {
    return c.mj_stackAllocInt(d, size);
}

pub fn markStack(d: *c.mjData) void {
    c.mj_markStack(d);
}

pub fn freeStack(d: *c.mjData) void {
    c.mj_freeStack(d);
}

pub fn stackAllocByte(d: *c.mjData, bytes: usize, alignment: usize) ?*anyopaque {
    return c.mj_stackAllocByte(d, bytes, alignment);
}

pub fn getCacheSize(cache: *c.mjCache) usize {
    return c.mj_getCacheSize(cache);
}

pub fn getCacheCapacity(cache: *c.mjCache) usize {
    return c.mj_getCacheCapacity(cache);
}

pub fn setCacheCapacity(cache: *c.mjCache, size: usize) void {
    _ = c.mj_setCacheCapacity(cache, size);
}

pub fn getCache() ?*c.mjCache {
    return c.mj_getCache();
}

pub fn clearCache(cache: *c.mjCache) void {
    c.mj_clearCache(cache);
}

pub fn loadXML(filename: [*:0]const u8, vfs: ?*const c.mjVFS, error_buf: ?[*]u8, error_sz: c_int) ?*c.mjModel {
    return c.mj_loadXML(filename, vfs, error_buf, error_sz);
}

pub fn parseXML(filename: [*:0]const u8, vfs: ?*const c.mjVFS, error_buf: ?[*]u8, error_sz: c_int) ?*c.mjSpec {
    return c.mj_parseXML(filename, vfs, error_buf, error_sz);
}

pub fn parseXMLString(xml: [*:0]const u8, vfs: ?*const c.mjVFS, error_buf: ?[*]u8, error_sz: c_int) ?*c.mjSpec {
    return c.mj_parseXMLString(xml, vfs, error_buf, error_sz);
}

pub fn compile(s: *c.mjSpec, vfs: ?*const c.mjVFS) ?*c.mjModel {
    return c.mj_compile(s, vfs);
}

pub fn copyBack(s: *c.mjSpec, m: *const c.mjModel) c_int {
    return c.mj_copyBack(s, m);
}

pub fn recompile(s: *c.mjSpec, vfs: ?*const c.mjVFS, m: *c.mjModel, d: *c.mjData) c_int {
    return c.mj_recompile(s, vfs, m, d);
}

pub fn freeLastXML() void {
    c.mj_freeLastXML();
}

pub fn saveXMLString(s: *const c.mjSpec, xml: [*]u8, xml_sz: c_int, error_buf: ?[*]u8, error_sz: c_int) c_int {
    return c.mj_saveXMLString(s, xml, xml_sz, error_buf, error_sz);
}

pub fn saveXML(s: *const c.mjSpec, filename: [*:0]const u8, error_buf: ?[*]u8, error_sz: c_int) c_int {
    return c.mj_saveXML(s, filename, error_buf, error_sz);
}

pub fn saveLastXML(filename: [*:0]const u8, model: *const c.mjModel, error_buf: [*:0]u8, error_buf_sz: c_int) c_int {
    return c.mj_saveLastXML(filename, model, error_buf, error_buf_sz);
}

pub fn printSchema(filename: ?[*:0]const u8, buffer: [*:0]u8, buffer_sz: c_int, flg_html: c_int, flg_pad: c_int) c_int {
    return c.mj_printSchema(filename, buffer, buffer_sz, flg_html, flg_pad);
}

pub fn copyModel(dest: ?*c.mjModel, src: *const c.mjModel) ?*c.mjModel {
    return c.mj_copyModel(dest, src);
}

pub fn saveModel(m: *const c.mjModel, filename: ?[*:0]const u8, buffer: ?*anyopaque, buffer_sz: c_int) void {
    c.mj_saveModel(m, filename, buffer, buffer_sz);
}

pub fn loadModel(filename: [*:0]const u8, vfs: ?*const c.mjVFS) ?*c.mjModel {
    return c.mj_loadModel(filename, vfs);
}

pub fn deleteModel(m: *c.mjModel) void {
    c.mj_deleteModel(m);
}

pub fn sizeModel(m: *const c.mjModel) c_int {
    return c.mj_sizeModel(m);
}

pub fn setConst(m: *c.mjModel, d: *c.mjData) void {
    c.mj_setConst(m, d);
}

pub fn setLengthRange(m: *c.mjModel, d: *c.mjData, index: c_int, opt: *const c.mjLROpt, error_buf: ?[*]u8, error_sz: c_int) c_int {
    return c.mj_setLengthRange(m, d, index, opt, error_buf, error_sz);
}

pub fn makeSpec() ?*c.mjSpec {
    return c.mj_makeSpec();
}

pub fn copySpec(s: *const c.mjSpec) ?*c.mjSpec {
    return c.mj_copySpec(s);
}

pub fn deleteSpec(s: *c.mjSpec) void {
    c.mj_deleteSpec(s);
}

pub fn defaultVFS(vfs: *c.mjVFS) void {
    c.mj_defaultVFS(vfs);
}

pub fn addFileVFS(vfs: *c.mjVFS, directory: [*:0]const u8, filename: [*:0]const u8) c_int {
    return c.mj_addFileVFS(vfs, directory, filename);
}

pub fn deleteVFS(vfs: *c.mjVFS) void {
    c.mj_deleteVFS(vfs);
}

pub fn addBufferVFS(vfs: *c.mjVFS, name: [*:0]const u8, buffer: *const anyopaque, nbuffer: c_int) c_int {
    return c.mj_addBufferVFS(vfs, name, buffer, nbuffer);
}

pub fn deleteFileVFS(vfs: *c.mjVFS, filename: [*:0]const u8) c_int {
    return c.mj_deleteFileVFS(vfs, filename);
}

pub fn step(m: *const c.mjModel, d: *c.mjData) void {
    c.mj_step(m, d);
}

pub fn step1(m: *const c.mjModel, d: *c.mjData) void {
    c.mj_step1(m, d);
}

pub fn step2(m: *const c.mjModel, d: *c.mjData) void {
    c.mj_step2(m, d);
}

pub fn forward(m: *const c.mjModel, d: *c.mjData) void {
    c.mj_forward(m, d);
}

pub fn inverse(m: *const c.mjModel, d: *c.mjData) void {
    c.mj_inverse(m, d);
}

pub fn forwardSkip(m: *const c.mjModel, d: *c.mjData, skipstage: c_int, skipsensor: c_int) void {
    c.mj_forwardSkip(m, d, skipstage, skipsensor);
}

pub fn inverseSkip(m: *const c.mjModel, d: *c.mjData, skipstage: c_int, skipsensor: c_int) void {
    c.mj_inverseSkip(m, d, skipstage, skipsensor);
}

pub fn fwdPosition(m: *const c.mjModel, d: *c.mjData) void {
    c.mj_fwdPosition(m, d);
}

pub fn fwdVelocity(m: *const c.mjModel, d: *c.mjData) void {
    c.mj_fwdVelocity(m, d);
}

pub fn fwdActuation(m: *const c.mjModel, d: *c.mjData) void {
    c.mj_fwdActuation(m, d);
}

pub fn fwdAcceleration(m: *const c.mjModel, d: *c.mjData) void {
    c.mj_fwdAcceleration(m, d);
}

pub fn fwdConstraint(m: *const c.mjModel, d: *c.mjData) void {
    c.mj_fwdConstraint(m, d);
}

pub fn Euler(m: *const c.mjModel, d: *c.mjData) void {
    c.mj_Euler(m, d);
}

pub fn RungeKutta(m: *const c.mjModel, d: *c.mjData, N: c_int) void {
    c.mj_RungeKutta(m, d, N);
}

pub fn implicit(m: *const c.mjModel, d: *c.mjData) void {
    c.mj_implicit(m, d);
}

pub fn invPosition(m: *const c.mjModel, d: *c.mjData) void {
    c.mj_invPosition(m, d);
}

pub fn invVelocity(m: *const c.mjModel, d: *c.mjData) void {
    c.mj_invVelocity(m, d);
}

pub fn invConstraint(m: *const c.mjModel, d: *c.mjData) void {
    c.mj_invConstraint(m, d);
}

pub fn compareFwdInv(m: *const c.mjModel, d: *c.mjData) void {
    c.mj_compareFwdInv(m, d);
}

pub fn sensorPos(m: *const c.mjModel, d: *c.mjData) void {
    c.mj_sensorPos(m, d);
}

pub fn sensorVel(m: *const c.mjModel, d: *c.mjData) void {
    c.mj_sensorVel(m, d);
}

pub fn sensorAcc(m: *const c.mjModel, d: *c.mjData) void {
    c.mj_sensorAcc(m, d);
}

pub fn energyPos(m: *const c.mjModel, d: *c.mjData) void {
    c.mj_energyPos(m, d);
}

pub fn energyVel(m: *const c.mjModel, d: *c.mjData) void {
    c.mj_energyVel(m, d);
}

pub fn checkPos(m: *const c.mjModel, d: *c.mjData) void {
    c.mj_checkPos(m, d);
}

pub fn checkVel(m: *const c.mjModel, d: *c.mjData) void {
    c.mj_checkVel(m, d);
}

pub fn checkAcc(m: *const c.mjModel, d: *c.mjData) void {
    c.mj_checkAcc(m, d);
}

pub fn kinematics(m: *const c.mjModel, d: *c.mjData) void {
    c.mj_kinematics(m, d);
}

pub fn comPos(m: *const c.mjModel, d: *c.mjData) void {
    c.mj_comPos(m, d);
}

pub fn camlight(m: *const c.mjModel, d: *c.mjData) void {
    c.mj_camlight(m, d);
}

pub fn flex(m: *const c.mjModel, d: *c.mjData) void {
    c.mj_flex(m, d);
}

pub fn tendon(m: *const c.mjModel, d: *c.mjData) void {
    c.mj_tendon(m, d);
}

pub fn transmission(m: *const c.mjModel, d: *c.mjData) void {
    c.mj_transmission(m, d);
}

pub fn crb(m: *const c.mjModel, d: *c.mjData) void {
    c.mj_crb(m, d);
}

pub fn makeM(m: *const c.mjModel, d: *c.mjData) void {
    c.mj_makeM(m, d);
}

pub fn factorM(m: *const c.mjModel, d: *c.mjData) void {
    c.mj_factorM(m, d);
}

pub fn solveM(m: *const c.mjModel, d: *c.mjData, x: [*]mjtNum, y: [*]const mjtNum, n: c_int) void {
    c.mj_solveM(m, d, x, y, n);
}

pub fn solveM2(m: *const c.mjModel, d: *c.mjData, x: [*]mjtNum, y: [*]const mjtNum, sqrtInvD: [*]const mjtNum, n: c_int) void {
    c.mj_solveM2(m, d, x, y, sqrtInvD, n);
}

pub fn comVel(m: *const c.mjModel, d: *c.mjData) void {
    c.mj_comVel(m, d);
}

pub fn passive(m: *const c.mjModel, d: *c.mjData) void {
    c.mj_passive(m, d);
}

pub fn subtreeVel(m: *const c.mjModel, d: *c.mjData) void {
    c.mj_subtreeVel(m, d);
}

pub fn rne(m: *const c.mjModel, d: *c.mjData, flg_acc: c_int, result: [*]mjtNum) void {
    c.mj_rne(m, d, flg_acc, result);
}

pub fn rnePostConstraint(m: *const c.mjModel, d: *c.mjData) void {
    c.mj_rnePostConstraint(m, d);
}

pub fn collision(m: *const c.mjModel, d: *c.mjData) void {
    c.mj_collision(m, d);
}

pub fn makeConstraint(m: *const c.mjModel, d: *c.mjData) void {
    c.mj_makeConstraint(m, d);
}

pub fn island(m: *const c.mjModel, d: *c.mjData) void {
    c.mj_island(m, d);
}

pub fn projectConstraint(m: *const c.mjModel, d: *c.mjData) void {
    c.mj_projectConstraint(m, d);
}

pub fn referenceConstraint(m: *const c.mjModel, d: *c.mjData) void {
    c.mj_referenceConstraint(m, d);
}

pub fn constraintUpdate(m: *const c.mjModel, d: *c.mjData, jar: [*]const mjtNum, cost: ?*mjtNum, flg_coneHessian: c_int) void {
    c.mj_constraintUpdate(m, d, jar, cost, flg_coneHessian);
}

pub fn stateSize(m: *const c.mjModel, sig: c_uint) c_int {
    return c.mj_stateSize(m, sig);
}

pub fn getState(m: *const c.mjModel, d: *const c.mjData, state: [*]mjtNum, sig: c_uint) void {
    c.mj_getState(m, d, state, sig);
}

pub fn setState(m: *const c.mjModel, d: *c.mjData, state: [*]const mjtNum, sig: c_uint) void {
    c.mj_setState(m, d, state, sig);
}

pub fn setKeyframe(m: *c.mjModel, d: *const c.mjData, k: c_int) void {
    c.mj_setKeyframe(m, d, k);
}

pub fn addContact(m: *const c.mjModel, d: *c.mjData, con: *const c.mjContact) c_int {
    return c.mj_addContact(m, d, con);
}

pub fn isPyramidal(m: *const c.mjModel) c_int {
    return c.mj_isPyramidal(m);
}

pub fn isSparse(m: *const c.mjModel) c_int {
    return c.mj_isSparse(m);
}

pub fn isDual(m: *const c.mjModel) c_int {
    return c.mj_isDual(m);
}

pub fn mulJacVec(m: *const c.mjModel, d: *const c.mjData, res: [*]mjtNum, vec: [*]const mjtNum) void {
    c.mj_mulJacVec(m, d, res, vec);
}

pub fn mulJacTVec(m: *const c.mjModel, d: *const c.mjData, res: [*]mjtNum, vec: [*]const mjtNum) void {
    c.mj_mulJacTVec(m, d, res, vec);
}

pub fn jac(m: *const c.mjModel, d: *const c.mjData, jacp: ?[*]mjtNum, jacr: ?[*]mjtNum, point: [*]const mjtNum, body: c_int) void {
    c.mj_jac(m, d, jacp, jacr, point, body);
}

pub fn jacBody(m: *const c.mjModel, d: *const c.mjData, jacp: ?[*]mjtNum, jacr: ?[*]mjtNum, body: c_int) void {
    c.mj_jacBody(m, d, jacp, jacr, body);
}

pub fn jacBodyCom(m: *const c.mjModel, d: *const c.mjData, jacp: ?[*]mjtNum, jacr: ?[*]mjtNum, body: c_int) void {
    c.mj_jacBodyCom(m, d, jacp, jacr, body);
}

pub fn jacSubtreeCom(m: *const c.mjModel, d: *c.mjData, jacp: [*]mjtNum, body: c_int) void {
    c.mj_jacSubtreeCom(m, d, jacp, body);
}

pub fn jacGeom(m: *const c.mjModel, d: *const c.mjData, jacp: ?[*]mjtNum, jacr: ?[*]mjtNum, geom: c_int) void {
    c.mj_jacGeom(m, d, jacp, jacr, geom);
}

pub fn jacSite(m: *const c.mjModel, d: *const c.mjData, jacp: ?[*]mjtNum, jacr: ?[*]mjtNum, site: c_int) void {
    c.mj_jacSite(m, d, jacp, jacr, site);
}

pub fn jacPointAxis(m: *const c.mjModel, d: *c.mjData, jacPoint: ?[*]mjtNum, jacAxis: ?[*]mjtNum, point: [*]const mjtNum, axis: [*]const mjtNum, body: c_int) void {
    c.mj_jacPointAxis(m, d, jacPoint, jacAxis, point, axis, body);
}

pub fn jacDot(m: *const c.mjModel, d: *const c.mjData, jacp: ?[*]mjtNum, jacr: ?[*]mjtNum, point: [*]const mjtNum, body: c_int) void {
    c.mj_jacDot(m, d, jacp, jacr, point, body);
}

pub fn angmomMat(m: *const c.mjModel, d: *c.mjData, mat: [*]mjtNum, body: c_int) void {
    c.mj_angmomMat(m, d, mat, body);
}

pub fn name2id(m: *const c.mjModel, obj_type: c_int, name: [*:0]const u8) c_int {
    return c.mj_name2id(m, obj_type, name);
}

pub fn id2name(m: *const c.mjModel, obj_type: c_int, id: c_int) ?[*:0]const u8 {
    return c.mj_id2name(m, obj_type, id);
}

pub fn fullM(m: *const c.mjModel, dst: [*]mjtNum, M: [*]const mjtNum) void {
    c.mj_fullM(m, dst, M);
}

pub fn mulM(m: *const c.mjModel, d: *const c.mjData, res: [*]mjtNum, vec: [*]const mjtNum) void {
    c.mj_mulM(m, d, res, vec);
}

pub fn mulM2(m: *const c.mjModel, d: *const c.mjData, res: [*]mjtNum, vec: [*]const mjtNum) void {
    c.mj_mulM2(m, d, res, vec);
}

pub fn addM(m: *const c.mjModel, d: *c.mjData, dst: [*]mjtNum, rownnz: ?[*]c_int, rowadr: ?[*]c_int, colind: ?[*]c_int) void {
    c.mj_addM(m, d, dst, rownnz, rowadr, colind);
}

pub fn applyFT(m: *const c.mjModel, d: *c.mjData, force: [*]const mjtNum, torque: [*]const mjtNum, point: [*]const mjtNum, body: c_int, qfrc_target: [*]mjtNum) void {
    c.mj_applyFT(m, d, force, torque, point, body, qfrc_target);
}

pub fn objectVelocity(m: *const c.mjModel, d: *const c.mjData, objtype: c_int, objid: c_int, res: [*]mjtNum, flg_local: c_int) void {
    c.mj_objectVelocity(m, d, objtype, objid, res, flg_local);
}

pub fn objectAcceleration(m: *const c.mjModel, d: *const c.mjData, objtype: c_int, objid: c_int, res: [*]mjtNum, flg_local: c_int) void {
    c.mj_objectAcceleration(m, d, objtype, objid, res, flg_local);
}

pub fn geomDistance(m: *const c.mjModel, d: *const c.mjData, geom1: c_int, geom2: c_int, distmax: mjtNum, fromto: ?[*]mjtNum) mjtNum {
    return c.mj_geomDistance(m, d, geom1, geom2, distmax, fromto);
}

pub fn contactForce(m: *const c.mjModel, d: *const c.mjData, id: c_int, result: [*]mjtNum) void {
    c.mj_contactForce(m, d, id, result);
}

pub fn differentiatePos(m: *const c.mjModel, qvel: [*]mjtNum, dt: mjtNum, qpos1: [*]const mjtNum, qpos2: [*]const mjtNum) void {
    c.mj_differentiatePos(m, qvel, dt, qpos1, qpos2);
}

pub fn integratePos(m: *const c.mjModel, qpos: [*]mjtNum, qvel: [*]const mjtNum, dt: mjtNum) void {
    c.mj_integratePos(m, qpos, qvel, dt);
}

pub fn normalizeQuat(m: *const c.mjModel, qpos: [*]mjtNum) void {
    c.mj_normalizeQuat(m, qpos);
}

pub fn local2Global(d: *c.mjData, xpos: [*]mjtNum, xmat: [*]mjtNum, pos: [*]const mjtNum, quat: [*]const mjtNum, body: c_int, sameframe: u8) void {
    c.mj_local2Global(d, xpos, xmat, pos, quat, body, sameframe);
}

pub fn getTotalmass(m: *const c.mjModel) mjtNum {
    return c.mj_getTotalmass(m);
}

pub fn setTotalmass(m: *c.mjModel, newmass: mjtNum) void {
    c.mj_setTotalmass(m, newmass);
}

pub fn getPluginConfig(m: *const c.mjModel, plugin_id: c_int, attrib: [*:0]const u8) ?[*:0]const u8 {
    return c.mj_getPluginConfig(m, plugin_id, attrib);
}

pub fn loadPluginLibrary(path: [*:0]const u8) void {
    c.mj_loadPluginLibrary(path);
}

pub fn loadAllPluginLibraries(directory: [*:0]const u8, callback: ?c.mjfPluginLibraryLoadCallback) void {
    c.mj_loadAllPluginLibraries(directory, callback);
}

pub fn version() c_int {
    return c.mj_version();
}

pub fn versionString() [*:0]const u8 {
    return c.mj_versionString();
}

pub fn printFormattedModel(m: *const c.mjModel, filename: [*:0]const u8, float_format: [*:0]const u8) void {
    c.mj_printFormattedModel(m, filename, float_format);
}

pub fn printModel(m: *const c.mjModel, filename: [*:0]const u8) void {
    c.mj_printModel(m, filename);
}

pub fn printFormattedData(m: *const c.mjModel, d: *const c.mjData, filename: [*:0]const u8, float_format: [*:0]const u8) void {
    c.mj_printFormattedData(m, d, filename, float_format);
}

pub fn printData(m: *const c.mjModel, d: *const c.mjData, filename: [*:0]const u8) void {
    c.mj_printData(m, d, filename);
}

pub fn multiRay(m: *const c.mjModel, d: *c.mjData, pnt: [*]const mjtNum, vec: [*]const mjtNum, geomgroup: ?[*]const u8, flg_static: u8, bodyexclude: c_int, geomid: [*]c_int, dist: [*]mjtNum, nray: c_int, cutoff: mjtNum) void {
    c.mj_multiRay(m, d, pnt, vec, geomgroup, flg_static, bodyexclude, geomid, dist, nray, cutoff);
}

pub fn ray(m: *const c.mjModel, d: *const c.mjData, pnt: [*]const mjtNum, vec: [*]const mjtNum, geomgroup: ?[*]const u8, flg_static: u8, bodyexclude: c_int, geomid: ?[*]c_int) mjtNum {
    return c.mj_ray(m, d, pnt, vec, geomgroup, flg_static, bodyexclude, geomid);
}

pub fn rayHfield(m: *const c.mjModel, d: *const c.mjData, geomid: c_int, pnt: [*]const mjtNum, vec: [*]const mjtNum) mjtNum {
    return c.mj_rayHfield(m, d, geomid, pnt, vec);
}

pub fn rayMesh(m: *const c.mjModel, d: *const c.mjData, geomid: c_int, pnt: [*]const mjtNum, vec: [*]const mjtNum) mjtNum {
    return c.mj_rayMesh(m, d, geomid, pnt, vec);
}

pub fn rayGeom(pos: [*]const mjtNum, mat: [*]const mjtNum, size: [*]const mjtNum, pnt: [*]const mjtNum, vec: [*]const mjtNum, geomtype: c_int) mjtNum {
    return c.mju_rayGeom(pos, mat, size, pnt, vec, geomtype);
}

pub fn rayFlex(m: *const c.mjModel, d: *const c.mjData, flex_layer: c_int, flg_vert: u8, flg_edge: u8, flg_face: u8, flg_skin: u8, flexid: c_int, pnt: [*]const mjtNum, vec: [*]const mjtNum, vertid: ?[*]c_int) mjtNum {
    return c.mju_rayFlex(m, d, flex_layer, flg_vert, flg_edge, flg_face, flg_skin, flexid, pnt, vec, vertid);
}

pub fn raySkin(nface: c_int, nvert: c_int, face: [*]const c_int, vert: [*]const f32, pnt: [*]const mjtNum, vec: [*]const mjtNum, vertid: ?[*]c_int) mjtNum {
    return c.mju_raySkin(nface, nvert, face, vert, pnt, vec, vertid);
}

pub fn defaultCamera(cam: *c.mjvCamera) void {
    c.mjv_defaultCamera(cam);
}

pub fn defaultFreeCamera(m: *const c.mjModel, cam: *c.mjvCamera) void {
    c.mjv_defaultFreeCamera(m, cam);
}

pub fn defaultPerturb(pert: *c.mjvPerturb) void {
    c.mjv_defaultPerturb(pert);
}

pub fn room2model(modelpos: [*]mjtNum, modelquat: [*]mjtNum, roompos: [*]const mjtNum, roomquat: [*]const mjtNum, scn: *const c.mjvScene) void {
    c.mjv_room2model(modelpos, modelquat, roompos, roomquat, scn);
}

pub fn model2room(roompos: [*]mjtNum, roomquat: [*]mjtNum, modelpos: [*]const mjtNum, modelquat: [*]const mjtNum, scn: *const c.mjvScene) void {
    c.mjv_model2room(roompos, roomquat, modelpos, modelquat, scn);
}

pub fn cameraInModel(headpos: [*]mjtNum, forward_vec: [*]mjtNum, up: [*]mjtNum, scn: *const c.mjvScene) void {
    c.mjv_cameraInModel(headpos, forward_vec, up, scn);
}

pub fn cameraInRoom(headpos: [*]mjtNum, forward_vec: [*]mjtNum, up: [*]mjtNum, scn: *const c.mjvScene) void {
    c.mjv_cameraInRoom(headpos, forward_vec, up, scn);
}

pub fn frustumHeight(scn: *const c.mjvScene) mjtNum {
    return c.mjv_frustumHeight(scn);
}

pub fn alignToCamera(res: [*]mjtNum, vec: [*]const mjtNum, forward_vec: [*]const mjtNum) void {
    c.mjv_alignToCamera(res, vec, forward_vec);
}

pub fn moveCamera(m: *const c.mjModel, action: c_int, reldx: mjtNum, reldy: mjtNum, scn: *const c.mjvScene, cam: *c.mjvCamera) void {
    c.mjv_moveCamera(m, action, reldx, reldy, scn, cam);
}

pub fn movePerturb(m: *const c.mjModel, d: *const c.mjData, action: c_int, reldx: mjtNum, reldy: mjtNum, scn: *const c.mjvScene, pert: *c.mjvPerturb) void {
    c.mjv_movePerturb(m, d, action, reldx, reldy, scn, pert);
}

pub fn moveModel(m: *const c.mjModel, action: c_int, reldx: mjtNum, reldy: mjtNum, roomup: [*]const mjtNum, scn: *c.mjvScene) void {
    c.mjv_moveModel(m, action, reldx, reldy, roomup, scn);
}

pub fn initPerturb(m: *const c.mjModel, d: *c.mjData, scn: *const c.mjvScene, pert: *c.mjvPerturb) void {
    c.mjv_initPerturb(m, d, scn, pert);
}

pub fn applyPerturbPose(m: *const c.mjModel, d: *c.mjData, pert: *const c.mjvPerturb, flg_paused: c_int) void {
    c.mjv_applyPerturbPose(m, d, pert, flg_paused);
}

pub fn applyPerturbForce(m: *const c.mjModel, d: *c.mjData, pert: *const c.mjvPerturb) void {
    c.mjv_applyPerturbForce(m, d, pert);
}

pub fn averageCamera(cam1: *const c.mjvGLCamera, cam2: *const c.mjvGLCamera) c.mjvGLCamera {
    return c.mjv_averageCamera(cam1, cam2);
}

pub fn select(m: *const c.mjModel, d: *const c.mjData, vopt: *const c.mjvOption, aspectratio: mjtNum, relx: mjtNum, rely: mjtNum, scn: *const c.mjvScene, selpnt: [*]mjtNum, geomid: ?[*]c_int, flexid: ?[*]c_int, skinid: ?[*]c_int) c_int {
    return c.mjv_select(m, d, vopt, aspectratio, relx, rely, scn, selpnt, geomid, flexid, skinid);
}

pub fn mjv_defaultOption(opt: *c.mjvOption) void {
    c.mjv_defaultOption(opt);
}

pub fn defaultFigure(fig: *c.mjvFigure) void {
    c.mjv_defaultFigure(fig);
}

pub fn initGeom(geom: *c.mjvGeom, geom_type: c_int, size: ?[*]const mjtNum, pos: ?[*]const mjtNum, mat: ?[*]const mjtNum, rgba: ?[*]const f32) void {
    c.mjv_initGeom(geom, geom_type, size, pos, mat, rgba);
}

pub fn connector(geom: *c.mjvGeom, geom_type: c_int, width: mjtNum, from: [*]const mjtNum, to: [*]const mjtNum) void {
    c.mjv_connector(geom, geom_type, width, from, to);
}

pub fn defaultScene(scn: *c.mjvScene) void {
    c.mjv_defaultScene(scn);
}

pub fn makeScene(m: *const c.mjModel, scn: *c.mjvScene, maxgeom: c_int) void {
    c.mjv_makeScene(m, scn, maxgeom);
}

pub fn freeScene(scn: *c.mjvScene) void {
    c.mjv_freeScene(scn);
}

pub fn updateScene(m: *const c.mjModel, d: *c.mjData, opt: *const c.mjvOption, pert: ?*const c.mjvPerturb, cam: *c.mjvCamera, catmask: c_int, scn: *c.mjvScene) void {
    c.mjv_updateScene(m, d, opt, pert, cam, catmask, scn);
}

pub fn copyModelViz(dest: ?*c.mjModel, src: *const c.mjModel) void {
    c.mjv_copyModel(dest, src);
}

pub fn addGeoms(m: *const c.mjModel, d: *c.mjData, opt: *const c.mjvOption, pert: ?*const c.mjvPerturb, catmask: c_int, scn: *c.mjvScene) void {
    c.mjv_addGeoms(m, d, opt, pert, catmask, scn);
}

pub fn makeLights(m: *const c.mjModel, d: *c.mjData, scn: *c.mjvScene) void {
    c.mjv_makeLights(m, d, scn);
}

pub fn updateCamera(m: *const c.mjModel, d: *c.mjData, cam: *c.mjvCamera, scn: *c.mjvScene) void {
    c.mjv_updateCamera(m, d, cam, scn);
}

pub fn updateSkin(m: *const c.mjModel, d: *const c.mjData, scn: *c.mjvScene) void {
    c.mjv_updateSkin(m, d, scn);
}

pub fn defaultContext(con: *c.mjrContext) void {
    c.mjr_defaultContext(con);
}

pub fn makeContext(m: *const c.mjModel, con: *c.mjrContext, fontscale: c_int) void {
    c.mjr_makeContext(m, con, fontscale);
}

pub fn changeFont(fontscale: c_int, con: *c.mjrContext) void {
    c.mjr_changeFont(fontscale, con);
}

pub fn addAux(index: c_int, width: c_int, height: c_int, samples: c_int, con: *c.mjrContext) void {
    c.mjr_addAux(index, width, height, samples, con);
}

pub fn freeContext(con: *c.mjrContext) void {
    c.mjr_freeContext(con);
}

pub fn resizeOffscreen(width: c_int, height: c_int, con: *c.mjrContext) void {
    c.mjr_resizeOffscreen(width, height, con);
}

pub fn uploadTexture(m: *const c.mjModel, con: *const c.mjrContext, texid: c_int) void {
    c.mjr_uploadTexture(m, con, texid);
}

pub fn uploadMesh(m: *const c.mjModel, con: *const c.mjrContext, meshid: c_int) void {
    c.mjr_uploadMesh(m, con, meshid);
}

pub fn uploadHField(m: *const c.mjModel, con: *const c.mjrContext, hfieldid: c_int) void {
    c.mjr_uploadHField(m, con, hfieldid);
}

pub fn restoreBuffer(con: *const c.mjrContext) void {
    c.mjr_restoreBuffer(con);
}

pub fn setBuffer(framebuffer: c_int, con: *c.mjrContext) void {
    c.mjr_setBuffer(framebuffer, con);
}

pub fn readPixels(rgb: ?[*]u8, depth: ?[*]f32, viewport: c.mjrRect, con: *const c.mjrContext) void {
    c.mjr_readPixels(rgb, depth, viewport, con);
}

pub fn drawPixels(rgb: ?[*]const u8, depth: ?[*]const f32, viewport: c.mjrRect, con: *const c.mjrContext) void {
    c.mjr_drawPixels(rgb, depth, viewport, con);
}

pub fn blitBuffer(src: c.mjrRect, dst: c.mjrRect, flg_color: c_int, flg_depth: c_int, con: *const c.mjrContext) void {
    c.mjr_blitBuffer(src, dst, flg_color, flg_depth, con);
}

pub fn setAux(index: c_int, con: *const c.mjrContext) void {
    c.mjr_setAux(index, con);
}

pub fn blitAux(index: c_int, src: c.mjrRect, left: c_int, bottom: c_int, con: *const c.mjrContext) void {
    c.mjr_blitAux(index, src, left, bottom, con);
}

pub fn text(font: c_int, txt: [*:0]const u8, con: *const c.mjrContext, x: f32, y: f32, r: f32, g: f32, b: f32) void {
    c.mjr_text(font, txt, con, x, y, r, g, b);
}

pub fn overlay(font: c_int, gridpos: c_int, viewport: c.mjrRect, overlay_text: ?[*:0]const u8, overlay2: ?[*:0]const u8, con: *const c.mjrContext) void {
    c.mjr_overlay(font, gridpos, viewport, overlay_text, overlay2, con);
}

pub fn maxViewport(con: *const c.mjrContext) c.mjrRect {
    return c.mjr_maxViewport(con);
}

pub fn rectangle(viewport: c.mjrRect, r: f32, g: f32, b: f32, a: f32) void {
    c.mjr_rectangle(viewport, r, g, b, a);
}

pub fn label(viewport: c.mjrRect, font: c_int, txt: [*:0]const u8, r: f32, g: f32, b: f32, a: f32, rt: f32, gt: f32, bt: f32, con: *const c.mjrContext) void {
    c.mjr_label(viewport, font, txt, r, g, b, a, rt, gt, bt, con);
}

pub fn figure(viewport: c.mjrRect, fig: *c.mjvFigure, con: *const c.mjrContext) void {
    c.mjr_figure(viewport, fig, con);
}

pub fn render(viewport: c.mjrRect, scn: *c.mjvScene, con: *const c.mjrContext) void {
    c.mjr_render(viewport, scn, con);
}

pub fn finish() void {
    c.mjr_finish();
}

pub fn getError() c_int {
    return c.mjr_getError();
}

pub fn findRect(x: c_int, y: c_int, nrect: c_int, rect: [*]const c.mjrRect) c_int {
    return c.mjr_findRect(x, y, nrect, rect);
}

pub fn themeSpacing(ind: c_int) c.mjuiThemeSpacing {
    return c.mjui_themeSpacing(ind);
}

pub fn themeColor(ind: c_int) c.mjuiThemeColor {
    return c.mjui_themeColor(ind);
}

pub fn uiAdd(ui: *c.mjUI, def: [*]const c.mjuiDef) void {
    c.mjui_add(ui, def);
}

pub fn uiAddToSection(ui: *c.mjUI, sect: c_int, def: [*]const c.mjuiDef) void {
    c.mjui_addToSection(ui, sect, def);
}

pub fn uiResize(ui: *c.mjUI, con: *const c.mjrContext) void {
    c.mjui_resize(ui, con);
}

pub fn uiUpdate(section: c_int, item: c_int, ui: *const c.mjUI, state: *const c.mjuiState, con: *const c.mjrContext) void {
    c.mjui_update(section, item, ui, state, con);
}

pub fn uiEvent(ui: *c.mjUI, state: *c.mjuiState, con: *const c.mjrContext) ?*c.mjuiItem {
    return c.mjui_event(ui, state, con);
}

pub fn uiRender(ui: *c.mjUI, state: *const c.mjuiState, con: *const c.mjrContext) void {
    c.mjui_render(ui, state, con);
}

pub fn attach(parent: *c.mjsElement, child: *const c.mjsElement, prefix: ?[*:0]const u8, suffix: ?[*:0]const u8) ?*c.mjsElement {
    return c.mjs_attach(parent, child, prefix, suffix);
}

pub fn addBody(body: *c.mjsBody, def: ?*const c.mjsDefault) ?*c.mjsBody {
    return c.mjs_addBody(body, def);
}

pub fn addSite(body: *c.mjsBody, def: ?*const c.mjsDefault) ?*c.mjsSite {
    return c.mjs_addSite(body, def);
}

pub fn addJoint(body: *c.mjsBody, def: ?*const c.mjsDefault) ?*c.mjsJoint {
    return c.mjs_addJoint(body, def);
}

pub fn addFreeJoint(body: *c.mjsBody) ?*c.mjsJoint {
    return c.mjs_addFreeJoint(body);
}

pub fn addGeom(body: *c.mjsBody, def: ?*const c.mjsDefault) ?*c.mjsGeom {
    return c.mjs_addGeom(body, def);
}

pub fn addCamera(body: *c.mjsBody, def: ?*const c.mjsDefault) ?*c.mjsCamera {
    return c.mjs_addCamera(body, def);
}

pub fn addLight(body: *c.mjsBody, def: ?*const c.mjsDefault) ?*c.mjsLight {
    return c.mjs_addLight(body, def);
}

pub fn addFrame(body: *c.mjsBody, parentframe: ?*c.mjsFrame) ?*c.mjsFrame {
    return c.mjs_addFrame(body, parentframe);
}

pub fn deleteElement(s: *c.mjSpec, element: *c.mjsElement) c_int {
    return c.mjs_delete(s, element);
}

pub fn addActuator(s: *c.mjSpec, def: ?*const c.mjsDefault) ?*c.mjsActuator {
    return c.mjs_addActuator(s, def);
}

pub fn addSensor(s: *c.mjSpec) ?*c.mjsSensor {
    return c.mjs_addSensor(s);
}

pub fn addFlex(s: *c.mjSpec) ?*c.mjsFlex {
    return c.mjs_addFlex(s);
}

pub fn addPair(s: *c.mjSpec, def: ?*const c.mjsDefault) ?*c.mjsPair {
    return c.mjs_addPair(s, def);
}

pub fn addExclude(s: *c.mjSpec) ?*c.mjsExclude {
    return c.mjs_addExclude(s);
}

pub fn addEquality(s: *c.mjSpec, def: ?*const c.mjsDefault) ?*c.mjsEquality {
    return c.mjs_addEquality(s, def);
}

pub fn addTendon(s: *c.mjSpec, def: ?*const c.mjsDefault) ?*c.mjsTendon {
    return c.mjs_addTendon(s, def);
}

pub fn wrapSite(tendon_ptr: *c.mjsTendon, name: [*:0]const u8) ?*c.mjsWrap {
    return c.mjs_wrapSite(tendon_ptr, name);
}

pub fn wrapGeom(tendon_ptr: *c.mjsTendon, name: [*:0]const u8, sidesite: ?[*:0]const u8) ?*c.mjsWrap {
    return c.mjs_wrapGeom(tendon_ptr, name, sidesite);
}

pub fn wrapJoint(tendon_ptr: *c.mjsTendon, name: [*:0]const u8, coef: f64) ?*c.mjsWrap {
    return c.mjs_wrapJoint(tendon_ptr, name, coef);
}

pub fn wrapPulley(tendon_ptr: *c.mjsTendon, divisor: f64) ?*c.mjsWrap {
    return c.mjs_wrapPulley(tendon_ptr, divisor);
}

pub fn addNumeric(s: *c.mjSpec) ?*c.mjsNumeric {
    return c.mjs_addNumeric(s);
}

pub fn addText(s: *c.mjSpec) ?*c.mjsText {
    return c.mjs_addText(s);
}

pub fn addTuple(s: *c.mjSpec) ?*c.mjsTuple {
    return c.mjs_addTuple(s);
}

pub fn addKey(s: *c.mjSpec) ?*c.mjsKey {
    return c.mjs_addKey(s);
}

pub fn addPlugin(s: *c.mjSpec) ?*c.mjsPlugin {
    return c.mjs_addPlugin(s);
}

pub fn addDefault(s: *c.mjSpec, classname: ?[*:0]const u8, parent: ?*const c.mjsDefault) ?*c.mjsDefault {
    return c.mjs_addDefault(s, classname, parent);
}

pub fn setToMotor(actuator: *c.mjsActuator) ?[*:0]const u8 {
    return c.mjs_setToMotor(actuator);
}

pub fn setToPosition(actuator: *c.mjsActuator, kp: f64, kv: ?[*]f64, dampratio: ?[*]f64, timeconst: ?[*]f64, inheritrange: f64) ?[*:0]const u8 {
    return c.mjs_setToPosition(actuator, kp, kv, dampratio, timeconst, inheritrange);
}

pub fn setToIntVelocity(actuator: *c.mjsActuator, kp: f64, kv: ?[*]f64, dampratio: ?[*]f64, timeconst: ?[*]f64, inheritrange: f64) ?[*:0]const u8 {
    return c.mjs_setToIntVelocity(actuator, kp, kv, dampratio, timeconst, inheritrange);
}

pub fn setToVelocity(actuator: *c.mjsActuator, kv: f64) ?[*:0]const u8 {
    return c.mjs_setToVelocity(actuator, kv);
}

pub fn setToDamper(actuator: *c.mjsActuator, kv: f64) ?[*:0]const u8 {
    return c.mjs_setToDamper(actuator, kv);
}

pub fn setToCylinder(actuator: *c.mjsActuator, timeconst: f64, bias: f64, area: f64, diameter: f64) ?[*:0]const u8 {
    return c.mjs_setToCylinder(actuator, timeconst, bias, area, diameter);
}

pub fn setToMuscle(actuator: *c.mjsActuator, timeconst: [*]f64, tausmooth: f64, range: [*]f64, force: f64, scale: f64, lmin: f64, lmax: f64, vmax: f64, fpmax: f64, fvmax: f64) ?[*:0]const u8 {
    return c.mjs_setToMuscle(actuator, timeconst, tausmooth, range, force, scale, lmin, lmax, vmax, fpmax, fvmax);
}

pub fn setToAdhesion(actuator: *c.mjsActuator, gain: f64) ?[*:0]const u8 {
    return c.mjs_setToAdhesion(actuator, gain);
}

pub fn addMesh(s: *c.mjSpec, def: ?*const c.mjsDefault) ?*c.mjsMesh {
    return c.mjs_addMesh(s, def);
}

pub fn addHField(s: *c.mjSpec) ?*c.mjsHField {
    return c.mjs_addHField(s);
}

pub fn addSkin(s: *c.mjSpec) ?*c.mjsSkin {
    return c.mjs_addSkin(s);
}

pub fn addTexture(s: *c.mjSpec) ?*c.mjsTexture {
    return c.mjs_addTexture(s);
}

pub fn addMaterial(s: *c.mjSpec, def: ?*const c.mjsDefault) ?*c.mjsMaterial {
    return c.mjs_addMaterial(s, def);
}

pub fn makeMesh(mesh: *c.mjsMesh, builtin: c_int, params: [*]f64, nparams: c_int) c_int {
    return c.mjs_makeMesh(mesh, builtin, params, nparams);
}

pub fn getSpec(element: *c.mjsElement) ?*c.mjSpec {
    return c.mjs_getSpec(element);
}

pub fn findSpec(spec: *c.mjSpec, name: [*:0]const u8) ?*c.mjSpec {
    return c.mjs_findSpec(spec, name);
}

pub fn findBody(s: *c.mjSpec, name: [*:0]const u8) ?*c.mjsBody {
    return c.mjs_findBody(s, name);
}

pub fn findElement(s: *c.mjSpec, obj_type: c_int, name: [*:0]const u8) ?*c.mjsElement {
    return c.mjs_findElement(s, obj_type, name);
}

pub fn findChild(body: *c.mjsBody, name: [*:0]const u8) ?*c.mjsBody {
    return c.mjs_findChild(body, name);
}

pub fn getParent(element: *c.mjsElement) ?*c.mjsBody {
    return c.mjs_getParent(element);
}

pub fn getFrame(element: *c.mjsElement) ?*c.mjsFrame {
    return c.mjs_getFrame(element);
}

pub fn findFrame(s: *c.mjSpec, name: [*:0]const u8) ?*c.mjsFrame {
    return c.mjs_findFrame(s, name);
}

pub fn getDefault(element: *c.mjsElement) ?*c.mjsDefault {
    return c.mjs_getDefault(element);
}

pub fn findDefault(s: *c.mjSpec, classname: [*:0]const u8) ?*c.mjsDefault {
    return c.mjs_findDefault(s, classname);
}

pub fn getSpecDefault(s: *c.mjSpec) ?*c.mjsDefault {
    return c.mjs_getSpecDefault(s);
}

pub fn getId(element: *c.mjsElement) c_int {
    return c.mjs_getId(element);
}

pub fn firstChild(body: *c.mjsBody, obj_type: c_int, recurse: c_int) ?*c.mjsElement {
    return c.mjs_firstChild(body, obj_type, recurse);
}

pub fn nextChild(body: *c.mjsBody, child: *c.mjsElement, recurse: c_int) ?*c.mjsElement {
    return c.mjs_nextChild(body, child, recurse);
}

pub fn firstElement(s: *c.mjSpec, obj_type: c_int) ?*c.mjsElement {
    return c.mjs_firstElement(s, obj_type);
}

pub fn nextElement(s: *c.mjSpec, element: *c.mjsElement) ?*c.mjsElement {
    return c.mjs_nextElement(s, element);
}

pub fn setName(element: *c.mjsElement, name: [*:0]const u8) c_int {
    return c.mjs_setName(element, name);
}

pub fn mjs_setBuffer(dest: *c.mjByteVec, array: *const anyopaque, size: c_int) void {
    c.mjs_setBuffer(dest, array, size);
}

pub fn setString(dest: *c.mjString, text_ptr: [*:0]const u8) void {
    c.mjs_setString(dest, text_ptr);
}

pub fn setStringVec(dest: *c.mjStringVec, text_ptr: [*:0]const u8) void {
    c.mjs_setStringVec(dest, text_ptr);
}

pub fn setInStringVec(dest: *c.mjStringVec, i: c_int, text_ptr: [*:0]const u8) u8 {
    return c.mjs_setInStringVec(dest, i, text_ptr);
}

pub fn appendString(dest: *c.mjStringVec, text_ptr: [*:0]const u8) void {
    c.mjs_appendString(dest, text_ptr);
}

pub fn setInt(dest: *c.mjIntVec, array: [*]const c_int, size: c_int) void {
    c.mjs_setInt(dest, array, size);
}

pub fn appendIntVec(dest: *c.mjIntVecVec, array: [*]const c_int, size: c_int) void {
    c.mjs_appendIntVec(dest, array, size);
}

pub fn setFloat(dest: *c.mjFloatVec, array: [*]const f32, size: c_int) void {
    c.mjs_setFloat(dest, array, size);
}

pub fn appendFloatVec(dest: *c.mjFloatVecVec, array: [*]const f32, size: c_int) void {
    c.mjs_appendFloatVec(dest, array, size);
}

pub fn setDouble(dest: *c.mjDoubleVec, array: [*]const f64, size: c_int) void {
    c.mjs_setDouble(dest, array, size);
}

pub fn setPluginAttributes(plugin: *c.mjsPlugin, attributes: ?*anyopaque) void {
    c.mjs_setPluginAttributes(plugin, attributes);
}

pub fn getName(element: *c.mjsElement) ?*c.mjString {
    return c.mjs_getName(element);
}

pub fn getString(source: *const c.mjString) ?[*:0]const u8 {
    return c.mjs_getString(source);
}

pub fn getDouble(source: *const c.mjDoubleVec, size: ?[*]c_int) [*]const f64 {
    return c.mjs_getDouble(source, size);
}

pub fn getInt(source: *const c.mjIntVec, size: ?[*]c_int) [*]const c_int {
    return c.mjs_getInt(source, size);
}

pub fn getBuffer(source: *const c.mjByteVec, size: ?[*]c_int) [*]const u8 {
    return c.mjs_getBuffer(source, size);
}

pub fn getPluginAttributes(plugin: *const c.mjsPlugin) ?*const anyopaque {
    return c.mjs_getPluginAttributes(plugin);
}

pub fn setDefault(element: *c.mjsElement, def: *const c.mjsDefault) void {
    c.mjs_setDefault(element, def);
}

pub fn setFrame(dest: *c.mjsElement, frame: *c.mjsFrame) c_int {
    return c.mjs_setFrame(dest, frame);
}

pub fn resolveOrientation(quat: [*]f64, degree: u8, sequence: ?[*:0]const u8, orientation: *const c.mjsOrientation) ?[*:0]const u8 {
    return c.mjs_resolveOrientation(quat, degree, sequence, orientation);
}

pub fn bodyToFrame(body: [*c]*c.mjsBody) ?*c.mjsFrame {
    return c.mjs_bodyToFrame(body);
}

pub fn setUserValue(element: *c.mjsElement, key: [*:0]const u8, data: *const anyopaque) void {
    c.mjs_setUserValue(element, key, data);
}

pub fn setUserValueWithCleanup(element: *c.mjsElement, key: [*:0]const u8, data: *const anyopaque, cleanup: ?*const fn (*const anyopaque) callconv(.C) void) void {
    c.mjs_setUserValueWithCleanup(element, key, data, cleanup);
}

pub fn getUserValue(element: *c.mjsElement, key: [*:0]const u8) ?*const anyopaque {
    return c.mjs_getUserValue(element, key);
}

pub fn deleteUserValue(element: *c.mjsElement, key: [*:0]const u8) void {
    c.mjs_deleteUserValue(element, key);
}

pub fn sensorDim(sensor: *const c.mjsSensor) c_int {
    return c.mjs_sensorDim(sensor);
}

pub fn defaultSpec(spec: *c.mjSpec) void {
    c.mjs_defaultSpec(spec);
}

pub fn defaultOrientation(orient: *c.mjsOrientation) void {
    c.mjs_defaultOrientation(orient);
}

pub fn defaultBody(body: *c.mjsBody) void {
    c.mjs_defaultBody(body);
}

pub fn defaultFrame(frame: *c.mjsFrame) void {
    c.mjs_defaultFrame(frame);
}

pub fn defaultJoint(joint: *c.mjsJoint) void {
    c.mjs_defaultJoint(joint);
}

pub fn defaultGeom(geom: *c.mjsGeom) void {
    c.mjs_defaultGeom(geom);
}

pub fn defaultSite(site: *c.mjsSite) void {
    c.mjs_defaultSite(site);
}

pub fn defaultCam(camera: *c.mjsCamera) void {
    c.mjs_defaultCamera(camera);
}

pub fn defaultLight(light: *c.mjsLight) void {
    c.mjs_defaultLight(light);
}

pub fn defaultFlex(flex_ptr: *c.mjsFlex) void {
    c.mjs_defaultFlex(flex_ptr);
}

pub fn defaultMesh(mesh: *c.mjsMesh) void {
    c.mjs_defaultMesh(mesh);
}

pub fn defaultHField(hfield: *c.mjsHField) void {
    c.mjs_defaultHField(hfield);
}

pub fn defaultSkin(skin: *c.mjsSkin) void {
    c.mjs_defaultSkin(skin);
}

pub fn defaultTexture(texture: *c.mjsTexture) void {
    c.mjs_defaultTexture(texture);
}

pub fn defaultMaterial(material: *c.mjsMaterial) void {
    c.mjs_defaultMaterial(material);
}

pub fn defaultPair(pair: *c.mjsPair) void {
    c.mjs_defaultPair(pair);
}

pub fn defaultEquality(equality: *c.mjsEquality) void {
    c.mjs_defaultEquality(equality);
}

pub fn defaultTendon(tendon_ptr: *c.mjsTendon) void {
    c.mjs_defaultTendon(tendon_ptr);
}

pub fn defaultActuator(actuator: *c.mjsActuator) void {
    c.mjs_defaultActuator(actuator);
}

pub fn defaultSensor(sensor: *c.mjsSensor) void {
    c.mjs_defaultSensor(sensor);
}

pub fn defaultNumeric(numeric: *c.mjsNumeric) void {
    c.mjs_defaultNumeric(numeric);
}

pub fn defaultText(text_ptr: *c.mjsText) void {
    c.mjs_defaultText(text_ptr);
}

pub fn defaultTuple(tuple: *c.mjsTuple) void {
    c.mjs_defaultTuple(tuple);
}

pub fn defaultKey(key: *c.mjsKey) void {
    c.mjs_defaultKey(key);
}

pub fn defaultSpecPlugin(plugin: *c.mjsPlugin) void {
    c.mjs_defaultPlugin(plugin);
}

pub fn asBody(element: *c.mjsElement) ?*c.mjsBody {
    return c.mjs_asBody(element);
}

pub fn asGeom(element: *c.mjsElement) ?*c.mjsGeom {
    return c.mjs_asGeom(element);
}

pub fn asJoint(element: *c.mjsElement) ?*c.mjsJoint {
    return c.mjs_asJoint(element);
}

pub fn asSite(element: *c.mjsElement) ?*c.mjsSite {
    return c.mjs_asSite(element);
}

pub fn asCamera(element: *c.mjsElement) ?*c.mjsCamera {
    return c.mjs_asCamera(element);
}

pub fn asLight(element: *c.mjsElement) ?*c.mjsLight {
    return c.mjs_asLight(element);
}

pub fn asFrame(element: *c.mjsElement) ?*c.mjsFrame {
    return c.mjs_asFrame(element);
}

pub fn asActuator(element: *c.mjsElement) ?*c.mjsActuator {
    return c.mjs_asActuator(element);
}

pub fn asSensor(element: *c.mjsElement) ?*c.mjsSensor {
    return c.mjs_asSensor(element);
}

pub fn asFlex(element: *c.mjsElement) ?*c.mjsFlex {
    return c.mjs_asFlex(element);
}

pub fn asPair(element: *c.mjsElement) ?*c.mjsPair {
    return c.mjs_asPair(element);
}

pub fn asEquality(element: *c.mjsElement) ?*c.mjsEquality {
    return c.mjs_asEquality(element);
}

pub fn asExclude(element: *c.mjsElement) ?*c.mjsExclude {
    return c.mjs_asExclude(element);
}

pub fn asTendon(element: *c.mjsElement) ?*c.mjsTendon {
    return c.mjs_asTendon(element);
}

pub fn asNumeric(element: *c.mjsElement) ?*c.mjsNumeric {
    return c.mjs_asNumeric(element);
}

pub fn asText(element: *c.mjsElement) ?*c.mjsText {
    return c.mjs_asText(element);
}

pub fn asTuple(element: *c.mjsElement) ?*c.mjsTuple {
    return c.mjs_asTuple(element);
}

pub fn asKey(element: *c.mjsElement) ?*c.mjsKey {
    return c.mjs_asKey(element);
}

pub fn asMesh(element: *c.mjsElement) ?*c.mjsMesh {
    return c.mjs_asMesh(element);
}

pub fn asHField(element: *c.mjsElement) ?*c.mjsHField {
    return c.mjs_asHField(element);
}

pub fn asSkin(element: *c.mjsElement) ?*c.mjsSkin {
    return c.mjs_asSkin(element);
}

pub fn asTexture(element: *c.mjsElement) ?*c.mjsTexture {
    return c.mjs_asTexture(element);
}

pub fn asMaterial(element: *c.mjsElement) ?*c.mjsMaterial {
    return c.mjs_asMaterial(element);
}

pub fn asPlugin(element: *c.mjsElement) ?*c.mjsPlugin {
    return c.mjs_asPlugin(element);
}

pub const MjfGeneric = *const fn (*const c.mjModel, *c.mjData) void;
pub const MjfConFilt = *const fn (*const c.mjModel, *c.mjData, c_int, c_int) c_int;
pub const MjfSensor = *const fn (*const c.mjModel, *c.mjData, c_int) void;
pub const MjfTime = *const fn () mjtNum;
pub const MjfAct = *const fn (*const c.mjModel, *const c.mjData, c_int) mjtNum;

pub fn setPassiveCallback(callback: ?MjfGeneric) void {
    c.mjcb_passive = callback;
}

pub fn setControlCallback(callback: ?MjfGeneric) void {
    c.mjcb_control = callback;
}

pub fn setContactFilterCallback(callback: ?MjfConFilt) void {
    c.mjcb_contactfilter = callback;
}

pub fn setSensorCallback(callback: ?MjfSensor) void {
    c.mjcb_sensor = callback;
}

pub fn setTimeCallback(callback: ?MjfTime) void {
    c.mjcb_time = callback;
}

pub fn setActDynCallback(callback: ?MjfAct) void {
    c.mjcb_act_dyn = callback;
}

pub fn setActGainCallback(callback: ?MjfAct) void {
    c.mjcb_act_gain = callback;
}

pub fn setActBiasCallback(callback: ?MjfAct) void {
    c.mjcb_act_bias = callback;
}

pub fn activatePlugin(s: *c.mjSpec, name: [*:0]const u8) c_int {
    return c.mjs_activatePlugin(s, name);
}

pub fn setDeepCopy(s: *c.mjSpec, deepcopy: c_int) c_int {
    return c.mjs_setDeepCopy(s, deepcopy);
}

pub fn resetCallbacks() void {
    c.mj_resetCallbacks();
}

pub fn getSDF(m: *const c.mjModel, id: c_int) ?*const c.mjpPlugin {
    return c.mjc_getSDF(m, id);
}

pub fn distance(m: *const c.mjModel, d: *const c.mjData, s: *const c.mjSDF, x: [*]const mjtNum) mjtNum {
    return c.mjc_distance(m, d, s, x);
}

pub fn gradient(m: *const c.mjModel, d: *const c.mjData, s: *const c.mjSDF, grad: [*]mjtNum, x: [*]const mjtNum) void {
    c.mjc_gradient(m, d, s, grad, x);
}

// MATH
//
//
pub fn normalize3(vec: *[3]mjtNum) mjtNum {
    return c.mju_normalize3(vec);
}

pub fn norm3(vec: [3]mjtNum) mjtNum {
    return c.mju_norm3(&vec);
}

pub fn dot3(vec1: [3]mjtNum, vec2: [3]mjtNum) mjtNum {
    return c.mju_dot3(&vec1, &vec2);
}

pub fn cross(res: *[3]mjtNum, a: [3]mjtNum, b: [3]mjtNum) void {
    c.mju_cross(res, &a, &b);
}

pub fn zero3(res: *[3]mjtNum) void {
    c.mju_zero3(res);
}

pub fn copy3(res: *[3]mjtNum, data: [3]mjtNum) void {
    c.mju_copy3(res, &data);
}

pub fn scl3(res: *[3]mjtNum, vec: [3]mjtNum, scalar_value: mjtNum) void {
    c.mju_scl3(res, &vec, scalar_value);
}

pub fn add3(res: *[3]mjtNum, vec1: [3]mjtNum, vec2: [3]mjtNum) void {
    c.mju_add3(res, &vec1, &vec2);
}

pub fn sub3(res: *[3]mjtNum, vec1: [3]mjtNum, vec2: [3]mjtNum) void {
    c.mju_sub3(res, &vec1, &vec2);
}

pub fn addTo3(res: *[3]mjtNum, vec: [3]mjtNum) void {
    c.mju_addTo3(res, &vec);
}

pub fn subFrom3(res: *[3]mjtNum, vec: [3]mjtNum) void {
    c.mju_subFrom3(res, &vec);
}

pub fn addToScl3(res: *[3]mjtNum, vec: [3]mjtNum, scalar_value: mjtNum) void {
    c.mju_addToScl3(res, &vec, scalar_value);
}

pub fn addScl3(res: *[3]mjtNum, vec1: [3]mjtNum, vec2: [3]mjtNum, scalar_value: mjtNum) void {
    c.mju_addScl3(res, &vec1, &vec2, scalar_value);
}

pub fn norm(res: []const mjtNum, n: c_int) mjtNum {
    return c.mju_norm(res.ptr, n);
}

pub fn normalize(res: []mjtNum, n: c_int) mjtNum {
    return c.mju_normalize(res.ptr, n);
}

pub fn dot(vec1: []const mjtNum, vec2: []const mjtNum, n: c_int) mjtNum {
    return c.mju_dot(vec1.ptr, vec2.ptr, n);
}

pub fn zero(res: []mjtNum, n: c_int) void {
    c.mju_zero(res.ptr, n);
}

pub fn fill(res: []mjtNum, val: mjtNum, n: c_int) void {
    c.mju_fill(res.ptr, val, n);
}

pub fn copy(res: []mjtNum, vec: []const mjtNum, n: c_int) void {
    c.mju_copy(res.ptr, vec.ptr, n);
}

pub fn sum(vec: []const mjtNum, n: c_int) mjtNum {
    return c.mju_sum(vec.ptr, n);
}

pub fn L1(vec: []const mjtNum, n: c_int) mjtNum {
    return c.mju_L1(vec.ptr, n);
}

pub fn scl(res: []mjtNum, vec: []const mjtNum, scalar_value: mjtNum, n: c_int) void {
    c.mju_scl(res.ptr, vec.ptr, scalar_value, n);
}

pub fn add(res: []mjtNum, vec1: []const mjtNum, vec2: []const mjtNum, n: c_int) void {
    c.mju_add(res.ptr, vec1.ptr, vec2.ptr, n);
}

pub fn sub(res: []mjtNum, vec1: []const mjtNum, vec2: []const mjtNum, n: c_int) void {
    c.mju_sub(res.ptr, vec1.ptr, vec2.ptr, n);
}

pub fn addTo(res: []mjtNum, vec: []const mjtNum, n: c_int) void {
    c.mju_addTo(res.ptr, vec.ptr, n);
}

pub fn subFrom(res: []mjtNum, vec: []const mjtNum, n: c_int) void {
    c.mju_subFrom(res.ptr, vec.ptr, n);
}

pub fn addToScl(res: []mjtNum, vec: []const mjtNum, scalar_value: mjtNum, n: c_int) void {
    c.mju_addToScl(res.ptr, vec.ptr, scalar_value, n);
}

pub fn addScl(res: []mjtNum, vec1: []const mjtNum, vec2: []const mjtNum, scalar_value: mjtNum, n: c_int) void {
    c.mju_addScl(res.ptr, vec1.ptr, vec2.ptr, scalar_value, n);
}

pub fn mulMatVec(res: []mjtNum, mat: []const mjtNum, vec: []const mjtNum, nr: c_int, nc: c_int) void {
    c.mju_mulMatVec(res.ptr, mat.ptr, vec.ptr, nr, nc);
}

pub fn mulMatTVec(res: []mjtNum, mat: []const mjtNum, vec: []const mjtNum, nr: c_int, nc: c_int) void {
    c.mju_mulMatTVec(res.ptr, mat.ptr, vec.ptr, nr, nc);
}

pub fn mulMatMat(res: []mjtNum, mat1: []const mjtNum, mat2: []const mjtNum, r1: c_int, c1: c_int, c2: c_int) void {
    c.mju_mulMatMat(res.ptr, mat1.ptr, mat2.ptr, r1, c1, c2);
}

pub fn mulMatMatT(res: []mjtNum, mat1: []const mjtNum, mat2: []const mjtNum, r1: c_int, c1: c_int, r2: c_int) void {
    c.mju_mulMatMatT(res.ptr, mat1.ptr, mat2.ptr, r1, c1, r2);
}

pub fn mulMatTMat(res: []mjtNum, mat1: []const mjtNum, mat2: []const mjtNum, r1: c_int, c1: c_int, c2: c_int) void {
    c.mju_mulMatTMat(res.ptr, mat1.ptr, mat2.ptr, r1, c1, c2);
}

pub fn transpose(res: []mjtNum, mat: []const mjtNum, nr: c_int, nc: c_int) void {
    c.mju_transpose(res.ptr, mat.ptr, nr, nc);
}

pub fn symmetrize(res: []mjtNum, mat: []const mjtNum, n: c_int) void {
    c.mju_symmetrize(res.ptr, mat.ptr, n);
}

pub fn eye(mat: []mjtNum, n: c_int) void {
    c.mju_eye(mat.ptr, n);
}

pub fn sqrMatTD(res: []mjtNum, mat: []const mjtNum, diag: []const mjtNum, nr: c_int, nc: c_int) void {
    c.mju_sqrMatTD(res.ptr, mat.ptr, diag.ptr, nr, nc);
}

pub fn transformSpatial(res: *[6]mjtNum, vec: [6]mjtNum, flg_force: c_int, newpos: [3]mjtNum, oldpos: [3]mjtNum, rotnew2old: ?*[9]mjtNum) void {
    c.mju_transformSpatial(res, &vec, flg_force, &newpos, &oldpos, if (rotnew2old) |p| p else null);
}

pub fn mulVecMatVec(vec1: []const mjtNum, mat: []const mjtNum, vec2: []const mjtNum, n: c_int) mjtNum {
    return c.mju_mulVecMatVec(vec1.ptr, mat.ptr, vec2.ptr, n);
}

//---------------------------------- Sparse math ---------------------------------------------------

pub fn dense2sparse(res: []mjtNum, mat: []const mjtNum, nr: c_int, nc: c_int, rownnz: []c_int, rowadr: []c_int, colind: []c_int, nnz: c_int) c_int {
    return c.mju_dense2sparse(res.ptr, mat.ptr, nr, nc, rownnz.ptr, rowadr.ptr, colind.ptr, nnz);
}

pub fn sparse2dense(res: []mjtNum, mat: []const mjtNum, nr: c_int, nc: c_int, rownnz: []const c_int, rowadr: []const c_int, colind: []const c_int) void {
    c.mju_sparse2dense(res.ptr, mat.ptr, nr, nc, rownnz.ptr, rowadr.ptr, colind.ptr);
}

pub fn mulMatVec3(res: *[3]mjtNum, mat: [9]mjtNum, vec: [3]mjtNum) void {
    c.mju_mulMatVec3(res, &mat, &vec);
}

pub fn mulMatTVec3(res: *[3]mjtNum, mat: [9]mjtNum, vec: [3]mjtNum) void {
    c.mju_mulMatTVec3(res, &mat, &vec);
}

pub fn dist3(pos1: [3]mjtNum, pos2: [3]mjtNum) mjtNum {
    return c.mju_dist3(&pos1, &pos2);
}

pub fn zero4(res: *[4]mjtNum) void {
    c.mju_zero4(res);
}

pub fn unit4(res: *[4]mjtNum) void {
    c.mju_unit4(res);
}

pub fn copy4(res: *[4]mjtNum, data: [4]mjtNum) void {
    c.mju_copy4(res, &data);
}

pub fn normalize4(vec: *[4]mjtNum) mjtNum {
    return c.mju_normalize4(vec);
}

pub fn rotVecQuat(res: *[3]mjtNum, vec: [3]mjtNum, quat: [4]mjtNum) void {
    c.mju_rotVecQuat(res, &vec, &quat);
}

pub fn negQuat(res: *[4]mjtNum, quat: [4]mjtNum) void {
    c.mju_negQuat(res, &quat);
}

pub fn mulQuat(res: *[4]mjtNum, quat1: [4]mjtNum, quat2: [4]mjtNum) void {
    c.mju_mulQuat(res, &quat1, &quat2);
}

pub fn mulQuatAxis(res: *[4]mjtNum, quat: [4]mjtNum, axis: [3]mjtNum) void {
    c.mju_mulQuatAxis(res, &quat, &axis);
}

pub fn axisAngle2Quat(res: *[4]mjtNum, axis: [3]mjtNum, angle: mjtNum) void {
    c.mju_axisAngle2Quat(res, &axis, angle);
}

pub fn quat2Vel(res: *[3]mjtNum, quat: [4]mjtNum, dt: mjtNum) void {
    c.mju_quat2Vel(res, &quat, dt);
}

pub fn subQuat(res: *[3]mjtNum, qa: [4]mjtNum, qb: [4]mjtNum) void {
    c.mju_subQuat(res, &qa, &qb);
}

pub fn quat2Mat(res: *[9]mjtNum, quat: [4]mjtNum) void {
    c.mju_quat2Mat(res, &quat);
}

pub fn mat2Quat(quat: *[4]mjtNum, mat: [9]mjtNum) void {
    c.mju_mat2Quat(quat, &mat);
}

pub fn derivQuat(res: *[4]mjtNum, quat: [4]mjtNum, vel: [3]mjtNum) void {
    c.mju_derivQuat(res, &quat, &vel);
}

pub fn quatIntegrate(quat: *[4]mjtNum, vel: [3]mjtNum, scale: mjtNum) void {
    c.mju_quatIntegrate(quat, &vel, scale);
}

pub fn quatZ2Vec(quat: *[4]mjtNum, vec: [3]mjtNum) void {
    c.mju_quatZ2Vec(quat, &vec);
}

pub fn mat2Rot(quat: *[4]mjtNum, mat: [9]mjtNum) c_int {
    return c.mju_mat2Rot(quat, &mat);
}

pub fn euler2Quat(quat: *[4]mjtNum, euler: [3]mjtNum, seq: [*:0]const u8) void {
    c.mju_euler2Quat(quat, &euler, seq);
}

pub fn mulPose(posres: *[3]mjtNum, quatres: *[4]mjtNum, pos1: [3]mjtNum, quat1: [4]mjtNum, pos2: [3]mjtNum, quat2: [4]mjtNum) void {
    c.mju_mulPose(posres, quatres, &pos1, &quat1, &pos2, &quat2);
}

pub fn negPose(posres: *[3]mjtNum, quatres: *[4]mjtNum, pos: [3]mjtNum, quat: [4]mjtNum) void {
    c.mju_negPose(posres, quatres, &pos, &quat);
}

pub fn trnVecPose(res: *[3]mjtNum, pos: [3]mjtNum, quat: [4]mjtNum, vec: [3]mjtNum) void {
    c.mju_trnVecPose(res, &pos, &quat, &vec);
}

pub fn cholFactor(mat: []mjtNum, n: c_int, mindiag: mjtNum) c_int {
    return c.mju_cholFactor(mat.ptr, n, mindiag);
}

pub fn cholSolve(res: []mjtNum, mat: []const mjtNum, vec: []const mjtNum, n: c_int) void {
    c.mju_cholSolve(res.ptr, mat.ptr, vec.ptr, n);
}

pub fn cholUpdate(mat: []mjtNum, x: []mjtNum, n: c_int, flg_plus: c_int) c_int {
    return c.mju_cholUpdate(mat.ptr, x.ptr, n, flg_plus);
}

pub fn cholFactorBand(mat: []mjtNum, ntotal: c_int, nband: c_int, ndense: c_int, diagadd: mjtNum, diagmul: mjtNum) mjtNum {
    return c.mju_cholFactorBand(mat.ptr, ntotal, nband, ndense, diagadd, diagmul);
}

pub fn cholSolveBand(res: []mjtNum, mat: []const mjtNum, vec: []const mjtNum, ntotal: c_int, nband: c_int, ndense: c_int) void {
    c.mju_cholSolveBand(res.ptr, mat.ptr, vec.ptr, ntotal, nband, ndense);
}

pub fn band2Dense(res: []mjtNum, mat: []const mjtNum, ntotal: c_int, nband: c_int, ndense: c_int, flg_sym: u8) void {
    c.mju_band2Dense(res.ptr, mat.ptr, ntotal, nband, ndense, flg_sym);
}

pub fn dense2Band(res: []mjtNum, mat: []const mjtNum, ntotal: c_int, nband: c_int, ndense: c_int) void {
    c.mju_dense2Band(res.ptr, mat.ptr, ntotal, nband, ndense);
}

pub fn bandMulMatVec(res: []mjtNum, mat: []const mjtNum, vec: []const mjtNum, ntotal: c_int, nband: c_int, ndense: c_int, nvec: c_int, flg_sym: u8) void {
    c.mju_bandMulMatVec(res.ptr, mat.ptr, vec.ptr, ntotal, nband, ndense, nvec, flg_sym);
}

pub fn bandDiag(i: c_int, ntotal: c_int, nband: c_int, ndense: c_int) c_int {
    return c.mju_bandDiag(i, ntotal, nband, ndense);
}

pub fn eig3(eigval: *[3]mjtNum, eigvec: *[9]mjtNum, quat: *[4]mjtNum, mat: [9]mjtNum) c_int {
    return c.mju_eig3(eigval, eigvec, quat, &mat);
}

pub fn boxQP(res: []mjtNum, R: []mjtNum, index: ?[]c_int, H: []const mjtNum, g: []const mjtNum, n: c_int, lower: ?[]const mjtNum, upper: ?[]const mjtNum) c_int {
    return c.mju_boxQP(res.ptr, R.ptr, if (index) |p| p.ptr else null, H.ptr, g.ptr, n, if (lower) |p| p.ptr else null, if (upper) |p| p.ptr else null);
}

pub fn boxQPmalloc(res: [*c][*c]mjtNum, R: [*c][*c]mjtNum, index: [*c][*c]c_int, H: [*c][*c]mjtNum, g: [*c][*c]mjtNum, n: c_int, lower: [*c][*c]mjtNum, upper: [*c][*c]mjtNum) void {
    c.mju_boxQPmalloc(res, R, if (index) |p| p else null, H, g, n, if (lower) |p| p else null, if (upper) |p| p else null);
}

pub const mju_error = c.mju_error;
pub const mju_warning = c.mju_warning;
pub const mju_clearHandlers = c.mju_clearHandlers;
pub const mju_malloc = c.mju_malloc;
pub const mju_free = c.mju_free;

pub fn warning(d: *c.mjData, warning_code: c_int, info: c_int) void {
    c.mj_warning(d, warning_code, info);
}

pub fn mjs_getError(s: *c.mjSpec) ?[*:0]const u8 {
    return c.mjs_getError(s);
}

pub fn isWarning(s: *c.mjSpec) c_int {
    return c.mjs_isWarning(s);
}

pub const mju_writeLog = c.mju_writeLog;

//---------------------------------- Miscellaneous -------------------------------------------------

pub fn muscleGain(len: mjtNum, vel: mjtNum, lengthrange: [2]mjtNum, acc0: mjtNum, prm: [9]mjtNum) mjtNum {
    return c.mju_muscleGain(len, vel, &lengthrange, acc0, &prm);
}

pub fn muscleBias(len: mjtNum, lengthrange: [2]mjtNum, acc0: mjtNum, prm: [9]mjtNum) mjtNum {
    return c.mju_muscleBias(len, &lengthrange, acc0, &prm);
}

pub fn muscleDynamics(ctrl: mjtNum, act: mjtNum, prm: [3]mjtNum) mjtNum {
    return c.mju_muscleDynamics(ctrl, act, &prm);
}

pub fn encodePyramid(pyramid: []mjtNum, force: []const mjtNum, mu: []const mjtNum, dim: c_int) void {
    c.mju_encodePyramid(pyramid.ptr, force.ptr, mu.ptr, dim);
}

pub fn decodePyramid(force: []mjtNum, pyramid: []const mjtNum, mu: []const mjtNum, dim: c_int) void {
    c.mju_decodePyramid(force.ptr, pyramid.ptr, mu.ptr, dim);
}

pub fn springDamper(pos0: mjtNum, vel0: mjtNum, Kp: mjtNum, Kv: mjtNum, dt: mjtNum) mjtNum {
    return c.mju_springDamper(pos0, vel0, Kp, Kv, dt);
}

pub fn min(a: mjtNum, b: mjtNum) mjtNum {
    return c.mju_min(a, b);
}

pub fn max(a: mjtNum, b: mjtNum) mjtNum {
    return c.mju_max(a, b);
}

pub fn clip(x: mjtNum, min_val: mjtNum, max_val: mjtNum) mjtNum {
    return c.mju_clip(x, min_val, max_val);
}

pub fn sign(x: mjtNum) mjtNum {
    return c.mju_sign(x);
}

pub fn round(x: mjtNum) c_int {
    return c.mju_round(x);
}

pub fn type2Str(t: c_int) ?[*:0]const u8 {
    return c.mju_type2Str(t);
}

pub fn str2Type(str: [*:0]const u8) c_int {
    return c.mju_str2Type(str);
}

pub fn writeNumBytes(nbytes: usize) ?[*:0]const u8 {
    return c.mju_writeNumBytes(nbytes);
}

pub fn warningText(warning_code: c_int, info: usize) ?[*:0]const u8 {
    return c.mju_warningText(warning_code, info);
}

pub fn isBad(x: mjtNum) c_int {
    return c.mju_isBad(x);
}

pub fn isZero(vec: []const mjtNum, n: c_int) c_int {
    return c.mju_isZero(vec.ptr, n);
}

pub fn standardNormal(num2: ?*mjtNum) mjtNum {
    return c.mju_standardNormal(num2);
}

pub fn f2n(res: []mjtNum, vec: []const f32, n: c_int) void {
    c.mju_f2n(res.ptr, vec.ptr, n);
}

pub fn n2f(res: []f32, vec: []const mjtNum, n: c_int) void {
    c.mju_n2f(res.ptr, vec.ptr, n);
}

pub fn d2n(res: []mjtNum, vec: []const f64, n: c_int) void {
    c.mju_d2n(res.ptr, vec.ptr, n);
}

pub fn n2d(res: []f64, vec: []const mjtNum, n: c_int) void {
    c.mju_n2d(res.ptr, vec.ptr, n);
}

pub fn insertionSort(list: []mjtNum, n: c_int) void {
    c.mju_insertionSort(list.ptr, n);
}

pub fn insertionSortInt(list: []c_int, n: c_int) void {
    c.mju_insertionSortInt(list.ptr, n);
}

pub fn Halton(index: c_int, base: c_int) mjtNum {
    return c.mju_Halton(index, base);
}

pub fn strncpy(dst: []u8, src: [*:0]const u8, n: c_int) [*:0]u8 {
    return c.mju_strncpy(dst.ptr, src, n);
}

pub fn sigmoid(x: mjtNum) mjtNum {
    return c.mju_sigmoid(x);
}

pub fn transitionFD(m: *const c.mjModel, d: *c.mjData, eps: mjtNum, flg_centered: u8, A: ?[*]mjtNum, B: ?[*]mjtNum, C: ?[*]mjtNum, D: ?[*]mjtNum) void {
    c.mjd_transitionFD(m, d, eps, flg_centered, A, B, C, D);
}

pub fn inverseFD(m: *const c.mjModel, d: *c.mjData, eps: mjtNum, flg_actuation: u8, DfDq: ?[*]mjtNum, DfDv: ?[*]mjtNum, DfDa: ?[*]mjtNum, DsDq: ?[*]mjtNum, DsDv: ?[*]mjtNum, DsDa: ?[*]mjtNum, DmDq: ?[*]mjtNum) void {
    c.mjd_inverseFD(m, d, eps, flg_actuation, DfDq, DfDv, DfDa, DsDq, DsDv, DsDa, DmDq);
}

pub fn subQuatDerivatives(qa: [*]const mjtNum, qb: [*]const mjtNum, Da: ?[*]mjtNum, Db: ?[*]mjtNum) void {
    c.mjd_subQuat(qa, qb, Da, Db);
}

pub fn quatIntegrateDerivatives(vel: [*]const mjtNum, scale: mjtNum, Dquat: ?[*]mjtNum, Dvel: ?[*]mjtNum, Dscale: ?[*]mjtNum) void {
    c.mjd_quatIntegrate(vel, scale, Dquat, Dvel, Dscale);
}

pub fn defaultPlugin(plugin: *c.mjpPlugin) void {
    c.mjp_defaultPlugin(plugin);
}

pub fn registerPlugin(plugin: *const c.mjpPlugin) c_int {
    return c.mjp_registerPlugin(plugin);
}

pub fn pluginCount() c_int {
    return c.mjp_pluginCount();
}

pub fn getPlugin(name: [*:0]const u8, slot: ?[*]c_int) ?*const c.mjpPlugin {
    return c.mjp_getPlugin(name, slot);
}

pub fn getPluginAtSlot(slot: c_int) ?*const c.mjpPlugin {
    return c.mjp_getPluginAtSlot(slot);
}

pub fn defaultResourceProvider(provider: *c.mjpResourceProvider) void {
    c.mjp_defaultResourceProvider(provider);
}

pub fn registerResourceProvider(provider: *const c.mjpResourceProvider) c_int {
    return c.mjp_registerResourceProvider(provider);
}

pub fn resourceProviderCount() c_int {
    return c.mjp_resourceProviderCount();
}

pub fn getResourceProvider(resource_name: [*:0]const u8) ?*const c.mjpResourceProvider {
    return c.mjp_getResourceProvider(resource_name);
}

pub fn getResourceProviderAtSlot(slot: c_int) ?*const c.mjpResourceProvider {
    return c.mjp_getResourceProviderAtSlot(slot);
}

pub fn threadPoolCreate(number_of_threads: usize) ?*c.mjThreadPool {
    return c.mju_threadPoolCreate(number_of_threads);
}

pub fn bindThreadPool(data: *c.mjData, thread_pool: ?*anyopaque) void {
    c.mju_bindThreadPool(data, thread_pool);
}

pub fn threadPoolEnqueue(thread_pool: *c.mjThreadPool, task: *c.mjTask) void {
    c.mju_threadPoolEnqueue(thread_pool, task);
}

pub fn threadPoolDestroy(thread_pool: *c.mjThreadPool) void {
    c.mju_threadPoolDestroy(thread_pool);
}

pub fn defaultTask(task: *c.mjTask) void {
    c.mju_defaultTask(task);
}

pub fn taskJoin(task: *c.mjTask) void {
    c.mju_taskJoin(task);
}

pub fn printMat(mat: []const mjtNum, nr: c_int, nc: c_int) void {
    c.mju_printMat(mat.ptr, nr, nc);
}

pub fn printMatSparse(mat: []const mjtNum, nr: c_int, rownnz: []const c_int, rowadr: []const c_int, colind: []const c_int) void {
    c.mju_printMatSparse(mat.ptr, nr, rownnz.ptr, rowadr.ptr, colind.ptr);
}
