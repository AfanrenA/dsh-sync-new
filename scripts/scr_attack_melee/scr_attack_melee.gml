// scr_attack_melee.gml
function scr_attack_melee(_owner, _weapon = noone) {
    if (!_owner.is_alive || _owner.is_dead) return;
    
    if (!instance_exists(_weapon)) {
        _weapon = _owner.current_weapon;
    }
    if (!instance_exists(_weapon)) return;
    
    if (_weapon.is_swinging) return;
    if (_weapon.cooldown_timer > 0) return;
    
    var _data = data_weapon_get(_weapon.weapon_id);
    if (_data == undefined) return;
    
    var _is_enemy = false;
    if (object_is_ancestor(_owner.object_index, obj_enemy_base)) {
        _is_enemy = true;
    }
    
    var _cooldown_multiplier = 1;
    if (_is_enemy) {
        _cooldown_multiplier = 0.5 + random(2.5);
        show_debug_message("[ATTACK] 敌人攻击 | 冷却倍率: " + string(_cooldown_multiplier));
    }
    
    var _swing_total = _data.swing_total_frames;
    if (_data.swing_up_frames != undefined && _data.swing_down_frames != undefined) {
        _swing_total = _data.swing_up_frames + _data.swing_down_frames;
    }
    
    _weapon.is_swinging = true;
    _weapon.swing_timer = _swing_total;
    _weapon.swing_total_frames = _swing_total;
    _weapon.slash_created = false;
    _weapon._swing_base_angle = _weapon.image_angle;
       // ★ 遗物：攻击冷却倍率
    var _relic_cd = 1.0;
    if (variable_instance_exists(_owner, "relic_attack_cd_mult")) {
        _relic_cd = _owner.relic_attack_cd_mult;
    }
    _weapon.cooldown_timer = _data.attack_speed * 60 * _cooldown_multiplier * _relic_cd;
    
    var _target_object = obj_enemy_base;
    if (_is_enemy) {
        _target_object = obj_player_base;
    }
    
    _weapon.hitbox_ref = scr_hitbox_create(
        _weapon,
        _owner,
                _weapon.final_stats.base_damage * scr_relic_get_damage_mult(_owner),
        _data.hitbox_life,
        _target_object
    );
    
    show_debug_message("[ATTACK] 近战攻击启动 | 武器: " + _weapon.weapon_id + " | 伤害: " + string(_weapon.final_stats.base_damage));
}