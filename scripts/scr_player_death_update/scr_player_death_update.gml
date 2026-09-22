// scr_player_death_update.gml
// 玩家死亡更新 - 只做淡出动画（粒子在 scr_player_death 中处理）

function scr_player_death_update(player_inst) {
    player_inst.death_timer += 1 / 60;
    
    var _total_duration = 1.5;
    var _progress = player_inst.death_timer / _total_duration;
    
    // ===== 阶段1：爆炸闪光（0 - 0.1） =====
    if (_progress < 0.1) {
        player_inst.image_blend = c_white;
        player_inst.image_alpha = 1;
    }
    
    // ===== 阶段2：消散（0.1 - 1.0） =====
    else if (_progress < 1.0) {
        var _fade_progress = (_progress - 0.1) / 0.9;
        var _alpha = 1 - _fade_progress;
        player_inst.image_alpha = _alpha;
        player_inst.image_blend = c_white;
        
        // 位置微微上浮
        player_inst.y -= 0.5;
    }
    
    // ===== 阶段3：完全消失 + 黑屏（1.0） =====
    else {
        player_inst.image_alpha = 0;
        player_inst.image_blend = c_white;
        
        if (instance_exists(obj_game_controller)) {
            obj_game_controller.black_screen_alpha = 1;
            obj_game_controller.show_revive_hint = true;
            obj_game_controller.revive_text = "数据消散！点击鼠标或按任意键重组";
        }
        
        // 检测输入复活
        if (keyboard_check_pressed(vk_anykey) || mouse_check_button_pressed(mb_left)) {
            scr_player_revive(player_inst);
        }
    }
}