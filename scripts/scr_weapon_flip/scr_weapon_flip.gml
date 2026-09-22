// ======================================================================
// scr_weapon_flip.gml
// 武器方向修正（左右翻转）
// 防止武器朝左时上下颠倒
// ======================================================================

/// @description 根据基础角度判断是否需要垂直翻转
/// @param {real} _base_angle 基础朝向角度
/// @returns {real} image_yscale 值（1 或 -1）
function scr_weapon_flip(_base_angle) {
    // 基础角度在 90°~270° 之间时，武器朝左，需要垂直翻转
    if (_base_angle > 90 && _base_angle < 270) {
        return -1;
    }
    return 1;
}