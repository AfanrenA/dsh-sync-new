/// @function scr_enemy_perception_update(enemy)
/// @param {id} enemy - 敌人实例
/// @description 更新敌人的感知数据，一次性计算所有信息

function scr_enemy_perception_update(enemy) {
    // ===== 1. 获取玩家 =====
    var _player = instance_find(obj_player_base, 0);
    if (!instance_exists(_player)) {
        enemy._perception = {
            has_target: false,
            target: noone,
            dist: 99999,
            dir_to_target: 0,
            angle_diff: 0,
            is_in_vision: false,
            is_in_aggro: false,
            is_in_attack: false,
            is_from_behind: false,
            is_lost: false,
            aggro_range: 800,
            attack_range: 600,
            behind_trigger_range: 200,
            lost_range: 900
        };
        enemy._ai_dir = 0;
        enemy._ai_dist = 0;
        enemy._ai_player = noone;
        return;
    }
    
    // ===== 2. 计算基础数据 =====
    var _dist = point_distance(enemy.x, enemy.y, _player.x, _player.y);
    var _dir_to_target = point_direction(enemy.x, enemy.y, _player.x, _player.y);
    var _facing_angle = enemy.facing_dir * 90;
    var _angle_diff = angle_difference(_dir_to_target, _facing_angle);
    
    // ===== 3. 从数据表读取参数 =====
    var _data = enemy.entity_data;
    
    // 默认值
    var _vision_angle = 160;
    var _aggro_range = 800;
    var _attack_range = 600;
    var _behind_trigger_range = 200;
    var _lost_range = 900;
    
    // 安全读取数据表（优先从 ai 子结构读取）
    if (is_struct(_data)) {
        // 尝试从 ai 子结构读取
        if (variable_struct_exists(_data, "ai") && is_struct(_data.ai)) {
            var _ai = _data.ai;
            if (_ai.vision_angle != undefined) _vision_angle = _ai.vision_angle;
            if (_ai.aggro_range != undefined) _aggro_range = _ai.aggro_range;
            if (_ai.attack_range != undefined) _attack_range = _ai.attack_range;
            if (_ai.behind_range != undefined) _behind_trigger_range = _ai.behind_range;
            if (_ai.lost_range != undefined) _lost_range = _ai.lost_range;
        }
        // 如果 ai 子结构没有，从根层级读取（兼容旧数据）
        else {
            if (variable_struct_exists(_data, "vision_angle")) _vision_angle = _data.vision_angle;
            if (variable_struct_exists(_data, "aggro_range")) _aggro_range = _data.aggro_range;
            if (variable_struct_exists(_data, "attack_range")) _attack_range = _data.attack_range;
            if (variable_struct_exists(_data, "behind_trigger_range")) _behind_trigger_range = _data.behind_trigger_range;
            if (variable_struct_exists(_data, "lost_range")) _lost_range = _data.lost_range;
        }
        
        // 如果 behind_trigger_range 没有设置，用攻击范围的一半
        if (_behind_trigger_range == 0 || _behind_trigger_range == undefined) {
            _behind_trigger_range = _attack_range * 0.5;
        }
        // 如果 lost_range 没有设置，用索敌范围 + 100
        if (_lost_range == 0 || _lost_range == undefined) {
            _lost_range = _aggro_range + 100;
        }
    }
    
    var _half_vision = _vision_angle / 2;
    
    // ===== 4. 计算感知结果 =====
    var _perception = {
        has_target: true,
        target: _player,
        dist: _dist,
        dir_to_target: _dir_to_target,
        angle_diff: _angle_diff,
        is_in_vision: (abs(_angle_diff) < _half_vision && _dist < _aggro_range),
        is_in_aggro: (_dist < _aggro_range),
        is_in_attack: (_dist < _attack_range),
        is_from_behind: (abs(_angle_diff) >= _half_vision && _dist < _behind_trigger_range),
        is_lost: (_dist > _lost_range),
        aggro_range: _aggro_range,
        attack_range: _attack_range,
        behind_trigger_range: _behind_trigger_range,
        lost_range: _lost_range
    };
    // ===== 4.5 受击强制索敌（覆盖正常感知） =====
if (enemy._aggro_timer > 0 && instance_exists(enemy._aggro_target)) {
    var _t = enemy._aggro_target;
    var _t_dist = point_distance(enemy.x, enemy.y, _t.x, _t.y);
    var _t_dir = point_direction(enemy.x, enemy.y, _t.x, _t.y);
    
    _perception.has_target = true;
    _perception.target = _t;
    _perception.dist = _t_dist;
    _perception.dir_to_target = _t_dir;
    _perception.is_in_vision = true;    // 强制视为在视野内
    _perception.is_in_aggro = true;
    _perception.is_in_attack = (_t_dist < _attack_range);
    _perception.is_from_behind = false;
    _perception.is_lost = (_t_dist > _lost_range);
}
    enemy._perception = _perception;
    
    // ===== 设置 _ai_dir 等供技能方向使用 =====
    enemy._ai_dir = _dir_to_target;
    enemy._ai_dist = _dist;
    enemy._ai_player = _player;
}