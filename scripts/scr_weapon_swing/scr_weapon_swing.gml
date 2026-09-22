// scr_weapon_swing.gml
function scr_weapon_swing(weapon_inst, swing_timer, facing_left) {
    if (swing_timer <= 0) return 0;
    
    var _data = weapon_inst.entity_data;
    if (_data == undefined) return 0;
    
    // ===== 获取角度参数 =====
    var _up_angle = _data.swing_up_angle != undefined ? _data.swing_up_angle : -60;
    var _down_angle = _data.swing_down_angle != undefined ? _data.swing_down_angle : 60;
    var _up_frames = _data.swing_up_frames != undefined ? _data.swing_up_frames : 15;
    var _down_frames = _data.swing_down_frames != undefined ? _data.swing_down_frames : 10;
    var _total_frames = _up_frames + _down_frames;
    
    // ===== 当前已过去帧数 =====
    var _elapsed = _total_frames - swing_timer;
    
    var _swing_angle = 0;
    
    if (_elapsed < _up_frames) {
        // ===== 上挑阶段：从 0 到 _up_angle（线性） =====
        var _p = _elapsed / _up_frames;
        _swing_angle = _up_angle * _p;
    } else {
        // ===== 下劈阶段：从 _up_angle 到 _down_angle（线性） =====
        var _p = (_elapsed - _up_frames) / _down_frames;
        _swing_angle = _up_angle + (_down_angle - _up_angle) * _p;
    }
    
    // ===== 朝左镜像 =====
    if (facing_left) {
        _swing_angle = -_swing_angle;
    }
    
    return _swing_angle;
}