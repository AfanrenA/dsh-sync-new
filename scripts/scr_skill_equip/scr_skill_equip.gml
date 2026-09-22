/// @description 装备武技到槽（交换：旧武技放回背包）
/// @param {id} player 玩家实例
/// @param {id} skill_inst 武技实例
function scr_skill_equip(player, skill_inst) {
    if (!instance_exists(player)) return;
    if (!instance_exists(skill_inst)) return;
    
    // ★ 先从背包移除新武技（腾格子）
    scr_inventory_remove(player, skill_inst);
    
    // 旧武技放回背包
    if (instance_exists(player.skill_instance)) {
        var _old_is_attachment = variable_instance_exists(player.skill_instance, "type") 
                                 && player.skill_instance.type == "附件";
        if (_old_is_attachment) {
            player.skill_instance.ammo_current = 0;
            
            if (variable_instance_exists(player, "aim_indicator_ref") && instance_exists(player.aim_indicator_ref)) {
                instance_destroy(player.aim_indicator_ref);
                player.aim_indicator_ref = noone;
            }
        }
        
        // ★ 背包满 → 中止，把新武技放回去
        if (array_length(player.inventory) >= player.inventory_size) {
            scr_show_hint(player, "背包已满");
            scr_inventory_add(player, skill_inst);   // 新武技放回去
            return;
        }
        
        scr_inventory_add(player, player.skill_instance);
        player.skill_instance.visible = false;
    }
    
    // 装备
    player.skill_slot = skill_inst.skill_id;
    player.skill_instance = skill_inst;
    
    if (instance_exists(skill_inst)) {
        var _is_attachment = variable_instance_exists(skill_inst, "type") && skill_inst.type == "附件";
        if (_is_attachment) {
            // ★ 附件：cooldown_timer 语义 = "装填进度"。装填进度同样绑定实例，不重置，
            //   否则换下再装上等于白送一次满弹。只有"弹没满且当前没在装填"时才起装填。
            //   ammo_max 在 entity_data 上（实例上只有 ammo_current），故从 data 读。
            var _ammo_max = variable_instance_exists(skill_inst, "ammo_max") ? skill_inst.ammo_max : skill_inst.data.ammo_max;
            if (skill_inst.cooldown_timer <= 0 && skill_inst.ammo_current < _ammo_max) {
                skill_inst.cooldown_timer = skill_inst.data.base_cooldown * 60;
            }

            // ★ 瞄准指示器是"装备态"资源，被销毁过就要重建（换下时会销毁）
            if (!variable_instance_exists(player, "aim_indicator_ref") || !instance_exists(player.aim_indicator_ref)) {
                var _indicator = instance_create_layer(0, 0, "Instances", obj_aim_indicator);
                player.aim_indicator_ref = _indicator;
            }
        }
        // ★ 普通武技：冷却不重置，继承实例上的剩余冷却
    }
    
    skill_inst.visible = false;
    
    show_debug_message("[装备] 武技 " + string(skill_inst.skill_id));
}