// scr_slash_scale.gml
// 剑气缩放动画 - 纯函数
// ★ 按"飞行进度"缩放，而不是按固定帧数：飞得越远越大

function scr_slash_scale(slash_inst) {
    // 飞行进度 0~1
    var _progress = 0;
    if (slash_inst.max_distance > 0) {
        _progress = clamp(slash_inst.traveled_distance / slash_inst.max_distance, 0, 1);
    }
    
    // 从 scale_start 长到 scale_end
    var _s = slash_inst.scale_start + (slash_inst.scale_end - slash_inst.scale_start) * _progress;
    slash_inst.image_xscale = _s;
    slash_inst.image_yscale = _s;
}