// ============================================================
// scr_apply_damage - 统一伤害函数（带击退）
// ============================================================

function scr_apply_damage(_target, _damage, _source = noone, _dir = -1) {
    // ===== 安全检查 =====
    if (!instance_exists(_target)) return;
    if (_target.hp <= 0) return;
    if (_damage <= 0) return;
    
    // ===== 保存目标信息（在实例销毁前保存） =====
    var _target_name = object_get_name(_target.object_index);
    var _is_player = object_is_ancestor(_target.object_index, obj_player_base);
    var _hp_before = _target.hp;
    
    // ===== 计算方向 =====
    if (_dir == -1 && instance_exists(_source)) {
        _dir = point_direction(_source.x, _source.y, _target.x, _target.y);
    }
    if (_dir == -1) _dir = 0;
    
    // ===== 扣血 =====
    _target.hp -= _damage;
    if (_target.hp < 0) _target.hp = 0;
    
    // ===== 受击反馈（闪白 + 硬直） =====
    scr_character_trigger_hit_response(_target, _dir);
    
    // ===== 击退 =====
    if (instance_exists(_source)) {
        var _power = 6 + _damage * 0.1;
        _power = clamp(_power, 3, 15);
        _target.x += lengthdir_x(_power, _dir);
        _target.y += lengthdir_y(_power, _dir);
        
        if (_target.collision_comp != noone) {
            scr_character_resolve_collision(_target);
        }
    }
    
    // ===== 死亡检测 =====
    var _is_dead = (_target.hp <= 0);
    if (_is_dead) {
        scr_character_die(_target);
    }
    
    // ===== 屏幕震动（仅玩家受击时） =====
    if (_is_player) {
        // 延后实现
        // scr_camera_shake(3, 6);
    }
    
    // ===== 调试 =====
    show_debug_message("⚔️ 伤害: " + string(_damage) + " → " + _target_name + 
                       " HP: " + string(_hp_before) + "→" + string(_target.hp));
}