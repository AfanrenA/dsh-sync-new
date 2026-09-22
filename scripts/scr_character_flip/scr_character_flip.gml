// scr_character_flip.gml
function scr_character_flip(character, target_x) {
    // ===== 攻击期间不翻转 =====
    if (instance_exists(character.current_weapon) && character.current_weapon.is_swinging) {
        return;
    }
    
    // ===== 原有翻转逻辑 =====
    if (target_x < character.x) {
        character.facing_dir = -1;
        character.image_xscale = -abs(character.image_xscale);
    } else {
        character.facing_dir = 1;
        character.image_xscale = abs(character.image_xscale);
    }
}