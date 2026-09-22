// ======================================================================
// obj_wall - Create 事件（V3 标准）
// ======================================================================

// ============================================================
// 1. ★ 配置碰撞组件 ★
// ============================================================
collision_mask = COLLISION_LAYER.WALL;
collision_response = "block";  // ★ 添加碰撞响应类型 ★
collision_width = sprite_width;
collision_height = sprite_height;
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
// 2. 调试日志
// ============================================================
show_debug_message("🧱 墙体已创建: (" + string(x) + ", " + string(y) + ")");