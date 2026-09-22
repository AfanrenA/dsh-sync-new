// obj_hint Draw GUI 事件

var _alpha = 1;
if (life_timer < 30) _alpha = life_timer / 30;

draw_set_alpha(_alpha);
draw_set_font(font_chinese);
draw_set_halign(fa_center);
draw_set_valign(fa_middle);

if (is_unlock_hint) {
    // 首次拾取样式：金色 + 描边 + 放大
    draw_set_color(c_black);
    draw_text(display_get_gui_width() / 2 + 2, 150 + 2, text);
    draw_set_color(make_color_rgb(255, 215, 0));
    draw_text_transformed(display_get_gui_width() / 2, 150, text, 1.3, 1.3, 0);
} else {
    // 普通提示样式
    draw_set_color(c_yellow);
    draw_text(display_get_gui_width() / 2, 100, text);
}

draw_set_alpha(1);
draw_set_color(c_white);