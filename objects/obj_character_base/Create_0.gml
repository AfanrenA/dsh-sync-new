// ============================================================
// obj_character_base - Create 事件
// ============================================================
event_inherited();

// ============================================================
// 1. 基础属性（所有角色共用）
// ============================================================
hp = 100;
max_hp = 100;
move_speed = 4;
facing = 1;
is_dead = false;
current_weapon = noone;
attack_cooldown = 0;

// ============================================================
// 2. 地面检测
// ============================================================
grounded = false;
in_air = false;

// ============================================================
// 3. 受击反馈
// ============================================================
hit_flash_timer = 0;
hit_stun_timer = 0;
is_in_hit_stun = false;

// ============================================================
// 4. 碰撞伤害参数
// ============================================================
collision_damage_base = 5;
collision_knockback_power = 15;
collision_damage_cooldown_max = 30;
collision_damage_cooldown = 0;

// ============================================================
// 5. 碰撞组件（★ 修复：包含 WALL 和 CHEST ★）
// ============================================================
collision_mask = COLLISION_LAYER.ENTITY | COLLISION_LAYER.WALL | COLLISION_LAYER.CHEST;
collision_response = "damage";

if (sprite_index != -1 && sprite_exists(sprite_index)) {
    var _spr_w = sprite_get_width(sprite_index);
    var _spr_h = sprite_get_height(sprite_index);
    collision_width = max(16, _spr_w * 1);
    collision_height = max(16, _spr_h * 1);
} else {
    collision_width = 32;
    collision_height = 32;
}

collision_comp = scr_component_collision_create(
    id,
    collision_mask,
    collision_width,
    collision_height
);
collision_comp.is_trigger = false;

show_debug_message("✅ 碰撞组件: " + string(object_get_name(object_index)) + 
                   " 尺寸: " + string(collision_width) + "x" + string(collision_height) +
                   " 类型: " + collision_response);