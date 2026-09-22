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

// ===== ★ 被动/主动分流标记 =====
//   false = 本命遗物（主动，单槽，按 R 触发）—— 原有行为
//   true  = 被动遗物（纯数据池，拾取后转成 relic_pool 条目并销毁本实例）
//   拾取时由 scr_item_pickup_relic 据此分流，主动逻辑完全不受影响。
is_passive = false;