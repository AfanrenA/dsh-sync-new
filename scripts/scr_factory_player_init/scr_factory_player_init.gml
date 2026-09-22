// scr_factory_player_init.gml
function scr_factory_player_init(player_inst) {
    var _data = player_inst.entity_data;
    if (_data == undefined) {
        show_debug_message("[PLAYER INIT] 错误：entity_data 是 undefined");
        return;
    }
    
    // ===== 通用状态 =====
    player_inst.is_alive = true;
    player_inst.is_hit_flashing = false;
    player_inst.hit_flash_timer = 0;
    player_inst.is_stunned = false;
    player_inst.stun_timer = 0;
    player_inst.hit_flash_duration = _data.hit_flash_duration;
    player_inst.hit_stun_duration = _data.hit_stun_duration;
    player_inst.hit_knockback_resist = _data.hit_knockback_resist;
    player_inst.move_dir_x = 0;
    player_inst.move_dir_y = 0;
    player_inst.facing_dir = 1;
    player_inst.current_weapon = noone;
    player_inst.is_invincible = false;
    player_inst.invincible_timer = 0;
    
    // ===== 护盾系统 =====
    player_inst.max_shield = _data.max_shield != undefined ? _data.max_shield : 0;
    player_inst.shield = player_inst.max_shield;
    player_inst.shield_regen_rate = _data.shield_regen_rate != undefined ? _data.shield_regen_rate : 0;
    player_inst.shield_regen_delay = _data.shield_regen_delay != undefined ? _data.shield_regen_delay : 300;
    player_inst.shield_regen_timer = 0;
    player_inst.shield_charge_effect = false;
    player_inst.shield_charge_progress = 0;
    player_inst.shield_full_flash = 0;
    player_inst.shield_was_full = false;
    
    // ===== 武器槽初始化 =====
    player_inst.weapon_slots = [noone, noone];
    player_inst.active_weapon_slot = 0;
    
    // ===== 从配置创建武器 =====
    var _config = _data.weapon_slots;
    if (array_length(_config) > 0) {
        for (var i = 0; i < array_length(_config); i++) {
            var _slot_config = _config[i];
            if (_slot_config.weapon_id != undefined && _slot_config.weapon_id != "") {
                var _weapon_inst = scr_factory_create("weapon", _slot_config.weapon_id, player_inst.x, player_inst.y, {
                    rarity: _slot_config.rarity_id,
                    owner: player_inst.id
                });
                player_inst.weapon_slots[i] = _weapon_inst;
            }
        }
    }
    
    // ===== 设当前武器 =====
    player_inst.current_weapon = player_inst.weapon_slots[player_inst.active_weapon_slot];
    
    show_debug_message("[PLAYER INIT] 玩家初始化完成: " + player_inst.character_id);
}