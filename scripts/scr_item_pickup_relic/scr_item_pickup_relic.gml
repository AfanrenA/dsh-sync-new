/// @function scr_item_pickup_relic(player, item)
/// @description 拾取本命遗物：优先装空槽，槽满进背包
function scr_item_pickup_relic(player, item) {
    if (!instance_exists(player)) return;
    if (!instance_exists(item)) return;
    if (!item.is_on_ground) return;

    var _display_name = item.entity_data != undefined ? item.entity_data.display_name : "未知遗物";

    // ===== 光晕处理 =====
    if (instance_exists(item.glow_ref)) {
        with (item.glow_ref) instance_destroy();
        item.glow_ref = noone;
    }

    // ===== 从地面移除 =====
    item.is_on_ground = false;
    item.owner_id = player;
    item.visible = false;

    // ===== 首次拾取提示 =====
    scr_check_first_pickup(player, item);

    // ===== ★ 优先装备到空槽 =====
    var _equipped = false;

    if (variable_instance_exists(player, "relic_slot")) {
        if (!instance_exists(player.relic_slot)) {
            // 遗物槽空 → 直接装备
            if (scr_relic_equip(player, item)) {
                _equipped = true;
                show_debug_message("[遗物] 自动装备到遗物槽");
            }
        }
    }

    // ===== 槽已占 → 加背包 =====
    if (!_equipped) {
        if (!scr_inventory_add(player, item)) {
            show_debug_message("[遗物] 背包已满");
            scr_show_hint(player, "背包已满");
            item.is_on_ground = true;
            item.owner_id = noone;
            item.visible = true;
            return;
        }
        item.visible = false;
        show_debug_message("[遗物] 拾取到背包: " + _display_name);
    }
}