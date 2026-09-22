event_inherited();
scr_draw_charge_indicator(self);

// ===== 武器切换过渡绘制 =====
if (weapon_switch_timer > 0) {
    var _elapsed = 14 - weapon_switch_timer;
    
    // ===== 旧武器：帧 0-10，淡出 + 微缩 =====
    if (_elapsed <= 10 && weapon_switch_old_sprite != -1) {
        var _old_progress = _elapsed / 10;
        var _old_alpha = lerp(1.0, 0.0, _old_progress);
        var _old_scale = lerp(1.0, 0.7, _old_progress);   // ★ XY 一起缩，从 1.0 到 0.7
        
        draw_sprite_ext(
            weapon_switch_old_sprite, weapon_switch_old_index,
            x, y,
            weapon_switch_old_xscale * _old_scale,   // ★ 用 _old_scale
            weapon_switch_old_yscale * _old_scale,   // ★ 用 _old_scale
            weapon_switch_old_angle,
            c_white, _old_alpha
        );
    }
    
    // ===== 新武器：帧 4-14，淡入 + 微放 =====
    if (_elapsed >= 4) {
        var _new = current_weapon;
        if (instance_exists(_new)) {
            var _new_progress = (_elapsed - 4) / 10;
            var _new_alpha = lerp(0.0, 1.0, _new_progress);
            var _new_scale = lerp(0.7, 1.0, _new_progress);   // ★ XY 一起缩，从 0.7 到 1.0
            
            draw_sprite_ext(
                _new.sprite_index, _new.image_index,
                x, y,
                _new.image_xscale * _new_scale,   // ★ 用 _new_scale
                _new.image_yscale * _new_scale,   // ★ 用 _new_scale
                weapon_switch_old_angle,
                c_white, _new_alpha
            );
        }
    }
}