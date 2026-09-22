// ======================================================================
// obj_hitbox - Draw 事件
// 调试绘制：显示真实的碰撞范围
// ======================================================================

// ---- 1. 半透明填充圆（显示碰撞范围） ----
draw_set_color(c_yellow);
draw_set_alpha(0.2);
draw_circle(x, y, hit_radius, true);   // 实心圆
draw_set_alpha(1);

// ---- 2. 黄色边框（精确边界） ----
draw_set_color(c_yellow);
draw_circle(x, y, hit_radius, false);  // 空心圆

// ---- 3. 中心红点 ----
draw_set_color(c_red);
draw_circle(x, y, 3, false);

// ---- 4. 显示半径数值（可选） ----
draw_set_color(c_white);
draw_text(x + hit_radius + 5, y - 5, "r=" + string(hit_radius));