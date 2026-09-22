// ======================================================================
// obj_character_base - Step 事件（V3 自定义碰撞版）
// ======================================================================

event_inherited();

// ============================================================
// 1. 地面检测
// ============================================================
grounded = place_meeting(x, y + 2, obj_wall);
in_air = !grounded;

// ============================================================
// 2. 受击反馈更新
// ============================================================
if (hit_flash_timer > 0) {
    hit_flash_timer -= 1;
}

if (hit_stun_timer > 0) {
    hit_stun_timer -= 1;
} else {
    if (is_in_hit_stun) {
        is_in_hit_stun = false;
        if (variable_instance_exists(id, "sprite_idle")) {
            var idle_sprite = sprite_idle;
            if (idle_sprite != -1 && idle_sprite != undefined) {
                sprite_index = idle_sprite;
            }
        }
    }
}

// ============================================================
// 3. 碰撞冷却递减
// ============================================================
if (collision_damage_cooldown > 0) {
    collision_damage_cooldown -= 1;
}


scr_character_clamp_to_room(id);  