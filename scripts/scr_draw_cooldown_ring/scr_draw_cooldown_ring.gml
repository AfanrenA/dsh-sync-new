// ============================================================
// scr_draw_cooldown_ring
// 在角色上方绘制冷却圈（攻击冷却 + 换弹进度）
// 用法：在角色的 Draw 事件中调用
//       scr_draw_cooldown_ring(inst)
// 
// V3 原则：
// - 模块化：独立脚本，可被任何角色调用
// - 可复用：玩家、敌人、召唤物共用
// - 单一职责：只做冷却圈绘制这一件事
// ============================================================

function scr_draw_cooldown_ring(inst) {
    /// @param inst 角色实例
    
    if (!instance_exists(inst)) exit;
    if (!instance_exists(inst.current_weapon)) exit;
    
    var _weapon = inst.current_weapon;
    
    var _cd = _weapon.attack_cooldown;
    var _max = _weapon.cooldown_max;
    var _is_reloading = _weapon.is_reloading;
    var _reload_timer = _weapon.reload_timer;
    var _reload_time = _weapon.reload_time;
    var _magazine_loading = _weapon.magazine_loading;
    var _magazine_max = _weapon.magazine_max;
    var _magazine_current = _weapon.magazine_current;
    
    // 决定显示什么：换弹优先
    var _display_cd = _cd;
    var _display_max = _max;
    var _is_loading = false;
    
    if (_is_reloading && _reload_time > 0) {
        _display_cd = _reload_timer;
        _display_max = _reload_time;
        _is_loading = true;
    }
    
    // 如果没有攻击冷却也没有换弹，不显示
    if (_display_cd <= 0 || _display_max <= 0) return;
    
    // ---- 绘制冷却圈 ----
    var _progress = _display_cd / _display_max;
    var _angle = (1 - _progress) * 360;
    var _cx = inst.x;
    var _cy = inst.y - 70;
    var _radius = 22;
    
    // 保存绘制状态
    var _old_colour = draw_get_color();
    var _old_alpha = draw_get_alpha();
    var _old_halign = draw_get_halign();
    var _old_valign = draw_get_valign();
    
    // 背景圈
    draw_set_color(c_gray);
    draw_set_alpha(0.3);
    draw_circle(_cx, _cy, _radius, false);
    
    // 进度圈（换弹用橙色，攻击用白色）
    if (_is_loading) {
        draw_set_color(c_orange);
    } else {
        draw_set_color(c_white);
    }
    draw_set_alpha(0.9);
    draw_arc(_cx, _cy, _radius, _radius, 0, _angle, 8);
    
    // ---- 中心文字 ----
    draw_set_alpha(1);
    draw_set_halign(fa_center);
    draw_set_valign(fa_middle);
    
    if (_is_loading && _magazine_max > 0) {
        draw_set_color(c_orange);
        draw_set_alpha(0.9 + 0.1 * sin(_reload_timer * 0.2));
        draw_text(_cx, _cy, string(_magazine_loading) + "/" + string(_magazine_max));
    } else if (_magazine_max > 0) {
        var _color = c_white;
        if (_magazine_current <= _magazine_max * 0.2) _color = c_red;
        else if (_magazine_current <= _magazine_max * 0.5) _color = c_yellow;
        draw_set_color(_color);
        draw_text(_cx, _cy, string(_magazine_current));
    }
    
    // 恢复绘制状态
    draw_set_color(_old_colour);
    draw_set_alpha(_old_alpha);
    draw_set_halign(_old_halign);
    draw_set_valign(_old_valign);
}