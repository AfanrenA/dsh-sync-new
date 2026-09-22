// scr_draw_ui_card.gml
/// @function scr_draw_ui_card(x, y, w, h, name, border_color, text_color, cooldown_progress, flash_timer, can_flash)

function scr_draw_ui_card(x, y, w, h, name, border_color, text_color, cooldown_progress = 1, flash_timer = 0, can_flash = true) {
    // ---- 卡片背景 ----
    draw_set_color(c_black);
    draw_set_alpha(0.6);
    draw_rectangle(x, y, x + w, y + h, false);
    draw_set_alpha(1);
    
    // ---- 冷却填充（从左到右，半透明边框颜色） ----
    if (cooldown_progress < 1 && cooldown_progress > 0) {
        var _fill_width = w * cooldown_progress;
        draw_set_alpha(0.4);
        draw_set_color(border_color);
        draw_rectangle(x, y, x + _fill_width, y + h, false);
        draw_set_alpha(1);
    }
    
    // ---- 闪烁：flash_timer > 0 时整个槽变白色 ----
    var _flash = 0;
    if (can_flash && flash_timer > 0) {
        _flash = flash_timer / 30;  // 30→0 线性衰减
    }
    
    // ---- 白色覆盖 ----
    if (_flash > 0) {
        draw_set_alpha(_flash);
        draw_set_color(c_white);
        draw_rectangle(x, y, x + w, y + h, false);
        draw_set_alpha(1);
    }
    
    // ---- 卡片边框 ----
    var _border_alpha = 0.7;
    if (_flash > 0) {
        _border_alpha = 1;
    }
    draw_set_color(_flash > 0 ? c_white : border_color);
    draw_set_alpha(_border_alpha);
    draw_rectangle(x, y, x + w, y + h, true);
    draw_set_alpha(1);
    
    // ---- 卡片内容文字 ----
    draw_set_color(_flash > 0 ? c_white : text_color);
    draw_set_alpha(1);
    draw_set_halign(fa_center);
    draw_set_valign(fa_middle);
    
    if (font_exists(font_chinese)) {
        draw_set_font(font_chinese);
    }
    
    var _display_name = name;
    if (string_length(_display_name) > 6) {
        _display_name = string_copy(_display_name, 1, 6) + "..";
    }
    
    draw_text(x + w / 2, y + h / 2, _display_name);
    
    // ---- 恢复默认 ----
    draw_set_halign(fa_left);
    draw_set_valign(fa_top);
    draw_set_font(-1);
    draw_set_color(c_white);
    draw_set_alpha(1);
}