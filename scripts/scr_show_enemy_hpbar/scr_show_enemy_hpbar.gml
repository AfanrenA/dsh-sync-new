/// @description 敌人受击时显示血条
/// @param {id} target_inst 受伤者

function scr_show_enemy_hpbar(target_inst) {
    if (target_inst.character_type == "enemy") {
        if (variable_struct_exists(target_inst, "hpbar_timer")) {
            target_inst.hpbar_timer = 600;   // 3 秒
            target_inst.hpbar_visible = true;
        }
    }
}