// ======================================================================
// scr_weapon_swing.gml
// 近战挥砍动画（正弦摆动）
// 
// 商业化设计原则：
//   1. 参数从武器实例读取（数据缓存模式，高性能）
//   2. 带有保底默认值，即使数据异常也能正常运行
//   3. 打印警告日志，方便开发者发现数据错误
// ======================================================================

/// @description 执行近战挥砍动画
/// @param {instance} _weapon 武器实例（含 swing_total_frames 和 swing_angle_range）
/// @param {real} _swing_timer 当前计时器
/// @param {real} _base_angle 基础朝向
/// @param {bool} _facing_left 是否朝左
/// @returns {struct} { image_angle, new_swing_timer }
function scr_weapon_swing(_weapon, _swing_timer, _base_angle, _facing_left) {
    // ===== 1. 计时器归零则结束 =====
    if (_swing_timer <= 0) {
        return { image_angle: _base_angle, new_swing_timer: 0 };
    }
    
    // ===== 2. 读取参数（从实例变量） =====
    var total_frames = _weapon.swing_total_frames;
    var angle_range = _weapon.swing_angle_range;
    
    // ===== 3. 保底默认值（防止数据异常导致动画消失） =====
    if (total_frames <= 0) {
        log_warning("swing_total_frames 为 0，使用默认值 10");
        total_frames = 10;
    }
    if (angle_range == 0) {
        log_warning("swing_angle_range 为 0，使用默认值 60");
        angle_range = 60;
    }
    
    // ===== 4. 计算进度和摆动角度 =====
    var progress = (total_frames - _swing_timer) / total_frames;  // 0→1
    var swing_angle = angle_range * sin(progress * pi);          // 正弦波
    
    // ===== 5. 朝左时镜像 =====
    if (_facing_left) {
        swing_angle = -swing_angle;
    }
    
    // ===== 6. 返回结果 =====
    return {
        image_angle: _base_angle + swing_angle,
        new_swing_timer: _swing_timer - 1
    };
}