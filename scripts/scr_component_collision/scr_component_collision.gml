// ======================================================================
// 碰撞组件 - 组合方式，不继承
// ======================================================================

// ----- 创建碰撞组件 -----
function scr_component_collision_create(_owner, _mask, _width, _height) {
    return {
        owner: _owner,
        mask: _mask,
        width: _width,
        height: _height,
        offset_x: 0,
        offset_y: 0,
        is_trigger: false   // false=实体阻挡, true=只检测不阻挡
    };
}

// ======================================================================
// scr_component_collision_check - 碰撞检测（V3 修复版）
// ======================================================================
/// @description 检测碰撞组件是否与任何匹配的对象重叠
/// @param {struct} _comp 碰撞组件
/// @param {real} _x 检测位置 X
/// @param {real} _y 检测位置 Y
/// @returns {ds_list} 碰撞到的对象列表

function scr_component_collision_check(_comp, _x, _y) {
    if (_comp == noone) return ds_list_create();
    
    var _owner = _comp.owner;
    var _half_w = _comp.width * 0.5;
    var _half_h = _comp.height * 0.5;
    
    var _left = _x - _half_w + _comp.offset_x;
    var _right = _x + _half_w + _comp.offset_x;
    var _top = _y - _half_h + _comp.offset_y;
    var _bottom = _y + _half_h + _comp.offset_y;
    
    var _list = ds_list_create();
    
    // ★ 关键修复：用 _comp 而不是 other._comp ★
    // 因为 _comp 是函数参数，在 with 内部通过 local 变量访问
    with (obj_collision_base) {
        // 过滤：掩码不匹配的跳过
        if ((collision_mask & _comp.mask) == 0) continue;  // ★ 改这里 ★
        // 跳过自己
        if (id == _comp.owner) continue;
        
        var _other_left = x - (collision_width * 0.5) + collision_offset_x;
        var _other_right = x + (collision_width * 0.5) + collision_offset_x;
        var _other_top = y - (collision_height * 0.5) + collision_offset_y;
        var _other_bottom = y + (collision_height * 0.5) + collision_offset_y;
        
        // AABB碰撞检测
        if (_left < _other_right && _right > _other_left &&
            _top < _other_bottom && _bottom > _other_top) {
            ds_list_add(_list, id);
        }
    }
    
    return _list;
}