// ======================================================================
// obj_chest - Draw 事件（V3 标准）
// ======================================================================
/// @description 绘制宝箱 + 辉光 + 按键提示


// ============================================================
// 1. 绘制宝箱本身
// ============================================================
draw_self();


// ============================================================
// 2. ★ 如果宝箱已打开，不画辉光 ★
// ============================================================
if (is_open) exit;


// ============================================================
// 3. 绘制未打开时的辉光（脉冲光晕）
// ============================================================
// 使用 pulse_timer 控制呼吸动画（在 Step 事件中更新）
var _pulse = 0.5 + 0.5 * sin(pulse_timer);
var _alpha = glow_alpha * (0.6 + 0.4 * _pulse);
var _scale = 1.0 + 0.08 * sin(pulse_timer * 0.7);

// 在宝箱周围画光晕
gpu_set_blendmode(bm_add);
draw_set_color(glow_color);
draw_set_alpha(_alpha);
draw_circle(x, y, max(sprite_width, sprite_height) * 0.6 * _scale, false);
draw_set_alpha(1);
gpu_set_blendmode(bm_normal);


// ============================================================
// 4. ★ 绘制按键提示（如果玩家在附近）★
// ============================================================
if (player_nearby) {
    // ---- 提示文字背景 ----
    var _text = "按 [E] 打开宝箱";
    var _text_w = string_width(_text) + 20;
    var _text_h = 24;
    var _tx = x;
    var _ty = y - sprite_height - 40;
    
    /* 背景半透明黑条
    draw_set_color(c_black);
    draw_set_alpha(0.6);
    draw_rectangle(_tx - _text_w/2, _ty - _text_h/2, _tx + _text_w/2, _ty + _text_h/2, true);
    draw_set_alpha(1);*/
    
    // 文字（白色，呼吸脉冲）
    var _text_alpha = 0.7 + 0.3 * sin(interact_timer);
    draw_set_color(c_white);
    draw_set_alpha(_text_alpha);
    draw_set_halign(fa_center);
    draw_set_valign(fa_middle);
    draw_text(_tx, _ty, _text);
    
    // 重置绘制状态
    draw_set_alpha(1);
    draw_set_halign(fa_left);
    draw_set_valign(fa_top);
}