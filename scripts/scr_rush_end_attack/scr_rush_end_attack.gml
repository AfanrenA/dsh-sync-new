function scr_rush_end_attack(owner) {
    if (!owner.is_alive || owner.is_dead) return;
    if (!instance_exists(owner.current_weapon)) return;
    
    var _weapon = owner.current_weapon;
    if (_weapon.attack_script == "" || _weapon.attack_script == undefined) return;
    owner.rush_is_skill_damage = false;
    // ===== 冲撞结束后，在 `_weapon` 上设置 `_swing_base_angle` =====
    // 确保攻击动画的基础角度是冲撞方向，而不是鼠标方向
    var _dir = owner.rush_dir;
    var _tx = owner.x + lengthdir_x(100, _dir);
    var _ty = owner.y + lengthdir_y(100, _dir);
    
    // ===== 在执行攻击前，保存当前武器角度作为基础角度 =====
    // 这样 `scr_weapon_swing_update` 才能正确计算偏移
    _weapon._swing_base_angle = _dir;
    
    script_execute(asset_get_index(_weapon.attack_script), owner, _weapon, _tx, _ty);
    
    show_debug_message("[RUSH] 冲撞结束，自动攻击");
}