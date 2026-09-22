// ======================================================================
// scr_projectile_scale.gml
// 剑气缩放动画模块
// 组合到需要缩放效果的飞行物上
// ======================================================================

/// @description 初始化缩放模块
/// @param {instance} _proj 飞行物实例
/// @param {real} _start 初始缩放
/// @param {real} _end 最终缩放
function scr_projectile_scale_start(_proj, _start, _end) {
    _proj.scale_start = _start;
    _proj.scale_end = _end;
    _proj._scale_progress = 0;
    _proj.scale_module = true;  // 标记已挂载
}

/// @description 更新缩放（由父对象 Step 调用）
/// @param {instance} _proj 飞行物实例
function scr_projectile_scale_update(_proj) {
    if (_proj.scale_start == undefined) return;
    
    _proj._scale_progress = 1 - (_proj.life / _proj.max_life);
    var _scale = lerp(_proj.scale_start, _proj.scale_end, _proj._scale_progress);
    _proj.image_xscale = _scale;
    _proj.image_yscale = _scale;
}