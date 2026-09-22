// scr_damage_feedback.gml
// 受击反馈 - 支持暴击增强
// ★ 重构：护盾受击不击退不硬直；击退不再乘5；粒子统一走 scr_hit_effect_trigger

function scr_damage_feedback(target_inst, attack_dir, knockback_power, stun_duration, is_critical = false, has_shield = false, attacker_inst = noone) {
    if (!instance_exists(target_inst)) return;
    
    if (target_inst.is_dead || !target_inst.is_alive) {
        if (target_inst.character_type == "player") {
            scr_screen_effect_trigger(10, 20, "damage");
        }
        return;
    }
    
    var _mult = is_critical ? 2.0 : 1.0;
    
    // ===== 1. 闪白 =====
    target_inst.is_hit_flashing = true;
    target_inst.hit_flash_timer = target_inst.hit_flash_duration * 60 * _mult;
    
    // ===== 2. 护盾专属反馈（护盾优先，不显示暴击特效） =====
    if (has_shield) {
        if (target_inst.shield <= 0) {
            scr_hit_effect_trigger(target_inst.x, target_inst.y, "shield_break");
        } else {
            scr_hit_effect_trigger(target_inst.x, target_inst.y, "shield_hit");
        }
        
        if (target_inst.character_type == "player") {
            scr_screen_effect_trigger(3, 6, "shield");
        }
        return;
    }
    
    // ===== 3. 无护盾受击特效 =====
    if (target_inst.character_type == "player") {
        scr_hit_effect_trigger(target_inst.x, target_inst.y, "player_hit");
    } else {
        scr_hit_effect_trigger(target_inst.x, target_inst.y, "enemy_hit");
    }
    
    // ===== 4. 暴击叠加（仅无护盾时） =====
    if (is_critical) {
        scr_hit_effect_trigger(target_inst.x, target_inst.y, "critical");
    }
    
    // ===== 5. 硬直 =====
    var _stun_frames = 0;
    if (object_is_ancestor(target_inst.object_index, obj_player_base)) {
        _stun_frames = stun_duration * 60 * _mult;
    } else if (object_is_ancestor(target_inst.object_index, obj_enemy_base)) {
        var _enemy_stun = stun_duration * 0.3;
        _stun_frames = clamp(_enemy_stun * 60, 5, 15);
        _stun_frames = ceil(_stun_frames);
    }
    
    if (_stun_frames < 5) _stun_frames = 5;
    
    if (_stun_frames > 0) {
        target_inst.is_stunned = true;
        target_inst.stun_timer = _stun_frames;
    }
    
    // ===== 6. 受击反应（敌人） =====
    if (object_is_ancestor(target_inst.object_index, obj_enemy_base)) {
        if (target_inst.ai_state == "charging") {
            target_inst.ai_state = "attack";
            target_inst._charge_timer = 0;
            target_inst.skill_charge_target = 0;
            if (instance_exists(target_inst._telegraph_ref)) {
                instance_destroy(target_inst._telegraph_ref);
                target_inst._telegraph_ref = noone;
            }
            target_inst._was_interrupted = true;
            
            // ★ 蓄力冷却：被打断后 2 秒内不再蓄力
            target_inst.enemy_skill_cooldown = 120;
        }
    }
    
    // ===== 6.5. 受击强制索敌（持续 5 秒） =====
    if (attacker_inst != noone && instance_exists(attacker_inst)) {
        target_inst._aggro_timer = 300;
        target_inst._aggro_target = attacker_inst;
    }
    
    // ===== 7. 击退 =====
    var _knockback_dist = knockback_power * _mult;
    target_inst.x += lengthdir_x(_knockback_dist, attack_dir);
    target_inst.y += lengthdir_y(_knockback_dist, attack_dir);
    
    // ★ 被击退算"被迫位移" → 动能回收器回收电量（自主位移如闪避不算）
    //   ★ 每一次击退是**独立事件** → 用全局递增计数当 event_id，
    //     这样 max_hp_per_event 上限对"每次挨打"生效。
    //     （旧写法不传 id，同 source 连续挨打会共用额度 → 第二次起回不了血）
    if (_knockback_dist > 0) {
        global.__kinetic_event_seq = (variable_global_exists("__kinetic_event_seq") ? global.__kinetic_event_seq : 0) + 1;
        scr_relic_passive_kinetic_on_shift(target_inst, _knockback_dist, "knockback", global.__kinetic_event_seq);
    }
    
    // ★ 挨打即算战斗行为（脱战计时清零）
    scr_combat_mark_action(target_inst);
    
    // ===== 8. 屏幕效果 =====
    if (target_inst.character_type == "player") {
        var _intensity = is_critical ? 8 : 4;
        var _duration = is_critical ? 15 : 8;
        scr_screen_effect_trigger(_intensity, _duration, "damage");
    }
}