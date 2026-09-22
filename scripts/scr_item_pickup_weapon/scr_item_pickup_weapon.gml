/// @function scr_item_pickup_weapon(player, item)
function scr_item_pickup_weapon(player, item) {
    var _weapon = item;
    if (!instance_exists(_weapon)) return;
    if (!_weapon.is_on_ground) return;
    
    // 光晕处理
    if (_weapon.keep_glow_on_pickup == false) {
        if (instance_exists(_weapon.glow_ref)) {
            with (_weapon.glow_ref) instance_destroy();
            _weapon.glow_ref = noone;
        }
    }
    
    _weapon.is_on_ground = false;
_weapon.owner_id = player;

// ★ 检查首次拾取
scr_check_first_pickup(player, _weapon);
    
    // ===== ★ 优先装备到空槽 =====
    var _equipped = false;
    for (var i = 0; i < array_length(player.weapon_slots); i++) {
        if (!instance_exists(player.weapon_slots[i])) {
            // 空槽 → 直接装备
            scr_weapon_equip(player, _weapon, i);
            _equipped = true;
            show_debug_message("[武器] 自动装备到槽 " + string(i));
            break;
        }
    }
    
    // ===== 没有空槽 → 加背包 =====
    if (!_equipped) {
        if (!scr_inventory_add(player, _weapon)) {
            show_debug_message("[武器] 背包已满");
            scr_show_hint(player, "背包已满");   // ★ 加这行
            _weapon.is_on_ground = true;
            _weapon.owner_id = noone;
            return;
        }
        _weapon.visible = false;
        show_debug_message("[武器] 拾取到背包: " + string(_weapon.weapon_id));
    }
}