// scr_skill_is_compatible.gml
/// @function scr_skill_is_compatible(skill_id, weapon_inst)
/// @param {string} skill_id 武技ID
/// @param {id} weapon_inst 武器实例
/// @return {bool} 是否兼容

function scr_skill_is_compatible(skill_id, weapon_inst) {
    if (skill_id == noone || skill_id == "") return false;
    if (!instance_exists(weapon_inst)) return false;
    
    var _skill_data = data_skill_get(skill_id);
    if (_skill_data == undefined) return false;
    
    // 获取武器类型
    var _weapon_type = weapon_inst.entity_data.type;
    var _compatible = _skill_data.compatible_weapon_types;
    
    for (var i = 0; i < array_length(_compatible); i++) {
        if (_compatible[i] == _weapon_type) {
            return true;
        }
    }
    return false;
}