/// @description 统一武技入口（仅玩家）
/// @param {id} weapon 武器实例
function scr_weapon_try_skill(weapon) {
    if (!instance_exists(weapon)) return;
    var _owner = weapon.owner_id;
    if (!instance_exists(_owner)) return;
    
    // 只处理玩家
    if (!object_is_ancestor(_owner.object_index, obj_player_base)) return;
    
    // ===== 检查武技槽 =====
    if (_owner.skill_slot == "" || _owner.skill_slot == noone) {
        if (_owner.input_right && _owner.skill_hint_cooldown <= 0) {
            scr_show_hint(_owner, "未装备武技");
            _owner.skill_hint_cooldown = 120;
        }
        return;
    }
    
    // ===== 检查兼容性 =====
    if (!scr_skill_is_compatible(_owner.skill_slot, weapon)) {
        if (_owner.input_right && _owner.skill_hint_cooldown <= 0) {
            scr_show_hint(_owner, "武器类型不匹配");
            _owner.skill_hint_cooldown = 120;
        }
        return;
    }
    
    var _skill_data = data_skill_get(_owner.skill_slot);
//show_debug_message("[DEBUG] skill_slot=" + string(_owner.skill_slot) + " | type=" + string(_skill_data != undefined ? _skill_data.type : "NULL"));

if (_skill_data != undefined && _skill_data.type == "附件") {
    scr_attachment_try_skill(weapon);
    return;
}
    
    // ===== 以下为普通武技逻辑（不变） =====
    
    // 检查冷却
    if (instance_exists(_owner.skill_instance) && _owner.skill_instance.cooldown_timer > 0) {
        // ★ 超频颗粒：冷却中允许"扣血强行释放"
        //   用户定案：先检查能不能放，**能放才扣血**（不会白扣）
        var _oc = scr_relic_passive_overclock_can_pay(_owner, "skill");
        if (!_oc.can) {
            if (_owner.input_right && _owner.skill_hint_cooldown <= 0) {
                scr_show_hint(_owner, "技能冷却中");
                _owner.skill_hint_cooldown = 120;
            }
            return;
        }

        // ===== 能超频：清掉冷却并扣血 =====
        if (_owner.input_right) {
            _owner.skill_instance.cooldown_timer = 0;      // 强行就绪
            scr_relic_passive_overclock_pay(_owner, "skill");

            if (_owner.skill_hint_cooldown <= 0) {
                scr_show_hint(_owner, "超频！");
                _owner.skill_hint_cooldown = 60;
            }
            // 不 return —— 继续走下面的蓄力/释放流程
        } else {
            return;
        }
    }
    
    // ===== 蓄力逻辑（状态在武器上） =====
    if (_owner.input_right) {
        if (!weapon.skill_charging) {
            if (instance_exists(_owner.skill_instance) && _owner.skill_instance.cooldown_timer <= 0) {
                weapon.skill_charging = true;
                weapon.skill_charge = 0;
            }
        }
        
        if (weapon.skill_charging) {
            weapon.skill_charge += 1/60;
            var _max_charge = data_skill_get(_owner.skill_slot).max_charge;
            if (weapon.skill_charge >= _max_charge) {
                weapon.skill_charge = _max_charge;
                scr_skill_cast(_owner, _owner.skill_slot, weapon.skill_charge, true);
                weapon.skill_charging = false;
                weapon.skill_charge = 0;
            }
        }
    } else {
        if (weapon.skill_charging) {
            scr_skill_cast(_owner, _owner.skill_slot, weapon.skill_charge, true);
            weapon.skill_charging = false;
            weapon.skill_charge = 0;
        }
    }
}