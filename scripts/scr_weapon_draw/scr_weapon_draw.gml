function scr_weapon_draw(weapon_inst) {
    if (weapon_inst.owner_id != noone) {
        var _draw_x = weapon_inst.owner_id.x;
        var _draw_y = weapon_inst.owner_id.y;
        var _angle = weapon_inst.image_angle;
        var _scale_y = 1;
        
        // V3 垂直翻转
        if (_angle > 90 && _angle < 270) {
            _scale_y = -1;
        }
        
        draw_sprite_ext(weapon_inst.sprite_index, 0, _draw_x, _draw_y, 1, _scale_y, _angle, c_white, 1);
        
        // 画发射点
        var _data = weapon_inst.entity_data;
        var _fire_x = 0;
        var _fire_y = 0;
        
        if (_data != undefined && _data.fire_offset_x != undefined && _data.fire_offset_y != undefined) {
            _fire_x = weapon_inst.x + lengthdir_x(_data.fire_offset_x, _angle) + lengthdir_x(_data.fire_offset_y, _angle + 90);
            _fire_y = weapon_inst.y + lengthdir_y(_data.fire_offset_x, _angle) + lengthdir_y(_data.fire_offset_y, _angle + 90);
        } else {
            _fire_x = weapon_inst.x + lengthdir_x(sprite_get_width(weapon_inst.sprite_index), _angle);
            _fire_y = weapon_inst.y + lengthdir_y(sprite_get_width(weapon_inst.sprite_index), _angle);
        }
        
        draw_set_color(c_yellow);
        draw_circle(_fire_x, _fire_y, 4, false);
        draw_set_alpha(1);
    } else {
        draw_self();
    }
    
    // 拾取提示
    if (weapon_inst.is_on_ground && weapon_inst.pickup_hint_visible) {
        draw_set_font(font_chinese);
        draw_set_color(c_white);
        draw_set_halign(fa_center);
        
        var _sprite = weapon_inst.sprite_index;
        var _center_x = weapon_inst.x + (sprite_get_width(_sprite) / 2) - sprite_get_xoffset(_sprite);
        var _top_y = weapon_inst.y - sprite_get_yoffset(_sprite) - 100;
        
        draw_text(_center_x, _top_y, "按 F 拾取");
        
        draw_set_halign(fa_left);
    }
}