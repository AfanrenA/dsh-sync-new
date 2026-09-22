event_inherited()
// ===== 基础判断 =====
if (!visible) exit;
if (global.hit_pause_timer > 0) exit;

// ===== 核心更新 =====
scr_weapon_cooldown_update(id);
scr_weapon_follow_owner(id);
scr_weapon_aim_update(id);

// ===== 切换完成反馈递减 =====
if (flash_timer > 0) flash_timer -= 1;

// ===== 冷却就绪闪光递减 =====
if (flash_ready_timer > 0) flash_ready_timer -= 1;

if (flash_skill_timer > 0) flash_skill_timer -= 1;

// ===== 攻击检测（仅玩家当前激活武器） =====
if (instance_exists(owner_id)) {
    if (object_is_ancestor(owner_id.object_index, obj_player_base)) {
        // ★ 闪避期间 + 闪避后 12 帧禁攻
        if (!owner_id.is_dashing && owner_id.dash_lockout_timer <= 0) {
            // 普攻
            if (owner_id.current_weapon == id && owner_id.input_left) {
                scr_weapon_try_attack(id);
            }
            
            // ★ 武技
            if (owner_id.current_weapon == id) {
                scr_weapon_try_skill(id);
            }
        }
    }
}



// ===== 地面拾取提示可见性（只判断、只销毁，不绘制） =====
if (!(is_on_ground && pickup_hint_visible)) {
    if (instance_exists(pickup_hint_ref)) {
        instance_destroy(pickup_hint_ref);
        pickup_hint_ref = noone;
    }
}