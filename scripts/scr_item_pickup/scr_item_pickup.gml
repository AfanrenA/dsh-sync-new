function scr_item_pickup(player, item) {
    if (!instance_exists(player)) return;
    if (!instance_exists(item)) return;
    if (!item.is_on_ground) return;
    
    if (scr_is_item_type(item.object_index, obj_weapon_base)) {
        scr_item_pickup_weapon(player, item);
    } else if (scr_is_item_type(item.object_index, obj_skill_base)) {
        scr_item_pickup_skill(player, item);
    } else if (scr_is_item_type(item.object_index, obj_agility_base)) {
        scr_item_pickup_agility(player, item);
    } else if (scr_is_item_type(item.object_index, obj_relic_base)) {
        scr_item_pickup_relic(player, item);
    } else {
        show_debug_message("[PICKUP] 未知物品类型: " + object_get_name(item.object_index));
    }
}