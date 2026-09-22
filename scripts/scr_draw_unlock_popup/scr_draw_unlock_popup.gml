/// @function scr_draw_unlock_popup(popup)
function scr_draw_unlock_popup(popup) {
    var _w = display_get_gui_width();
    var _h = display_get_gui_height();
    var _cx = _w / 2;
    var _cy = _h / 2;
    
    // 上下浮动
    var _bob_offset = sin(popup.bob_timer) * 20;
    var _cy_actual = _cy + _bob_offset;
    
    // 淡出
    var _alpha = 1;
    if (popup.life_timer < popup.fade_start) _alpha = popup.life_timer / popup.fade_start;
    
    // 呼吸缩放
    var _pulse_scale = 1 + 0.15 * sin(popup.pulse_timer);
    
    // ===== 1. 背景（半透明黑） =====
    draw_set_alpha(0.7 * _alpha);
    draw_set_color(c_black);
    draw_rectangle(0, 0, _w, _h, false);
    
    // ===== 2. 星芒背景 =====
    var _glow_alpha = (0.6 + 0.2 * sin(popup.pulse_timer)) * _alpha;
    draw_set_alpha(_glow_alpha);
    draw_set_color(popup.rarity_color);
    
    // ----- 2.1 主射线（4 条短的） -----
    var _main_count = 4;
    var _main_outer_r = 200 * _pulse_scale;   // ★ 从 400 改成 200
    var _main_base_r = 10;
    
    for (var i = 0; i < _main_count; i++) {
        var _angle = (i * 360 / _main_count) - 90;
        var _tip_x = _cx + lengthdir_x(_main_outer_r, _angle);
        var _tip_y = _cy_actual + lengthdir_y(_main_outer_r, _angle);
        var _base1_x = _cx + lengthdir_x(_main_base_r, _angle + 90);
        var _base1_y = _cy_actual + lengthdir_y(_main_base_r, _angle + 90);
        var _base2_x = _cx + lengthdir_x(_main_base_r, _angle - 90);
        var _base2_y = _cy_actual + lengthdir_y(_main_base_r, _angle - 90);
        draw_triangle(_tip_x, _tip_y, _base1_x, _base1_y, _base2_x, _base2_y, false);
    }
    
    // ----- 2.2 次射线（4 条中等，错开 45°） -----
    var _sub_count = 4;
    var _sub_outer_r = 150 * _pulse_scale;   // ★ 从 250 改成 150
    var _sub_base_r = 6;
    var _sub_offset = 45;
    
    for (var i = 0; i < _sub_count; i++) {
        var _angle = (i * 360 / _sub_count) - 90 + _sub_offset;
        var _tip_x = _cx + lengthdir_x(_sub_outer_r, _angle);
        var _tip_y = _cy_actual + lengthdir_y(_sub_outer_r, _angle);
        var _base1_x = _cx + lengthdir_x(_sub_base_r, _angle + 90);
        var _base1_y = _cy_actual + lengthdir_y(_sub_base_r, _angle + 90);
        var _base2_x = _cx + lengthdir_x(_sub_base_r, _angle - 90);
        var _base2_y = _cy_actual + lengthdir_y(_sub_base_r, _angle - 90);
        draw_triangle(_tip_x, _tip_y, _base1_x, _base1_y, _base2_x, _base2_y, false);
    }
    
    // ----- 2.3 短射线（8 条短的，错开 22.5°） -----
    var _short_count = 8;
    var _short_outer_r = 80 * _pulse_scale;   // ★ 从 120 改成 80
    var _short_base_r = 4;
    var _short_offset = 22.5;
    
    for (var i = 0; i < _short_count; i++) {
        var _angle = (i * 360 / _short_count) - 90 + _short_offset;
        var _tip_x = _cx + lengthdir_x(_short_outer_r, _angle);
        var _tip_y = _cy_actual + lengthdir_y(_short_outer_r, _angle);
        var _base1_x = _cx + lengthdir_x(_short_base_r, _angle + 90);
        var _base1_y = _cy_actual + lengthdir_y(_short_base_r, _angle + 90);
        var _base2_x = _cx + lengthdir_x(_short_base_r, _angle - 90);
        var _base2_y = _cy_actual + lengthdir_y(_short_base_r, _angle - 90);
        draw_triangle(_tip_x, _tip_y, _base1_x, _base1_y, _base2_x, _base2_y, false);
    }
    
    // ----- 2.4 大中心圆（包裹物品） -----
    
    // 中圈（品质颜色，更亮）
    draw_set_alpha(_glow_alpha * 0.6);
    draw_set_color(popup.rarity_color);
    draw_circle(_cx, _cy_actual, 120 * _pulse_scale, false);
   
    
    // ===== 3. 物品图（跟背景一起浮动 + 用精灵实际中心） =====
    if (instance_exists(popup.item)) {
        var _sprite = popup.item.sprite_index;
        var _sw = sprite_get_width(_sprite);
        var _sh = sprite_get_height(_sprite);
        var _sx_offset = sprite_get_xoffset(_sprite);
        var _sy_offset = sprite_get_yoffset(_sprite);
        
        var _offset_x = (_sw / 2) - _sx_offset;
        var _offset_y = (_sh / 2) - _sy_offset;
        
        var _scale = 100 / max(_sw, _sh);
        
        draw_set_alpha(_alpha);
        draw_sprite_ext(
            _sprite, 0,
            _cx - _offset_x * _scale,
            _cy_actual - _offset_y * _scale,
            _scale, _scale,
            0,
            c_white, _alpha
        );
    }
    
    // ===== 4. 顶部大字 =====
    draw_set_alpha(_alpha);
    draw_set_font(font_chinese);
    draw_set_halign(fa_center);
    draw_set_valign(fa_middle);
    
    var _title_y = _cy_actual - 250;
    var _title_scale = 2.0;
    
    // "恭喜你解锁了"（8 方向暗金描边）
    draw_set_color(make_color_rgb(180, 140, 0));
    var _outline_offset = 3;
    for (var i = 0; i < 8; i++) {
        var _angle = i * 45;
        var _ox = lengthdir_x(_outline_offset, _angle);
        var _oy = lengthdir_y(_outline_offset, _angle);
        draw_text_transformed(_cx + _ox, _title_y + _oy, "恭喜你解锁了", _title_scale, _title_scale, 0);
    }
    
    // 主体（金色）
    draw_set_color(make_color_rgb(255, 215, 0));
    draw_text_transformed(_cx, _title_y, "恭喜你解锁了", _title_scale, _title_scale, 0);
    
    // 物品名（8 方向描边）
    var _name_y = _title_y + 70;
    
    draw_set_color(c_black);
    for (var i = 0; i < 8; i++) {
        var _angle = i * 45;
        var _ox = lengthdir_x(_outline_offset, _angle);
        var _oy = lengthdir_y(_outline_offset, _angle);
        draw_text_transformed(_cx + _ox, _name_y + _oy, popup.name, _title_scale, _title_scale, 0);
    }
    
    // 主体（品质颜色）
    draw_set_color(popup.rarity_color);
    draw_text_transformed(_cx, _name_y, popup.name, _title_scale, _title_scale, 0);
    
    // ===== 5. 重置 =====
    draw_set_alpha(1);
    draw_set_color(c_white);
    draw_set_halign(fa_left);
    draw_set_valign(fa_top);
}