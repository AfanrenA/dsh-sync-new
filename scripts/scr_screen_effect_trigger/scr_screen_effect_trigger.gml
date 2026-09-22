/// @description 触发屏幕效果
/// @param {real} _intensity 震动强度（建议 3-8）
/// @param {real} _duration 震动持续时间（帧，建议 5-15）
/// @param {string} _type 效果类型："damage" 红圈 | "shield" 白圈 | "both"

function scr_screen_effect_trigger(_intensity = 5, _duration = 10, _type = "damage") {
    show_debug_message("[SCREEN] 触发！强度=" + string(_intensity) + ", 类型=" + _type);
    
    if (!instance_exists(obj_screen_effect)) {
        show_debug_message("[SCREEN] ❌ obj_screen_effect 不存在！");
        return;
    }
    
    var _effect = obj_screen_effect;
    
    // ===== 1. 屏幕震动 =====
    if (_intensity > 0) {
        _effect.shake_intensity = max(_effect.shake_intensity, _intensity);
        _effect.shake_duration = max(_effect.shake_duration, _duration);
    }
    
    // ===== 2. 边缘颜色 =====
    if (_type == "damage" || _type == "both") {
        // 血量越低，红色越深
        var _player = instance_find(obj_player_base, 0);
        if (instance_exists(_player)) {
            var _hp_ratio = _player.hp / _player.max_hp;
            // 血量越低，目标透明度越高（0.2 ~ 0.8）
            var _target_alpha = 0.2 + (1 - _hp_ratio) * 0.6;
            _effect.edge_target_alpha = max(_effect.edge_alpha, _target_alpha);
            _effect.edge_alpha = max(_effect.edge_alpha, _target_alpha);
        } else {
            var _target_alpha = 0.4;
            _effect.edge_target_alpha = max(_effect.edge_alpha, _target_alpha);
            _effect.edge_alpha = max(_effect.edge_alpha, _target_alpha);
        }
        // 重置淡出计时器（保持显示）
        _effect.edge_fade_speed = 0.02;
    }
    
    // ===== 3. 护盾白圈 =====
   if (_type == "shield" || _type == "both") {
    show_debug_message("[SCREEN] 触发护盾白圈，当前 shield_edge_alpha=" + string(_effect.shield_edge_alpha));
    var _target_alpha = 0.6;
    _effect.shield_edge_alpha = max(_effect.shield_edge_alpha, _target_alpha);
    _effect.shield_edge_fade_speed = 0.03;
}
}