/// @function scr_hitbox_life_update(_hitbox)
/// @param {id} _hitbox Hitbox 实例
/// @description 生命周期管理

function scr_hitbox_life_update(_hitbox) {
    _hitbox.life_frames -= 1;
    if (_hitbox.life_frames <= 0) {
        instance_destroy(_hitbox);
    }
}