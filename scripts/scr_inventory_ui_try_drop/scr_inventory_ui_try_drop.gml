/// @function scr_inventory_ui_try_drop(ui, inv_index)
/// @description 右键背包格：弹出确认框
function scr_inventory_ui_try_drop(ui, inv_index) {
    var _player = instance_find(obj_player_base, 0);
    if (!instance_exists(_player)) return;
    if (inv_index < 0 || inv_index >= array_length(_player.inventory)) return;
    
    var _item = _player.inventory[inv_index];
    if (!instance_exists(_item)) return;
    
    // ★ 不能丢当前激活武器
    if (_item == _player.current_weapon) {
        scr_show_hint(_player, "当前武器无法丢弃，请先切换");
        return;
    }
    
    // 打开确认框
    ui.confirm_active = true;
    ui.confirm_action = "drop";
    ui.confirm_inv_index = inv_index;
    ui.confirm_slot = -1;
    
    // 兼容武器和武技的字段名
    var _name = "";
    if (variable_instance_exists(_item, "display_name") && _item.display_name != "") {
        _name = _item.display_name;
    } else if (variable_instance_exists(_item, "skill_name") && _item.skill_name != "") {
        _name = _item.skill_name;
    }
    ui.confirm_item_name = _name;
    
    // 品质颜色（兼容判断）
    ui.confirm_item_rarity_color = c_white;
    if (variable_instance_exists(_item, "rarity_color")) {
        ui.confirm_item_rarity_color = _item.rarity_color;
    }
}