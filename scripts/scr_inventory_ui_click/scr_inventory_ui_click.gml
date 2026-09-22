/// @function scr_inventory_ui_click(ui)
function scr_inventory_ui_click(ui) {
    var _player = instance_find(obj_player_base, 0);
    if (!instance_exists(_player)) return;
    
    var _mx = device_mouse_x_to_gui(0);
    var _my = device_mouse_y_to_gui(0);
    
    // ===== 检测"槽"点击 =====
    var _left_x = ui.ui_equip_x;
    var _left_y = ui.ui_equip_y
    for (var i = 0; i < 6; i++) {
        var _sx = _left_x;
        var _sy = _left_y + i * (ui.slot_size + ui.slot_gap);
        if (_mx >= _sx && _mx <= _sx + ui.slot_size && _my >= _sy && _my <= _sy + ui.slot_size) {
            if (mouse_check_button_pressed(mb_left)) {
                ui.selected_slot = i;
				
                show_debug_message("[UI] 选中槽 " + string(i));
            }
            return;
        }
    }
    
    // ===== 检测"背包格子"点击 =====
    var _right_x = ui.ui_right_x;
    var _right_y = ui.ui_right_y;
    for (var row = 0; row < ui.inventory_rows; row++) {
        for (var col = 0; col < ui.inventory_cols; col++) {
            var _index = row * ui.inventory_cols + col;
            var _ix = _right_x + col * (ui.slot_size + ui.slot_gap);
            var _iy = _right_y + row * (ui.slot_size + ui.slot_gap);
            if (_mx >= _ix && _mx <= _ix + ui.slot_size && _my >= _iy && _my <= _iy + ui.slot_size) {
                if (mouse_check_button_pressed(mb_left)) {
    if (_index == ui._last_click_index && ui._double_click_timer > 0) {
        // 双击 → 触发装备
        scr_inventory_ui_equip_auto( ui, _index);
        ui._double_click_timer = 0;
        ui._last_click_index = -1;
    } else {
        // 单击 → 选中
        ui.selected_inventory = _index;
        ui._last_click_index = _index;
        ui._double_click_timer = 20;   // 20 帧内再点击算双击
    }
}
                return;
            }
        }
    }
}