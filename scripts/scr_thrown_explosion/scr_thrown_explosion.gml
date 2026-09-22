function do_explosion() {
    // ★ 统一调用爆炸函数 ★
    scr_area_damage(
        x, y,                    // 爆炸位置
        explosion_radius,        // 爆炸半径
        explosion_damage,        // 伤害值
        owner,                   // 伤害来源
        true,                    // 伤害玩家
        true                     // 伤害敌人
    );
    
    // ---- 预警圈消失 ----
    if (warning != noone) instance_destroy(warning);
    
    // ---- 爆炸特效 ----
    instance_create_layer(x, y, "Effects", obj_explosion_effect);
    
    // ---- 销毁自己 ----
    instance_destroy();
}