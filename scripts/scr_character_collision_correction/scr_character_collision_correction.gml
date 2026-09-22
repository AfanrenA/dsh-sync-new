// ============================================================
// scr_character_collision_correction - 碰撞修正
// 把角色从墙/宝箱等碰撞体中推出来
// ============================================================

function scr_character_collision_correction(inst) {
    if (!instance_exists(inst)) exit;
    if (inst.collision_comp == noone) exit;
    
    // 最多尝试 5 次修正
    for (var _attempt = 0; _attempt < 5; _attempt++) {
        var _list = scr_component_collision_check(inst.collision_comp, inst.x, inst.y);
        var _blocked = false;
        
        for (var i = 0; i < ds_list_size(_list); i++) {
            var _other = _list[| i];
            if (_other == inst) continue;
            if (!instance_exists(_other)) continue;
            if (_other.collision_response == "block") {
                _blocked = true;
                break;
            }
        }
        ds_list_destroy(_list);
        
        if (!_blocked) break;
        
        // 逐步推开（向上一帧位置方向）
        var _dx = inst.x - inst.xprevious;
        var _dy = inst.y - inst.yprevious;
        if (_dx == 0 && _dy == 0) {
            // 如果没移动，随便找一个方向推开
            _dx = 1;
            _dy = 0;
        }
        var _dist = point_distance(0, 0, _dx, _dy);
        if (_dist > 0) {
            inst.x += (_dx / _dist) * 2;
            inst.y += (_dy / _dist) * 2;
        } else {
            inst.x += 2;
        }
    }
}