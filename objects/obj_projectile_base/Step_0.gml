// ======================================================================
// obj_projectile_base - Step 事件（V3 统一碰撞版）
// ======================================================================

// ============================================================
// 1. 基础飞行
// ============================================================
x += lengthdir_x(speed, direction);
y += lengthdir_y(speed, direction);
image_angle = direction;

// ============================================================
// 1.5 ★ 剑气缩放动画 ★
// ============================================================
if (variable_instance_exists(id, "scale_start") && 
    variable_instance_exists(id, "scale_end") && 
    max_life > 0 && life > 0) {
    var _progress = 1 - (life / max_life);
    var _scale = scale_start + (scale_end - scale_start) * _progress;
    image_xscale = _scale;
    image_yscale = _scale;
}

// ============================================================
// 2. 调用可选模块
// ============================================================
if (scale_module != noone) {
    scr_projectile_scale_update(self);
}
if (gravity_module != noone) {
    scr_projectile_gravity_update(self);
}
if (tracking_module != noone) {
    scr_projectile_tracking_update(self);
}

// ============================================================
// 3. 生命周期递减
// ============================================================
life -= 1;

if (life <= 0) {
    if (is_explosive) {
        scr_projectile_explode(self);
    }
    scr_spawn_spark(x, y, c_gray, 5);
    instance_destroy();
    exit;
}

// ============================================================
// 4. 安全检查：发射者不存在则销毁
// ============================================================
if (owner != noone && !instance_exists(owner)) {
    scr_spawn_spark(x, y, c_red, 3);
    instance_destroy();
    exit;
}

// ============================================================
// 5. ★★★ 统一碰撞检测 ★★★
// ============================================================
var _hit = collision_line(
    xprevious, yprevious,
    x, y,
    obj_collision_base,
    false,
    true
);

if (_hit != noone && _hit != owner) {
    
    // ---- 检测是否撞到敌人（如果是玩家发射的） ----
    if (owner != noone && owner.object_index == obj_player) {
        if (object_is_ancestor(_hit.object_index, obj_enemy_base)) {
            // ★ 使用统一伤害函数 ★
            scr_apply_damage(_hit, damage, owner);
            
            scr_spawn_spark(x, y, c_red, 12);
            scr_spawn_spark(x, y, c_orange, 6);
            
            // ★ 调用子类回调后销毁 ★
            if (variable_instance_exists(id, "on_hit_enemy")) {
                on_hit_enemy(_hit);
            }
            instance_destroy();
            exit;
        }
    }
    
    // ---- 检测是否撞到玩家（如果是敌人发射的） ----
    if (owner != noone && (owner.object_index == obj_enemy_base || 
                           owner.object_index == obj_enemy_melee)) {
        if (object_is_ancestor(_hit.object_index, obj_player_base)) {
            // ★ 使用统一伤害函数 ★
            scr_apply_damage(_hit, damage, owner);
            
            scr_spawn_spark(x, y, c_red, 12);
            scr_spawn_spark(x, y, c_orange, 6);
            
            // ★ 调用子类回调后销毁 ★
            if (variable_instance_exists(id, "on_hit_player")) {
                on_hit_player(_hit);
            }
            instance_destroy();
            exit;
        }
    }
    
    // ---- 撞到其他碰撞体（墙壁、宝箱等） ----
    scr_spawn_spark(x, y, c_yellow, 8);
    scr_spawn_spark(x, y, c_orange, 5);
    
    if (variable_instance_exists(id, "on_collision")) {
        on_collision(_hit);
    }
    instance_destroy();
    exit;
}