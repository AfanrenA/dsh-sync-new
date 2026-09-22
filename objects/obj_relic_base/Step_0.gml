event_inherited();      // ★ 父对象：漂浮 + 光晕

// ===== 遗物冷却递减（装在槽里时）=====
if (!is_on_ground) {
    if (cooldown_timer > 0) {
        cooldown_timer -= 1;
    }
}