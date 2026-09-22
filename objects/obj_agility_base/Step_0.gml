event_inherited()

// ===== 身法冷却递减（未装备时）=====
// ★ 冷却绑定"实例"而非槽位：待在背包 / 躺在地上也照样走表。
//   已装备时由 scr_character_state_update 第 3b 段统一递减，
//   这里必须互斥判断，否则会与那段重复 → 2 倍速回冷却。
var _equipped = (owner_id != noone) && instance_exists(owner_id)
             && variable_instance_exists(owner_id, "agility_instance")
             && owner_id.agility_instance == id;

if (!_equipped) {
    if (cooldown_timer > 0) {
        cooldown_timer -= 1;
    }
}