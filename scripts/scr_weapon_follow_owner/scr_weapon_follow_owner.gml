// scr_weapon_follow_owner.gml
function scr_weapon_follow_owner(weapon) {
    if (!instance_exists(weapon.owner_id)) return;
    
    weapon.x = weapon.owner_id.x;
    weapon.y = weapon.owner_id.y;
    
    // 武器显示在持有者前面
    weapon.depth = weapon.owner_id.depth - 1;
}