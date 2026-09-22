// ======================================================================
// scr_projectile_gravity.gml
// 投掷物重力模块
// 组合到需要抛物线效果的飞行物上
// ======================================================================

/// @description 初始化重力模块
/// @param {instance} _proj 飞行物实例
/// @param {real} _gravity 重力值（默认 0.15）
function scr_projectile_gravity_start(_proj, _gravity) {
    _proj.gravity = _gravity || 0.15;
    _proj.gravity_module = true;
}

/// @description 更新重力（由父对象 Step 调用）
/// @param {instance} _proj 飞行物实例
function scr_projectile_gravity_update(_proj) {
    if (_proj.gravity == undefined) return;
    
    _proj.speed += _proj.gravity;
    _proj.direction = point_direction(
        _proj.x, _proj.y,
        _proj.x + lengthdir_x(_proj.speed, _proj.direction),
        _proj.y + lengthdir_y(_proj.speed, _proj.direction)
    );
}