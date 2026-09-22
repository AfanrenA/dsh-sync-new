// obj_relic_base Create —— 本命遗物基类
// 继承 obj_item_base（display_name / rarity / rarity_color / entity_data / rarity_data
//                    / owner_id / is_on_ground / glow_ref / pickup_hint_* ）
event_inherited();

// ===== 遗物特有 =====
relic_id = "";
slot_type = "relic";
depth = 115;

// ===== 主动状态 =====
cooldown_timer = 0;          // 冷却剩余帧数
is_active = false;           // 是否处于"生效中"
active_timer = 0;            // 生效剩余帧数

// ===== 主动效果脚本（由工厂从数据表填） =====
active_script = "";