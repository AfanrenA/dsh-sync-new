// scr_factory_enemy_create.gml

function scr_factory_enemy_create(enemy_id, spawn_x, spawn_y) {
    var enemy_data = data_enemy_get(enemy_id);
    if (enemy_data == undefined) {
        show_debug_message("[FACTORY ERROR] 敌人数据不存在: " + enemy_id);
        return noone;
    }
    
    var _obj = enemy_data.object != undefined ? enemy_data.object : obj_enemy_base;
    var inst = instance_create_layer(spawn_x, spawn_y, "Instances", _obj);
    
    inst.character_id = enemy_id;
    inst.entity_data = enemy_data;
    inst.character_type = "enemy";
    
    // ===== 基础属性 =====
    inst.max_hp = enemy_data.max_hp;
    inst.hp = enemy_data.max_hp;
    inst.move_speed = enemy_data.move_speed;
    inst.armor = enemy_data.base_armor;
    
    // ===== 护盾 =====
    if (enemy_data.max_shield != undefined) {
        inst.max_shield = enemy_data.max_shield;
        inst.shield = enemy_data.max_shield;
    }
    if (enemy_data.shield_regen_rate != undefined) {
        inst.shield_regen_rate = enemy_data.shield_regen_rate;
    }
    if (enemy_data.shield_regen_delay != undefined) {
        inst.shield_regen_delay = enemy_data.shield_regen_delay;
    }
    
    // ===== 受击反馈 =====
    inst.hit_flash_duration = enemy_data.hit_flash_duration;
    inst.hit_knockback_resist = enemy_data.hit_knockback_resist;
    inst.hit_stun_duration = enemy_data.hit_stun_duration;
    
    // ★ 删除"武器槽"两行（武器创建交给 scr_factory_enemy_init）
    
    // ===== 技能系统 =====
    if (enemy_data.skill_id != undefined) {
        inst.enemy_skill_id = enemy_data.skill_id;
        inst.enemy_skill_rarity = enemy_data.skill_rarity != undefined ? enemy_data.skill_rarity : "common";
        inst.enemy_skill_use_chance = enemy_data.skill_use_chance != undefined ? enemy_data.skill_use_chance : 0.5;
        inst.enemy_skill_max_cooldown = enemy_data.skill_cooldown != undefined ? enemy_data.skill_cooldown : 300;
        inst.enemy_skill_cooldown = 0;
    }
    
    // ===== 从数据表读取 AI 配置 =====
    if (enemy_data.ai != undefined) {
        var _ai = enemy_data.ai;
        inst.aggro_range = _ai.aggro_range != undefined ? _ai.aggro_range : 800;
        inst.attack_range = _ai.attack_range != undefined ? _ai.attack_range : 300;
        inst.patrol_speed = _ai.patrol_speed != undefined ? _ai.patrol_speed : 1;
        inst.chase_speed = _ai.chase_speed != undefined ? _ai.chase_speed : 1.5;
    }
    
    // ===== 派系 =====
    inst.faction_id = enemy_data.faction_id;
    inst.faction_data = data_faction_get(enemy_data.faction_id);
    
    // ===== 初始化敌人 =====
    scr_factory_enemy_init(inst);
    
    show_debug_message("[FACTORY] 敌人创建: " + enemy_id + " | 对象: " + object_get_name(_obj));
    return inst;
}