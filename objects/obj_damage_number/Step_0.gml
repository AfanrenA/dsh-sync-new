// 边飞边变大
if (image_xscale < target_scale) {
    image_xscale += 0.05;   // 从 0.05 改成 0.15
    image_yscale += 0.05;
    if (image_xscale > target_scale) {
        image_xscale = target_scale;
        image_yscale = target_scale;
    }
}

// ===== 减速 =====
hspeed *= 0.96;
vspeed *= 0.96;

// ===== 生命周期 =====
life_timer -= 1;

// ===== 淡出 =====
if (life_timer < fade_start) {
    image_alpha = life_timer / fade_start;
}

if (life_timer <= 0) {
    instance_destroy();
}