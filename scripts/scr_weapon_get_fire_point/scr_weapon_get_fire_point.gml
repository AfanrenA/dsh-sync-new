// ======================================================================
// scr_weapon_get_fire_point.gml
// 获取武器发射点的世界坐标（从武器尖端）
// 
// 商业化标准做法（DNF / 空洞骑士 / 死亡细胞 通用方案）：
//   1. 定义"局部偏移"：武器朝右（0°）时，尖端相对于武器原点的位置
//   2. 使用旋转公式：将局部偏移转换为世界偏移（支持任意角度）
//   3. 微调通过数据表配置，而不是硬编码在代码里
// 
// ★★★ 关键修复：使用 base_angle 作为方向依据 ★★★
// 因为武器的左右翻转是通过 image_yscale = -1 实现的，
// 而方向存储在 base_angle 中（由 scr_weapon_aim 计算）
// ======================================================================

/// @description 获取武器发射点的世界坐标
/// @param {instance} _weapon 武器实例
/// @returns {struct} { x, y } 或 noone
/*function scr_weapon_get_fire_point(_weapon) {
    if (!instance_exists(_weapon)) return noone;
    if (_weapon.sprite_index == noone) return noone;
    
    // ===== 1. 获取精灵信息 =====
    var _sprite = _weapon.sprite_index;
    var _sprite_w = sprite_get_width(_sprite);
    var _sprite_h = sprite_get_height(_sprite);
    var _origin_x = sprite_get_xoffset(_sprite);
    var _origin_y = sprite_get_yoffset(_sprite);
    
    // ===== 2. 计算基础局部偏移（武器朝右 0° 时，尖端位置） =====
    // 水平方向：从原点到右边缘（握把到剑尖）
    var _local_x = _sprite_w - _origin_x;
    // 垂直方向：从原点到垂直中间（握把到中线）
    var _local_y = 0;
    
    // ===== 3. 从数据表读取微调（每个武器独立配置） =====
    var _data = data_weapon_get(_weapon.weapon_id);
    if (_data != undefined) {
        // 如果数据表配置了 fire_offset_x，使用配置值（覆盖默认计算）
        if (variable_struct_exists(_data, "fire_offset_x")) {
            _local_x = _data.fire_offset_x;
        }
        // 如果数据表配置了 fire_offset_y，使用配置值（覆盖默认 0）
        if (variable_struct_exists(_data, "fire_offset_y")) {
            _local_y = _data.fire_offset_y;
        }
    }
    
    // ===== 4. 应用缩放 =====
    _local_x *= abs(_weapon.image_xscale);
    _local_y *= abs(_weapon.image_yscale);
    
    // ===== 5. 处理翻转（朝左时尖端在左边） =====
    if (_weapon.image_xscale < 0) {
        _local_x = -_local_x;
    }
    
    // ================================================================
    // ★★★ 核心：使用 base_angle 作为方向（而不是 image_angle） ★★★
    // 因为：
    //   - 武器的方向由 scr_weapon_aim 计算并存入 base_angle
    //   - image_angle 在挥砍时会被动画修改，不能作为方向依据
    //   - 左右翻转通过 image_yscale = -1 实现，base_angle 保持不变
    // ================================================================
    var _angle = _weapon.base_angle;
    var _rad = degtorad(_angle);
    var _cos = cos(_rad);
    var _sin = sin(_rad);
    
    // ===== 6. 旋转公式（将局部偏移转为世界偏移） =====
    var _world_x = _local_x * _cos - _local_y * _sin;
    var _world_y = _local_x * _sin + _local_y * _cos;
    // ===== ★★★ 调试日志（测试通过后删除） ★★★ =====
    show_debug_message("=== scr_weapon_get_fire_point 调试 ===");
    show_debug_message("_weapon.base_angle: " + string(_weapon.base_angle));
    show_debug_message("_weapon.image_xscale: " + string(_weapon.image_xscale));
    show_debug_message("_weapon.image_yscale: " + string(_weapon.image_yscale));
    show_debug_message("_local_x: " + string(_local_x));
    show_debug_message("_local_y: " + string(_local_y));
    show_debug_message("_world_x: " + string(_world_x));
    show_debug_message("_world_y: " + string(_world_y));
    show_debug_message("武器位置: (" + string(_weapon.x) + ", " + string(_weapon.y) + ")");
    show_debug_message("发射点: (" + string(_weapon.x + _world_x) + ", " + string(_weapon.y + _world_y) + ")");
    // ===== 7. 返回最终坐标 =====
    return {
        x: _weapon.x + _world_x,
        y: _weapon.y + _world_y
    };
	
}