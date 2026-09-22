/// obj_item_base Step —— 所有地面物品共用：漂浮 + 光晕跟随
/// ★ 子对象在自己的 Step 里必须调用 event_inherited()

// ===== 地面漂浮效果（每个实例随机相位，避免同步）=====
if (is_on_ground) {
    if (!variable_instance_exists(self, "_bob_timer")) {
        _bob_timer = random(360);
        _start_y = y;
        _bob_speed = random_range(0.022, 0.038);
    }
    _bob_timer += 1;
    y = _start_y + sin(_bob_timer * _bob_speed) * 3;
    image_alpha = 0.8 + 0.2 * sin(_bob_timer * _bob_speed * 0.66);

    // ===== 光晕跟随 =====
    if (instance_exists(glow_ref)) {
        glow_ref.x = x;
        glow_ref.y = y;
    }
} else {
    image_alpha = 1;
}