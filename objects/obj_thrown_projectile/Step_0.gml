/// @description 投掷物 - Step 事件

// ============================================================
// ★★★ 优先处理：炸弹倒计时（父类执行前先拦截）★★★
// ============================================================
if (state == "arming") {
    x = target_x;
    y = target_y;
    gravity = 0;

    breath_phase += 0.05;
    image_alpha = 0.7 + 0.3 * sin(breath_phase);
    
    var _mix = 0.5 + 0.5 * sin(breath_phase);
    image_blend = merge_color(c_orange, c_red, _mix);

    arming_timer--;
    if (arming_timer <= 0) {
        image_blend = c_red;
        do_explosion();
    }
    exit;  // ← 不执行父类 Step
}

// ============================================================
// 然后调用父类（飞行 + 碰撞检测）
// ============================================================
event_inherited();

// ============================================================
// 飞行状态
// ============================================================
if (state == "flying") {
    // ---- 生成拖尾粒子 ----
    var _particle = instance_create_layer(x, y, "Effects", obj_trail_particle);
    _particle.sprite_index = spr_trail_smoke;
    _particle.image_xscale = 0.5 + random(0.5);
    _particle.image_yscale = _particle.image_xscale;
    _particle.image_angle = random(360);
    _particle.image_blend = c_orange;
    _particle.fade_speed = 0.03 + random(0.03);

    // ---- 飞行位置计算（抛物线） ----
    var _progress = traveled / max_range;
    if (_progress > 1) _progress = 1;

    var _x_pos = lerp(start_x, target_x, _progress);
    var _arc_height = 4 * max_range * 0.3;
    var _y_pos = lerp(start_y, target_y, _progress) - _arc_height * _progress * (1 - _progress);
    _y_pos += gravity * traveled * 0.1;

    x = _x_pos;
    y = _y_pos;
    traveled += speed;

    // ---- 到达目标点 ----
    if (traveled >= max_range) {
        x = target_x;
        y = target_y;
        start_x = target_x;
        start_y = target_y;

        if (is_explosive) {
            state = "arming";
            arming_timer = 60;
        } else {
            instance_destroy();
            return;
        }
    }
}