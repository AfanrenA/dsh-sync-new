/// @description 判断物品是否属于某类（★ 兼容"直接用基类"的情况）
/// @param {real} obj_index 物品的 object_index
/// @param {real} base_obj 目标基类
/// @returns {bool}
/// @note GM 的 object_is_ancestor(A, A) 返回 false，
///       所以直接用基类当实体的物品（如 obj_relic_base）必须额外判等
function scr_is_item_type(obj_index, base_obj) {
    if (obj_index == base_obj) return true;
    return object_is_ancestor(obj_index, base_obj);
}