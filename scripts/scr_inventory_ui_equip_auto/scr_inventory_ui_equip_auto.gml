/// @function scr_inventory_ui_equip_auto(ui, inv_index)
/// @description 双击/E：优先空槽，满了提示选槽
function scr_inventory_ui_equip_auto(ui, inv_index) {
    var _player = instance_find(obj_player_base, 0);
    if (!instance_exists(_player)) return;
    if (inv_index < 0 || inv_index >= array_length(_player.inventory)) return;
    
    var _item = _player.inventory[inv_index];
    if (!instance_exists(_item)) return;
    
    // ===== 1. 判断物品类型 =====
    var _is_weapon = false;
    var _is_skill = false;
    var _is_agility = false;
    var _is_relic = false;
    
        if (scr_is_item_type(_item.object_index, obj_weapon_base)) {
        _is_weapon = true;
    } else if (scr_is_item_type(_item.object_index, obj_agility_base)) {
        _is_agility = true;
    } else if (scr_is_item_type(_item.object_index, obj_relic_base)) {
        _is_relic = true;
    } else if (scr_is_item_type(_item.object_index, obj_skill_base)) {
        _is_skill = true;
    }
    
    if (!_is_weapon && !_is_skill && !_is_agility && !_is_relic) {
        scr_show_hint(_player, "此物品无法装备");
        return;
    }
    
    // ===== 2. 决定目标槽 =====
    var _target_slot = -1;
    var _selected = ui.selected_slot;
    
    if (_selected >= 0) {
        if ((_selected == 0 || _selected == 1) && _is_weapon) {
            _target_slot = _selected;
        } else if (_selected == 2 && _is_skill) {
            _target_slot = 2;
        } else if (_selected == 3 && _is_agility) {
            _target_slot = 3;
        } else if (_selected == 4 && _is_relic) {
            _target_slot = 4;
        } else {
            scr_show_hint(_player, "槽位类型不匹配");
            return;
        }
    } else {
        if (_is_weapon) {
            if (!instance_exists(_player.weapon_slots[0])) {
                _target_slot = 0;
            } else if (!instance_exists(_player.weapon_slots[1])) {
                _target_slot = 1;
            } else {
                scr_show_hint(_player, "武器槽已满，请左键选择要替换的槽位");
                return;
            }
        } else if (_is_skill) {
            if (!instance_exists(_player.skill_instance)) {
                _target_slot = 2;
            } else {
                scr_show_hint(_player, "武技槽已满，请左键选中武技槽后替换");
                return;
            }
        } else if (_is_agility) {
            if (!instance_exists(_player.agility_instance)) {
                _target_slot = 3;
            } else {
                scr_show_hint(_player, "身法槽已满，请左键选中身法槽后替换");
                return;
            }
        } else if (_is_relic) {
            if (!instance_exists(_player.relic_slot)) {
                _target_slot = 4;
            } else {
                scr_show_hint(_player, "遗物槽已满，请左键选中遗物槽后替换");
                return;
            }
        }
    }
    
    if (_target_slot == -1) {
        scr_show_hint(_player, "此物品无法装备");
        return;
    }
    
    // ===== 3. 执行装备 =====
    var _equipped = false;
    
    if (_target_slot == 0 || _target_slot == 1) {
        scr_weapon_equip(_player, _item, _target_slot);
        _equipped = true;
    } else if (_target_slot == 2) {
        scr_skill_equip(_player, _item);
        _equipped = true;
    } else if (_target_slot == 3) {
        scr_agility_equip(_player, _item);
        _equipped = true;
    } else if (_target_slot == 4) {
        _equipped = scr_relic_equip(_player, _item);
    }
    
    // ===== 4. 闪烁反馈 =====
    if (_equipped) {
        ui.flash_inventory_index = inv_index;
        ui.flash_inventory_timer = 10;
        ui.flash_slot_index = _target_slot;
        ui.flash_slot_timer = 10;
        ui.selected_inventory = -1;
    }
}