/// @function scr_draw_confirm_dialog(ui)
function scr_draw_confirm_dialog(ui) {
    if (!ui.confirm_active) return;
    
    // 全屏半透明黑
    var _gw = display_get_gui_width();
    var _gh = display_get_gui_height();
    draw_set_alpha(0.5);
    draw_set_color(c_black);
    draw_rectangle(0, 0, _gw, _gh, false);
    draw_set_alpha(1);
    
    // 确认框位置（屏幕中央）
    var _cw = 400;
    var _ch = 200;
    var _cx = _gw / 2 - _cw / 2;
    var _cy = _gh / 2 - _ch / 2;
    
    // 框背景
    draw_set_color(make_color_rgb(40, 40, 40));
    draw_rectangle(_cx, _cy, _cx + _cw, _cy + _ch, false);
    
    // 边框
    draw_set_color(c_white);
    draw_rectangle(_cx, _cy, _cx + _cw, _cy + _ch, true);
    
    // 标题
    draw_set_font(font_chinese);
    draw_set_halign(fa_center);
    draw_set_valign(fa_middle);
    draw_set_color(c_white);
    draw_text(_cx + _cw / 2, _cy + 40, "确认丢弃");
    
    // 物品名（品质颜色）
    draw_set_color(ui.confirm_item_rarity_color);
    draw_text(_cx + _cw / 2, _cy + 90, ui.confirm_item_name);
    
    // 按钮
    var _btn_w = 100;
    var _btn_h = 40;
    var _btn_y = _cy + _ch - 60;
    
    // 确认按钮
    var _confirm_x = _cx + _cw / 2 - _btn_w - 10;
    draw_set_color(make_color_rgb(100, 40, 40));
    draw_rectangle(_confirm_x, _btn_y, _confirm_x + _btn_w, _btn_y + _btn_h, false);
    draw_set_color(c_white);
    draw_rectangle(_confirm_x, _btn_y, _confirm_x + _btn_w, _btn_y + _btn_h, true);
    draw_text(_confirm_x + _btn_w / 2, _btn_y + _btn_h / 2, "确认");
    
    // 取消按钮
    var _cancel_x = _cx + _cw / 2 + 10;
    draw_set_color(make_color_rgb(40, 40, 60));
    draw_rectangle(_cancel_x, _btn_y, _cancel_x + _btn_w, _btn_y + _btn_h, false);
    draw_set_color(c_white);
    draw_rectangle(_cancel_x, _btn_y, _cancel_x + _btn_w, _btn_y + _btn_h, true);
    draw_text(_cancel_x + _btn_w / 2, _btn_y + _btn_h / 2, "取消");
    
    // 重置
    draw_set_halign(fa_left);
    draw_set_valign(fa_top);
}