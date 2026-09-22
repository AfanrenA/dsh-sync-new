// obj_hitbox Create 事件

weapon_ref = noone;
owner_id = noone;
damage = 0;
life_frames = 10;
hitbox_w = 0;
hitbox_h = 0;
hitbox_offset = 0;
target_object = noone;
hit_radius = 15;
knockback_power = 5.0;
stun_duration = 0.15;

// ===== 行为模式 =====
hitbox_behavior = "damage_only";   // "damage_only" 或 "destroy_projectiles"

// ===== 命中管理 =====
has_hit = false;                   // 是否已命中（保留兼容）
hit_targets = [];                  // 已命中的目标列表（防止重复伤害）