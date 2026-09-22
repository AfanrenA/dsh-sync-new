function scr_weapon_cooldown_update(weapon) {
    if (weapon.cooldown_timer > 0) {
        weapon.cooldown_timer -= 1;
        if (weapon.cooldown_timer <= 0) {
            // ★ 只在"被装备"时触发虚影，地上不触发
            if (!weapon.is_on_ground && instance_exists(weapon.owner_id)) {
                // ★ 远程武器不闪 CD 就绪（枪的 CD 是射速间隔，不是技能就绪）
                //    远程的闪光改在"换弹完成"时触发
                var _is_ranged = variable_instance_exists(weapon, "max_ammo");
                if (!_is_ranged) {
                    weapon.flash_ready_timer = 30;
                }
            }
        }
    }
}