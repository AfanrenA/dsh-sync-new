/// @function scr_draw_pickup_hint(inst, label, name, color)
function scr_draw_pickup_hint(inst, label, name, color) {
    if (!instance_exists(inst)) return;
    if (!inst.is_on_ground) return;
    if (!inst.pickup_hint_visible) return;
    
    // ★ 检查 pickup_hint_ref 是否存在
    if (!variable_instance_exists(inst, "pickup_hint_ref")) {
        inst.pickup_hint_ref = noone;
    }
    
    // 如果物品没有提示对象，创建
    if (!instance_exists(inst.pickup_hint_ref)) {
        var _hint = instance_create_depth(inst.x, inst.y - 60, -100, obj_pickup_hint);
        _hint.target_item = inst;
        inst.pickup_hint_ref = _hint;
    }
    
    // 更新提示内容
    var _hint = inst.pickup_hint_ref;
    _hint.hint_label = label;
    _hint.hint_name = name;
    _hint.hint_color = color;
}