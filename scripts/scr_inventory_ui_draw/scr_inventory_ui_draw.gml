/// @function scr_inventory_ui_draw(ui)
function scr_inventory_ui_draw(ui) {
	
    var _player = instance_find(obj_player_base, 0);
	if (!_player.inventory_ui_open) return;
    if (!instance_exists(_player)) return;
    
    // 重置绘图状态
    draw_set_alpha(1);
    draw_set_color(c_white);
    
    var _w = display_get_gui_width();
    var _h = display_get_gui_height();
    
    // ===== 1. 半透明背景 =====
    draw_set_alpha(0.7);
    draw_set_color(c_black);
    draw_rectangle(0, 0, _w, _h, false);
    draw_set_alpha(1);
    
    // ===== 2. 标题 =====
    draw_set_font(font_chinese);
    draw_set_halign(fa_center);
    draw_set_valign(fa_middle);
    draw_set_color(c_white);
    draw_text(_w / 2, 60, "背包 (Tab / ESC 关闭)");
    
    // ===== 3. 左侧：角色属性 =====
    scr_draw_character_stats(ui, _player);
    
    // ===== 4. 中间：装备栏 =====
    scr_draw_equipment_slots(ui, _player);
    
    // ===== 5. 右侧：背包 =====
    scr_draw_inventory_grid(ui, _player);
    
    // ===== 6. 悬浮详情 =====
    scr_draw_hover_tooltip(ui, _player);
    
    // ===== 7. 点击预览 =====
    if (instance_exists(ui.preview_item)) {
        var _mx = device_mouse_x_to_gui(0);
        var _my = device_mouse_y_to_gui(0);
        scr_draw_item_tooltip(ui.preview_item, _mx, _my);
		
    }
	
    // ===== 8. 确认框（最上层） =====
scr_draw_confirm_dialog(ui);
    // ===== 9. 重置绘图状态 =====
    draw_set_color(c_white);
    draw_set_alpha(1);
    draw_set_halign(fa_left);
    draw_set_valign(fa_top);
}