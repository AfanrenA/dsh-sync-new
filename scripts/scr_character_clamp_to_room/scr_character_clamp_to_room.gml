// ============================================================
// scr_character_clamp_to_room - 地图边界限制
// 角色不能超出房间边界，保持最少 50 像素距离
// ============================================================

function scr_character_clamp_to_room(inst) {
    if (!instance_exists(inst)) exit;
    
    var _margin = 50;
    
    // 获取房间尺寸
    var _room_w = room_width;
    var _room_h = room_height;
    
    // 如果角色有碰撞组件，基于碰撞盒尺寸计算
    var _half_w = 16;
    var _half_h = 16;
    if (inst.collision_comp != noone) {
        _half_w = inst.collision_comp.width * 0.5;
        _half_h = inst.collision_comp.height * 0.5;
    }
    
    // 边界限制（考虑碰撞盒半宽/半高）
    var _min_x = _margin + _half_w;
    var _max_x = _room_w - _margin - _half_w;
    var _min_y = _margin + _half_h;
    var _max_y = _room_h - _margin - _half_h;
    
    // 应用限制
    inst.x = clamp(inst.x, _min_x, _max_x);
    inst.y = clamp(inst.y, _min_y, _max_y);
}