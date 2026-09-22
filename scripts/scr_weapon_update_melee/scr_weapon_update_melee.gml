// ======================================================================
// scr_weapon_update_melee.gml
// 近战武器动画驱动（可复用模块）
// ======================================================================

/// @description 驱动近战武器的挥砍动画
/// @param {instance} _weapon 武器实例

// ======================================================================
// 职责：
//   1. 计算挥砍角度（调用 scr_weapon_swing）
//   2. ★ 剑气生成已禁用 → 改用延迟剑气系统（scr_attack_melee 触发）
//   3. 挥砍结束重置状态
// ======================================================================

function scr_weapon_update_melee(_weapon) {
    
    // ============================================================
    // 1. 安全检查
    // ============================================================
    if (!_weapon.is_swinging) exit;
    
    if (!instance_exists(_weapon.owner)) {
        _weapon.is_swinging = false;
        _weapon.image_angle = _weapon.base_angle;
        exit;
    }
    
    // ============================================================
    // 2. 计算挥砍角度
    // ============================================================
    var _facing_left = (_weapon.image_yscale < 0);
    var _swing_result = scr_weapon_swing(
        _weapon,
        _weapon.swing_timer,
        _weapon.base_angle,
        _facing_left
    );
    _weapon.image_angle = _swing_result.image_angle;
    _weapon.swing_timer = _swing_result.new_swing_timer;
    
    // ============================================================
    // 3. ★ 剑气生成已禁用 ★
    // ============================================================
    // 原剑气逻辑在挥砍过程中触发，现改为延迟剑气系统
    // 剑气由 scr_attack_melee 触发，延迟1秒后从 fire_point 发射
    // 优点：剑气发射位置固定（fire_point），发射时间可控
    // 
    // 如需恢复原剑气逻辑，取消下方代码注释即可
    // ============================================================
    /*
    if (_weapon.swing_timer > 0 && _weapon.weapon_type == "melee") {
        var _total = _weapon.swing_total_frames;
        var _progress = (_total - _weapon.swing_timer) / _total;
        
        var _data = data_weapon_get(_weapon.weapon_id);
        if (_data != undefined && _data.slash_sprite != noone) {
            scr_weapon_slash(_weapon, _weapon.base_angle, _progress, _data, _weapon.owner);
        }
    }
    */
    
    // ============================================================
    // 4. 挥砍结束
    // ============================================================
    if (_weapon.swing_timer <= 0) {
        _weapon.is_swinging = false;
        _weapon.image_angle = _weapon.base_angle;
    }
}