// ======================================================================
// scr_weapon_factory.gml
// 武器工厂 - ID到对象的映射和武器创建
// ======================================================================

/// @description 根据武器数据表 ID 获取对应的对象资源
/// @param {string} _id 武器 ID（如 "w_sword"）
/// @returns {object} 武器对象资源
function scr_weapon_get_object_from_id(_id) {
    static _map = {
        sword: obj_changjian,
        axe: obj_axe,
        powergun: obj_powergun,
		firebomb: obj_firebomb,
		dagger: obj_dagger
    };
    
    if (!struct_exists(_map, _id)) {
        show_debug_message("⚠️ 未知武器 ID: " + string(_id));
        return noone;
    }
    return _map[$ _id];
}