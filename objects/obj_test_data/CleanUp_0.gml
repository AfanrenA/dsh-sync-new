// ===== obj_test_room Clean Up 事件 =====
if (variable_global_exists("psystem")) {
    part_system_destroy(global.psystem);
    part_type_destroy(global.pt_shield_hit);
    part_type_destroy(global.pt_shield_break);
    part_type_destroy(global.pt_player_hit);
    part_type_destroy(global.pt_enemy_hit);
    part_type_destroy(global.pt_critical);
	part_type_destroy(global.pt_shield_flash);   // 新增
	part_type_destroy(global.pt_death_player);
part_type_destroy(global.pt_death_enemy);
}