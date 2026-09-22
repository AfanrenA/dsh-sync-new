/// @function scr_draw_inventory_grid(ui, player)
function scr_draw_inventory_grid(ui, player) {
    var _x = ui.ui_right_x;
    var _y = ui.ui_right_y;
    
    // 标题
    draw_set_font(font_chinese);
    draw_set_halign(fa_center);
    draw_set_valign(fa_middle);
    draw_set_color(c_yellow);
    draw_text(_x + ui.inventory_cols * (ui.slot_size + ui.slot_gap) / 2, _y - 30, "背包");
    
   // 分页信息（只有多页才显示）
if (ui.inventory_max_page > 1) {
    draw_set_color(c_white);
    draw_text(_x + ui.inventory_cols * (ui.slot_size + ui.slot_gap) / 2, _y - 60, 
              "第 " + string(ui.inventory_page + 1) + " / " + string(ui.inventory_max_page) + " 页");
}
    var _start_index = ui.inventory_page * ui.inventory_per_page;
    
    for (var row = 0; row < ui.inventory_rows; row++) {
        for (var col = 0; col < ui.inventory_cols; col++) {
            var _index = _start_index + row * ui.inventory_cols + col;
            var _ix = _x + col * (ui.slot_size + ui.slot_gap);
            var _iy = _y + row * (ui.slot_size + ui.slot_gap);
            
            // 是否"已解锁"
            var _is_unlocked = (_index < player.inventory_size);
            
            // 背景
            if (_is_unlocked) {
                draw_set_color(make_color_rgb(40, 40, 40));
            } else {
                draw_set_color(make_color_rgb(20, 20, 20));
            }
            draw_rectangle(_ix, _iy, _ix + ui.slot_size, _iy + ui.slot_size, false);
            
            // 边框
            var _border_color = c_white;
            var _border_thickness = 1;
            if (_is_unlocked) {
                if (_index == ui.selected_inventory) {
                    _border_color = c_yellow;
                    _border_thickness = 4;
                }
                if (_index == ui.hover_inventory && _index != ui.selected_inventory) {
                    _border_color = make_color_rgb(150, 200, 255);
                    _border_thickness = 2;
                }
                
                // ★ 闪烁覆盖（双击替换后的源格）
                if (_index == ui.flash_inventory_index && ui.flash_inventory_timer > 0) {
                    _border_color = c_white;
                    _border_thickness = 4 + ui.flash_inventory_timer;
                }
            } else {
                _border_color = make_color_rgb(80, 80, 80);
            }
            
            draw_set_color(_border_color);
            for (var t = 0; t < _border_thickness; t++) {
                draw_rectangle(_ix - t, _iy - t, _ix + ui.slot_size + t, _iy + ui.slot_size + t, true);
            }
            
            // 未解锁 → 画锁
            if (!_is_unlocked) {
                draw_set_color(make_color_rgb(100, 100, 100));
                draw_set_halign(fa_center);
                draw_set_valign(fa_middle);
                draw_text(_ix + ui.slot_size / 2, _iy + ui.slot_size / 2, "锁");
                continue;
            }
            
            // 物品
            if (_index < array_length(player.inventory)) {
                var _item = player.inventory[_index];
                if (instance_exists(_item)) {
                    scr_draw_item_in_slot(_item, _ix, _iy, ui.slot_size, _index == ui.selected_inventory);
                }
            }
        }
    }
    
    // 重置
    draw_set_halign(fa_left);
    draw_set_valign(fa_top);
    draw_set_color(c_white);
}