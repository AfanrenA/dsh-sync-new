// ======================================================================
// obj_chest - Create 事件（V3 标准）
// ======================================================================

// ============================================================
// 1. ★ 配置碰撞组件 ★
// ============================================================
// ★ 修正：宝箱属于 CHEST 层 ★
collision_mask = COLLISION_LAYER.CHEST;
// ★ 添加碰撞响应类型 ★
collision_response = "block";  // 阻挡型

collision_width = sprite_width * 0.9;
collision_height = sprite_height * 0.9;
collision_offset_x = 0;
collision_offset_y = 0;

collision_comp = scr_component_collision_create(
    id,
    collision_mask,
    collision_width,
    collision_height
);
collision_comp.offset_x = collision_offset_x;
collision_comp.offset_y = collision_offset_y;
collision_comp.is_trigger = false;


// ============================================================
// 2. 基础状态
// ============================================================
is_open = false;
chest_id = "chest_melee";


// ============================================================
// 3. ★ 从数据表读取配置 ★
// ============================================================
var _data = data_chest_get(chest_id);
if (_data != undefined) {
    weapon_pool = _data.weapon_pool;
    glow_color = _data.glow_color;
    glow_alpha = _data.glow_alpha;
    glow_pulse_speed = _data.glow_pulse_speed;
    particle_count = _data.particle_count;
    particle_speed = _data.particle_speed;
    particle_life = _data.particle_life;
    rarity_override = _data.rarity_override;
    show_debug_message("📦 宝箱已创建: " + string(chest_id) + ", 武器池: " + string(array_length(weapon_pool)) + " 种");
} else {
    show_debug_message("⚠️ 宝箱数据不存在: " + string(chest_id) + "，使用默认值");
    weapon_pool = ["sword", "axe"];
    glow_color = c_lime;
    glow_alpha = 0.15;
    glow_pulse_speed = 1.5;
    particle_count = 20;
    particle_speed = 6;
    particle_life = 15;
    rarity_override = -1;
}


// ============================================================
// 4. 交互状态
// ============================================================
player_nearby = false;
interact_timer = 0;
pulse_timer = 0;


// ============================================================
// 5. ★ 交互检测半径 ★
// ============================================================
bbox_radius = max(sprite_width, sprite_height) * 0.5 + 100;


// ============================================================
// 6. 调试日志
// ============================================================
show_debug_message("✅ 宝箱创建完成: " + string(chest_id) + " 位置: (" + string(x) + ", " + string(y) + ")");