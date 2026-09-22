// data_agility.gml
// 身法数据表
// 字段说明：
//   slot             —— 插槽类型，固定 "agility"
//   display_name     —— 显示名
//   cooldown         —— 冷却帧数
//   distance         —— 位移距离（像素）
//   invincible_frames—— 完成后无敌帧数
//   direction_mode   —— 方向模式："away"=远离鼠标，"toward"=朝向鼠标
//   vfx_type         —— 视觉类型
//   speed_mult       —— 移速倍率（横冲直撞用）
//   duration         —— 持续帧数（横冲直撞用）

function data_agility_get(_id) {
    var _db = {
        "dash": {
            slot: "agility",
            display_name: "闪避",
			object: obj_agility_dash,
            cooldown: 90,
            distance: 400,
            invincible_frames: 12,
            direction_mode: "mouse",
            vfx_type: "afterimage",
			description: "闪身步！",
			// ★ 品质倍率（common → divine，7 档）
            quality_distance_mult:   [1.0, 1.1, 1.25, 1.4, 1.6, 1.85, 2.2],
            quality_cooldown_mult:   [1.0, 0.95, 0.9, 0.85, 0.8, 0.7, 0.6],
            quality_ghost_density:   [50, 45, 40, 35, 30, 25, 18],   // ★ 残影间隔（像素），越小越密
        },
        "charge": {
            slot: "agility",
            display_name: "横冲直撞",
            cooldown: 600,
            duration: 600,
            speed_mult: 2.0,
            invincible_frames: 0,
            direction_mode: "mouse",
            vfx_type: "arrow_indicator"
        }
    };
    
    if (variable_struct_exists(_db, _id)) return _db[$ _id];
    return undefined;
}