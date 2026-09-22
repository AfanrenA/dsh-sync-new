// obj_hitbox Step 事件

// ★ 顿帧暂停
if (global.hit_pause_timer > 0) exit;

// ===== 1. 位置更新 =====
scr_hitbox_update_position(self);

// ===== 2. 碰撞检测 =====
var _hit = collision_circle(x, y, hit_radius, target_object, false, true);
if (_hit != noone && _hit != owner_id) {
    scr_hitbox_check_collision(self);
}

// ===== 3. 生命周期 =====
scr_hitbox_life_update(self);