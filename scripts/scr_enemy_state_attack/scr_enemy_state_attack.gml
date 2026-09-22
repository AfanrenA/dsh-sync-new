/// @function scr_enemy_state_attack(enemy)
function scr_enemy_state_attack(enemy) {
    var p = enemy._perception;
    if (!p.has_target) return;
    
    var _ai = enemy.entity_data.ai;
    var _chase_speed = _ai.chase_speed != undefined ? _ai.chase_speed : 1.5;
    
    var _weapon = enemy.current_weapon;
    if (!instance_exists(_weapon)) return;
    
    var _weapon_data = _weapon.entity_data;
    var _weapon_attack_speed = _weapon_data.attack_speed != undefined ? _weapon_data.attack_speed : 1.5;
    var _weapon_range = _weapon_data.attack_range != undefined ? _weapon_data.attack_range : 48;
    
    var _dir = p.dir_to_target;
    enemy.facing_dir = sign(cos(degtorad(_dir)));
    enemy.image_xscale = enemy.facing_dir;
    
    var _dist = p.dist;
    
    // ===== ★ 预判：玩家是否在靠近 =====
    var _is_approaching = false;
    if (enemy._last_dist != undefined) {
        _is_approaching = (_dist < enemy._last_dist - 0.5);   // 这一帧比上一帧近了
    }
    enemy._last_dist = _dist;
    
    // ===== ★ 攻击范围：靠近时放大 =====
    var _attack_range = _weapon_range * 1.2;   // 默认攻击范围
    if (_is_approaching) {
        _attack_range = _weapon_range * 2.5;   // 靠近时，攻击范围放大到 1.8 倍
    }
    
    var _chase_range = _weapon_range * 2.0;
    
    // ===== 1. 太远 → 追击 =====
    if (_dist > _chase_range) {
        enemy.x += lengthdir_x(_chase_speed, _dir);
        enemy.y += lengthdir_y(_chase_speed, _dir);
        return;
    }
    
    // ===== 2. 中距离 → 靠近 =====
    if (_dist > _attack_range) {
        enemy.x += lengthdir_x(_chase_speed * 0.8, _dir);
        enemy.y += lengthdir_y(_chase_speed * 0.8, _dir);
        return;
    }
    
    // ===== 3. 攻击范围 → 攻击 =====
    enemy._attack_timer -= 1;
    if (enemy._attack_timer > 0) return;
    if (_weapon.cooldown_timer > 0) return;
    
    scr_weapon_try_attack(_weapon);
    
    var _attack_cooldown = 10 + (30 / _weapon_attack_speed);
    _attack_cooldown = clamp(_attack_cooldown, 10, 40);
    enemy._attack_timer = _attack_cooldown;
}