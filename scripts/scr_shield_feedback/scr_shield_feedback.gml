/// @description 护盾受击反馈 - 只做闪光，不做击退
/// @param {id} target_inst 受击者
/// @param {real} hit_dir 受击方向
function scr_shield_feedback(target_inst, hit_dir) {
    if (!instance_exists(target_inst)) return;
    
    // 护盾闪光（由角色父对象的 Draw 事件读取）
    target_inst.is_shield_flashing = true;
    target_inst.shield_flash_timer = 6;
    
    // ★ 击退已删除（护盾受击不击退，符合商业游戏惯例）
    
    show_debug_message("[SHIELD] 护盾受击反馈");
}