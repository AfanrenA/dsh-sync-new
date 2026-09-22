event_inherited()
// ===== 切换完成反馈（闪白 + 放大回弹） =====
if (flash_timer > 0) {
    var _progress = 1 - (flash_timer / 10);
    var _extra_scale = 1 + 0.2 * sin(_progress * pi);
    var _flash_alpha = (1 - _progress) * 0.7;
    
    draw_sprite_ext(
        sprite_index, image_index,
        x, y,
        image_xscale * _extra_scale,
        image_yscale * _extra_scale,
        image_angle,
        c_white,
        _flash_alpha
    );
}

// ===== 冷却就绪：虚影放大回弹（20帧） =====
if (flash_ready_timer > 0) {
    var _progress = 1 - (flash_ready_timer / 30);        // 0 → 1
    var _scale = 1 + 0.2 * sin(_progress * pi);          // 1.0 → 1.5 → 1.0
    var _alpha = (1 - _progress) * 0.6;                  // 0.6 → 0
    
    draw_sprite_ext(
        sprite_index, image_index,
        x, y,
        image_xscale * _scale,
        image_yscale * _scale,
        image_angle,
        c_white,        // ★ A方案：不染色，保持武器原色
        _alpha
    );
}
// ===== 武技冷却就绪：品质色虚影放大回弹（30帧） =====
if (flash_skill_timer > 0) {
    var _progress = 1 - (flash_skill_timer / 30);        // 0 → 1
    var _scale = 1 + 0.8 * sin(_progress * pi);          // 1.0 → 1.8 → 1.0
    var _alpha = (1 - _progress) * 0.7;                  // 0.7 → 0
    
    var _skill_color = rarity_color != undefined ? rarity_color : c_white;
    
    draw_sprite_ext(
        sprite_index, image_index,
        x, y,
        image_xscale * _scale,
        image_yscale * _scale,
        image_angle,
        _skill_color,
        _alpha
    );
}


