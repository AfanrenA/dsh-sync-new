/// @description 远程发射点 - 固定像素偏移（商业标准版）
/// 适用于：枪、弓等远程武器
/// 特点：发射点位置完全由数据表控制，不受翻转影响

// ============================================================
// 1. 安全检查
// ============================================================
if (!instance_exists(weapon_ref)) {
    instance_destroy();
    exit;
}

// ============================================================
// 2. 读取数据表
// ============================================================
var _data = data_weapon_get(weapon_ref.weapon_id);
if (_data == undefined) {
    x = weapon_ref.x;
    y = weapon_ref.y;
    exit;
}

// ============================================================
// 3. ★ 从数据表读取固定发射点偏移 ★
// ============================================================
// fire_point_x: 水平偏移（正=向右，负=向左）
// fire_point_y: 垂直偏移（正=向下，负=向上）
var _offset_x = 64;  // 默认值
var _offset_y = 0;   // 默认值

if (struct_exists(_data, "fire_point_x")) {
    _offset_x = _data.fire_point_x;
}
if (struct_exists(_data, "fire_point_y")) {
    _offset_y = _data.fire_point_y;
}

// ============================================================
// 4. ★ 根据翻转方向调整水平偏移 ★
// ============================================================
// 当武器朝左时，水平偏移取反，垂直偏移保持不变
var _flip = sign(weapon_ref.image_xscale);  // 1=朝右，-1=朝左

// ★ 关键：只有水平偏移受翻转影响 ★
var _final_x = _offset_x * _flip;   // 朝右时不变，朝左时取反
var _final_y = _offset_y;           // ★ 垂直偏移永远不变 ★

// ============================================================
// 5. ★ 计算最终发射点位置（使用 base_angle）★
// ============================================================
var _angle = weapon_ref.base_angle;

// 水平偏移（沿武器朝向方向）
x = weapon_ref.x + lengthdir_x(_final_x, _angle);
y = weapon_ref.y + lengthdir_y(_final_x, _angle);

// 垂直偏移（垂直于武器朝向方向）
var _perp_angle = _angle + 90;
x += lengthdir_x(_final_y, _perp_angle);
y += lengthdir_y(_final_y, _perp_angle);