/// @description 发射后坐力位移（锁定移动期间用）
/// @param {id} player 玩家实例
function scr_fire_recoil_execute(player) {
    if (!instance_exists(player)) return;
    if (player.fire_recoil_timer <= 0) return;
    
    player.fire_recoil_timer--;
    
    var _new_x = player.x + player.fire_recoil_vx;
    var _new_y = player.y + player.fire_recoil_vy;
    
    if (!place_meeting(_new_x, player.y, obj_wall_base)) player.x = _new_x;
    if (!place_meeting(player.x, _new_y, obj_wall_base)) player.y = _new_y;
    
    if (player.fire_recoil_timer <= 0) {
        player.fire_recoil_vx = 0;
        player.fire_recoil_vy = 0;
    }
}