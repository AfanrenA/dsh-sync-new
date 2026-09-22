/// @description 生成伤害数字
function scr_spawn_damage_number(_x, _y, _damage, _is_critical) {
    var _num = instance_create_depth(_x, _y, -100000, obj_damage_number);
    if (!instance_exists(_num)) return;
    
    _num.damage_value = round(_damage);
    _num.is_critical = _is_critical;
    
    // ===== ★ 随机方向 + 随机速度 =====
    var _angle, _speed;
    if (_is_critical) {
        // 暴击：全方向 + 速度大（炸开感）
        _angle = random_range(0, 360);
        _speed = random_range(6, 12);   // ★ 从 3~6 改成 6~12
    } else {
        // 普通：往上飞，左右偏
        _angle = random_range(-20, 20) - 90;
        _speed = random_range(2, 4);    // ★ 从 1.5~2.5 改成 2~4
    }
    
    _num.hspeed = lengthdir_x(_speed, _angle);
    _num.vspeed = lengthdir_y(_speed, _angle);
    
    // ===== 伤害越高，数字越大 =====
    var _damage_factor = clamp(_damage / 15, 0.6, 2.5);
    
    var _start_scale = 0.8 * _damage_factor;
    var _target_scale = 2.5 * _damage_factor;
    
    if (_is_critical) {
        _target_scale = 5.0 * _damage_factor;
    }
    
    _target_scale *= random_range(0.9, 1.1);
    
    _num.image_xscale = _start_scale;
    _num.image_yscale = _start_scale;
    _num.target_scale = _target_scale;
    
    // ★ 随机旋转角度
    _num.text_rotation = random_range(-30, 30);
}