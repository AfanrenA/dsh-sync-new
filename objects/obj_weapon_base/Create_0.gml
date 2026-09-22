// ============================================================
// obj_weapon_base - Create 事件
// ============================================================

// ★★★ 所有变量在 Create 中声明（保证 Step 不会报错）★★★

// ---- 基础 ----
is_dropped = false;
owner = noone;
weapon_id = "";
weapon_name = "";
weapon_type = "";
rarity = "common";
rarity_color = c_white;
damage = 10;
cooldown = 30;
attack_cooldown = 0;
cooldown_max = 0;

// ---- 近战 ----
is_swinging = false;
swing_timer = 0;
swing_total_frames = 10;
swing_angle_range = 60;
swing_distance = 25;
hitbox_ref = noone;
base_angle = 0;

// ---- 剑气 ----
slash_sprite = noone;
slash_speed = 8;
slash_life = 30;
slash_scale_start = 0.5;
slash_scale_end = 2.0;
slash_delay = 0;
slash_queued = false;

// ---- 碰撞盒 ----
hitbox_life = 12;
hitbox_radius = 25;
can_deflect = false;
hitbox_offset_x = 0;
hitbox_offset_y = 0;

// ---- 远程 ----
bullet_sprite = noone;
bullet_speed = 12;
bullet_life = 60;
visual_recoil = 0;
physical_recoil = 0;
recoil_strength = 0;
recoil_timer = 0;
recoil_offset = 0;
recoil_angle = 0;

// ---- 弹匣 ----
burst_max = 0;
burst_interval = 3;
burst_cooldown = 60;
magazine_max = 0;
magazine_current = 0;
is_reloading = false;
reload_timer = 0;
reload_time = 0;
magazine_loading = 0;

// ---- 投掷 ----
throw_speed = 8;
throw_gravity = 0.15;
throw_life = 60;
projectile_obj = noone;

// ---- 元素/飞刀 ----
element = "";
element_dot_damage = 0;
element_dot_duration = 0;
element_damage = 0;
trail_color = c_white;
stick_duration = 600;
bleed_damage = 0;
bleed_duration = 0;
bleed_interval = 15;
pierce = false;

// ---- 爆炸 ----
is_explosive = false;
explosion_delay = 30;
explosion_radius = 80;
explosion_damage = 20;
warning_radius = 120;
warning_duration = 90;
warning_alpha = 0.25;
warning_scale_start = 0.3;

// ---- 外部引用 ----
fire_point = noone;
glow_ref = noone;
muzzle_flash = noone;
pickup_cooldown = 0;
slash_created = false;
attack_behavior = noone;
quality_base = 0;
quality_offset = 0;

