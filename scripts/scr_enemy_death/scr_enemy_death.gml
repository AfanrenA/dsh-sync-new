// scr_enemy_death.gml
// 敌人死亡 - 掉落

function scr_enemy_death(enemy_inst, attacker_inst) {
    show_debug_message("[DEATH] ❗ 敌人死亡函数被调用: " + string(enemy_inst.character_id));
    if (enemy_inst.is_dead) return;
    
    enemy_inst.is_dead = true;
    enemy_inst.is_alive = false;
    enemy_inst.is_hit_flashing = false;
    enemy_inst.hit_flash_timer = 0;
    enemy_inst.mask_index = -1;
    enemy_inst.solid = false;
    // ★ 黑客帝国数据消散
	var _halo = instance_create_depth(enemy_inst.x, enemy_inst.y - 30, -99998, obj_death_halo);
    _halo.halo_color = make_color_rgb(255, 220, 150);   // 暖色（金橙）
    _halo.target_ref = enemy_inst;
    part_particles_create(global.psystem, enemy_inst.x, enemy_inst.y, global.pt_death_enemy, 80);
    // 清除蓄力
    enemy_inst._charge_timer = 0;
    enemy_inst.skill_charge_target = 0;
    
    // 清除预警
    if (instance_exists(enemy_inst._telegraph_ref)) {
        instance_destroy(enemy_inst._telegraph_ref);
        enemy_inst._telegraph_ref = noone;
    }
    // ★ 销毁头顶状态图标
    if (variable_instance_exists(enemy_inst, "_indicator_ref")) {
        if (instance_exists(enemy_inst._indicator_ref)) {
            instance_destroy(enemy_inst._indicator_ref);
        }
        enemy_inst._indicator_ref = noone;
    }
    // ============================================================
    // 掉落武器
    // ============================================================
    if (enemy_inst.current_weapon != noone) {
        var _weapon = enemy_inst.current_weapon;
        _weapon.is_on_ground = true;
        _weapon.owner_id = noone;
        _weapon.x = enemy_inst.x + random_range(-20, 20);
        _weapon.y = enemy_inst.y + random_range(-20, 20);
        _weapon.visible = true;
        _weapon.depth = 105;
        
        scr_glow_attach(_weapon);
        
        enemy_inst.current_weapon = noone;
        show_debug_message("[死亡] 掉落武器: " + _weapon.weapon_id);
    }
    
    // ============================================================
    // 掉落技能
    // ============================================================
    if (enemy_inst.enemy_skill_id != "" && enemy_inst.enemy_skill_id != undefined) {
        if (random(1) < 0.3) {
            var _skill_rarity = enemy_inst.enemy_skill_rarity != undefined ? enemy_inst.enemy_skill_rarity : "common";
            var _skill_inst = scr_factory_skill_create(
                enemy_inst.enemy_skill_id,
                _skill_rarity,
                enemy_inst.x + irandom_range(-20, 20),
                enemy_inst.y + irandom_range(-20, 20),
                noone
            );
            
            if (instance_exists(_skill_inst)) {
                _skill_inst.is_on_ground = true;
                _skill_inst.owner_id = noone;
                _skill_inst.visible = true;
                _skill_inst.depth = 105;
                
                scr_glow_attach(_skill_inst);
                
                show_debug_message("[死亡] 掉落技能: " + enemy_inst.enemy_skill_id);
            }
        }
    }
    // 记录击杀
var _player = instance_find(obj_player_base, 0);
if (instance_exists(_player)) {
    var _enemy_id = enemy_inst.character_id;
    if (!variable_struct_exists(_player.kill_records, _enemy_id)) {
        _player.kill_records[$ _enemy_id] = 0;
    }
    _player.kill_records[$ _enemy_id] += 1;
    _player.kill_total += 1;
}
    // ============================================================
    // 重置死亡计时器
    // ============================================================
    enemy_inst.death_timer = 0;
    
    show_debug_message("[DEATH] 敌人死亡: " + enemy_inst.character_id);
}