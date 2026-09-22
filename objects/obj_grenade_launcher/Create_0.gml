event_inherited();

// ===== 轨迹（起点→终点插值 + 弧线）=====
start_x = 0;
start_y = 0;
end_x = 0;
end_y = 0;
progress = 0;         // 0 → 1
duration = 60;        // 总帧数
arc_height = 60;      // 弧线最高点偏移

// ===== 爆炸 =====
explosion_damage = 0;
explosion_radius = 64;
explosion_knockback = 0;
explosion_stun_duration = 0;
explosion_falloff_min = 0.3;

// ===== 数据缓存 =====
data = undefined;

// ===== 视觉 =====
image_speed = 0;
image_angle = 0;

is_player_grenade = false;