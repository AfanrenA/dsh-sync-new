// scr_factory_create.gml
function scr_factory_create(type, id, x, y, extra = undefined) {
    // ===== 安全读取 extra 字段 =====
    var _rarity = "common";
    var _owner = noone;
    var _proj_dir = 0;
    var _target = noone;
    
    if (extra != undefined) {
        if (variable_struct_exists(extra, "rarity")) _rarity = extra.rarity;
        if (variable_struct_exists(extra, "owner")) _owner = extra.owner;
        if (variable_struct_exists(extra, "dir")) _proj_dir = extra.dir;
        if (variable_struct_exists(extra, "target")) _target = extra.target;
    }
    
    switch (type) {
        case "enemy":
            return scr_factory_enemy_create(id, x, y);
        
        case "weapon":
            return scr_factory_weapon_create(id, _rarity, x, y, _owner);
        
        case "skill":
            return scr_factory_skill_create(id, _rarity, x, y, _owner);
        
        case "player":
            return scr_factory_player_create(id, x, y);
        
        case "projectile":
            return scr_factory_projectile_create(id, x, y, _proj_dir, _owner, _target);
        
		case "agility":
            return scr_factory_agility_create(id, _rarity, x, y, _owner);
		case "relic":
            return scr_factory_relic_create(id, _rarity, x, y, _owner);
        default:
            show_debug_message("[FACTORY ERROR] 未知类型: " + type);
            return noone;
    }
}