// ============================================================
// scr_character_resolve_collision - 完整修复版
// ============================================================

function scr_character_resolve_collision(inst) {
    if (!instance_exists(inst)) exit;
    if (inst.collision_comp == noone) exit;
    
    var _list = scr_component_collision_check(inst.collision_comp, inst.x, inst.y);
    var _count = ds_list_size(_list);
    
    var _blocked = false;
    var _damage_target = noone;
    
    for (var i = 0; i < _count; i++) {
        var _other = _list[| i];
        if (_other == inst) continue;
        if (!instance_exists(_other)) continue;
        
        var _is_character = (_other.collision_response == "damage");
        if (_is_character && _other.hp <= 0) continue;
        
        switch (_other.collision_response) {
            case "block":
                _blocked = true;
                break;
            case "damage":
                if (_other.hp > 0) _damage_target = _other;
                break;
            case "trigger":
                if (script_exists(_other.on_trigger_enter)) {
                    _other.on_trigger_enter(inst);
                }
                break;
            case "ignore":
                break;
        }
        if (_blocked) break;
    }
    
    // ===== 阻挡处理 =====
    if (_blocked) {
        // 完全回退
        inst.x = inst.xprevious;
        inst.y = inst.yprevious;
        
        // 分别尝试 X 和 Y 方向
        var _can_x = true;
        var _can_y = true;
        
        var _test_x = inst.xprevious + (inst.x - inst.xprevious);
        var _list_x = scr_component_collision_check(inst.collision_comp, _test_x, inst.y);
        for (var j = 0; j < ds_list_size(_list_x); j++) {
            var _other = _list_x[| j];
            if (_other == inst) continue;
            if (!instance_exists(_other)) continue;
            if (_other.collision_response == "block") {
                _can_x = false;
                break;
            }
        }
        ds_list_destroy(_list_x);
        
        var _test_y = inst.yprevious + (inst.y - inst.yprevious);
        var _list_y = scr_component_collision_check(inst.collision_comp, inst.x, _test_y);
        for (var k = 0; k < ds_list_size(_list_y); k++) {
            var _other = _list_y[| k];
            if (_other == inst) continue;
            if (!instance_exists(_other)) continue;
            if (_other.collision_response == "block") {
                _can_y = false;
                break;
            }
        }
        ds_list_destroy(_list_y);
        
        if (_can_x) inst.x = _test_x;
        if (_can_y) inst.y = _test_y;
        if (!_can_x && !_can_y) {
            inst.x = inst.xprevious;
            inst.y = inst.yprevious;
        }
        
        ds_list_destroy(_list);
        return;
    }
    
    // ===== 伤害碰撞 =====
    if (instance_exists(_damage_target)) {
        if (!instance_exists(inst) || !instance_exists(_damage_target)) {
            ds_list_destroy(_list);
            return;
        }
        if (inst.hp <= 0 || _damage_target.hp <= 0) {
            ds_list_destroy(_list);
            return;
        }
        
        if (inst.collision_damage_cooldown > 0 || _damage_target.collision_damage_cooldown > 0) {
            ds_list_destroy(_list);
            return;
        }
        
        // ---- 强制分离 ----
        var _dx = inst.x - _damage_target.x;
        var _dy = inst.y - _damage_target.y;
        var _dist = point_distance(0, 0, _dx, _dy);
        if (_dist < 20 && _dist > 0) {
            var _push = (20 - _dist) * 0.5 + 2;
            var _dir_sep = point_direction(_damage_target.x, _damage_target.y, inst.x, inst.y);
            inst.x += lengthdir_x(_push, _dir_sep);
            inst.y += lengthdir_y(_push, _dir_sep);
            _damage_target.x += lengthdir_x(_push, _dir_sep + 180);
            _damage_target.y += lengthdir_y(_push, _dir_sep + 180);
        }
        
        // ---- 计算伤害 ----
        var _rel_x = (inst.x - inst.xprevious) - (_damage_target.x - _damage_target.xprevious);
        var _rel_y = (inst.y - inst.yprevious) - (_damage_target.y - _damage_target.yprevious);
        var _rel_speed = point_distance(0, 0, _rel_x, _rel_y);
        
        var _damage = inst.collision_damage_base + floor(_rel_speed / 10);
        _damage = max(1, _damage);
        
        // ---- 扣血 ----
        scr_apply_damage(inst, _damage, _damage_target);
        scr_apply_damage(_damage_target, _damage, inst);
        
        // ---- 弹开 ----
        var _dir = point_direction(_damage_target.x, _damage_target.y, inst.x, inst.y);
        var _power = inst.collision_knockback_power + floor(_rel_speed / 15);
        _power = clamp(_power, 5, 30);
        
        inst.x += lengthdir_x(_power, _dir);
        inst.y += lengthdir_y(_power, _dir);
        _damage_target.x += lengthdir_x(_power, _dir + 180);
        _damage_target.y += lengthdir_y(_power, _dir + 180);
        
        // ---- ★ 弹开后立即进行碰撞修正，防止穿墙 ----
        scr_character_collision_correction(inst);
        scr_character_collision_correction(_damage_target);
        
        // ---- 受击反馈 ----
        scr_character_trigger_hit_response(inst, _dir);
        scr_character_trigger_hit_response(_damage_target, _dir + 180);
        
        // ---- 冷却 ----
        inst.collision_damage_cooldown = inst.collision_damage_cooldown_max;
        _damage_target.collision_damage_cooldown = _damage_target.collision_damage_cooldown_max;
        
        show_debug_message("💥 碰撞! " + string(object_get_name(inst.object_index)) + 
                           " ↔ " + string(object_get_name(_damage_target.object_index)) + 
                           " 伤害: " + string(_damage));
    }
    
    ds_list_destroy(_list);
    
    // ===== ★ 最后统一进行边界限制 =====
    scr_character_clamp_to_room(inst);
}