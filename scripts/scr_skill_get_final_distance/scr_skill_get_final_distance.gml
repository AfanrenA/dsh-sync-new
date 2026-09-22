/// @description 统一计算武技的最终飞行距离（预警线、剑气都用这个）
/// @param {id} owner 释放者
/// @param {string} skill_id 武技 ID
/// @param {real} charge_time 蓄力时间（秒）
/// @returns {real} 最终飞行距离
function scr_skill_get_final_distance(owner, skill_id, charge_time) {
    var _data = data_skill_get(skill_id);
    if (_data == undefined) return 0;
    
    // ===== 判断是玩家还是敌人 =====
    var _is_player = false;
    if (object_is_ancestor(owner.object_index, obj_player_base)) {
        _is_player = true;
    }
    
    // ===== 蓄力进度 =====
    var _max_charge = _data.max_charge != undefined && _data.max_charge > 0 ? _data.max_charge : 1;
var _charge_progress = charge_time / _max_charge;
    
    // ===== 基础距离 =====
    var _min_dist = _data.min_distance != undefined ? _data.min_distance : 0;
    var _max_dist = _data.base_distance;
    var _distance = _min_dist + (_max_dist - _min_dist) * _charge_progress;
    
    // ===== 品质加成 =====
    var _quality_index = 0;
    if (_is_player && instance_exists(owner.skill_instance)) {
        _quality_index = owner.skill_instance.quality_index;
    }
    var _range_mult = data_skill_get_quality_mult(skill_id, _quality_index, "quality_range_mult");
    _distance *= _range_mult;
    
    // ===== 敌人的 dist_mult =====
    var _dist_mult = 1;
    if (!_is_player) {
        var _ai_config = _data.ai;
        if (_ai_config != undefined) {
            _dist_mult = 1 + _charge_progress * 2.0;
        }
    }
    
    return _distance * _dist_mult;
}