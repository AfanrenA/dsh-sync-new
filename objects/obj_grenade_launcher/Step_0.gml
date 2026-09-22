/// @description 榴弹炮飞行物 Step（插值 + 弧线 + 碰撞爆炸）
// 不调 event_inherited()

if (global.hit_pause_timer > 0) exit;

// ===== 1. 进度推进 =====
progress += 1 / duration;

// ===== 2. 到达终点 → 爆炸 =====
if (progress >= 1) {
    x = end_x;
    y = end_y;
    scr_grenade_explode(self);
    exit;
}

// ===== 3. 插值 + 弧线 =====
var _t = progress;
var _arc = sin(_t * pi) * arc_height;

x = lerp(start_x, end_x, _t);
y = lerp(start_y, end_y, _t) - _arc;   // 减去弧高 = 往上拱

// ===== 4. 朝向速度方向（视觉）=====
// 算当前位置相对上一帧的方向
var _prev_x = lerp(start_x, end_x, _t - 1/duration);
var _prev_y = lerp(start_y, end_y, _t - 1/duration) - sin((_t - 1/duration) * pi) * arc_height;
image_angle = point_direction(_prev_x, _prev_y, x, y);

// ===== 5. 碰撞检测（墙/建筑/敌人）=====
var _hit_wall = place_meeting(x, y, obj_wall_base)
             || place_meeting(x, y, obj_building_base)
             || place_meeting(x, y, obj_chest_base);
var _hit_enemy = collision_circle(x, y, 4, obj_enemy_base, false, true) != noone;

if (_hit_wall || _hit_enemy) {
    scr_grenade_explode(self);
    exit;
}