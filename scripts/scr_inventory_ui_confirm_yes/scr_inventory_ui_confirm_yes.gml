/// @function scr_inventory_ui_confirm_yes(ui)
function scr_inventory_ui_confirm_yes(ui) {
    var _player = instance_find(obj_player_base, 0);
    if (!instance_exists(_player)) return;
    
    if (ui.confirm_action == "drop") {
        var _inv_index = ui.confirm_inv_index;
        if (_inv_index >= 0 && _inv_index < array_length(_player.inventory)) {
            var _item = _player.inventory[_inv_index];
            if (instance_exists(_item)) {
                scr_item_drop_to_ground(_player, _item);
            }
        }
    }
    
    // 关闭确认框
    ui.confirm_active = false;
    ui.confirm_action = "";
    ui.confirm_inv_index = -1;
    ui.confirm_slot = -1;
}

/// @function scr_inventory_ui_confirm_no(ui)
function scr_inventory_ui_confirm_no(ui) {
    ui.confirm_active = false;
    ui.confirm_action = "";
    ui.confirm_inv_index = -1;
    ui.confirm_slot = -1;
}