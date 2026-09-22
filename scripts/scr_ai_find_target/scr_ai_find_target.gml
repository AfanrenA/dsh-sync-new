// ============================================================
// scr_ai_find_target - 查找最近的玩家
// ============================================================

function scr_ai_find_target(_inst, _max_range) {
    var _target = noone;
    var _min_dist = _max_range;
    
    // 找玩家
    with (obj_player) {
        if (!instance_exists(id)) continue;
        if (hp <= 0) continue;
        var _dist = point_distance(_inst.x, _inst.y, x, y);
        if (_dist < _min_dist) {
            _target = id;
            _min_dist = _dist;
        }
    }
    
    // 如果没找到，再找 obj_player_base
    if (!instance_exists(_target)) {
        with (obj_player_base) {
            if (!instance_exists(id)) continue;
            if (hp <= 0) continue;
            var _dist = point_distance(_inst.x, _inst.y, x, y);
            if (_dist < _min_dist) {
                _target = id;
                _min_dist = _dist;
            }
        }
    }
    
    return _target;
}