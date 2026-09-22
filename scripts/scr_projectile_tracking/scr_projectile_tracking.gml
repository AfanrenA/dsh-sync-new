// ======================================================================
// scr_projectile_tracking.gml
// 跟踪目标模块
// 组合到需要自动追踪的飞行物上
// ======================================================================

/// @description 初始化跟踪模块
/// @param {instance} _proj 飞行物实例
/// @param {instance} _target 跟踪目标
/// @param {real} _turn_speed 转向速度（默认 0.05）
function scr_projectile_tracking_start(_proj, _target, _turn_speed) {
    _proj.track_target = _target;
    _proj.track_speed = _turn_speed || 0.05;
    _proj.tracking_module = true;
}

/// @description 更新跟踪（由父对象 Step 调用）
/// @param {instance} _proj 飞行物实例
function scr_projectile_tracking_update(_proj) {
    if (!instance_exists(_proj.track_target)) return;
    
    var _target_angle = point_direction(
        _proj.x, _proj.y,
        _proj.track_target.x, _proj.track_target.y
    );
    
    // 平滑转向目标
    var _angle_diff = angle_difference(_target_angle, _proj.direction);
    _proj.direction += _angle_diff * _proj.track_speed;
}