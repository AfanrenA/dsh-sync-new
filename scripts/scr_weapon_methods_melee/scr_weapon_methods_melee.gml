/// @description 近战武器方法集
/// @param {instance} _weapon 武器实例
function scr_weapon_methods_melee(_weapon) {
    
    /// @description 检查是否可以攻击
    _weapon.can_fire = function() {
        return (attack_cooldown <= 0);
    };
    
    /// @description 近战不需要换弹
    _weapon.needs_reload = function() {
        return false;
    };
    
    /// @description 近战不换弹
    _weapon.start_reload = function() {
        // 近战武器无换弹逻辑
    };
    
    /// @description 近战攻击执行
    _weapon.execute_attack = function(_owner, _target_x, _target_y) {
        if (!can_fire()) return false;
        
        // 触发近战攻击（挥砍动画 + 碰撞盒）
        attack_cooldown = cooldown;
        
        // 调用攻击脚本
        if (attack_behavior != noone) {
            script_execute(attack_behavior, _owner, id);
        }
        
        return true;
    };
    
    show_debug_message("   🗡️ 绑定近战方法集");
}