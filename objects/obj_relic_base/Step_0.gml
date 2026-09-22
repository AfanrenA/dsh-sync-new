event_inherited();      // ★ 父对象：漂浮 + 光晕

// ===== 遗物冷却递减 =====
// ★ 冷却绑定"实例"，不绑定槽位：装在槽里、躺在地上、待在背包里都照样走表。
//   这样"换下 → 等一会儿 → 再装上"不能刷新冷却（成熟商用游戏的做法）。
//   递减放在实例自己的 Step 里，天然覆盖上述所有状态，且不会重复递减。
if (cooldown_timer > 0) {
    cooldown_timer -= 1;
}

// ===== 生效计时（active_timer）=====
// ★ 绝对不要在这里递减 active_timer！
//   生效倒计时的唯一责任方是 obj_player_base/Step_0：
//       if (relic_slot.is_active) { active_timer--; if (<=0) scr_relic_deactivate(...) }
//   关键差别：那里到期会调用 scr_relic_deactivate **还原所有倍率 + 外观**。
//   曾经在这里也减过一次 → 这里先把 is_active 置 false，player 那段就再也不进，
//   scr_relic_deactivate 永不执行 → 蟹化倍率永久残留（"持续时间远远超过设定"）。
//   教训：一个状态只允许一个地方负责推进 + 收尾。