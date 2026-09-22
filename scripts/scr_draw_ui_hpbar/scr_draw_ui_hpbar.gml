/// @description 绘制完整血条（自适应宽度）
function scr_draw_ui_hpbar(_player) {
    var _x = 20;
    var _y = 20;
    var _h = 16;
    var _seg_w = 16;  // 格子宽度
    var _shield_h = 10;    // 护盾高度（更细）
    // 1. 血条
    scr_draw_hp_battery(_player, _x, _y, _h, _seg_w);
    
    // 2. 护盾层
    var _has_shield = variable_struct_exists(_player, "max_shield");
    if (_has_shield && _player.max_shield > 0) {
        scr_draw_shield_layer(_player, _x, _y + _h + 10,_shield_h, _seg_w);
    }
}