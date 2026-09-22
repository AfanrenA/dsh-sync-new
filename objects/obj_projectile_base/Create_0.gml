//obj_projectile_base Create
projectile_id = "";
// ★ 禁用 GM 内置运动系统：用自定义变量，避免自动位移
speed = 0;
direction = 0;
hspeed = 0;
vspeed = 0;
move_speed = 0;
move_dir = 0;

damage = 0;
life = 0;
max_life = 0;
owner_id = noone;
target_object = noone;
element_type = "none";
// 受击反馈参数（由发射者注入）
knockback_power = 5.0;    // 默认值
stun_duration = 0.15;     // 默认值
color = c_white;

// ===== 距离控制（只声明，不赋值） =====
max_distance = 0;
min_distance = 0;
traveled_distance = 0;