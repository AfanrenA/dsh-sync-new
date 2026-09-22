/// @description 读遗物伤害倍率（兜底，任意角色可调）
/// @param {id} owner 角色实例
/// @returns {real} 伤害倍率（默认 1.0）
function scr_relic_get_damage_mult(owner) {
    if (!instance_exists(owner)) return 1.0;
    if (!variable_instance_exists(owner, "relic_damage_mult")) return 1.0;
    return owner.relic_damage_mult;
}