draw_set_font(font_chinese);
draw_set_halign(fa_center);
draw_set_valign(fa_middle);

var _text = string(damage_value);
var _sx = image_xscale;
var _sy = image_yscale;
var _rot = text_rotation;   // ★ 用 text_rotation 作为旋转角度

// 外发光（暴击）
if (is_critical) {
    draw_set_alpha(0.3);
    draw_set_color(make_color_rgb(255, 200, 0));
    for (var _i = 0; _i < 8; _i++) {
        var _angle = _i * 45;
        var _offset = 3;
        draw_text_transformed(x + lengthdir_x(_offset, _angle), y + lengthdir_y(_offset, _angle), _text, _sx, _sy, _rot);
    }
    draw_set_alpha(1);
}

// 金色描边
draw_set_color(make_color_rgb(255, 215, 0));
draw_text_transformed(x + 2, y, _text, _sx, _sy, _rot);
draw_text_transformed(x - 2, y, _text, _sx, _sy, _rot);
draw_text_transformed(x, y + 2, _text, _sx, _sy, _rot);
draw_text_transformed(x, y - 2, _text, _sx, _sy, _rot);

// 红色主体
draw_set_color(c_red);
draw_text_transformed(x, y, _text, _sx, _sy, _rot);

draw_set_color(c_white);
draw_set_alpha(1);