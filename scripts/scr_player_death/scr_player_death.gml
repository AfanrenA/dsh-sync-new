// scr_player_death.gml
function scr_player_death(player_inst) {
    if (player_inst.is_dead) return;
    
    player_inst.is_dead = true;
    player_inst.is_alive = false;
    player_inst.is_player = true;
    player_inst.death_timer = 0;
    player_inst.death_fade_progress = 0;
    
    player_inst.is_hit_flashing = false;
    player_inst.hit_flash_timer = 0;
    
    var _halo = instance_create_depth(player_inst.x, player_inst.y - 30, -99998, obj_death_halo);
    _halo.halo_color = make_color_rgb(200, 240, 255);
    _halo.target_ref = player_inst;
    part_particles_create(global.psystem, player_inst.x, player_inst.y, global.pt_death_player, 80);
    
    // ============================================================
    // 掉落当前武器
    // ============================================================
    if (player_inst.current_weapon != noone) {
        var _weapon = player_inst.current_weapon;
        _weapon.is_on_ground = true;
        _weapon.owner_id = noone;
        _weapon.x = player_inst.x + random_range(-20, 20);
        _weapon.y = player_inst.y + random_range(-20, 20);
        
        if (variable_instance_exists(_weapon, "_bob_timer")) {
            _weapon._bob_timer = 0;
            _weapon._start_y = _weapon.y;
        }
        
        if (_weapon.rarity != undefined && _weapon.rarity != "") {
            scr_glow_attach(_weapon);
        }
        
        // ★ 清空武器槽（新结构）
        player_inst.weapon_slots[player_inst.active_weapon_slot] = noone;
        player_inst.current_weapon = noone;
    }
    
    show_debug_message("[DEATH] 玩家死亡，武器已掉落");
}