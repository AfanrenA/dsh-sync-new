// scr_factory_weapon_create.gml
function scr_factory_weapon_create(weapon_id, rarity_id, spawn_x, spawn_y, owner_id) {
    var weapon_data = data_weapon_get(weapon_id);
    if (weapon_data == undefined) {
        show_debug_message("[FACTORY ERROR] 武器数据不存在: " + weapon_id);
        return noone;
    }
    
    // ===== ★ 如果 rarity_id 无效，从数据表随机生成 =====
    if (rarity_id == undefined || rarity_id == "") {
        var _range = weapon_data.rarity_range;
        if (_range != undefined && array_length(_range) == 2) {
            var _tier = irandom_range(_range[0], _range[1]);
            var _rarity_list = ["common", "rare", "elite", "epic", "legendary", "mythic", "divine"];
            if (_tier >= 1 && _tier <= 7) {
                rarity_id = _rarity_list[_tier - 1];
            } else {
                rarity_id = "common";
            }
        } else {
            rarity_id = "common";
        }
        show_debug_message("[FACTORY] 自动生成品质: " + rarity_id + " (范围: " + string(_range) + ")");
    }
    
    var rarity_data = data_rarity_get(rarity_id);
    if (rarity_data == undefined) {
        show_debug_message("[FACTORY ERROR] 品质数据不存在: " + rarity_id + "，使用 common");
        rarity_id = "common";
        rarity_data = data_rarity_get("common");
        if (rarity_data == undefined) {
            return noone;
        }
    }
    
    // ===== 从数据表读取对象 =====
    var _obj = weapon_data.object != undefined ? weapon_data.object : obj_weapon_melee_base;
    
    var inst = instance_create_layer(spawn_x, spawn_y, "Instances", _obj);
    
    inst.weapon_id = weapon_id;
    inst.rarity = rarity_id;
    inst.entity_data = weapon_data;
    inst.rarity_data = rarity_data;
    inst.final_stats = data_weapon_get_final_stats(weapon_id, rarity_id);
    inst.owner_id = owner_id;
    inst.is_on_ground = (owner_id == noone);
    inst.rarity_color = scr_get_rarity_color(rarity_id);
    inst.display_name = weapon_data.display_name;
    inst.keep_glow_on_pickup = weapon_data.keep_glow_on_pickup != undefined ? weapon_data.keep_glow_on_pickup : true;
    
    scr_factory_weapon_init(inst);
    
    if (inst.is_on_ground) {
        scr_glow_attach(inst);
    }
    
    show_debug_message("[FACTORY] 武器创建: " + weapon_id + " | 品质: " + rarity_id + " | 对象: " + object_get_name(_obj));
    return inst;
}