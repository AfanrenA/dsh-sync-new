// obj_relic_lightning_bolt Step

life -= 1;
if (life <= 0) {
    instance_destroy();
    exit;
}

// ===== ★ 跟随持有者 =====
if (instance_exists(follow_ref)) {
    x = follow_ref.x + follow_offset_x;
    y = follow_ref.y + follow_offset_y;
}

// ===== ★ 每帧重新生成骨架折线（狂暴变化的来源）=====
//    用 (帧号 + 种子) 驱动，形状持续变化
jitter_timer += 1;

var _seg = segment_count;
var _pts = [];
for (var s = 0; s <= _seg; s++) {
    var _t = s / _seg;

    // 基准点（从原始 points 插值）
    var _bx = 0;
    var _by = 0;
    if (array_length(points) >= 2) {
        var _src_n = array_length(points) - 1;
        var _ft = _t * _src_n;
        var _i0 = floor(_ft);
        var _i1 = min(_i0 + 1, _src_n);
        var _frac = _ft - _i0;
        _bx = lerp(points[_i0][0], points[_i1][0], _frac);
        _by = lerp(points[_i0][1], points[_i1][1], _frac);
    }

    // ★ 每帧剧烈抖动（首尾不抖）
    if (s > 0 && s < _seg) {
        var _wave = sin(jitter_seed + s * 1.3 + jitter_timer * 0.35);
        var _amp  = 8 + abs(_wave) * 22;                 // 8 ~ 30 像素
        var _perp = point_direction(0, 0, _bx, _by) + 90;
        if (_bx == 0 && _by == 0) _perp = random(360);

        _bx += lengthdir_x(random_range(-_amp, _amp), _perp);
        _by += lengthdir_y(random_range(-_amp, _amp), _perp);
    }

    array_push(_pts, [_bx, _by]);
}
points_live = _pts;   // ★ 供 Draw 使用

// ===== 伤害判定 =====
if (instance_exists(owner_ref) && array_length(points_live) >= 2) {
    var _target_obj = obj_enemy_base;
    if (object_is_ancestor(owner_ref.object_index, obj_enemy_base)) {
        _target_obj = obj_player_base;
    }

    for (var i = 0; i < array_length(points_live); i += 2) {
        var _px = x + points_live[i][0];
        var _py = y + points_live[i][1];

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
        _pkt.knockback = 2;
        _pkt.stun = 0.05;
        scr_damage_apply(_hit, _pkt, owner_ref);
        array_push(has_hit, _hit);
    }
}