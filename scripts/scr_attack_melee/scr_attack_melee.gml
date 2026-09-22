/// @description 近战攻击行为
/// @param {instance} _owner 攻击者
/// @param {instance} _weapon 武器实例（可选，兼容调用）
/// @param {real} _tx 目标X（近战不使用）
/// @param {real} _ty 目标Y（近战不使用）
function scr_attack_melee(_owner, _weapon = noone, _tx = 0, _ty = 0) {
    
    // ---- 如果没有传入 _weapon，从 _owner 获取 ----
    if (!instance_exists(_weapon)) {
        _weapon = _owner.current_weapon;
    }
    
    // ---- 安全检查 ----
    if (!instance_exists(_weapon)) {
        show_debug_message("⚠️ 近战攻击失败：持有者没有武器");
        return;
    }
    if (_weapon.is_swinging) return;
    
    // ---- 启动挥砍 ----
    _weapon.is_swinging = true;
    _weapon.swing_timer = _weapon.swing_total_frames;
    _weapon.slash_created = false;
    
    if (instance_exists(_weapon.hitbox_ref)) {
        instance_destroy(_weapon.hitbox_ref);
    }
    
    var _data = data_weapon_get(_weapon.weapon_id);
    var _hitbox_life = (_data != undefined && variable_struct_exists(_data, "hitbox_life")) 
                       ? _data.hitbox_life 
                       : _weapon.swing_total_frames + 10;
    
    // ★★★ 修复：安全读取 can_deflect ★★★
    var _can_deflect = false;
    if (_data != undefined && variable_struct_exists(_data, "can_deflect")) {
        _can_deflect = _data.can_deflect;
    }
    // 如果数据表没有，尝试从武器实例读取
    if (!_can_deflect && variable_instance_exists(_weapon, "can_deflect")) {
        _can_deflect = _weapon.can_deflect;
    }
    
    _weapon.hitbox_ref = scr_hitbox_create(
        _weapon,
        _owner,
        _weapon.damage,
        _hitbox_life,
        _can_deflect
    );
    
    // ★ 调试
    if (instance_exists(_weapon.hitbox_ref)) {
        show_debug_message("✅ Hitbox 创建成功，位置: (" + string(_weapon.hitbox_ref.x) + ", " + string(_weapon.hitbox_ref.y) + ")");
    } else {
        show_debug_message("❌ Hitbox 创建失败");
    }
    
    if (_data != undefined && _data.slash_sprite != noone) {
        _weapon.slash_delay = 25;
        _weapon.slash_queued = true;
        show_debug_message("🗡️ 剑气已排队，1秒后发射");
    }
}