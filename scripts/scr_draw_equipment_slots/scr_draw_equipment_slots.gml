/// @function scr_draw_equipment_slots(ui, player)
function scr_draw_equipment_slots(ui, player) {
    var _x = ui.ui_equip_x;
    var _y = ui.ui_equip_y;
    
    // 标题
    draw_set_font(font_chinese);
    draw_set_halign(fa_center);
    draw_set_valign(fa_middle);
    draw_set_color(c_yellow);
    draw_text(_x + ui.slot_size / 2, _y - 30, "装备");
    
    var _slot_names = ["武器 1", "武器 2", "武技", "身法", "遗物", "伴生体"];
    var _slot_items = [
        player.weapon_slots[0],
        player.weapon_slots[1],
        player.skill_instance,
        player.agility_instance,
        player.relic_slot,
        player.companion_slot
    ];
    
    for (var i = 0; i < 6; i++) {
        var _sx = _x;
        var _sy = _y + i * (ui.slot_size + ui.slot_gap);
        
        // 背景
        draw_set_color(make_color_rgb(60, 60, 60));
        draw_rectangle(_sx, _sy, _sx + ui.slot_size, _sy + ui.slot_size, false);
        
        // 边框（选中/悬浮/当前装备/闪烁）
var _border_color = c_white;
var _border_thickness = 1;

// 悬浮
if (i == ui.hover_slot && i != ui.selected_slot) {
    _border_color = make_color_rgb(150, 200, 255);
    _border_thickness = 2;
}

// ★ 当前装备武器槽（呼吸金色）
if ((i == 0 || i == 1) && i == player.active_weapon_slot) {
    var _breathe = 3 + sin(current_time * 0.005) * 1.5;
    _border_color = make_color_rgb(255, 200, 0);
    _border_thickness = _breathe;
}

// 选中（覆盖）
if (i == ui.selected_slot) {
    _border_color = c_aqua;
    _border_thickness = 4;
}

// 闪烁（覆盖）
if (i == ui.flash_slot_index && ui.flash_slot_timer > 0) {
    _border_color = c_yellow;
    _border_thickness = 4 + ui.flash_slot_timer;
}

draw_set_color(_border_color);
for (var t = 0; t < _border_thickness; t++) {
    draw_rectangle(_sx - t, _sy - t, _sx + ui.slot_size + t, _sy + ui.slot_size + t, true);
}
        
        // 槽名（左侧）
        draw_set_halign(fa_right);
        draw_set_color(c_white);
        draw_text(_sx - 10, _sy + ui.slot_size / 2, _slot_names[i]);
        draw_set_halign(fa_center);
        
        // 物品
        var _item = _slot_items[i];
        if (instance_exists(_item)) {
            // 兼容性检查（武技/身法槽）
            // 兼容性检查（只对武技槽）
var _is_compatible = true;
if (i == 2) {
    if (player.skill_slot != "" && player.skill_slot != noone) {
        _is_compatible = scr_skill_is_compatible(player.skill_slot, player.current_weapon);
    }
}
            
            if (_is_compatible) {
                scr_draw_item_in_slot(_item, _sx, _sy, ui.slot_size, i == ui.selected_slot);
            } else {
                // 灰显
                draw_set_alpha(0.4);
                scr_draw_item_in_slot(_item, _sx, _sy, ui.slot_size, false);
                draw_set_alpha(1);
                
                // 画"不兼容"标记
                draw_set_color(c_red);
                draw_set_halign(fa_center);
                draw_set_valign(fa_middle);
                draw_text(_sx + ui.slot_size / 2, _sy + ui.slot_size - 20, "不兼容");
            }
        }
    }
    
    // 重置
    draw_set_halign(fa_left);
    draw_set_valign(fa_top);
    draw_set_color(c_white);
}