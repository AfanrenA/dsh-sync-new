// ============================================================
// obj_collision_base - Create 事件
// 所有碰撞物体的父对象，声明碰撞相关变量
// ============================================================

// ---- 碰撞基本属性（子类覆盖） ----
collision_mask = COLLISION_LAYER.NONE;
collision_width = 16;
collision_height = 16;
collision_offset_x = 0;
collision_offset_y = 0;

// ---- 碰撞响应类型 ----
collision_response = "block";  // block / damage / trigger / ignore

// ---- 碰撞组件（子类创建） ----
collision_comp = noone;

// ---- 碰撞伤害参数（damage 类型使用） ----
collision_damage_base = 5;
collision_knockback_power = 12;
collision_damage_cooldown_max = 30;
collision_damage_cooldown = 0;