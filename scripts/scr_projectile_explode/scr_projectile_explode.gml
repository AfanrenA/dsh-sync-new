// ============================================================
// scr_projectile_explode.gml
// 爆炸模块 - 组合到炸弹等爆炸型飞行物上
// ============================================================

/// @description 初始化爆炸模块
/// @param {instance} _proj 飞行物实例
/// @param {real} _radius 爆炸半径
/// @param {real} _damage 爆炸伤害
function scr_projectile_explode_start(_proj, _radius, _damage) {
    _proj.explosion_radius = _radius || 80;
    _proj.explosion_damage = _damage || 20;
    _proj.is_explosive = true;
}

/// @description 执行爆炸
/// @param {instance} _proj 飞行物实例
function scr_projectile_explode(_proj) {
    // ★ 使用统一范围伤害函数 ★
    scr_area_damage(
        _proj.x, _proj.y,                           // 爆炸位置
        _proj.explosion_radius,                     // 爆炸半径
        _proj.explosion_damage,                     // 伤害值
        _proj.owner,                                // 伤害来源
        true,                                       // 伤害玩家
        true                                        // 伤害敌人
    );
    
    // 爆炸特效
    scr_spawn_spark(_proj.x, _proj.y, c_orange, 20);
    scr_spawn_spark(_proj.x, _proj.y, c_red, 15);
    scr_spawn_spark(_proj.x, _proj.y, c_yellow, 10);
}