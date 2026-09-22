/// @description 统一攻击入口（玩家和敌人都走这里）
/// @param {id} weapon 武器实例
function scr_weapon_try_attack(weapon) {
    if (!instance_exists(weapon)) return;
    if (!instance_exists(weapon.owner_id)) return;
    if (weapon.is_on_ground) return;
    if (weapon.cooldown_timer > 0) return;
    
    // 近战：挥砍中不触发
    if (variable_instance_exists(weapon, "is_swinging") && weapon.is_swinging) return;
    
    // 调用攻击脚本
    if (weapon.attack_script != "" && weapon.attack_script != undefined) {
        script_execute(asset_get_index(weapon.attack_script), weapon.owner_id, weapon);
    }
}