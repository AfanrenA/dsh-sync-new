//obj_weapon_thrown_base Create
event_inherited();

// ===== 蓄力变量 =====
throw_charge = 0;
throw_max_charge = 60;
thrown_projectile_ref = noone;

// ===== 投掷变量 =====
throw_mode = "charged";

// ===== 瞄准平滑 =====
_aim_smooth_timer = 0;
_aim_state = "idle";
_aim_timer = 0;
_aim_start_angle = 0;