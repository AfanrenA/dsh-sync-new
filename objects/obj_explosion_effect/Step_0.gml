
// obj_explosion_effect - Step 事件
fade_timer--;
if (fade_timer <= 0) {
    image_alpha -= 0.05;
    if (image_alpha <= 0) instance_destroy();
}