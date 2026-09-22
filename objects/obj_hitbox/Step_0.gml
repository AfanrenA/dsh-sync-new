// ======================================================================
// obj_hitbox - Step 事件
// 近战攻击碰撞盒
// 
// ★★★ 自适应方案：自动根据精灵尺寸计算位置和半径 ★★★
//   1. 位置：根据精灵宽度自动计算尖端位置 + 数据表偏移微调
//   2. 半径：根据精灵高度自动计算碰撞范围
//   3. 使用 image_angle 完美跟随挥砍弧线
//   4. ★★★ 每把武器可独立调节 hitbox 圆心位置 ★★★
// ======================================================================
show_debug_message("📍 Hitbox 位置: (" + string(x) + ", " + string(y) + ")");
// ===== 1. 安全检查 =====
if (!instance_exists(weapon_ref)) {
    if (hit_list != noone) ds_list_destroy(hit_list);
    instance_destroy();
    exit;
}

// ===== 2. hack 武器特殊处理 =====
if (weapon_ref.weapon_type == "hack") {
    if (weapon_ref.swing_timer <= 0) {
        if (extra_life > 0) {
            extra_life -= 1;
        } else {
            if (hit_list != noone) ds_list_destroy(hit_list);
            instance_destroy();
            exit;
        }
    }
}

// ===== 3. 记录上一帧位置（用于路径检测） =====
var prev_x = x;
var prev_y = y;

// ===== 4. ★★★ 自动计算尖端位置（自适应精灵宽度）★★★ =====
var _sprite = weapon_ref.sprite_index;
var _sprite_w = sprite_get_width(_sprite);
var _sprite_h = sprite_get_height(_sprite);
var _origin_x = sprite_get_xoffset(_sprite);
var _origin_y = sprite_get_yoffset(_sprite);

// ---- 距离：从原点到右边缘（自适应宽度） ----
var _weapon_length = _sprite_w - _origin_x;
var _scale = abs(weapon_ref.image_xscale);
var _fire_dist = _weapon_length * _scale + 5;  // +5 超出尖端

// ★★★ 使用 image_angle（实时跟随挥砍弧线）★★★
var _angle = weapon_ref.image_angle;

// ---- 计算基础位置 ----
var _base_x = weapon_ref.x + lengthdir_x(_fire_dist, _angle);
var _base_y = weapon_ref.y + lengthdir_y(_fire_dist, _angle);

// ===== 5. ★★★ 读取数据表偏移量（每把武器独立调节）★★★ =====
var _offset_x = 0;
var _offset_y = 0;
var _data = data_weapon_get(weapon_ref.weapon_id);
if (_data != undefined) {
    if (variable_struct_exists(_data, "hitbox_offset_x")) {
        _offset_x = _data.hitbox_offset_x;
    }
    if (variable_struct_exists(_data, "hitbox_offset_y")) {
        _offset_y = _data.hitbox_offset_y;
    }
}

// ---- ★★★ 应用偏移（沿武器朝向方向）★★★ ----
// 水平偏移沿武器朝向（image_angle）
// 垂直偏移沿武器朝向的垂直方向（image_angle + 90）
var _perp_angle = _angle + 90;
x = _base_x + lengthdir_x(_offset_x, _angle) + lengthdir_x(_offset_y, _perp_angle);
y = _base_y + lengthdir_y(_offset_x, _angle) + lengthdir_y(_offset_y, _perp_angle);

// ===== 6. ★★★ 自适应碰撞半径（根据精灵高度）★★★ =====
// 计算精灵的实际高度（考虑缩放）
var _actual_h = _sprite_h * abs(weapon_ref.image_yscale);
// 碰撞半径 = 精灵高度的一半 * 0.8（让碰撞盒略小于视觉范围）
// 这样不同大小的武器自动有不同的碰撞范围
var _auto_radius = max(_actual_h * 0.8, 15);  // 最小 15 像素，防止太小
hit_radius = _auto_radius;

// ===== 7. 判断攻击者类型 =====
var _is_player = false;
var _is_enemy = false;

if (owner != noone && instance_exists(owner)) {
    if (object_is_ancestor(owner.object_index, obj_player_base)) {
        _is_player = true;
    } else if (object_is_ancestor(owner.object_index, obj_enemy_base)) {
        _is_enemy = true;
    } else {
        _is_player = (owner.object_index == obj_player);
        _is_enemy = (owner.object_index == obj_enemy);
    }
}

// ===== 8. 碰撞检测：玩家武器 → 打敌人 =====
if (_is_player) {
    var target = collision_circle(x, y, hit_radius, obj_character_base, false, true);
   // ★ 调试
if (target != noone) {
    show_debug_message("🎯 Hitbox 检测到目标: " + string(object_get_name(target.object_index)));
} else {
    show_debug_message("❌ Hitbox 未检测到任何目标");
}
   if (target != noone && target != owner && ds_list_find_index(hit_list, target) == -1) {
        if (object_is_ancestor(target.object_index, obj_enemy_base)) {
            ds_list_add(hit_list, target);
            
            if (variable_instance_exists(target, "hp")) {
                target.hp -= damage;
                
                // ★ 触发受击反馈 ★
                var _dir = point_direction(x, y, target.x, target.y);
                scr_character_trigger_hit_response(target, _dir);
            }
            if (variable_instance_exists(target, "cooldown")) {
                target.cooldown = 30;
            }
            
            var angle = point_direction(x, y, target.x, target.y);
            target.x += lengthdir_x(12, angle);
            target.y += lengthdir_y(12, angle);
            scr_spawn_simple_particles(x, y, 3, c_yellow, 0.6, 2, 5);
        }
    }
}

// ===== 9. 碰撞检测：敌人武器 → 打玩家 =====
if (_is_enemy) {
    var target = collision_circle(x, y, hit_radius, obj_character_base, false, true);
    if (target != noone && target != owner && ds_list_find_index(hit_list, target) == -1) {
        if (object_is_ancestor(target.object_index, obj_player_base)) {
            ds_list_add(hit_list, target);
            
            if (variable_instance_exists(target, "electricity")) {
                target.electricity -= damage;
            }
            if (variable_instance_exists(target, "hurt_flash")) {
                target.hurt_flash = 10;
            }
            if (variable_instance_exists(target, "hit_stun")) {
                target.hit_stun = 8;
            }
            
            // ★ 触发受击反馈（玩家受击）★
            var _dir = point_direction(x, y, target.x, target.y);
            scr_character_trigger_hit_response(target, _dir);
            
            var angle = point_direction(x, y, target.x, target.y);
            target.x += lengthdir_x(8, angle);
            target.y += lengthdir_y(8, angle);
            
            if (variable_instance_exists(target, "electricity") && target.electricity <= 0) {
                target.electricity = 0;
                if (variable_instance_exists(target, "is_dead")) {
                    target.is_dead = true;
                }
            }
            
            scr_spawn_simple_particles(target.x, target.y, 6, c_red, 0.8, 3, 8);
        }
    }
}
// ===== 10. 抵消飞行物 =====
if (can_deflect) {
    var projectile = collision_circle(x, y, hit_radius, obj_projectile_base, false, true);
    if (projectile != noone && projectile.owner != owner) {
        scr_spawn_simple_particles(x, y, 5, c_yellow, 0.3, 0.6, 2, 5);
        instance_destroy(projectile);
    }
}

// ===== 11. 生命周期 =====
life -= 1;
if (life <= 0) {
    if (hit_list != noone) ds_list_destroy(hit_list);
    instance_destroy();
}