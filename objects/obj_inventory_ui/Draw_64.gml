// obj_inventory_ui Draw GUI 事件

// ===== 1. 解锁弹窗（不管背包开不开都画） =====
for (var i = 0; i < array_length(unlock_popups); i++) {
    scr_draw_unlock_popup(unlock_popups[i]);
}

// ===== 2. 背包 UI =====
if (!is_open) exit;
scr_inventory_ui_draw(self);
// ===== ★ 排序按钮绘制 =====
var _player = instance_find(obj_player_base, 0);
if (instance_exists(_player) && _player.inventory_ui_open) {
    var _btn_w = 80;
    var _btn_h = 28;
    var _btn_x = ui_right_x + inventory_cols * (slot_size + slot_gap) - _btn_w;
    var _btn_y = ui_right_y - 30 - _btn_h * 0.5;
    
    var _mx = device_mouse_x_to_gui(0);
    var _my = device_mouse_y_to_gui(0);
    var _btn_hover = (_mx >= _btn_x && _mx <= _btn_x + _btn_w &&
                      _my >= _btn_y && _my <= _btn_y + _btn_h);
    
    draw_set_alpha(1);
    draw_set_color(_btn_hover ? make_color_rgb(90, 140, 200) : make_color_rgb(60, 90, 130));
    draw_rectangle(_btn_x, _btn_y, _btn_x + _btn_w, _btn_y + _btn_h, false);
    
    draw_set_color(c_white);
    draw_rectangle(_btn_x, _btn_y, _btn_x + _btn_w, _btn_y + _btn_h, true);
    
    draw_set_font(font_chinese);
    draw_set_halign(fa_center);
    draw_set_valign(fa_middle);
    draw_text(_btn_x + _btn_w * 0.5, _btn_y + _btn_h * 0.5, "整理");
    
    draw_set_halign(fa_left);
    draw_set_valign(fa_top);
    draw_set_color(c_white);
}