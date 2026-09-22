// scr_factory_enemy_init.gml
function scr_factory_enemy_init(enemy_inst) {
    var _data = enemy_inst.entity_data;
    if (_data == undefined) {
        show_debug_message("[ENEMY INIT] 错误：entity_data 是 undefined");
        return;
    }
    
    // ===== 通用状态 =====
    enemy_inst.is_alive = true;
    enemy_inst.is_hit_flashing = false;
    enemy_inst.hit_flash_timer = 0;
    enemy_inst.is_stunned = false;
    enemy_inst.stun_timer = 0;
    enemy_inst.hit_flash_duration = _data.hit_flash_duration;
    enemy_inst.hit_stun_duration = _data.hit_stun_duration;
    enemy_inst.hit_knockback_resist = _data.hit_knockback_resist;
    enemy_inst.move_dir_x = 0;
    enemy_inst.move_dir_y = 0;
    enemy_inst.facing_dir = 1;
    enemy_inst.current_weapon = noone;
    
    // ===== AI 状态 =====
    enemy_inst.ai_state = "patrol";
    enemy_inst.target = noone;
    enemy_inst.aggro_timer = 0;
    enemy_inst._patrol_timer = 60 + irandom(60);
    enemy_inst._patrol_dir = irandom(7) * 45;
    enemy_inst._attack_timer = 0;
    enemy_inst._ai_player = noone;
    enemy_inst._ai_dist = 0;
    enemy_inst._ai_dir = 0;
    enemy_inst._curious_timer = 300;
    enemy_inst._player_in_sight = false;
    
    // ===== 护盾系统 =====
    enemy_inst.max_shield = _data.max_shield != undefined ? _data.max_shield : 0;
    enemy_inst.shield = enemy_inst.max_shield;
    enemy_inst.shield_regen_rate = _data.shield_regen_rate != undefined ? _data.shield_regen_rate : 0;
    enemy_inst.shield_regen_delay = _data.shield_regen_delay != undefined ? _data.shield_regen_delay : 300;
    enemy_inst.shield_regen_timer = 0;
    enemy_inst.shield_charge_effect = false;
    enemy_inst.shield_charge_progress = 0;
    enemy_inst.shield_full_flash = 0;
    enemy_inst.shield_was_full = false;
    
    // ===== ★ 从配置创建武器（敌人只需要一个） =====
    var _config = _data.weapon_slots;
    if (array_length(_config) > 0) {
        var _slot_config = _config[0];
        if (_slot_config.weapon_id != undefined && _slot_config.weapon_id != "") {
            var _weapon_inst = scr_factory_weapon_create(
                _slot_config.weapon_id,
                _slot_config.rarity_id,
                enemy_inst.x,
                enemy_inst.y,
                enemy_inst.id
            );
            enemy_inst.current_weapon = _weapon_inst;
        }
    }
    
    // ===== 技能系统 =====
    if (_data.skill_id != undefined && _data.skill_id != "") {
        var _skill_inst = scr_factory_skill_create(
            _data.skill_id,
            _data.skill_rarity != undefined ? _data.skill_rarity : "common",
            enemy_inst.x, enemy_inst.y,
            enemy_inst.id
        );
        
        if (instance_exists(_skill_inst)) {
            enemy_inst.enemy_skill_id = _data.skill_id;
            enemy_inst.enemy_skill_instance = _skill_inst;
            enemy_inst.enemy_skill_use_chance = _data.skill_use_chance != undefined ? _data.skill_use_chance : 0.1;
            enemy_inst.enemy_skill_max_cooldown = _data.skill_cooldown != undefined ? _data.skill_cooldown : 300;
            enemy_inst.enemy_skill_cooldown = 0;
            _skill_inst.visible = false;
            _skill_inst.is_on_ground = false;
            _skill_inst.owner_id = enemy_inst;
        }
    }
    
    show_debug_message("[ENEMY INIT] 敌人初始化完成: " + enemy_inst.character_id);
}