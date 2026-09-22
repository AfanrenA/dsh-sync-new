/// @description 拖尾粒子 - 逐帧淡出
image_alpha -= fade_speed;
life--;

if (image_alpha <= 0 || life <= 0) {
    instance_destroy();
}