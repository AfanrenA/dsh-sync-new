/// @description 榴弹爆炸（范围伤害 + 击退 + 特效）
/// @param {id} grenade 榴弹实例
function scr_grenade_explode(grenade) {
    if (!instance_exists(grenade)) return;
    
    var _x = grenade.x;
    var _y = grenade.y;
    var _owner = grenade.owner_id;
    var _radius = grenade.explosion_radius;
    var _base_damage = grenade.explosion_damage;
    var _base_knockback = grenade.explosion_knockback;
    var _stun = grenade.explosion_stun_duration;
    var _falloff_min = grenade.explosion_falloff_min;
    
    // ===== 1. 扫范围内敌人 =====
    var _targets = [];
    with (obj_enemy_base) {
        if (!is_alive || is_dead) continue;
        var _dist = point_distance(x, y, _x, _y);
        if (_dist <= _radius) {
            array_push(_targets, id);
        }
    }
    
    // ===== 2. 对每个目标结算伤害 =====
    for (var i = 0; i < array_length(_targets); i++) {
        var _t = _targets[i];
        if (!instance_exists(_t)) continue;
        
        var _dist = point_distance(_x, _y, _t.x, _t.y);
        var _ratio = _dist / _radius;
        var _falloff = 1 - _ratio * (1 - _falloff_min);
        _falloff = clamp(_falloff, _falloff_min, 1.0);
        
        var _final_damage = _base_damage * _falloff;
        var _final_knockback = _base_knockback * _falloff;
        
        var _pkt = scr_damage_packet_create(_final_damage);
        _pkt.knockback = _final_knockback;
        if (_stun > 0) _pkt.stun = _stun;
        
        scr_damage_apply(_t, _pkt, _owner);
        scr_show_enemy_hpbar(_t);
    }
    
        // ===== 3. 视觉特效 =====
    var _fx = instance_create_layer(_x, _y, "Instances", obj_explosion_effect);
    if (instance_exists(_fx)) {
        _fx.max_radius = _radius;
    }
    
    // ★ 爆炸烟雾（多方向喷）
    scr_explosion_smoke(_x, _y, _radius);
    
    // ===== 4. 销毁榴弹 =====
    instance_destroy(grenade);
}