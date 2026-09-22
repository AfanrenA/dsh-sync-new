// ======================================================================
// obj_particle 步进事件
// ======================================================================
// 物理
x_speed *= friction;
y_speed += gravity;
x += x_speed;
y += y_speed;

// 生命周期
life -= 1;
if (life <= 0) {
    instance_destroy();
    exit;
}

// 淡出
image_alpha = life / max_life;  // 需要存初始life