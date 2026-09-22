/// @description 发射后坐力位移（锁定移动期间用）
/// @param {id} player 玩家实例
function scr_fire_recoil_execute(player) {
    if (!instance_exists(player)) return;
    if (player.fire_recoil_timer <= 0) return;
    
    player.fire_recoil_timer--;
    
    var _new_x = player.x + player.fire_recoil_vx;
    var _new_y = player.y + player.fire_recoil_vy;
    
    var _before_x = player.x;
    var _before_y = player.y;
    
    if (!place_meeting(_new_x, player.y, obj_wall_base)) player.x = _new_x;
    if (!place_meeting(player.x, _new_y, obj_wall_base)) player.y = _new_y;
    
    // ★ 后坐力算"被迫位移" → 动能回收器回收电量（区别于身法闪避，闪避不算）
    //   ★ event_id 由 scr_attachment_fire 在**开始后坐力时**自增，
    //     同一次后坐力 25 帧共用一份回收额度。
    //     否则逐帧各算一次，会把 max_hp_per_event 上限绕过 25 倍（5 血变 125 血）。
    var _moved = point_distance(_before_x, _before_y, player.x, player.y);
    if (_moved > 0) {
        var _eid = variable_instance_exists(player, "_recoil_event_id") ? player._recoil_event_id : 0;
        scr_relic_passive_kinetic_on_shift(player, _moved, "recoil", _eid);
    }
    
    if (player.fire_recoil_timer <= 0) {
        player.fire_recoil_vx = 0;
        player.fire_recoil_vy = 0;
    }
}