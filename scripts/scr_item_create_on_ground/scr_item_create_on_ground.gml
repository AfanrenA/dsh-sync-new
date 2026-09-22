function scr_item_create_on_ground(item_type, item_id, x, y, rarity = "common", extra = undefined) {
    var _item_ref = noone;
    
    switch (item_type) {
        case "weapon":
            _item_ref = scr_factory_create("weapon", item_id, x, y, { rarity: rarity, owner: noone });
            if (!instance_exists(_item_ref)) return noone;
            
            _item_ref.is_on_ground = true;
            _item_ref.owner_id = noone;
            _item_ref.visible = true;
            _item_ref.depth = 105;
            
            // ★ 挂光晕
            scr_glow_attach(_item_ref);
            break;
            
        case "skill":
            _item_ref = scr_factory_create("skill", item_id, x, y, { rarity: rarity, owner: noone });
            if (!instance_exists(_item_ref)) return noone;
            
            _item_ref.is_on_ground = true;
            _item_ref.owner_id = noone;
            _item_ref.visible = true;
            _item_ref.depth = 105;
            
            // ★ 挂光晕
            scr_glow_attach(_item_ref);
            break;
            
        case "agility":
            _item_ref = scr_factory_create("agility", item_id, x, y, { rarity: rarity, owner: noone });
            if (!instance_exists(_item_ref)) return noone;
            
            _item_ref.is_on_ground = true;
            _item_ref.owner_id = noone;
            _item_ref.visible = true;
            _item_ref.depth = 105;
            
            // ★ 挂光晕
            scr_glow_attach(_item_ref);
            break;
			
        case "relic":
            _item_ref = scr_factory_create("relic", item_id, x, y, { rarity: rarity, owner: noone });
            if (!instance_exists(_item_ref)) return noone;
            
            _item_ref.is_on_ground = true;
            _item_ref.owner_id = noone;
            _item_ref.visible = true;
            _item_ref.depth = 105;
            
            // ★ 挂光晕
            scr_glow_attach(_item_ref);
            break;
        
        // ★ 被动遗物（纯数据池，掉在地上只为"可以被拾取"）
        case "relic_passive":
            _item_ref = scr_factory_relic_passive_create(item_id, rarity, x, y);
            if (!instance_exists(_item_ref)) return noone;
            
            _item_ref.is_on_ground = true;
            _item_ref.owner_id = noone;
            _item_ref.visible = true;
            _item_ref.depth = 105;
            break;
            
        default:
            show_debug_message("[ITEM] 未知物品类型: " + item_type);
            return noone;
    }
    
    show_debug_message("[ITEM] 地面创建: " + item_type + " | " + item_id + " | " + rarity);
    return _item_ref;
}