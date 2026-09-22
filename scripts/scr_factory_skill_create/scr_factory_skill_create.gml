// scr_factory_skill_create.gml
function scr_factory_skill_create(skill_id, rarity_id, spawn_x, spawn_y, owner_id = noone) {
    var _data = data_skill_get(skill_id);
    if (_data == undefined) {
        show_debug_message("[SKILL FACTORY] 武技数据不存在: " + skill_id);
        return noone;
    }
    
    var _rarity_data = data_rarity_get(rarity_id);
    if (_rarity_data == undefined) {
        show_debug_message("[SKILL FACTORY] 品质数据不存在: " + rarity_id);
        return noone;
    }
    
    // ===== 从数据表读取对象 =====
    var _obj = _data.object != undefined ? _data.object : obj_skill_base;
    
    var inst = instance_create_layer(spawn_x, spawn_y, "Instances", _obj);
    
    inst.skill_id = skill_id;
    inst.rarity = rarity_id;
    inst.entity_data = _data;
    inst.rarity_data = _rarity_data;
	inst.display_name = _data.display_name;
    inst.owner_id = owner_id;
    inst.is_on_ground = (owner_id == noone || owner_id == -4);
    
    scr_factory_skill_init(inst);
    
    show_debug_message("[SKILL FACTORY] 创建: " + skill_id + " | 对象: " + object_get_name(_obj));
    return inst;
}