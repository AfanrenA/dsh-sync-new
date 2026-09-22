/// @function scr_inventory_ui_try_unequip(ui, slot)
/// @description 右键装备槽：卸下物品到背包（不弹确认框）
function scr_inventory_ui_try_unequip(ui, slot) {
    var _player = instance_find(obj_player_base, 0);
    if (!instance_exists(_player)) return;
    
    // 取槽内物品
    var _item = noone;
    if (slot == 0 || slot == 1) {
        _item = _player.weapon_slots[slot];
    } else if (slot == 2) {
        _item = _player.skill_instance;
    } else if (slot == 3) {
        _item = _player.agility_instance;
    } else if (slot == 4) {
        _item = _player.relic_slot;
    } else if (slot == 5) {
        _item = _player.companion_slot;
    }
    
    if (!instance_exists(_item)) {
        scr_show_hint(_player, "槽位为空");
        return;
    }
    
    // 检查背包是否满
    if (array_length(_player.inventory) >= _player.inventory_size) {
        scr_show_hint(_player, "背包已满");
        return;
    }
    
    // ===== ★ 关键：遗物卸下前必须先关闭效果（防倍率残留）=====
    if (slot == 4) {
        scr_relic_deactivate(_player, _item);
    }
    
    // 加入背包
    scr_inventory_add(_player, _item);
    
    // 清空槽位
    if (slot == 0 || slot == 1) {
        _player.weapon_slots[slot] = noone;
        if (_player.active_weapon_slot == slot) {
            _player.current_weapon = noone;
        }
        _item.visible = false;
        _item.owner_id = noone;
    } else if (slot == 2) {
        _player.skill_instance = noone;
        _player.skill_slot = "";
    } else if (slot == 3) {
        _player.agility_instance = noone;
        _player.agility_slot = "";
    } else if (slot == 4) {
        // ★ 遗物：卸下后实例保留在背包
        _player.relic_slot = noone;
        if (variable_instance_exists(_player, "relic_slot_id")) {
            _player.relic_slot_id = "";
        }
        _item.visible = false;
        _item.owner_id = _player;
    } else if (slot == 5) {
        _player.companion_slot = noone;
    }
    
    // 闪烁反馈
    ui.flash_slot_index = slot;
    ui.flash_slot_timer = 10;
    
    show_debug_message("[UI] 卸下槽 " + string(slot));
}	