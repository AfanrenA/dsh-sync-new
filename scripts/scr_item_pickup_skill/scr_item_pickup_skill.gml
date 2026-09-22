/// @function scr_item_pickup_skill(player, item)
function scr_item_pickup_skill(player, item) {
    var _skill_inst = item;
    if (!instance_exists(_skill_inst)) return;
    if (!_skill_inst.is_on_ground) return;
    
    // 光晕处理
    if (instance_exists(_skill_inst.glow_ref)) {
        with (_skill_inst.glow_ref) instance_destroy();
        _skill_inst.glow_ref = noone;
    }
    
    // 从地面移除
    _skill_inst.is_on_ground = false;
    _skill_inst.owner_id = player;
	scr_check_first_pickup(player, _skill_inst);
    
    var _slot_type = _skill_inst.entity_data.slot;   // "skill" | "agility"
    var _display_name = _skill_inst.entity_data != undefined ? _skill_inst.entity_data.display_name : "未知";
    
    // ===== ★ 优先装备到空槽 =====
    var _equipped = false;
    
    if (_slot_type == "skill") {
        if (!instance_exists(player.skill_instance)) {
            // 武技槽空 → 直接装备
            scr_skill_equip(player, _skill_inst);
            _equipped = true;
            show_debug_message("[技能] 自动装备到武技槽");
        }
    } 
    
    // ===== 槽已满 → 加背包 =====
    if (!_equipped) {
        if (!scr_inventory_add(player, _skill_inst)) {
            show_debug_message("[技能] 背包已满");
            scr_show_hint(player, "背包已满");   // ★ 加这行
            _skill_inst.is_on_ground = true;
            _skill_inst.owner_id = noone;
            return;
        }
        _skill_inst.visible = false;
        show_debug_message("[技能] 拾取到背包: " + _display_name);
    }
}