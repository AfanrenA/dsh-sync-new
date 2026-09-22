// ===== 角色本体（唯一一次绘制） =====
draw_self();


// ===== 受击闪白（在角色之上叠加） =====
if (is_hit_flashing && !is_dead) {
    var _sprite = sprite_index;
    var _w = sprite_get_width(_sprite);
    var _h = sprite_get_height(_sprite);
    var _xoff = sprite_get_xoffset(_sprite);
    var _yoff = sprite_get_yoffset(_sprite);
    var _center_x = x + (_w / 2) - _xoff;
    var _center_y = y + (_h / 2) - _yoff;
    
    draw_set_alpha(0.5);
    draw_set_color(c_white);
    draw_rectangle(_center_x - _w/2, _center_y - _h/2, _center_x + _w/2, _center_y + _h/2, false);
    draw_set_alpha(1);
    draw_set_color(c_white);   // ★ 恢复颜色，防止污染后续绘制
}
// ===== 护盾：描边发光（8方向偏移 + bm_add）=====
// ★ 修正：原来条件是 `shield >= max_shield`（**必须满盾**）→ 被打掉一格就完全不发光。
//   用户反馈"护盾被打掉两格，发光描边特效就没了"。
//   改成**按剩余比例**决定亮度：盾越满越亮，空了才熄灭。
//   （护盾满时额外加一点呼吸感，突出"满盾"状态）
if (!is_dead && max_shield > 0 && shield > 0) {
    var _ratio = clamp(shield / max_shield, 0, 1);

    // 基础亮度随比例上升（0.04 ~ 0.20），满盾时再叠一层呼吸
    var _intensity = 0.04 + 0.16 * _ratio;
    if (_ratio >= 1) {
        _intensity = 0.20 + 0.08 * (0.5 + 0.5 * sin(current_time / 300));
    }

    // 描边宽度也随比例微调（盾少 → 描边细一点，视觉上"虚弱"）
    var _off = 2 + round(2 * _ratio);

    var _offsets = [
        [-_off, 0], [_off, 0], [0, -_off], [0, _off],
        [-_off + 1, -_off + 1], [_off - 1, -_off + 1],
        [-_off + 1, _off - 1], [_off - 1, _off - 1]
    ];
    var _col = make_color_rgb(100, 180, 255);

    gpu_set_blendmode(bm_add);
    for (var _i = 0; _i < array_length(_offsets); _i++) {
        var _ox = _offsets[_i][0];
        var _oy = _offsets[_i][1];
        draw_sprite_ext(
            sprite_index, image_index,
            x + _ox, y + _oy,
            image_xscale, image_yscale,
            image_angle,
            _col, _intensity
        );
    }
    gpu_set_blendmode(bm_normal);
}