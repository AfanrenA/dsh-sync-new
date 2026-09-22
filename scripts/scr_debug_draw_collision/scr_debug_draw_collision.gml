// ======================================================================
// scr_debug_draw_collision.gml - 高科技半透明碰撞盒调试
// 风格：半透明填充 + 亮色边框 + 发光效果
// ======================================================================

function scr_debug_draw_collision(_obj) {
    if (!instance_exists(_obj)) return;
    if (_obj.collision_comp == noone) return;
    
    var _comp = _obj.collision_comp;
    var _half_w = _comp.width * 0.5;
    var _half_h = _comp.height * 0.5;
    
    var _x1 = _obj.x - _half_w + _comp.offset_x;
    var _y1 = _obj.y - _half_h + _comp.offset_y;
    var _x2 = _obj.x + _half_w + _comp.offset_x;
    var _y2 = _obj.y + _half_h + _comp.offset_y;
    
    // ---- 根据类型选择颜色 ----
    var _color, _alpha_fill, _alpha_border;
    
    switch (_obj.object_index) {
        case obj_player_base:
        case obj_player:
            // 玩家：蓝色系
            _color = c_blue;
            _alpha_fill = 0.15;
            _alpha_border = 0.6;
            break;
            
        case obj_enemy_base:
            // 敌人：红色系
            _color = c_red;
            _alpha_fill = 0.15;
            _alpha_border = 0.6;
            break;
            
        default:
            // 其他：白色
            _color = c_white;
            _alpha_fill = 0.1;
            _alpha_border = 0.4;
            break;
    }
    
    // ---- 1. 半透明填充（显示碰撞区域） ----
    draw_set_color(_color);
    draw_set_alpha(_alpha_fill);
    draw_rectangle(_x1, _y1, _x2, _y2, true);
    
    // ---- 2. 亮色边框（发光感） ----
    draw_set_color(_color);
    draw_set_alpha(_alpha_border);
    draw_rectangle(_x1, _y1, _x2, _y2, false);
    
    // ---- 3. 四角发光点（高科技风格） ----
    var _dot_size = 3;
    draw_set_alpha(0.8);
    
    // 四个角
    draw_circle(_x1, _y1, _dot_size, false);
    draw_circle(_x2, _y1, _dot_size, false);
    draw_circle(_x1, _y2, _dot_size, false);
    draw_circle(_x2, _y2, _dot_size, false);
    
    // ---- 4. 中心十字线（精确定位） ----
    draw_set_alpha(0.3);
    draw_line(_x1, (_y1 + _y2) * 0.5, _x2, (_y1 + _y2) * 0.5);
    draw_line((_x1 + _x2) * 0.5, _y1, (_x1 + _x2) * 0.5, _y2);
    
    // ---- 5. 尺寸标签 ----
    var _label = string(round(_comp.width)) + "x" + string(round(_comp.height));
    draw_set_alpha(0.7);
    draw_set_color(_color);
    draw_text(_x1, _y1 - 16, _label);
    
    // ---- 恢复透明度 ----
    draw_set_alpha(1.0);
}