// ======================================================================
// scr_weapon_slash.gml
// 近战剑气发射（从武器尖端）
// 
// 商业化标准做法：
//   1. 使用 fire_point 实体获取尖端位置（可靠且统一）
//   2. 发射点偏移量在数据表中配置，每个武器独立微调
//   3. 支持任意方向（上、下、左、右、斜向）精准发射
// ======================================================================

/// @description 从武器尖端发射剑气
/// @param {instance} _weapon 武器实例
/// @param {real} _base_angle 基础朝向角度
/// @param {real} _progress 挥砍进度（0-1）
/// @param {struct} _weapon_data 武器数据
/// @param {instance} _owner 持有者
/// @returns {bool} 是否生成了剑气
function scr_weapon_slash(_weapon, _base_angle, _progress, _weapon_data, _owner) {
    // ===== 1. 前置条件检查 =====
    if (_weapon.weapon_type != "melee") return false;
    if (_weapon_data.slash_sprite == noone) return false;
    if (_weapon.slash_created) return false;
    if (_progress < 0.4 || _progress > 0.6) return false;
    
    // ===== 2. 安全检查：持有者必须存在 =====
    if (!instance_exists(_owner)) {
        log_warning("剑气发射失败：持有者不存在");
        return false;
    }
    
    // ===== 3. ★ 从 fire_point 实体读取发射点（不再调用函数计算）★ =====
    if (!instance_exists(_weapon.fire_point)) {
        log_warning("剑气发射失败：fire_point 不存在");
        return false;
    }
    var _fire_x = _weapon.fire_point.x;
    var _fire_y = _weapon.fire_point.y;
    
    // ===== 4. 创建剑气实例 =====
    var slash = instance_create_layer(_fire_x, _fire_y, "Instances", _weapon_data.slash_sprite);
    if (!instance_exists(slash)) {
        log_error("剑气创建失败");
        return false;
    }
    
    // ===== 5. 用 with 强制锁定所有属性 =====
    with (slash) {
        direction = _base_angle;
        speed = _weapon_data.slash_speed;
        life = _weapon_data.slash_life;
        max_life = life;
        damage = _weapon.damage;
        owner = _owner;
        image_angle = _base_angle;
        
        var _scale_start = _weapon_data.slash_scale_start;
        var _scale_end = _weapon_data.slash_scale_end;
        scr_projectile_scale_start(self, _scale_start, _scale_end);
        image_xscale = _scale_start;
        image_yscale = _scale_start;
    }
    
    // ===== 6. 标记已生成 =====
    _weapon.slash_created = true;
    
    log_debug("✅ 近战剑气生成！位置: (" + string(_fire_x) + ", " + string(_fire_y) + "), 速度: " + string(slash.speed));
    
    return true;
}