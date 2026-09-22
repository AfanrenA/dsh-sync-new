// ===== 跟随角色（角色消失则自己消失） =====
if (instance_exists(target_ref)) {
    x = target_ref.x;
    y = target_ref.y - 80;   // 头上 30 像素
} else {
    // 角色已消失，光环也消失
    instance_destroy();
    exit;
}

// ===== 生命周期 =====
life_timer -= 1;

// ===== 淡出（最后 30 帧） =====
if (life_timer < 30) {
    image_alpha = life_timer / 30;
}

if (life_timer <= 0) {
    instance_destroy();
}