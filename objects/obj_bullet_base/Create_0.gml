// obj_bullet_base Create 事件
event_inherited();

// ===== 子弹专有变量 =====
bullet_id = "";
pierce_count = 0;
bounce_count = 0;
hit_targets = [];
bullet_sprite = -1;

// ===== 子弹默认值（武器脚本会覆盖） =====
move_speed = 0;
move_dir = 0;
life = 600;
max_life = 600;
damage = 1;
max_distance = 0;      // 0 = 不按距离销毁，只按 life / 碰撞
min_distance = 0;
traveled_distance = 0;
scale_start = 1.0;     // 子弹不缩放
scale_end = 1.0;
scale_speed = 0;
image_xscale = 1.0;
image_yscale = 1.0;
knockback_power = 3.0;
stun_duration = 0.1;