/// @function scr_draw_hover_tooltip(ui, player)
function scr_draw_hover_tooltip(ui, player) {
    var _mx = device_mouse_x_to_gui(0);
    var _my = device_mouse_y_to_gui(0);
    
    // 装备栏悬浮
    if (ui.hover_slot >= 0 && ui.hover_slot < 6) {
        var _slot_items = [
            player.weapon_slots[0],
            player.weapon_slots[1],
            player.skill_instance,
            player.agility_instance,
            player.relic_slot,
            player.companion_slot
        ];
        var _item = _slot_items[ui.hover_slot];
        if (instance_exists(_item)) {
            scr_draw_item_tooltip(_item, _mx, _my);
        }
    }
    
    // 背包悬浮
    var _start_index = ui.inventory_page * ui.inventory_per_page;
    if (ui.hover_inventory >= _start_index && ui.hover_inventory < _start_index + ui.inventory_per_page) {
        if (ui.hover_inventory < array_length(player.inventory)) {
            var _item = player.inventory[ui.hover_inventory];
            if (instance_exists(_item)) {
                scr_draw_item_tooltip(_item, _mx, _my);
            }
        }
    }
}