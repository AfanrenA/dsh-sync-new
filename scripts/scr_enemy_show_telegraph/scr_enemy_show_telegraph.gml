/// @function scr_enemy_show_telegraph(enemy, dir, range, duration)
/// @param {id} enemy - 敌人实例
/// @param {real} dir - 方向角度
/// @param {real} range - 技能范围
/// @param {real} duration - 持续帧数（默认999）

function scr_enemy_show_telegraph(enemy, dir, range, duration) {
    var _duration = 999;
    if (duration != undefined) _duration = duration;
    
    // 如果已有预警，直接更新
    if (instance_exists(enemy._telegraph_ref)) {
        enemy._telegraph_ref.dir = dir;
        enemy._telegraph_ref.range = range;
        enemy._telegraph_ref.timer = 0;
        return;
    }
    
    var _telegraph = instance_create_layer(enemy.x, enemy.y, "Instances", obj_telegraph);
    _telegraph.follow_target = enemy;
    _telegraph.dir = dir;
    _telegraph.range = range;
    _telegraph.lifetime = _duration;
    _telegraph.timer = 0;
    
    enemy._telegraph_ref = _telegraph;
}