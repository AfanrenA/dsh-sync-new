//obj_weapon_base Create
event_inherited();

// ===== 武器特有 =====
weapon_id = "";
display_name = "";        // ★ 暂时保留，第三步再改成 display_name
final_stats = undefined;
cooldown_timer = 0;
can_attack = true;
attack_script = "";
depth = 105;
skill_charging = false;
skill_charge = 0;
flash_timer = 0;
// ===== 冷却就绪闪光 =====
flash_ready_timer = 0;    // ★ 新增：冷却归零瞬间置 12，Step 递减
flash_skill_timer = 0;
