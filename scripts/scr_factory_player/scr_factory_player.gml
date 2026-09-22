// scr_factory_player_create.gml
function scr_factory_player_create(player_id, spawn_x, spawn_y) {
    var player_data = data_player_get(player_id);
    if (player_data == undefined) {
        show_debug_message("[FACTORY ERROR] 玩家数据不存在: " + player_id);
        return noone;
    }
    
    var _obj = player_data.object != undefined ? player_data.object : obj_player;
    var inst = instance_create_layer(spawn_x, spawn_y, "Instances", _obj);
    inst.inventory_size = player_data.inventory_size;
    inst.inventory_display_size = player_data.inventory_display_size;
    inst.character_id = player_id;
    inst.entity_data = player_data;
    inst.hp = player_data.max_hp;
    inst.max_hp = player_data.max_hp;
    inst.move_speed = player_data.move_speed;
    inst.armor = player_data.base_armor;
    inst.active_weapon_slot = player_data.active_weapon_slot;
    inst.level = player_data.level;
    inst.exp = player_data.exp;
    inst.exp_to_next = player_data.exp_to_next;
    inst.skill_points = player_data.skill_points;
    
    // ★ 不设 weapon_slots，交给 scr_factory_player_init
    
    scr_factory_player_init(inst);
    
    show_debug_message("[FACTORY] 玩家创建: " + player_id + " | 对象: " + object_get_name(_obj));
    return inst;
}