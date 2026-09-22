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
// ===== 护盾满：描边发光（8方向偏移 + bm_add，低强度） =====
if (!is_dead && max_shield > 0 && shield >= max_shield) {
    var _breath = 0.15 + 0.1 * sin(current_time / 300);   // 0.05 ~ 0.25
    var _offsets = [[-4,0],[4,0],[0,-4],[0,4],[-3,-3],[3,-3],[-3,3],[3,3]];
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
            _col, _breath
        );
    }
    gpu_set_blendmode(bm_normal);
}