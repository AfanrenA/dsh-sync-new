/// @function scr_enemy_ai_update(enemy)
/// @param {id} enemy 敌人实例
/// @description AI调度器：感知更新 → 状态切换 → 行为执行

function scr_enemy_ai_update(enemy) {
    // ===== 死亡检查 =====
    if (!enemy.is_alive || enemy.is_dead) return;
    if (enemy.is_stunned) return;
    
    // ===== 0. 受击强制索敌计时器递减 =====
    if (enemy._aggro_timer > 0) {
        enemy._aggro_timer -= 1;
        if (enemy._aggro_timer <= 0) {
            enemy._aggro_target = noone;
        }
    }
    
    // ===== 1. 更新感知数据 =====
    scr_enemy_perception_update(enemy);
    
    // ===== 2. 状态切换（决策中心） =====
    scr_enemy_ai_transition(enemy);
    
    // ===== 3. 执行状态行为 =====
    switch (enemy.ai_state) {
        case "patrol":
            scr_enemy_state_patrol(enemy);
            break;
        case "chase":
            scr_enemy_state_chase(enemy);
            break;
        case "attack":
            scr_enemy_state_attack(enemy);
            break;
        case "charging":
            scr_enemy_state_charging(enemy);
            break;
        default:
            enemy.ai_state = "patrol";
            show_debug_message("[AI] " + object_get_name(enemy.object_index) + " 未知状态，回到巡逻");
            break;
    }
}