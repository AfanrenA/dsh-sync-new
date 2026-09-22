// ===== 黑屏 =====
if (black_screen_alpha > 0) {
    draw_set_color(c_black);
    draw_set_alpha(black_screen_alpha);
    draw_rectangle(0, 0, display_get_gui_width(), display_get_gui_height(), false);
    draw_set_alpha(1);
}

// ===== 复活提示 =====
if (black_screen_alpha > 0.5) {
    draw_set_font(font_chinese);
    draw_set_color(c_white);
    draw_set_alpha(0.8 + 0.2 * sin(current_time / 500));
    draw_set_halign(fa_center);
    draw_set_valign(fa_middle);
    draw_text(display_get_gui_width() / 2, display_get_gui_height() / 2 + 50, "数据消散！点击鼠标或按任意键重组");
    draw_set_alpha(1);
    draw_set_halign(fa_left);
    draw_set_valign(fa_top);
}