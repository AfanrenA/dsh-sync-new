/// @description 触发受击特效
/// @param {real} _x 特效位置 X
/// @param {real} _y 特效位置 Y
/// @param {string} _effect_type 特效类型
function scr_hit_effect_trigger(_x, _y, _effect_type) {
    if (!variable_global_exists("psystem")) return;
    
   switch (_effect_type) {
    case "shield_hit":
        part_particles_create(global.psystem, _x, _y, global.pt_shield_hit, 5);
        break;
	case "shield_break":
        part_particles_create(global.psystem, _x, _y, global.pt_shield_break, 10);   // 碎片
        part_particles_create(global.psystem, _x, _y, global.pt_shield_flash, 1);    // 闪光
        break;
    case "player_hit":
        part_particles_create(global.psystem, _x, _y, global.pt_player_hit, 8);
        break;
    case "enemy_hit":
        part_particles_create(global.psystem, _x, _y, global.pt_enemy_hit, 8);
        break;
	case "critical":
        part_particles_create(global.psystem, _x, _y, global.pt_critical, 15);        // 火花
        part_particles_create(global.psystem, _x, _y, global.pt_critical_glow, 2);    // 光晕
        break;
}
}