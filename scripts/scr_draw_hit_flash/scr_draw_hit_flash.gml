// ============================================================
// scr_draw_hit_flash - 增强版
// 白→红交替闪烁，持续 0.3-0.4 秒
// ============================================================

function scr_draw_hit_flash(inst) {
    if (!instance_exists(inst)) exit;
    if (inst.hit_flash_timer <= 0) exit;
    if (!inst.visible) exit;
    
    var _spr = inst.sprite_index;
    if (_spr == -1 || !sprite_exists(_spr)) exit;
    
    var _timer = inst.hit_flash_timer;
    var _max = 30;          // 总持续 20 帧 ≈ 0.33 秒
    var _progress = _timer / _max;
    
    // ★ 闪烁频率：每 4 帧切换一次颜色（比之前更慢，更明显）
    var _flash_color = (floor(_timer / 10) % 2 == 0) ? c_white : c_red;
    
    // 透明度：从 0.85 开始衰减，最后消失
    var _alpha = _progress * 0.85;
    
    var _spr_w = sprite_get_width(_spr);
    var _spr_h = sprite_get_height(_spr);
    
    var _x1 = inst.x - _spr_w * 0.5 * abs(inst.image_xscale);
    var _y1 = inst.y - _spr_h * 0.5 * abs(inst.image_yscale);
    var _x2 = inst.x + _spr_w * 0.5 * abs(inst.image_xscale);
    var _y2 = inst.y + _spr_h * 0.5 * abs(inst.image_yscale);
    
    var _old_colour = draw_get_color();
    var _old_alpha = draw_get_alpha();
    
    draw_set_color(_flash_color);
    draw_set_alpha(_alpha);
    draw_rectangle_colour(_x1, _y1, _x2, _y2, 
        _flash_color, _flash_color, _flash_color, _flash_color, false);
    
    draw_set_color(_old_colour);
    draw_set_alpha(_old_alpha);
}