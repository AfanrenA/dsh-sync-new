// scr_projectile_collision.gml
// 投射物碰撞检测 - 纯函数

function scr_projectile_collision(projectile_inst) {
    // ===== 获取精灵尺寸 =====
    var _sprite_width = sprite_get_width(projectile_inst.sprite_index);
    var _sprite_height = sprite_get_height(projectile_inst.sprite_index);
    
    // ===== 当前缩放 =====
    var _scale_x = projectile_inst.image_xscale;
    var _scale_y = projectile_inst.image_yscale;
    
    // ===== 计算椭圆半轴 =====
    var _half_w = (_sprite_width / 2) * _scale_x;
    var _half_h = (_sprite_height / 2) * _scale_y;
    
    // 保底最小尺寸
    if (_half_w < 3) _half_w = 3;
    if (_half_h < 3) _half_h = 3;
    
    // ===== 根据 owner 类型自动判断目标 =====
    var _target_object = noone;
    
    if (instance_exists(projectile_inst.owner_id)) {
        if (object_is_ancestor(projectile_inst.owner_id.object_index, obj_player_base)) {
            _target_object = obj_enemy_base;
        } else if (object_is_ancestor(projectile_inst.owner_id.object_index, obj_enemy_base)) {
            _target_object = obj_player_base;
        }
    }
    
    // 没有目标 → 不检测
    if (_target_object == noone) {
        return noone;
    }
    
    // ===== 椭圆碰撞检测 =====
    var _hit = collision_ellipse(
        projectile_inst.x - _half_w,
        projectile_inst.y - _half_h,
        projectile_inst.x + _half_w,
        projectile_inst.y + _half_h,
        _target_object,
        false,
        true
    );
    
    // ★ 修正：返回检测结果
    if (_hit != noone) {
        return _hit;
    }
    
    return noone;
}