function scr_show_hint(owner, text) {
    var _hint = instance_create_depth(0, 0, -15000, obj_hint);
    _hint.text = text;
}