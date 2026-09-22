// scr_character_state_update.gml
/// @function scr_character_state_update(character)
/// @param {id} character 角色实例
/// @description 所有角色通用的状态更新（闪白、冷却、冲撞、硬直）

function scr_character_state_update(character) {
    // ===== 1. 闪白 =====
    if (character.is_hit_flashing) {
        character.hit_flash_timer -= 1;
        if (character.hit_flash_timer <= 0) {
            character.is_hit_flashing = false;
        }
    }
    
    // ===== 2. 护盾闪烁 =====
    if (character.is_shield_flashing) {
        character.shield_flash_timer -= 1;
        if (character.shield_flash_timer <= 0) {
            character.is_shield_flashing = false;
        }
    }
    
            // ===== 3. 技能冷却递减（含冷却结束瞬间触发闪烁） =====
    if (instance_exists(character.skill_instance)) {
        if (character.skill_instance.cooldown_timer > 0) {
            character.skill_instance.cooldown_timer -= 1;
            
            // ★ 附件装填判定（紧跟递减，用同一个 cooldown_timer）
            var _is_attachment = variable_instance_exists(character.skill_instance, "type") 
                                 && character.skill_instance.type == "附件";
            if (_is_attachment) {
                var _sk = character.skill_instance;
                var _total = _sk.data.base_cooldown * 60;
                var _elapsed = _total - _sk.cooldown_timer;
                var _progress = _elapsed / _total;
                var _should_have = floor(_progress * _sk.ammo_max);
                if (_should_have > _sk.ammo_max) _should_have = _sk.ammo_max;
                if (_sk.ammo_current < _should_have) {
                    _sk.ammo_current = _should_have;
                }
            }
            
            // ★ 冷却从 1 → 0 的瞬间才闪
            if (character.skill_instance.cooldown_timer == 0 && character.skill_slot != noone && character.skill_slot != "") {
                character.skill_flash_timer = 30;
                
                // ★ 附件装满处理
                if (_is_attachment) {
                    character.skill_instance.ammo_current = character.skill_instance.ammo_max;
                }
                
                // ★ 触发武器上的武技虚影（地上武器不触发）
                if (instance_exists(character.current_weapon) && !character.current_weapon.is_on_ground) {
                    
                    // ★ 附件型武技 + 远程武器 → 不闪武技虚影（改由榴弹匣 UI 提示）
                    var _weapon_is_ranged = variable_instance_exists(character.current_weapon, "max_ammo");
                    
                    if (!(_is_attachment && _weapon_is_ranged)) {
                        character.current_weapon.flash_skill_timer = 30;
                    }
                }
            }
        }
    }
    
    // ===== 3b. 身法冷却递减（含冷却结束瞬间触发闪烁） =====
    if (instance_exists(character.agility_instance)) {
        if (character.agility_instance.cooldown_timer > 0) {
            character.agility_instance.cooldown_timer -= 1;
            // ★ 冷却从 1 → 0 的瞬间才闪
            if (character.agility_instance.cooldown_timer == 0 && character.agility_slot != noone && character.agility_slot != "") {
                character.agility_flash_timer = 30;
            }
        }
    }
    
    // ★ 敌人技能冷却递减（玩家没有这个变量，用 variable_instance_exists 保护）
    if (variable_instance_exists(character, "enemy_skill_cooldown")) {
        if (character.enemy_skill_cooldown > 0) {
            character.enemy_skill_cooldown -= 1;
        }
    }
    
    // ===== 3c. 遗物冷却结束闪烁 =====
    // ★ 冷却本身由 obj_relic_base/Step_0 实例自减（含背包/地面，绑定实例不绑槽位）。
    //   这里只负责"冷却刚好走完"的瞬间触发闪烁，语义与武技/身法一致。
    //   用 _relic_prev_cd 记录上一帧值做"降沿检测"，避免依赖 Step 执行顺序：
    //   若写死 ==1，当遗物 Step 先跑（本帧已减到 0）就会漏掉闪烁。
    if (variable_instance_exists(character, "relic_slot") && instance_exists(character.relic_slot)) {
        var _rel = character.relic_slot;
        if (variable_instance_exists(_rel, "cooldown_timer")) {
            var _prev = variable_instance_exists(character, "_relic_prev_cd") ? character._relic_prev_cd : 0;
            if (_prev > 0 && _rel.cooldown_timer <= 0 && variable_instance_exists(character, "relic_flash_timer")) {
                character.relic_flash_timer = 30;
            }
            character._relic_prev_cd = max(_rel.cooldown_timer, 0);
        }
    }
    
    // ===== 4. 闪烁计时递减 =====
    if (character.skill_flash_timer > 0) character.skill_flash_timer -= 1;
    if (character.agility_flash_timer > 0) character.agility_flash_timer -= 1;
    if (variable_instance_exists(character, "relic_flash_timer")) {
        if (character.relic_flash_timer > 0) character.relic_flash_timer -= 1;
    }
    
    // ===== 5. 蛮牛冲撞更新 =====
    if (character.is_rushing) {
        var _dx = lengthdir_x(character.rush_speed, character.rush_dir);
        var _dy = lengthdir_y(character.rush_speed, character.rush_dir);
        var _new_x = character.x + _dx;
        var _new_y = character.y + _dy;
        
        if (place_meeting(_new_x, _new_y, obj_wall_base) ||
            place_meeting(_new_x, _new_y, obj_chest_base) ||
            place_meeting(_new_x, _new_y, obj_building_base)) {
            character.is_rushing = false;
            character.is_invincible = false;
            character.rush_traveled = 0;
            scr_rush_end_attack(character);
            exit;
        }
        
        character.x = _new_x;
        character.y = _new_y;
        character.rush_traveled += character.rush_speed;
        
        var _is_enemy = object_is_ancestor(character.rush_owner.object_index, obj_enemy_base);
        var _enemy_target = _is_enemy ? obj_player_base : obj_enemy_base;
        
        var _hit = collision_circle(character.x, character.y, 20, _enemy_target, false, true);
        if (_hit != noone && _hit != character.rush_owner) {
            var _already_hit = false;
            for (var i = 0; i < array_length(character.rush_hit_list); i++) {
                if (character.rush_hit_list[i] == _hit) {
                    _already_hit = true;
                    break;
                }
            }
            
            if (!_already_hit) {
                show_debug_message("[冲撞] 命中敌人 id=" + string(_hit) + " | hit_list长度=" + string(array_length(character.rush_hit_list)));
                var _pkt = scr_damage_packet_create(character.rush_damage);
_pkt.knockback = character.rush_knockback;
// 蛮牛暴击数据从哪来？下面说
scr_damage_apply(_hit, _pkt, character.rush_owner);
                array_push(character.rush_hit_list, _hit);
            } else {
                show_debug_message("[冲撞] 已命中过 id=" + string(_hit) + "，跳过");
            }
        }
        
        if (character.rush_traveled >= character.rush_distance) {
            character.is_rushing = false;
            character.is_invincible = false;
            character.rush_traveled = 0;
            scr_rush_end_attack(character);
        }
    }
    
    // ===== 6. 硬直递减 =====
    if (character.is_stunned) {
        character.stun_timer -= 1;
        if (character.stun_timer <= 0) {
            character.is_stunned = false;
            
            if (object_is_ancestor(character.object_index, obj_enemy_base)) {
                // 清除蓄力状态
                if (character.ai_state == "charging") {
                    character.ai_state = "attack";
                    character._charge_timer = 0;
                    if (instance_exists(character._telegraph_ref)) {
                        instance_destroy(character._telegraph_ref);
                        character._telegraph_ref = noone;
                    }
                }
                // ★ 强制恢复移动
                character.move_dir_x = 0;
                character.move_dir_y = 0;
                // 如果卡在 attack 状态但没有目标，回到 patrol
                if (!instance_exists(character.target) || !character.target.is_alive) {
                    character.ai_state = "patrol";
                }
                show_debug_message("[STATE] 敌人硬直恢复 | ai_state: " + string(character.ai_state));
            }
        }
    }
    
    // ===== 7. 受击停顿 =====
    if (character.hit_pause_timer > 0) {
        character.hit_pause_timer -= 1;
    }
}