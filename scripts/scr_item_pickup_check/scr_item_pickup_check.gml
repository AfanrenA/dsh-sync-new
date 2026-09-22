/// @function scr_item_pickup_check(player)
/// @param {id} player 玩家实例

function scr_item_pickup_check(player) {
    // 重置所有地面物品的提示
    with (obj_weapon_base) {
        if (is_on_ground) pickup_hint_visible = false;
    }
    with (obj_skill_base) {
        if (is_on_ground) pickup_hint_visible = false;
    }
    with (obj_agility_base) {
        if (is_on_ground) pickup_hint_visible = false;
    }
    // ★ 遗物
    with (obj_relic_base) {
        if (is_on_ground) pickup_hint_visible = false;
    }
    
    var nearest_item = noone;
    var nearest_dist = 120;
    
    // 检测武器
    with (obj_weapon_base) {
        if (is_on_ground) {
            var dist = point_distance(x, y, other.x, other.y);
            if (dist < 120) {
                pickup_hint_visible = true;
                var _center_x = (bbox_left + bbox_right) / 2;
                var _center_y = (bbox_top + bbox_bottom) / 2;
                var _sprite_h = bbox_bottom - bbox_top;
                pickup_hint_x = _center_x;
                pickup_hint_y = _center_y - _sprite_h / 2 - 30;
                if (dist < nearest_dist) {
                    nearest_dist = dist;
                    nearest_item = id;
                }
            }
        }
    }
    
    // ★ 检测技能
    with (obj_skill_base) {
        if (is_on_ground) {
            var dist = point_distance(x, y, other.x, other.y);
            if (dist < 120) {
                pickup_hint_visible = true;
                var _center_x = (bbox_left + bbox_right) / 2;
                var _center_y = (bbox_top + bbox_bottom) / 2;
                var _sprite_h = bbox_bottom - bbox_top;
                pickup_hint_x = _center_x;
                pickup_hint_y = _center_y - _sprite_h / 2 - 30;
                if (dist < nearest_dist) {
                    nearest_dist = dist;
                    nearest_item = id;
                }
            }
        }
    }
    
    // ★ 检测身法
    with (obj_agility_base) {
        if (is_on_ground) {
            var dist = point_distance(x, y, other.x, other.y);
            if (dist < 120) {
                pickup_hint_visible = true;
                var _center_x = (bbox_left + bbox_right) / 2;
                var _center_y = (bbox_top + bbox_bottom) / 2;
                var _sprite_h = bbox_bottom - bbox_top;
                pickup_hint_x = _center_x;
                pickup_hint_y = _center_y - _sprite_h / 2 - 30;
                if (dist < nearest_dist) {
                    nearest_dist = dist;
                    nearest_item = id;
                }
            }
        }
    }
    
    // ★ 检测遗物
    with (obj_relic_base) {
        if (is_on_ground) {
            var dist = point_distance(x, y, other.x, other.y);
            if (dist < 120) {
                pickup_hint_visible = true;
                var _center_x = (bbox_left + bbox_right) / 2;
                var _center_y = (bbox_top + bbox_bottom) / 2;
                var _sprite_h = bbox_bottom - bbox_top;
                pickup_hint_x = _center_x;
                pickup_hint_y = _center_y - _sprite_h / 2 - 30;
                if (dist < nearest_dist) {
                    nearest_dist = dist;
                    nearest_item = id;
                }
            }
        }
    }
    
       if (keyboard_check_pressed(ord("F"))) {
        // ★★★ DEBUG ★★★
        show_debug_message("=== [拾取] F 按下 ===");
        show_debug_message("nearest_item = " + string(nearest_item));
        show_debug_message("exists = " + string(instance_exists(nearest_item)));
        if (nearest_item != noone) {
            show_debug_message("object = " + object_get_name(nearest_item.object_index));
            show_debug_message("is_on_ground = " + string(nearest_item.is_on_ground));
        } else {
            show_debug_message("object = 无（没扫到任何物品）");
        }
        show_debug_message("====================");
        
        if (nearest_item != noone) {
            scr_item_pickup(player, nearest_item);
        }
    }
}