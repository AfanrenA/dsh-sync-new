// obj_enemy_indicator Draw 事件

if (!instance_exists(follow_target)) {
    instance_destroy();
    exit;
}

x = follow_target.x;
y = follow_target.y - 60;

if (lifetime != -1) {
    timer += 1;
    if (timer >= lifetime) {
        instance_destroy();
        exit;
    }
}

if (lifetime != -1 && timer < 30) {
    flash_timer += 1;
    if (flash_timer < 15) alpha = 1;
    else if (flash_timer < 30) alpha = 0;
    else alpha = 1;
} else {
    alpha = 1;
}

// ===== 根据类型绘制 =====
draw_set_alpha(alpha);
draw_set_halign(fa_center);
draw_set_valign(fa_middle);

// ★ 设置字体
draw_set_font(font_ui);

if (indicator_type == "exclamation") {
    draw_set_color(c_red);
    draw_text(x, y, "!");
} else if (indicator_type == "question") {
    draw_set_color(c_red);
    draw_text(x, y, "?");
} else if (indicator_type == "alert") {
    draw_set_color(c_red);
    draw_text(x - 20, y, "!");
    draw_text(x + 20, y, "?");
}

draw_set_alpha(1);
draw_set_color(c_white);