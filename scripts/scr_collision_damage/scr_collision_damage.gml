/// @function scr_collision_damage(player_inst)
function scr_collision_damage(player_inst) {
    var _sprite = player_inst.sprite_index;
    var _sprite_width = sprite_get_width(_sprite);
    var _sprite_height = sprite_get_height(_sprite);
    
    var _half_w = (_sprite_width / 2) * abs(player_inst.image_xscale) * 0.7;
    var _half_h = (_sprite_height / 2) * abs(player_inst.image_yscale) * 0.7;
    
    if (_half_w < 10) _half_w = 10;
    if (_half_h < 10) _half_h = 10;
    
    var _enemy = collision_rectangle(
        player_inst.x - _half_w, player_inst.y - _half_h,
        player_inst.x + _half_w, player_inst.y + _half_h,
        obj_enemy_base, false, true
    );
    
    if (_enemy != noone) {
        // ★ 敌人已死亡 → 跳过碰撞
        if (_enemy.is_dead || !_enemy.is_alive) return;
        
        // ★ 玩家冲撞无敌时 → 不触发碰撞（冲撞时无敌，不该被碰撞伤害）
        if (player_inst.is_invincible) return;
        
        var _collision_damage = 5;
        
        // 玩家受击
        var _player_data = player_inst.entity_data;
        var _p_knockback = (_player_data != undefined && _player_data.collision_knockback != undefined) ? _player_data.collision_knockback : 3.0;
        var _p_stun = (_player_data != undefined && _player_data.collision_stun != undefined) ? _player_data.collision_stun : 0.1;
        
        // 玩家撞敌人
var _pkt = scr_damage_packet_create(_collision_damage);
_pkt.ignore_crit = true;
_pkt.knockback = _p_knockback;
_pkt.stun = _p_stun;
scr_damage_apply(player_inst, _pkt, _enemy);
        
        // 敌人受击
        var _enemy_data = _enemy.entity_data;
        var _e_stun = (_enemy_data != undefined && _enemy_data.hit_stun_duration != undefined) ? _enemy_data.hit_stun_duration : 0.1;
        var _e_knockback = 5.0;
        
        // 敌人撞玩家
var _pkt2 = scr_damage_packet_create(_collision_damage);
_pkt2.ignore_crit = true;
_pkt2.knockback = _e_knockback;
_pkt2.stun = _e_stun;
scr_damage_apply(_enemy, _pkt2, player_inst);
        
        scr_show_enemy_hpbar(_enemy);
    }
}