/// @description 炸弹投掷物 - 创建
event_inherited();  // 继承 obj_projectile_base

// ---- 基础参数 ----
target_x = 0;
target_y = 0;
start_x = x;
start_y = y;
traveled = 0;
max_range = 500;
speed = 8;
gravity = 0.15;
damage = 25;

is_explosive = true;
explosion_delay = 30;
explosion_radius = 120;
explosion_damage = 40;
element = "";
element_dot_damage = 0;
element_dot_duration = 0;

// ---- 状态机 ----
state = "flying";   // "flying" | "arming"

// ---- 方向 ----
direction = point_direction(x, y, target_x, target_y);
image_angle = direction;

// ---- 呼吸动画 ----
breath_phase = 0;

// ---- 预警圈 ----
warning = noone;

// ---- ★★★ 覆盖父类的碰撞响应函数 ★★★ ----
function on_collision(_other) {
    // 炸弹撞墙立即爆炸
    x = x - lengthdir_x(5, direction);
    y = y - lengthdir_y(5, direction);
    target_x = x;
    target_y = y;
    do_explosion();
}

show_debug_message("💣 炸弹投掷物已创建");