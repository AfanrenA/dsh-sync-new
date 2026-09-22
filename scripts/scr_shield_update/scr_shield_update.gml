// scr_shield_update.gml
function scr_shield_update(player_inst) {
    // ===== 1. 护盾恢复（满血才能恢复） =====
    if (player_inst.hp >= player_inst.max_hp) {
        if (player_inst.shield_regen_timer > 0) {
            player_inst.shield_regen_timer -= 1;
        } else {
            if (player_inst.shield < player_inst.max_shield) {
                // 触发充电特效
                if (!player_inst.shield_charge_effect) {
                    player_inst.shield_charge_effect = true;
                    player_inst.shield_charge_progress = 0;
                }
                
                player_inst.shield += player_inst.shield_regen_rate / 60;
                if (player_inst.shield > player_inst.max_shield) {
                    player_inst.shield = player_inst.max_shield;
                }
                
                player_inst.shield_charge_progress = player_inst.shield / player_inst.max_shield;
            }
        }
    }
    
    // ===== 2. 充满特效 =====
    var _is_full = (player_inst.shield >= player_inst.max_shield && player_inst.max_shield > 0);
    if (_is_full && !player_inst.shield_was_full) {
        // 护盾刚满 → 触发展示计时器（3秒）
        player_inst.shield_full_show_timer = 180;  // 180帧 = 3秒
        player_inst.shield_full_show_alpha = 1;
        player_inst.shield_full_flash = 15;
        show_debug_message("[SHIELD] 护盾充满！展示");
    }
    player_inst.shield_was_full = _is_full;
    
    // ===== 3. 护盾满展示计时器递减 =====
    if (player_inst.shield_full_show_timer > 0) {
        player_inst.shield_full_show_timer -= 1;
        if (player_inst.shield_full_show_timer == 0) {
            // 计时结束，开始淡出
            player_inst.shield_full_show_alpha = 0;
            show_debug_message("[SHIELD] 护盾展示结束");
        }
    }
    
    // ===== 4. 如果护盾受伤，立即隐藏展示 =====
    if (player_inst.shield < player_inst.max_shield && player_inst.shield_full_show_timer > 0) {
        player_inst.shield_full_show_timer = 0;
        player_inst.shield_full_show_alpha = 0;
        show_debug_message("[SHIELD] 护盾受伤，展示取消");
    }
    
    // ===== 5. 闪烁计时器 =====
    if (player_inst.shield_full_flash > 0) {
        player_inst.shield_full_flash -= 1;
    }
    
    // ===== 6. 护盾满后关闭充电特效 =====
    if (player_inst.shield >= player_inst.max_shield) {
        player_inst.shield_charge_effect = false;
        player_inst.shield_charge_progress = 1;
    }
}