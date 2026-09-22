// ======================================================================
// scr_hitbox_update.gml
// 更新碰撞盒位置
// 
// V3 架构：
//   hitbox 独立计算位置，不依赖 fire_point
//   每帧从武器位置 + 朝向 + swing_distance 重新计算
// ======================================================================

/// @description 更新碰撞盒位置到武器尖端
/// @param {instance} _hitbox 碰撞盒实例
function scr_hitbox_update(_hitbox) {
    if (!instance_exists(_hitbox)) return;
    if (!instance_exists(_hitbox.weapon_ref)) return;
    
    var _weapon = _hitbox.weapon_ref;
    
    // ===== ★★★ 独立计算尖端位置（不依赖 fire_point）★★★ =====
    var _dist = _weapon.swing_distance + 10;
    var _angle = _weapon.base_angle;
    
    _hitbox.x = _weapon.x + lengthdir_x(_dist, _angle);
    _hitbox.y = _weapon.y + lengthdir_y(_dist, _angle);
}