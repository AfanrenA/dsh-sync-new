/// @function scr_enemy_spawn_indicator(enemy, type)
/// @param {id} enemy - 敌人实例
/// @param {string} type - "exclamation" 或 "question" 或 "alert"

function scr_enemy_spawn_indicator(enemy, type) {
    // 如果已有指示器且类型相同，不重复创建
    if (instance_exists(enemy._indicator_ref)) {
        if (enemy._indicator_ref.indicator_type == type) {
            return;  // 已存在，不重复创建
        }
        // 类型不同，销毁旧的
        instance_destroy(enemy._indicator_ref);
        enemy._indicator_ref = noone;
    }
    
    var _indicator = instance_create_layer(enemy.x, enemy.y - 60, "Instances", obj_enemy_indicator);
    _indicator.follow_target = enemy;
    _indicator.indicator_type = type;
    
    // 感叹号：持续显示（lifetime = -1 表示永久）
    // 问号/警惕：闪烁后消失（2秒）
    if (type == "exclamation") {
        _indicator.lifetime = -1;  // 永久，由外部控制销毁
        _indicator.flash_count = 1;
    } else {
        _indicator.lifetime = 120;   // 2秒后消失
        _indicator.flash_count = 1;
    }
    
    enemy._indicator_ref = _indicator;
    enemy._indicator_timer = 120;
}