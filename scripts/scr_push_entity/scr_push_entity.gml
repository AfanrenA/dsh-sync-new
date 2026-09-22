// ======================================================================
// scr_push_entity_out_of_box.gml
// ======================================================================

/// @description 把实体从碰撞箱中推出去
/// @param {instance} _entity 被推的实体
/// @param {real} _box_x 碰撞箱中心X
/// @param {real} _box_y 碰撞箱中心Y
/// @param {real} _box_w 碰撞箱宽度
/// @param {real} _box_h 碰撞箱高度
function scr_push_entity_out_of_box(_entity, _box_x, _box_y, _box_w, _box_h) {
    if (!instance_exists(_entity)) return;
    if (_entity.collision_comp == noone) return;
    
    var _half_w = _box_w * 0.5;
    var _half_h = _box_h * 0.5;
    
    var _left = _box_x - _half_w;
    var _right = _box_x + _half_w;
    var _top = _box_y - _half_h;
    var _bottom = _box_y + _half_h;
    
    var _comp = _entity.collision_comp;
    var _e_half_w = _comp.width * 0.5;
    var _e_half_h = _comp.height * 0.5;
    var _e_left = _entity.x - _e_half_w + _comp.offset_x;
    var _e_right = _entity.x + _e_half_w + _comp.offset_x;
    var _e_top = _entity.y - _e_half_h + _comp.offset_y;
    var _e_bottom = _entity.y + _e_half_h + _comp.offset_y;
    
    // 计算重叠量
    var _overlap_left = _e_right - _left;
    var _overlap_right = _right - _e_left;
    var _overlap_top = _e_bottom - _top;
    var _overlap_bottom = _bottom - _e_top;
    
    // 找出最小的重叠方向
    var _min_overlap = min(_overlap_left, _overlap_right, _overlap_top, _overlap_bottom);
    
    if (_min_overlap == _overlap_left) {
        _entity.x -= _overlap_left;
    } else if (_min_overlap == _overlap_right) {
        _entity.x += _overlap_right;
    } else if (_min_overlap == _overlap_top) {
        _entity.y -= _overlap_top;
    } else if (_min_overlap == _overlap_bottom) {
        _entity.y += _overlap_bottom;
    }
    
    //show_debug_message("✅ 实体被推开: " + string(_entity.object_index));
}