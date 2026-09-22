/// @function scr_item_pickup_agility(player, item)
function scr_item_pickup_agility(player, item) {
    var _agility_inst = item;
    if (!instance_exists(_agility_inst)) return;
    if (!_agility_inst.is_on_ground) return;
    
    // 光晕处理
    if (instance_exists(_agility_inst.glow_ref)) {
        with (_agility_inst.glow_ref) instance_destroy();
        _agility_inst.glow_ref = noone;
    }
    
    // 从地面移除
    _agility_inst.is_on_ground = false;
    _agility_inst.owner_id = player;
    scr_check_first_pickup(player, _agility_inst);
    
    var _display_name = "未知身法";
    if (_agility_inst.entity_data != undefined && variable_struct_exists(_agility_inst.entity_data, "display_name")) {
        _display_name = _agility_inst.entity_data.display_name;
    }
    
    // ===== 优先装备到空槽 =====
    var _equipped = false;
    
    if (!instance_exists(player.agility_instance)) {
        scr_agility_equip(player, _agility_inst);
        _equipped = true;
        show_debug_message("[身法] 自动装备到身法槽");
    }
    
    // ===== 槽已满 → 加背包 =====
    if (!_equipped) {
        if (!scr_inventory_add(player, _agility_inst)) {
            show_debug_message("[身法] 背包已满");
            scr_show_hint(player, "背包已满");   // ★ 加这行
            _agility_inst.is_on_ground = true;
            _agility_inst.owner_id = noone;
            return;
        }
        _agility_inst.visible = false;
        show_debug_message("[身法] 拾取到背包: " + _display_name);
    }
}