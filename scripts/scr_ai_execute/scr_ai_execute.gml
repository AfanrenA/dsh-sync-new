// ============================================================
// scr_ai_execute - AI 执行层（V3 模块化）
// 通用的行为执行函数
// ============================================================

/// @description 执行追击行为
/// @param {instance} _inst 敌人实例
/// @param {instance} _target 目标实例
/// @param {real} _speed 移动速度
/// @param {real} _stop_distance 停止距离（到达后停止）
function scr_ai_execute_chase(_inst, _target, _speed, _stop_distance = 10) {
    if (!instance_exists(_target)) return false;
    
    var _dist = point_distance(_inst.x, _inst.y, _target.x, _target.y);
    if (_dist <= _stop_distance) return false;
    
    var _dir = point_direction(_inst.x, _inst.y, _target.x, _target.y);
    
    // ★★★ 加调试 ★★★
    show_debug_message("🏃 追击: 距离=" + string(_dist) + " 速度=" + string(_speed) + " 方向=" + string(_dir));
    
    _inst.x += lengthdir_x(_speed, _dir);
    _inst.y += lengthdir_y(_speed, _dir);
    
    // 更新朝向
    if (abs(_target.x - _inst.x) > 5) {
        _inst.image_xscale = sign(_target.x - _inst.x);
    }
    
    return true;
}

/// @description 执行撤退行为
/// @param {instance} _inst 敌人实例
/// @param {instance} _target 目标实例
/// @param {real} _speed 移动速度
/// @param {real} _max_retreat 最大撤退距离
function scr_ai_execute_retreat(_inst, _target, _speed, _max_retreat = 200) {
    if (!instance_exists(_target)) return false;
    
    var _dir = point_direction(_target.x, _target.y, _inst.x, _inst.y);
    _inst.x += lengthdir_x(_speed, _dir);
    _inst.y += lengthdir_y(_speed, _dir);
    
    // 更新朝向（面向目标）
    if (abs(_target.x - _inst.x) > 5) {
        _inst.image_xscale = sign(_target.x - _inst.x);
    }
    
    return true;
}

/// @description 执行待机/游走行为
/// @param {instance} _inst 敌人实例
/// @param {real} _speed 移动速度
/// @param {real} _wander_radius 游走半径
function scr_ai_execute_idle(_inst, _speed = 1, _wander_radius = 50) {
    // 如果没有游走目标或到达目标，生成新的游走点
    if (!variable_instance_exists(_inst, "_wander_x") || 
        point_distance(_inst.x, _inst.y, _inst._wander_x, _inst._wander_y) < 10) {
        _inst._wander_x = _inst.x + irandom_range(-_wander_radius, _wander_radius);
        _inst._wander_y = _inst.y + irandom_range(-_wander_radius, _wander_radius);
        // 确保游走点在地图内
        _inst._wander_x = clamp(_inst._wander_x, 50, room_width - 50);
        _inst._wander_y = clamp(_inst._wander_y, 50, room_height - 50);
    }
    
    var _dir = point_direction(_inst.x, _inst.y, _inst._wander_x, _inst._wander_y);
    _inst.x += lengthdir_x(_speed, _dir);
    _inst.y += lengthdir_y(_speed, _dir);
}

/// @description 执行攻击行为
/// @param {instance} _inst 敌人实例
/// @param {instance} _target 目标实例
/// @param {instance} _weapon 武器实例
function scr_ai_execute_attack(_inst, _target, _weapon) {
    if (!instance_exists(_target)) return false;
    if (!instance_exists(_weapon)) return false;
    
    // ★★★ 检查武器是否能开火（按类型分化）★★★
    if (!_weapon.can_fire()) {
        // ★★★ 只有远程武器才尝试换弹（近战/投掷不会进入这里）★★★
        if (_weapon.weapon_type == "ranged" && _weapon.needs_reload()) {
            _weapon.start_reload();
        }
        return false;
    }
    
    // 获取攻击方向（指向目标）
    var _dir = point_direction(_inst.x, _inst.y, _target.x, _target.y);
    _weapon.base_angle = _dir;
    
    // 执行攻击
    if (_weapon.attack_behavior != undefined && script_exists(_weapon.attack_behavior)) {
        // 根据武器类型传递不同参数
        var _weapon_type = _weapon.weapon_type;
        if (_weapon_type == "ranged" || _weapon_type == "thrown") {
            script_execute(_weapon.attack_behavior, _inst);
        } else {
            // 近战攻击需要传递目标位置
            script_execute(_weapon.attack_behavior, _inst, _weapon, _target.x, _target.y);
        }
        
        _weapon.attack_cooldown = _weapon.cooldown;
        _weapon.cooldown_max = _weapon.cooldown;
        return true;
    }
    
    return false;
}