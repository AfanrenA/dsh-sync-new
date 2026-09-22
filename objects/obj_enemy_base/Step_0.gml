// ============================================================
// obj_enemy_base - Step 事件
// ============================================================

// 1. 继承父对象
event_inherited();

// 2. 决策
ai_decision_timer -= 1;
if (ai_decision_timer <= 0) {
    ai_decision_timer = ai_decision_interval;
    if (enemy_data != undefined && enemy_data.ai_script != undefined) {
        // ★ 修复：用 asset_get_index 获取脚本索引
        var _script = asset_get_index(enemy_data.ai_script);
        if (_script != -1) {
            script_execute(_script, id);
        }
    }
}
show_debug_message("📊 当前 AI 状态: " + string(ai_state));
// 3. 执行
scr_ai_execute_behavior(id);

// 4. 碰撞修正
scr_character_resolve_collision(id);

// 5. 武器跟随
if (instance_exists(current_weapon)) {
    current_weapon.x = x;
    current_weapon.y = y;
    current_weapon.image_xscale = image_xscale;
	current_weapon.depth = depth - 1;  // ★ 武器在敌人上方一层
}