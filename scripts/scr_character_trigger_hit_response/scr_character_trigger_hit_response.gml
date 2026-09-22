// ============================================================
// scr_character_trigger_hit_response
// 触发角色的受击反馈（闪白 + 硬直 + 特效接口）
// 用法：scr_character_trigger_hit_response(inst, hit_direction)
//
// V3 原则检查：
// - 单一职责 ✅ 只做"触发受击反馈"这一件事
// - 模块化 ✅ 独立脚本，可被任何角色调用
// - 可复用 ✅ 玩家和敌人共用
// - 父对象轻薄 ✅ 基类只调用接口，不写死实现
// ============================================================

function scr_character_trigger_hit_response(inst, hit_direction = 0) {
    /// @param inst           角色实例
    /// @param hit_direction  受击方向（用于击退方向，默认0）
    show_debug_message("受击反馈触发！实例: " + string(inst));
    // ========== 安全检查 ==========
    if (!instance_exists(inst)) exit;
    if (inst.hp <= 0) exit;  // 已死亡不受击
    
    // ========== 1. 闪白效果 ==========
    inst.hit_flash_timer = 30;  // 6帧 ≈ 0.1秒
    
    // ========== 2. 硬直效果 ==========
    inst.hit_stun_timer = 20;   // 8帧 ≈ 0.13秒
    inst.is_in_hit_stun = true;
    
    // ========== 3. 受击动画（如果角色有定义受击精灵） ==========
    if (variable_instance_exists(inst, "sprite_hit")) {
        var hit_sprite = inst.sprite_hit;
        if (hit_sprite != -1 && hit_sprite != undefined) {
            inst.sprite_index = hit_sprite;
            inst.image_index = 0;
        }
    }
    
    // ========== 4. 触发受击特效（调用独立接口） ==========
    // 基类只负责调用接口，不关心具体实现
    if (script_exists(scr_character_spawn_hit_effect)) {
        scr_character_spawn_hit_effect(inst, hit_direction);
    }
        // ===== 调试：确认变量被设置 =====
    show_debug_message("闪白计时器: " + string(inst.hit_flash_timer) + 
                       " 硬直计时器: " + string(inst.hit_stun_timer));

    // ========== 5. 受击音效（占位） ==========
    // 后续接入音效系统
    
    // ========== 6. 通知 UI 系统（预留，待 UI 系统实现后启用） ==========
    // 玩家受击时，UI 层需要知道以触发屏幕闪红
    // 目前 UI 系统尚未实现，暂时注释掉
    /*
    if (inst.object_index == obj_player_base || inst.object_index == obj_player) {
        if (script_exists(scr_ui_on_player_hit)) {
            scr_ui_on_player_hit(inst);
        }
    }
    */
}