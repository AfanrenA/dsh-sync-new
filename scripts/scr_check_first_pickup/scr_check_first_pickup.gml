/// @function scr_check_first_pickup(player, item)
function scr_check_first_pickup(player, item) {
    var _id = "";
    var _name = "";
    var _is_weapon = false;
    var _is_skill = false;
    var _is_relic = false;
    
    // 武器
    if (scr_is_item_type(item.object_index, obj_weapon_base))  {
        if (variable_instance_exists(item, "weapon_id")) {
            _id = item.weapon_id;
        }
        if (item.entity_data != undefined) {
            _name = item.entity_data.display_name;
        }
        _is_weapon = true;
    }
    // 武技/身法
    else if (scr_is_item_type(item.object_index, obj_skill_base) || scr_is_item_type(item.object_index, obj_agility_base)) {
        if (variable_instance_exists(item, "skill_id")) {
            _id = item.skill_id;
        } else if (variable_instance_exists(item, "agility_id")) {
            _id = item.agility_id;
        }
        if (item.entity_data != undefined) {
            _name = item.entity_data.display_name;
        }
        _is_skill = true;
    }
    // ★ 遗物
            else if (scr_is_item_type(item.object_index, obj_relic_base))   {
        if (variable_instance_exists(item, "relic_id")) {
            _id = item.relic_id;
        }
        if (item.entity_data != undefined) {
            _name = item.entity_data.display_name;
        }
        _is_relic = true;
    }
    else {
        return;
    }
    
    // ★ 如果 _id 为空，用 _name 代替
    if (_id == "" || _id == undefined) {
        _id = _name;
    }
    
    if (_id == "" || _id == undefined) return;
    
    // 检查是否"已解锁"
    var _is_new = true;
    
    if (_is_weapon) {
        for (var i = 0; i < array_length(player.unlocked_weapons); i++) {
            if (player.unlocked_weapons[i] == _id) {
                _is_new = false;
                break;
            }
        }
    } else if (_is_skill) {
        for (var i = 0; i < array_length(player.unlocked_skills); i++) {
            if (player.unlocked_skills[i] == _id) {
                _is_new = false;
                break;
            }
        }
    } else if (_is_relic) {
        for (var i = 0; i < array_length(player.unlocked_relics); i++) {
            if (player.unlocked_relics[i] == _id) {
                _is_new = false;
                break;
            }
        }
    }
    
    if (_is_new) {
        if (_is_weapon) {
            array_push(player.unlocked_weapons, _id);
        } else if (_is_skill) {
            array_push(player.unlocked_skills, _id);
        } else if (_is_relic) {
            array_push(player.unlocked_relics, _id);
        }
        
        // ★ 加到 obj_inventory_ui.unlock_popups
        var _ui = instance_find(obj_inventory_ui, 0);
        if (instance_exists(_ui)) {
            var _rarity_color = c_white;
            var _rarity_data = data_rarity_get(item.rarity);
            if (_rarity_data != undefined && variable_struct_exists(_rarity_data, "ui_color")) {
                var _color_str = _rarity_data.ui_color;
                if (is_string(_color_str)) {
                    _rarity_color = scr_get_color_from_hex(_color_str);
                } else {
                    _rarity_color = _color_str;
                }
            }
            
            _ui.unlock_popups = [];
            array_push(_ui.unlock_popups, {
                item: item,
                name: _name,
                rarity_color: _rarity_color,
                life_timer: 300,
                fade_start: 60,
                bob_timer: 0,
                pulse_timer: 0,
            });
        }
    }
}