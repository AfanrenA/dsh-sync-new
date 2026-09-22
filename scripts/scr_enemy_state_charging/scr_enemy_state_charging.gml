/// @function scr_enemy_state_charging(enemy)
/// @param {id} enemy - 敌人实例
/// @description 纯执行：蓄力行为（预判瞄准 + 更新预警 + 蓄力进度）

function scr_enemy_state_charging(enemy) {
    var p = enemy._perception;
    if (!p.has_target) {
        return;
    }
    
    // ===== ★ 受击打断蓄力 =====
    if (enemy._was_interrupted) {
        // 清除预警
        if (instance_exists(enemy._telegraph_ref)) {
            instance_destroy(enemy._telegraph_ref);
            enemy._telegraph_ref = noone;
        }
        // 切换回 attack 状态（会触发普攻反击）
        enemy.ai_state = "attack";
        enemy._attack_timer = 10;  // 快速反击
        enemy._was_interrupted = false;
        show_debug_message("[AI] 蓄力被打断，反击");
        return;
    }
    
    // ===== 从数据表读取配置 =====
    var _ai = enemy.entity_data.ai;
    var _attack_range = _ai.attack_range != undefined ? _ai.attack_range : 300;
    
    // ===== 面向目标 =====
    enemy.facing_dir = sign(cos(degtorad(p.dir_to_target)));
    enemy.image_xscale = enemy.facing_dir;
    
    // ===== ★ 预判目标位置 =====
    var _player = p.target;
    var _prediction_frames = 20;
    var _player_speed = point_distance(0, 0, _player.hspeed, _player.vspeed);
    var _pred_dist = _player_speed * _prediction_frames / 60;
    
    var _pred_x = _player.x;
    var _pred_y = _player.y;
    if (_player_speed > 0.5) {
        var _player_dir = point_direction(0, 0, _player.hspeed, _player.vspeed);
        _pred_x = _player.x + lengthdir_x(_pred_dist, _player_dir);
        _pred_y = _player.y + lengthdir_y(_pred_dist, _player_dir);
    }
    
    var _aim_dir = point_direction(enemy.x, enemy.y, _pred_x, _pred_y);
    
    // ===== ★ 包抄偏移 =====
    if (p.dist > _attack_range * 0.8 && p.dist < _attack_range * 3) {
        enemy._flank_timer -= 1;
        if (enemy._flank_timer <= 0) {
            enemy._flank_side = irandom(1) * 2 - 1;
            enemy._flank_timer = 180 + irandom(120);
        }
        var _flank_angle = 15 + (1 - p.dist / (_attack_range * 3)) * 20;
        _aim_dir += _flank_angle * enemy._flank_side;
    }
    
    // ===== ★ 武器指向预判方向 =====
    if (instance_exists(enemy.current_weapon)) {
        enemy.current_weapon.image_angle = _aim_dir;
    }
    
    // ===== 蓄力时站定不动 =====
    // ★ 原「缓慢移动」逻辑已移除：敌人边蓄力边前进/后退会让预警线起点持续漂移，
    //   玩家看到的预警线终点和剑气实际落点对不上（差 10~20%）。
    //   蓄力技能的定位是"给玩家反应时间"，站定才有预警意义。
    
    // ===== ★ 蓄力进度 =====
    enemy._charge_timer += 1/60;
    var _progress = 0;
    if (enemy.skill_charge_target > 0) {
        _progress = enemy._charge_timer / enemy.skill_charge_target;
        _progress = clamp(_progress, 0, 1);
    }
    
    // ===== ★ 更新预警线（用统一距离计算） =====
    var _final_distance = scr_skill_get_final_distance(enemy, enemy.enemy_skill_id, enemy._charge_timer);
    
    if (instance_exists(enemy._telegraph_ref)) {
        enemy._telegraph_ref.dir = _aim_dir;
        enemy._telegraph_ref.range = _final_distance;
    } else {
        scr_enemy_show_telegraph(enemy, _aim_dir, _final_distance, 999);
    }
    
    // ===== 蓄力完成 → 释放技能 =====
    if (enemy._charge_timer >= enemy.skill_charge_target) {
        if (instance_exists(enemy._telegraph_ref)) {
            instance_destroy(enemy._telegraph_ref);
            enemy._telegraph_ref = noone;
        }
        
        scr_skill_cast(enemy, enemy.enemy_skill_id, enemy._charge_timer);
        enemy.enemy_skill_cooldown = enemy.enemy_skill_max_cooldown;
        enemy._attack_timer = 30;
        
        // ★ 重置蓄力变量
        enemy._charge_timer = 0;
        enemy.skill_charge_target = 0;
        
        // ★ 切回 attack 状态
        enemy.ai_state = "attack";
        
        show_debug_message("[AI] 蓄力完成，释放技能，回到攻击状态");
    }
}