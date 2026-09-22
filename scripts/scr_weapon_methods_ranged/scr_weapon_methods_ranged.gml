/// @description 远程武器方法集
/// @param {instance} _weapon 武器实例
function scr_weapon_methods_ranged(_weapon) {
    
    /// @description 检查是否可以开火
    _weapon.can_fire = function() {
        if (is_reloading) return false;
        if (attack_cooldown > 0) return false;
        return true;
    };
    
    /// @description 检查是否需要换弹
    _weapon.needs_reload = function() {
        if (magazine_max <= 0) return false;
        return (magazine_current <= 0);
    };
    
    /// @description 开始换弹
    _weapon.start_reload = function() {
        if (is_reloading) return;
        if (magazine_current >= magazine_max) return;
        is_reloading = true;
        reload_timer = burst_cooldown;
        reload_time = burst_cooldown;
        magazine_loading = 0;
        show_debug_message("🔄 开始换弹: " + string(weapon_name));
    };
    
    /// @description 远程攻击执行
    _weapon.execute_attack = function(_owner, _target_x, _target_y) {
        if (!can_fire()) return false;
        
        // 消耗弹药
        if (magazine_max > 0) {
            if (magazine_current <= 0) {
                start_reload();
                return false;
            }
            magazine_current -= 1;
        }
        
        // 触发攻击
        attack_cooldown = cooldown;
        
        // 调用攻击脚本
        if (attack_behavior != noone) {
            script_execute(attack_behavior, _owner, id, _target_x, _target_y);
        }
        
        return true;
    };
    
    show_debug_message("   🔫 绑定远程方法集");
}