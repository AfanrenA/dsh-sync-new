event_inherited();

// ============================================================
// 敌人独有变量（父类 obj_character_base 没有的）
// ============================================================
// 受击强制索敌计时器
_aggro_timer = 0;
_aggro_target = noone;
// ----- 移动 -----
move_dir_x = 0;
move_dir_y = 0;
facing_dir = 1;                          // 1=右，-1=左

// ----- 敌人特有 -----
faction_data = undefined;
ai_behavior = "";                        // "aggressive" | "passive"
attack_type = "";                        // "melee" | "ranged"
ai_state = "patrol";                     // patrol / chase / attack / curious / alert / charging
target = noone;                          // 当前目标
character_type ="enemy";
// ----- 敌人特有 HUD -----
hpbar_timer = 0;
hpbar_alpha = 0;
hpbar_visible = false;
shield_full_show_timer = 0;
shield_full_show_alpha = 0;

// ----- 巡逻变量 -----
_patrol_timer = 0;
_patrol_dir = 0;
_attack_timer = 0;

// ----- 敌人技能系统（独立于父类） -----
enemy_skill_id = "";
enemy_skill_rarity = "common";
enemy_skill_instance = noone;
enemy_skill_cooldown = 0;                // 当前剩余冷却（帧）
enemy_skill_max_cooldown = 300;
enemy_skill_use_chance = 0.5;

// ----- 感知系统 -----
_perception = noone;

// ----- 追击状态 -----
_chase_triggered = false;
_need_turn = false;
_turn_timer = 0;

// ----- 好奇/警惕/反击（A类型用） -----
_curious_timer = 0;
_curious_target_dir = 0;
_alert_count = 0;
_alert_trigger_window = 0;
_alert_watch_timer = 0;
_is_counter_attacking = false;
_counter_attack_timer = 0;

// ----- 状态指示器 -----
_indicator_ref = noone;
_indicator_timer = 0;

// ----- 派系 -----
faction = "B";
hostiles = ["player", "C", "D", "npc"];

// ============================================================
// 技能蓄力系统（charging 状态专用）
// ============================================================
_charge_timer = 0;                       // 蓄力计时器（秒）
_telegraph_ref = noone;                  // 预警对象引用
skill_charge_target = 3.0;               // 目标蓄力时间（秒）
skill_charge_range = 300;                // 蓄力最大范围
skill_charge_dir = 0;                    // 蓄力方向

// ----- 血条控制 -----
_hpbar_shown = false;  // 是否已显示血条

// ===== 追击智能系统 =====
_flank_side = 1;             // 包抄方向：1=左，-1=右
_flank_timer = 300;          // 包抄切换计时器
_last_dir_to_target = 0;     // 上一帧目标方向
_circle_detected_timer = 0;  // 绕圈检测计时器

// ===== 蓄力智能系统 =====
_last_charge_dist = 0;  // 上次蓄力时的距离（用于检测变化）

// ===== 打断拉距系统 =====
_was_interrupted = false;   // 是否被普攻打断蓄力
_last_dist = 9999;      // ★ 新增：上一帧到玩家的距离