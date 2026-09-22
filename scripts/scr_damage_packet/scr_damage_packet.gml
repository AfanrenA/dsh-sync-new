// scr_damage_packet.gml
// 伤害包 - 纯数据容器，把"伤害来源"和"伤害结算"解耦
// 所有攻击（武器/技能/身法/遗物/投射物）都通过这里组包

/// @description 创建一个伤害包
/// @param {real} _damage 基础伤害
/// @returns {struct} 伤害包
function scr_damage_packet_create(_damage) {
    return {
        damage: _damage,
        crit_chance: 0,
        crit_multiplier: 1.5,
        can_crit: false,
        knockback: 5.0,
        stun: 0.1,
        element_type: "none",
        element_damage: 0,
        ignore_crit: false
    };
}

/// @description 从武器数据填包（近战/远程普攻）
function scr_damage_packet_from_weapon(_pkt, _weapon_data) {
    if (_weapon_data == undefined) return _pkt;
    
    if (variable_struct_exists(_weapon_data, "can_crit") && _weapon_data.can_crit) {
        _pkt.can_crit = true;
        _pkt.crit_chance = variable_struct_exists(_weapon_data, "crit_chance") ? _weapon_data.crit_chance : 0.1;
        _pkt.crit_multiplier = variable_struct_exists(_weapon_data, "crit_multiplier") ? _weapon_data.crit_multiplier : 1.5;
    }
    if (variable_struct_exists(_weapon_data, "knockback_power")) {
        _pkt.knockback = _weapon_data.knockback_power;
    }
    if (variable_struct_exists(_weapon_data, "stun_duration")) {
        _pkt.stun = _weapon_data.stun_duration;
    }
    return _pkt;
}

/// @description 从投射物自身填包（子弹/剑气，脱离武器独立结算）
function scr_damage_packet_from_projectile(_pkt, _proj) {
    if (!instance_exists(_proj)) return _pkt;
    
    if (variable_instance_exists(_proj, "has_projectile_crit") && _proj.has_projectile_crit) {
        _pkt.can_crit = true;
        _pkt.crit_chance = _proj.projectile_crit_chance;
        _pkt.crit_multiplier = _proj.projectile_crit_multiplier;
    }
    if (variable_instance_exists(_proj, "knockback_power")) {
        _pkt.knockback = _proj.knockback_power;
    }
    if (variable_instance_exists(_proj, "stun_duration")) {
        _pkt.stun = _proj.stun_duration;
    }
    if (variable_instance_exists(_proj, "element_type")) {
        _pkt.element_type = _proj.element_type;
    }
    return _pkt;
}