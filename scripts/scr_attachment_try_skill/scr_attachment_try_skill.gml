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
            if (_skill.cooldown_timer > 0 || _skill.ammo_current <= 0) {
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
            
            if (_skill.cooldown_timer > 0 || _skill.ammo_current <= 0) {
                _skill.aiming = false;
                return;
            }
            
            scr_attachment_fire(_owner, _skill, weapon);
            _skill.ammo_current -= 1;
            _skill.aiming = false;
            
            // ★ 打完最后一发 → 触发冷却
            if (_skill.ammo_current <= 0) {
                _skill.cooldown_timer = _skill.data.base_cooldown * 60;
            }
        }
    }
}