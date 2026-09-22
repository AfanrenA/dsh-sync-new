/// @description 对玩家背包数组排序：类型 → 品质（降序）→ 名字
///              全内联，无匿名函数，避开 GM 2026 作用域问题
/// @param {id} player 玩家实例
/// @returns {bool} 是否执行了排序
function scr_inventory_sort(player) {
    if (!instance_exists(player)) return false;
    
    var _inv = player.inventory;
    var _n = array_length(_inv);
    if (_n <= 1) return false;
    
    // 插入排序
    for (var i = 1; i < _n; i++) {
        var _key = _inv[i];
        
        // 预先算 key 的三个排序字段
                var _key_type = 99;
                var _key_type = 99;
        if (scr_is_item_type(_key.object_index, obj_weapon_base))       _key_type = 0;
        else if (scr_is_item_type(_key.object_index, obj_skill_base))   _key_type = 1;
        else if (scr_is_item_type(_key.object_index, obj_relic_base))   _key_type = 2;
        else if (scr_is_item_type(_key.object_index, obj_agility_base)) _key_type = 3;
        
        var _key_rarity = 0;
        if (variable_instance_exists(_key, "rarity") && _key.rarity != undefined && _key.rarity != "") {
            var _rd_k = data_rarity_get(_key.rarity);
            if (_rd_k != undefined) _key_rarity = _rd_k.tier;
        }
        
        var _key_name = "";
        if (variable_instance_exists(_key, "display_name") && _key.display_name != "") {
            _key_name = _key.display_name;
        }
        
        // 向前找插入位置
        var j = i - 1;
        while (j >= 0) {
            var _cur = _inv[j];
            
            // 算当前元素的三个排序字段
                        var _cur_type = 99;
                        var _cur_type = 99;
            if (scr_is_item_type(_cur.object_index, obj_weapon_base))       _cur_type = 0;
            else if (scr_is_item_type(_cur.object_index, obj_skill_base))   _cur_type = 1;
            else if (scr_is_item_type(_cur.object_index, obj_relic_base))   _cur_type = 2;
            else if (scr_is_item_type(_cur.object_index, obj_agility_base)) _cur_type = 3;
            
            var _cur_rarity = 0;
            if (variable_instance_exists(_cur, "rarity") && _cur.rarity != undefined && _cur.rarity != "") {
                var _rd_c = data_rarity_get(_cur.rarity);
                if (_rd_c != undefined) _cur_rarity = _rd_c.tier;
            }
            
            var _cur_name = "";
            if (variable_instance_exists(_cur, "display_name") && _cur.display_name != "") {
                _cur_name = _cur.display_name;
            }
            
            // 比较：_cur 应排在 _key 前面吗？
            var _cur_before = false;
            if (_cur_type != _key_type) {
                _cur_before = (_cur_type < _key_type);
            } else if (_cur_rarity != _key_rarity) {
                _cur_before = (_cur_rarity > _key_rarity);   // 品质降序
            } else {
                _cur_before = (_cur_name < _key_name);
            }
            
            if (_cur_before) break;
            _inv[j + 1] = _inv[j];
            j -= 1;
        }
        _inv[j + 1] = _key;
    }
    
    return true;
}