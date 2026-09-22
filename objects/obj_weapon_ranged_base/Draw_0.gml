event_inherited();

// ===== 后坐力偏移 =====
var _draw_x = x;
var _draw_y = y;
if (recoil_timer > 0) {
    var _t = recoil_timer / 15;
    var _ease = _t * (2 - _t);
    var _recoil_back = recoil_offset * _ease;
    _draw_x -= lengthdir_x(_recoil_back, image_angle);
    _draw_y -= lengthdir_y(_recoil_back, image_angle);
}

// ===== 画武器 =====
draw_sprite_ext(sprite_index, image_index, _draw_x, _draw_y, image_xscale, image_yscale, image_angle, c_white, image_alpha);

// ===== ★ 附件叠加（画在武器之后）=====
if (instance_exists(owner_id) && instance_exists(owner_id.skill_instance)) {
    var _sk = owner_id.skill_instance;
    var _is_attachment = variable_instance_exists(_sk, "type") && _sk.type == "附件";
    
    if (_is_attachment && _sk.data != undefined) {
        
        // 按弹药选形态
        var _att_spr = (_sk.ammo_current > 0) ? _sk.data.attachment_sprite_loaded : _sk.data.attachment_sprite_empty;
        
        if (_att_spr != -1 && sprite_exists(_att_spr)) {
            
            // 挂载点偏移（先按武器翻转镜像，再沿角度旋转）
var _mount_x = _sk.data.attachment_mount_x;
var _mount_y = _sk.data.attachment_mount_y;

// ★ 武器 yscale 翻转时，挂载点 y 取反（相对武器原点镜像）
if (image_yscale < 0) _mount_y = -_mount_y;

var _ax = _draw_x + lengthdir_x(_mount_x, image_angle) + lengthdir_x(_mount_y, image_angle + 90);
var _ay = _draw_y + lengthdir_y(_mount_x, image_angle) + lengthdir_y(_mount_y, image_angle + 90);

draw_sprite_ext(_att_spr, 0, _ax, _ay, image_xscale, image_yscale, image_angle, c_white, image_alpha);
        }
    }
}

// ===== 换弹圈 =====
scr_draw_reload_ring(self);