/// @description 投掷武器方法集
/// @param {instance} _weapon 武器实例
function scr_weapon_methods_thrown(_weapon) {
    
    /// @description 检查是否可以投掷
    _weapon.can_fire = function() {
        return (attack_cooldown <= 0);
    };
    
    /// @description 投掷不需要换弹
    _weapon.needs_reload = function() {
        return false;
    };
    
    /// @description 投掷不换弹
    _weapon.start_reload = function() {
        // 投掷武器无换弹逻辑
    };
    
    /// @description 投掷攻击执行
    _weapon.execute_attack = function(_owner, _target_x, _target_y) {
        if (!can_fire()) return false;
        
        attack_cooldown = cooldown;
        
        // 调用攻击脚本
        if (attack_behavior != noone) {
            script_execute(attack_behavior, _owner, id, _target_x, _target_y);
        }
        
        return true;
    };
    
    show_debug_message("   🪃 绑定投掷方法集");
}