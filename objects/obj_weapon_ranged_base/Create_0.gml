event_inherited();

// ===== 弹匣 =====
current_ammo = 0;
max_ammo = 0;
is_reloading = false;
reload_progress = 0;
reload_timer = 0;
reload_time_per_bullet = 30;

// ===== 射击 =====
fire_mode = "auto";

// ===== 后坐力 =====
recoil_timer = 0;
recoil_offset = 0;
recoil_angle = 0;

// ===== 瞄准平滑 =====
_aim_smooth_timer = 0;
_aim_state = "idle";
_aim_timer = 0;
_aim_start_angle = 0;