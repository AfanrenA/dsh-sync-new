// ============================================================
// scr_ai_core - AI 核心框架（V3 模块化）
// 所有敌人共用，提供通用AI能力
// ============================================================

/// @description 获取最近的玩家目标
/// @param {instance} _inst 敌人实例
/// @param {real} _max_range 最大索敌范围（0表示不限制）
/// @returns {instance} 玩家实例 或 noone
function scr_ai_get_target(_inst, _max_range = 0) {
    var _target = noone;
    var _min_dist = _max_range;
    
    // 遍历所有玩家（支持多人）
    with (obj_player) {
        if (!instance_exists(id)) continue;
        if (hp <= 0) continue;
        
        var _dist = point_distance(_inst.x, _inst.y, x, y);
        if (_max_range > 0 && _dist > _max_range) continue;
        
        if (_target == noone || _dist < _min_dist) {
            _target = id;
            _min_dist = _dist;
        }
    }
    
    // 如果没有找到目标，检查 obj_player_base（玩家基类）
    if (_target == noone) {
        with (obj_player_base) {
            if (!instance_exists(id)) continue;
            if (hp <= 0) continue;
            
            var _dist = point_distance(_inst.x, _inst.y, x, y);
            if (_max_range > 0 && _dist > _max_range) continue;
            
            if (_target == noone || _dist < _min_dist) {
                _target = id;
                _min_dist = _dist;
            }
        }
    }
    
    return _target;
}

/// @description 检测目标是否在攻击范围内
/// @param {instance} _inst 敌人实例
/// @param {instance} _target 目标实例
/// @param {real} _attack_range 攻击范围
/// @returns {bool}
function scr_ai_can_attack(_inst, _target, _attack_range) {
    if (!instance_exists(_target)) return false;
    var _dist = point_distance(_inst.x, _inst.y, _target.x, _target.y);
    return _dist <= _attack_range;
}

/// @description 检测目标是否在索敌范围内
/// @param {instance} _inst 敌人实例
/// @param {instance} _target 目标实例
/// @param {real} _aggro_range 索敌范围
/// @returns {bool}
function scr_ai_in_aggro_range(_inst, _target, _aggro_range) {
    if (!instance_exists(_target)) return false;
    var _dist = point_distance(_inst.x, _inst.y, _target.x, _target.y);
    return _dist <= _aggro_range;
}

/// @description 获取移动到目标点的方向
/// @param {instance} _inst 敌人实例
/// @param {real} _target_x 目标X
/// @param {real} _target_y 目标Y
/// @returns {real} 角度（0~360）
function scr_ai_get_direction(_inst, _target_x, _target_y) {
    return point_direction(_inst.x, _inst.y, _target_x, _target_y);
}

/// @description 获取到目标的距离
/// @param {instance} _inst 敌人实例
/// @param {instance} _target 目标实例
/// @returns {real}
function scr_ai_get_distance(_inst, _target) {
    if (!instance_exists(_target)) return 9999;
    return point_distance(_inst.x, _inst.y, _target.x, _target.y);
}

/// @description 选择随机行为（根据权重）
/// @param {struct} _weights 权重表 { chase: 50, attack: 40, ... }
/// @returns {string} 选中的行为名称
function scr_ai_choose_behavior(_weights) {
    var _total = 0;
    var _keys = ds_list_create();
    var _values = ds_list_create();
    
    // ★ 手动遍历 struct 的键（GMS2 不支持 for-in）
    var _keys_list = struct_get_names(_weights);
    for (var i = 0; i < array_length(_keys_list); i++) {
        var _key = _keys_list[i];
        ds_list_add(_keys, _key);
        var _val = _weights[$ _key];
        ds_list_add(_values, _val);
        _total += _val;
    }
    
    if (_total <= 0) {
        ds_list_destroy(_keys);
        ds_list_destroy(_values);
        return "idle";
    }
    
    var _roll = random(_total);
    var _cumulative = 0;
    for (var i = 0; i < ds_list_size(_keys); i++) {
        _cumulative += ds_list_find_value(_values, i);
        if (_roll < _cumulative) {
            var _result = ds_list_find_value(_keys, i);
            ds_list_destroy(_keys);
            ds_list_destroy(_values);
            return _result;
        }
    }
    
    var _result = ds_list_find_value(_keys, 0);
    ds_list_destroy(_keys);
    ds_list_destroy(_values);
    return _result;
}