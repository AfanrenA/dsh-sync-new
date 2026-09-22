// scr_character_move.gml
// 角色移动行为 - 纯函数，不依赖对象
// 调用方式：scr_character_move_execute(character_inst)

/// @function scr_character_move_execute(character_inst)
/// @param {id} character_inst 角色实例
/// @description 根据 move_dir_x/move_dir_y 和 move_speed 移动角色
///              ★ 支持遗物倍率：直线 / 斜向 分别倍率
function scr_character_move_execute(character_inst) {
    // 如果角色死亡或硬直，不移动
    if (!character_inst.is_alive || character_inst.is_stunned) {
        return;
    }

    // ===== 遗物倍率兜底（老对象可能没这变量）=====
    var _line_mult = 1.0;
    var _diag_mult = 1.0;
    if (variable_instance_exists(character_inst, "relic_move_mult")) {
        _line_mult = character_inst.relic_move_mult;
    }
    if (variable_instance_exists(character_inst, "relic_move_diag_mult")) {
        _diag_mult = character_inst.relic_move_diag_mult;
    }

    // 归一化移动方向，防止斜向移动速度翻倍
    var dir_len = point_distance(0, 0, character_inst.move_dir_x, character_inst.move_dir_y);
    if (dir_len > 0) {
        var norm_x = character_inst.move_dir_x / dir_len;
        var norm_y = character_inst.move_dir_y / dir_len;

        // ★ 直线 / 斜向 判定：move_dir 只有 -1/0/1，斜向时 dir_len ≈ 1.414
        //   阈值 1.1 安全：单键=1.0，斜向=1.414，无输入=0
        var _mult = _line_mult;
        if (dir_len > 1.1) {
            _mult = _diag_mult;
        }

        character_inst.x += norm_x * character_inst.move_speed * _mult;
        character_inst.y += norm_y * character_inst.move_speed * _mult;
    }
}