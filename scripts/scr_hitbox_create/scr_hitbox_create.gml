// ======================================================================
// scr_hitbox_create.gml
// 创建近战攻击碰撞盒
// 
// ★★★ 自适应方案：自动根据精灵尺寸计算位置和半径 ★★★
//   1. 位置：根据精灵宽度自动计算尖端位置 + 数据表偏移微调
//   2. 半径：根据精灵高度自动计算碰撞范围
//   3. 使用 image_angle 完美跟随挥砍弧线
//   4. ★★★ 每把武器可独立调节 hitbox 圆心位置 ★★★
// ======================================================================

/// @description 创建近战攻击碰撞盒
/// @param {instance} _weapon 武器实例
/// @param {instance} _owner 攻击者（玩家或敌人）
/// @param {real} _damage 伤害值
/// @param {real} _life 存活帧数
/// @param {bool} _can_deflect 是否抵消飞行物
/// @returns {instance} 碰撞盒实例
function scr_hitbox_create(_weapon, _owner, _damage, _life, _can_deflect) {
    // ===== 1. ★★★ 自动计算尖端位置（自适应精灵尺寸）★★★ =====
    var _sprite = _weapon.sprite_index;
    var _sprite_w = sprite_get_width(_sprite);
    var _sprite_h = sprite_get_height(_sprite);
    var _origin_x = sprite_get_xoffset(_sprite);
    
    // ---- 尖端距离（自适应宽度） ----
    var _weapon_length = _sprite_w - _origin_x;
    var _scale = abs(_weapon.image_xscale);
    var _fire_dist = _weapon_length * _scale + 5;
    var _angle = _weapon.image_angle;
    
    // ---- 基础位置 ----
    var _base_x = _weapon.x + lengthdir_x(_fire_dist, _angle);
    var _base_y = _weapon.y + lengthdir_y(_fire_dist, _angle);
    
    // ===== 2. ★★★ 读取数据表偏移量（每把武器独立调节）★★★ =====
    var _offset_x = 0;
    var _offset_y = 0;
    var _data = data_weapon_get(_weapon.weapon_id);
    if (_data != undefined) {
        if (variable_struct_exists(_data, "hitbox_offset_x")) {
            _offset_x = _data.hitbox_offset_x;
        }
        if (variable_struct_exists(_data, "hitbox_offset_y")) {
            _offset_y = _data.hitbox_offset_y;
        }
    }
    
    // ---- ★★★ 应用偏移（沿武器朝向方向）★★★ ----
    var _perp_angle = _angle + 90;
    var _fire_x = _base_x + lengthdir_x(_offset_x, _angle) + lengthdir_x(_offset_y, _perp_angle);
    var _fire_y = _base_y + lengthdir_y(_offset_x, _angle) + lengthdir_y(_offset_y, _perp_angle);
    
    // ===== 3. 碰撞半径（自适应高度） =====
    var _actual_h = _sprite_h * abs(_weapon.image_yscale);
    var _auto_radius = max(_actual_h * 0.8, 15);
    
    // ===== 4. 创建碰撞盒实例 =====
    var hitbox = instance_create_layer(_fire_x, _fire_y, "Instances", obj_hitbox);
    if (!instance_exists(hitbox)) return noone;
    
    // ===== 5. 设置碰撞盒属性 =====
    hitbox.weapon_ref = _weapon;           // 绑定的武器
    hitbox.damage = _damage;               // 伤害值
    hitbox.owner = _owner;                 // 攻击者
    hitbox.can_deflect = _can_deflect || false;
    hitbox.life = _life;                   // 存活帧数
    hitbox.max_life = hitbox.life;
    hitbox.hit_radius = _auto_radius;      // ★ 自动计算的半径
    hitbox.extra_life = 0;
    
    // ===== 6. hack 武器特殊处理 =====
    // hack 类型武器攻击后需要延迟 0.25 秒销毁（动画感）
    if (_weapon.weapon_type == "hack") {
        hitbox.extra_life = 15;
    }
    
    return hitbox;
}