/// @description 飞刀步进（继承父类碰撞检测）

// ---- 先执行父类（飞行 + 碰撞检测 + 自动销毁） ----
event_inherited();

// ---- 尾迹（飞行时生成） ----
if (life > 0) {
   // ---- 生成尾迹粒子（每帧一个，更密集） ----
trail_timer++;
// 改为每帧生成，不要 %2
var _particle = instance_create_layer(x, y, "Effects", obj_dagger_trail);
_particle.sprite_index = spr_dagger_trail;
_particle.image_blend = trail_color;
_particle.image_alpha = 0.8;                    // 0.6 → 0.8 更亮
_particle.image_xscale = 0.8 + random(0.6);     // 0.5→0.8 更大
_particle.image_yscale = _particle.image_xscale;
_particle.image_angle = random(360);
_particle.fade_speed = 0.02 + random(0.02);     // 0.05→0.02 更持久
_particle.life = 30;                            // 20→30 更长
        }
    
