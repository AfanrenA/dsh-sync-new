// scr_weapon_swing_update.gml
function scr_weapon_swing_update(weapon) {
    if (!weapon.is_swinging) return;
    
    if (weapon._swing_base_angle == undefined) {
        weapon._swing_base_angle = weapon.image_angle;
    }
    
    var _facing_left = (weapon.owner_id != noone && weapon.owner_id.facing_dir < 0);
    var _swing_offset = scr_weapon_swing(weapon, weapon.swing_timer, _facing_left);
    weapon.image_angle = weapon._swing_base_angle + _swing_offset;
    
    weapon.swing_timer -= 1;
    
    if (weapon.swing_timer <= 0) {
        weapon.is_swinging = false;
        weapon.swing_timer = 0;
        
        // ===== 攻击结束：进入停顿阶段 =====
        weapon._aim_state = "pause";
        weapon._aim_timer = 5;  // 停顿5帧
        weapon._aim_start_angle = weapon.image_angle;
    }
}