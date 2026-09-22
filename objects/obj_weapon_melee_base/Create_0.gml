//obj_weapon_melee_base Create
event_inherited();

// ===== 挥砍变量 =====
is_swinging = false;
swing_timer = 0;
swing_total_frames = 15;
swing_angle_range = 60;
hitbox_ref = noone;

// ===== 瞄准平滑 =====
_aim_smooth_timer = 0;
_aim_state = "idle";
_aim_timer = 0;
_aim_start_angle = 0;

// ===== 剑气相关 =====
slash_pending = false;
slash_delay_frames = 0;