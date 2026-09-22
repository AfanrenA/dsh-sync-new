/// obj_weapon_glow Step 事件

// ===== 如果武器不存在，销毁光晕 =====
if (!instance_exists(parent_weapon)) {
    instance_destroy();
    exit;
}

// ===== 跟随武器位置 =====
x = parent_weapon.x;
y = parent_weapon.y;
image_xscale = parent_weapon.image_xscale;
image_yscale = parent_weapon.image_yscale;

// ★ 跟随武器的可见状态
visible = parent_weapon.visible;