/// @description 附件型武技入口（右键：按下瞄准，松开发射）
/// @param {id} weapon 武器实例
function scr_attachment_try_skill(weapon) {
    if (!instance_exists(weapon)) return;
    var _owner = weapon.owner_id;
    if (!instance_exists(_owner)) return;
    
    var _skill = _owner.skill_instance;
    if (!instance_exists(_skill)) return;
    
    if (_owner.current_weapon != weapon) return;
    
    // ===== 状态机 =====
    if (!_skill.aiming) {
        if (mouse_check_button_pressed(mb_right)) {
            
            // ★ 后坐力期间禁止瞄准
            if (variable_instance_exists(_owner, "fire_recoil_timer") && _owner.fire_recoil_timer > 0) {
                if (_owner.skill_hint_cooldown <= 0) {
                    scr_show_hint(_owner, "后坐力中");
                    _owner.skill_hint_cooldown = 60;
                }
                return;
            }
            
            // 冷却中 或 没弹 → 不能瞄准
            //   ★ 例外：超频补弹刚放行（_oc_ready_shot）→ 允许这一发
            var _oc_pass = variable_instance_exists(_owner, "_oc_ready_shot") && _owner._oc_ready_shot;

            if ((_skill.cooldown_timer > 0 || _skill.ammo_current <= 0) && !_oc_pass) {
                // ★ 超频颗粒：允许"扣血补一发"（补弹，不动装填进度）
                //   用户定案：先检查能不能补，能补才扣血。
                var _rc = scr_relic_passive_overclock_can_refill(_owner);
                if (_rc.can) {
                    scr_relic_passive_overclock_refill(_owner);
                    if (_owner.skill_hint_cooldown <= 0) {
                        scr_show_hint(_owner, "超频装填！");
                        _owner.skill_hint_cooldown = 60;
                    }
                    // ★ 补完这一帧不放行 —— 让玩家**松手再按**，手感更清晰，
                    //   也避免"按住右键逐帧补弹"把血刷光。
                    //   （_oc_ready_shot 会保持到下一次按下时生效）
                    return;
                }

                if (_owner.skill_hint_cooldown <= 0) {
                    scr_show_hint(_owner, "榴弹装填中");
                    _owner.skill_hint_cooldown = 120;
                }
                return;
            }
            
            _skill.aiming = true;
            _skill.aiming_just_started = true;
            _skill.weapon_ref = weapon;
			// ★ 武器进入瞄准姿态
weapon._aim_state = "aiming";
weapon._aim_pitch = 15;
            // 不在这里记录 aim_target，交给 obj_aim_indicator Step 每帧写
        }
    } else {
        if (_skill.aiming_just_started) {
            _skill.aiming_just_started = false;
        } else if (mouse_check_button_released(mb_right)) {
            
            // ★ 超频放行：这一发允许无视"装填未完成"（补弹买来的通行证）
            var _oc_pass_fire = variable_instance_exists(_owner, "_oc_ready_shot") && _owner._oc_ready_shot;

            if ((_skill.cooldown_timer > 0 || _skill.ammo_current <= 0) && !_oc_pass_fire) {
                _skill.aiming = false;
                return;
            }
            
            scr_attachment_fire(_owner, _skill, weapon);
            _skill.ammo_current -= 1;
            _skill.aiming = false;
            
            // ★ 通行证用完即清（只放行这一发）
            if (_oc_pass_fire) {
                _owner._oc_ready_shot = false;
                _owner._oc_ready_shot_timer = 0;
            }
            
            // ★ 打完最后一发 → 触发冷却
            //   _oc_ready_shot 已清，所以这一发打完仍会正常进入装填
            if (_skill.ammo_current <= 0) {
                _skill.cooldown_timer = _skill.data.base_cooldown * 60;
            }
        }
    }
}