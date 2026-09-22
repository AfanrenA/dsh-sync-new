// obj_screen_effect Step 事件
/// @description 更新屏幕效果

// ===== 边缘红圈淡出 =====
if (edge_alpha > 0) {
    edge_alpha -= edge_fade_speed;
    if (edge_alpha < 0) edge_alpha = 0;
}

// ===== 护盾白圈淡出 =====
if (shield_edge_alpha > 0) {
    shield_edge_alpha -= shield_edge_fade_speed;
    if (shield_edge_alpha < 0) shield_edge_alpha = 0;
}

// ===== 屏幕震动衰减 =====
if (shake_duration > 0) {
    shake_duration -= 1;
    shake_intensity *= 0.92;  // 快速衰减
    if (shake_duration <= 0) {
        shake_intensity = 0;
        shake_x = 0;
        shake_y = 0;
    }
}

// ===== 计算震动偏移 =====
if (shake_duration > 0 && shake_intensity > 0.1) {
    shake_x = random_range(-shake_intensity, shake_intensity);
    shake_y = random_range(-shake_intensity, shake_intensity);
} else {
    shake_x = 0;
    shake_y = 0;
}