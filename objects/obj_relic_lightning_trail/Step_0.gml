// obj_relic_lightning_trail Step

if (!instance_exists(owner_ref)) {
    instance_destroy();
    exit;
}

// ===== 1. 所有点一起老化 =====
var _n = array_length(points);
var _all_dead = true;

for (var i = 0; i < _n; i++) {
    points[i][2] += 1;
    // ★ 注意：age 存的是"老化帧数"，不是"剩余寿命"
    if (points[i][2] < point_max_age) {
        _all_dead = false;
    }
}

// ===== 2. 全部老化完 → 销毁 =====
if (_n == 0 || _all_dead) {
    instance_destroy();
    exit;
}

// ===== 3. 持续伤害 =====
damage_timer -= 1;
if (damage_timer <= 0) {
    damage_timer = damage_interval;

    var _target_obj = obj_enemy_base;
    if (object_is_ancestor(owner_ref.object_index, obj_enemy_base)) {
        _target_obj = obj_player_base;
    }

    // ★ 只对"还活着"的点做判定，每 3 个取 1 个
    for (var i = 0; i < _n; i += 3) {
        if (points[i][2] >= point_max_age) continue;   // 已消失的点不判定

        var _px = points[i][0];
        var _py = points[i][1];

        var _hit = collision_circle(_px, _py, damage_radius, _target_obj, false, true);
        if (_hit == noone) continue;
        if (!_hit.is_alive || _hit.is_dead) continue;

        var _already = false;
        for (var j = 0; j < array_length(has_hit); j++) {
            if (has_hit[j] == _hit) { _already = true; break; }
        }
        if (_already) continue;

        var _pkt = scr_damage_packet_create(damage * scr_relic_get_damage_mult(owner_ref));
        _pkt.ignore_crit = true;
        _pkt.knockback = 1;
        _pkt.stun = 0.03;
        scr_damage_apply(_hit, _pkt, owner_ref);
        array_push(has_hit, _hit);
    }
}