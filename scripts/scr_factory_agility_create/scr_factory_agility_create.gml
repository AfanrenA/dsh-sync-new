// scr_factory_agility_create.gml
function scr_factory_agility_create(agility_id, rarity_id, spawn_x, spawn_y, owner_id = noone) {
    var _data = data_agility_get(agility_id);
    if (_data == undefined) {
        show_debug_message("[AGILITY FACTORY] 身法数据不存在: " + agility_id);
        return noone;
    }
    
    var _rarity_data = data_rarity_get(rarity_id);
    if (_rarity_data == undefined) {
        show_debug_message("[AGILITY FACTORY] 品质数据不存在: " + rarity_id);
        return noone;
    }
    
    // ===== 从数据表读取对象 =====
   var _obj = obj_agility_base;
if (variable_struct_exists(_data, "object") && _data.object != undefined) {
    _obj = _data.object;
}
    
    var inst = instance_create_layer(spawn_x, spawn_y, "Instances", _obj);
    
    inst.agility_id = agility_id;          // ★ 保持字段名一致（scr_skill_equip 读这个）
    inst.agility_id = agility_id;         // ★ 身法自己的字段
    inst.rarity = rarity_id;
    inst.entity_data = _data;
    inst.rarity_data = _rarity_data;
    inst.display_name = _data.display_name;
    inst.owner_id = owner_id;
    inst.is_on_ground = (owner_id == noone || owner_id == -4);
    
    scr_factory_agility_init(inst);
    
    show_debug_message("[AGILITY FACTORY] 创建: " + agility_id + " | 对象: " + object_get_name(_obj));
    return inst;
}