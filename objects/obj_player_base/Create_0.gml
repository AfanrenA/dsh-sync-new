event_inherited();
inventory_ui_open = false;
// ===== 遗物系统 =====
relics = [];

// ===== 技能系统 =====
skills = [];

// ===== 输入 =====
input_left = false;
input_right = false;

// ===== 武器槽（2 个） =====
weapon_slots = [noone, noone];
active_weapon_slot = 0;
// current_weapon 已在 obj_character_base 声明

// ===== 武技槽（1 个） =====
skill_slot = "";
skill_instance = noone;
skill_cooldown_timer = 0;

// ===== 身法槽（1 个） =====
agility_slot = "";
agility_instance = noone;


// ===== 伴生体槽（1 个，预留） =====
companion_slot = noone;

// ===== 背包 =====
inventory = [];
inventory_size = 8;           // 已解锁格子数（动态增长）
inventory_display_size = 24;  // UI 画多少格



// ===== 玩家独有变量 =====
move_dir_x = 0;
move_dir_y = 0;
facing_dir = 1;
level = 1;
current_exp = 0;
exp_to_next = 100;
skill_points = 0;
is_invincible = false;
invincible_timer = 0;
faction_data = undefined;
character_type = "player";
// ===== 武器切换过渡 =====
weapon_switch_timer = 0;            // 0 = 无过渡，>0 = 过渡中
weapon_switch_old_sprite = -1;      // 旧武器精灵（快照）
weapon_switch_old_index = 0;        // 旧武器 image_index
weapon_switch_old_angle = 0;        // 旧武器朝向
weapon_switch_old_xscale = 1;       // 旧武器缩放
weapon_switch_old_yscale = 1;
// ===== 角色属性（UI 显示） =====
race = "人类";
title = "新兵";
skill_hint_cooldown = 0;

// ===== 记录系统 =====
kill_records = {};        // 击杀记录：{ "enemy_hr_swordsman_a": 5, ... }
kill_total = 0;           // 总击杀数
unlocked_weapons = [];    // 已解锁武器 ID
unlocked_skills = [];     // 已解锁武技 ID
unlocked_relics = [];     // 已解锁遗物 ID

is_dashing = false;
dash_timer = 0;

dash_lockout_timer = 0;