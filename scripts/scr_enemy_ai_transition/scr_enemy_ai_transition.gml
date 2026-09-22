/// @function scr_enemy_ai_transition(enemy)
/// @param {id} enemy - 敌人实例
/// @description 唯一决策中心：根据感知数据和当前状态，决定下一个状态

function scr_enemy_ai_transition(enemy) {
    var p = enemy._perception;
    
    // ============================================================
    // 1. 最高优先级：无目标 / 目标丢失 / 目标死亡
    // ============================================================
    if (!p.has_target) {
        if (enemy.ai_state != "patrol") {
            enemy.ai_state = "patrol";
            // 清除战斗标识
            enemy._chase_triggered = false;
            enemy._need_turn = false;
            // 清除指示器
            if (instance_exists(enemy._indicator_ref)) {
                instance_destroy(enemy._indicator_ref);
                enemy._indicator_ref = noone;
            }
            // 清除预警
            if (instance_exists(enemy._telegraph_ref)) {
                instance_destroy(enemy._telegraph_ref);
                enemy._telegraph_ref = noone;
            }
            show_debug_message("[AI] " + object_get_name(enemy.object_index) + " 没有目标，回到巡逻");
        }
        return;
    }
    
    // 目标死亡检查
    if (instance_exists(p.target)) {
        if (!p.target.is_alive || p.target.is_dead) {
            if (enemy.ai_state != "patrol") {
                enemy.ai_state = "patrol";
                enemy._chase_triggered = false;
                enemy._need_turn = false;
                if (instance_exists(enemy._indicator_ref)) {
                    instance_destroy(enemy._indicator_ref);
                    enemy._indicator_ref = noone;
                }
                if (instance_exists(enemy._telegraph_ref)) {
                    instance_destroy(enemy._telegraph_ref);
                    enemy._telegraph_ref = noone;
                }
                show_debug_message("[AI] " + object_get_name(enemy.object_index) + " 目标死亡，回到巡逻");
            }
            return;
        }
    }
    
    // ============================================================
    // 2. 获取AI配置（从数据表读取）
    // ============================================================
    var _ai = enemy.entity_data.ai;
    var _attack_range = _ai.attack_range != undefined ? _ai.attack_range : 300;
    var _behind_range = _ai.behind_range != undefined ? _ai.behind_range : 150;
    
    // ============================================================
    // 3. 判断触发条件
    // ============================================================
    var _front_trigger = p.is_in_vision && p.is_in_aggro;
    var _behind_trigger = p.is_from_behind && p.dist < _attack_range * 2;
    var _can_chase = _front_trigger || _behind_trigger;
    
    // ============================================================
    // 4. 技能系统检测（用于 attack → charging 切换）
    // ============================================================
    var _has_skill = (enemy.enemy_skill_id != "" && enemy.enemy_skill_id != undefined);
    var _skill_ready = false;
    var _skill_range = _attack_range;
    var _skill_data = undefined;
    
    if (_has_skill) {
        _skill_data = data_skill_get(enemy.enemy_skill_id);
        if (_skill_data != undefined) {
            _skill_range = _skill_data.ai.use_range != undefined ? _skill_data.ai.use_range : _attack_range;
        }
        if (enemy.enemy_skill_cooldown <= 0) {
            _skill_ready = true;
        }
    }
    
    // ============================================================
    // 5. 状态切换决策
    // ============================================================
    
    // ----- 5.1 patrol 状态 -----
    if (enemy.ai_state == "patrol") {
        if (_can_chase) {
            enemy.ai_state = "chase";
            enemy._chase_triggered = true;
            
            // 感叹号
            if (!instance_exists(enemy._indicator_ref) || enemy._indicator_ref.indicator_type != "exclamation") {
                scr_enemy_spawn_indicator(enemy, "exclamation");
            }
            
            // 背后触发需要转身
            if (_behind_trigger && !_front_trigger) {
                enemy._need_turn = true;
                enemy._turn_timer = 15;
            } else {
                enemy._need_turn = false;
                enemy.facing_dir = sign(cos(degtorad(p.dir_to_target)));
                enemy.image_xscale = enemy.facing_dir;
            }
            
            show_debug_message("[AI] " + object_get_name(enemy.object_index) + " 进入追击状态");
        }
        return;
    }
    
    // ----- 5.2 chase 状态 -----
    if (enemy.ai_state == "chase") {
        // 出口：目标丢失
        if (p.is_lost) {
            enemy.ai_state = "patrol";
            enemy._chase_triggered = false;
            enemy._need_turn = false;
            if (instance_exists(enemy._indicator_ref)) {
                instance_destroy(enemy._indicator_ref);
                enemy._indicator_ref = noone;
            }
            show_debug_message("[AI] " + object_get_name(enemy.object_index) + " 目标丢失，回到巡逻");
            return;
        }
        
        // 出口：进入攻击范围 → attack
        if (p.dist < _attack_range * 0.9) {
            enemy.ai_state = "attack";
            enemy._attack_timer = 0;
			show_debug_message("[AI] attack状态 | skill_ready=" + string(_skill_ready) + " | cooldown=" + string(enemy.enemy_skill_cooldown) + " | dist=" + string(p.dist) + " | range=" + string(_skill_range));
            show_debug_message("[AI] " + object_get_name(enemy.object_index) + " 进入攻击状态");
            return;
        }
        return;
    }
    
    // ----- 5.3 attack 状态 -----
    if (enemy.ai_state == "attack") {
        // 出口：目标跑出攻击范围 → chase
        if (p.dist > _attack_range * 1.0) {
            enemy.ai_state = "chase";
            show_debug_message("[AI] " + object_get_name(enemy.object_index) + " 目标跑出攻击范围，继续追击");
            return;
        }
        
        if (_has_skill && _skill_ready && _skill_data != undefined) {
    if (p.dist < _skill_range * 1.2) {
        enemy.ai_state = "charging";
        enemy._charge_timer = 0;
        // ★ 蓄力目标不超过 max_charge
        var _max_charge = _skill_data.max_charge != undefined ? _skill_data.max_charge : 3;
        enemy.skill_charge_target = random_range(1.5, _max_charge);
        enemy.skill_charge_range = _skill_range;
        enemy.skill_charge_dir = p.dir_to_target;
        enemy._last_charge_dist = p.dist;
        
        // ★ 计算剑气实际飞行距离
                // ★ 统一走 scr_skill_get_final_distance，杜绝两套公式
        var _final_distance = scr_skill_get_final_distance(enemy, enemy.enemy_skill_id, enemy.skill_charge_target);
        
        // 预警线长度 = 剑气飞行距离
        scr_enemy_show_telegraph(enemy, enemy.skill_charge_dir, 50, _final_distance);
        
        show_debug_message("[AI] " + object_get_name(enemy.object_index) + 
            " 技能就绪，开始蓄力 | 目标: " + string(enemy.skill_charge_target) + "s | 剑气距离: " + string(_final_distance));
        return;
    }
}
        return;
    }
    
    // ----- 5.4 charging 状态 -----
if (enemy.ai_state == "charging") {
    // 出口：目标丢失 → 取消蓄力，回到 patrol
    if (p.is_lost) {
        enemy.ai_state = "patrol";
        // ★ 重置蓄力变量
        enemy._charge_timer = 0;
        enemy.skill_charge_target = 0;
        if (instance_exists(enemy._telegraph_ref)) {
            instance_destroy(enemy._telegraph_ref);
            enemy._telegraph_ref = noone;
        }
        show_debug_message("[AI] " + object_get_name(enemy.object_index) + " 目标丢失，取消蓄力");
        return;
    }
    
    // 出口：目标跑出攻击范围 → 回到 chase
    if (p.dist > _attack_range * 1.5) {
        enemy.ai_state = "chase";
        // ★ 重置蓄力变量
        enemy._charge_timer = 0;
        enemy.skill_charge_target = 0;
        if (instance_exists(enemy._telegraph_ref)) {
            instance_destroy(enemy._telegraph_ref);
            enemy._telegraph_ref = noone;
        }
        show_debug_message("[AI] " + object_get_name(enemy.object_index) + " 目标跑远，取消蓄力");
        return;
    }
    return;
}
    
    // ----- 5.5 兜底：未知状态 -----
    if (enemy.ai_state != "patrol" && enemy.ai_state != "chase" && 
        enemy.ai_state != "attack" && enemy.ai_state != "charging") {
        enemy.ai_state = "patrol";
        show_debug_message("[AI] " + object_get_name(enemy.object_index) + " 未知状态，回到巡逻");
    }
}