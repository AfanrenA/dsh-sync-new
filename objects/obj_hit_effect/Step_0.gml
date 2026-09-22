/// @description 特效逐帧更新
life--;
image_alpha = life / 15;    // 逐渐淡出
size += 0.5;                // 逐渐扩散
x += x_speed;
y += y_speed;
x_speed *= 0.9;             // 减速
y_speed *= 0.9;

if (life <= 0) {
    instance_destroy();
}