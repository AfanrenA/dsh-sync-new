// 测试工厂创建玩家
var player = scr_factory_create("player", "player_warrior", 400, 300);
show_debug_message("玩家创建成功，ID: " + string(player));
// 创建背包 UI

// 测试敌人工厂
var enemy1 = scr_factory_create("enemy", "enemy_hr_swordsman_a", 1300, 400);
show_debug_message("守卫敌人创建成功，ID: " + string(enemy1));

// ===== 地面物品统一使用 scr_item_create_on_ground =====	
scr_item_create_on_ground("weapon", "sword_basic", 300, 300, "rare");
scr_item_create_on_ground("weapon", "axe", 500, 300, "common");
scr_item_create_on_ground("weapon", "axe", 500, 350, "mythic");
scr_item_create_on_ground("weapon", "gun_pulse", 600, 260, "elite");
scr_item_create_on_ground("agility", "dash", 600, 1000, "rare");
scr_item_create_on_ground("agility", "dash", 700, 1000, "divine");
scr_item_create_on_ground("skill", "skill_slash_wave", 400, 800, "mythic");
scr_item_create_on_ground("skill", "skill_slash_wave", 400, 1000, "divine");
scr_item_create_on_ground("skill", "skill_bull_rush", 300, 1100, "legendary");
scr_item_create_on_ground("skill", "skill_bull_rush", 500, 1300, "epic");
scr_item_create_on_ground("skill", "skill_grenade", 500, 1000, "divine");

// ===== 遗物测试 =====
scr_item_create_on_ground("relic", "relic_crabification", 700, 800, "rare");
scr_item_create_on_ground("relic", "relic_thunder", 800, 800, "epic");
scr_item_create_on_ground("relic", "relic_crabification", 900, 800, "legendary");

// ============================================================
// ★ 粒子系统初始化（按角色尺寸 72x72 / 64x64 调整）
// ============================================================
global.psystem = part_system_create();
part_system_depth(global.psystem, -99999);

// ---------- 护盾受击（白色球形，小而精） ----------
global.pt_shield_hit = part_type_create();
part_type_shape(global.pt_shield_hit, pt_shape_sphere);
part_type_size(global.pt_shield_hit, 0.5, 1, -0.02, 0);
part_type_speed(global.pt_shield_hit, 1.5, 3, -0.05, 0);
part_type_direction(global.pt_shield_hit, 0, 359, 0, 0);
part_type_color2(global.pt_shield_hit, c_white, make_color_rgb(200, 240, 255));
part_type_alpha2(global.pt_shield_hit, 0.8, 0);
part_type_life(global.pt_shield_hit, 8, 14);
part_type_blend(global.pt_shield_hit, 1);
// ---------- 护盾破碎（碎片，半透明，慢） ----------
global.pt_shield_break = part_type_create();
part_type_shape(global.pt_shield_break, pt_shape_pixel);
part_type_size(global.pt_shield_break, 0.5, 35, -0.02, 0);        // ★ 大小范围拉大：1~6
part_type_speed(global.pt_shield_break, 0.5, 10, -0.03, 0);     // ★ 速度范围拉大：0.5~5
part_type_direction(global.pt_shield_break, 0, 359, 0, 0);     // 全方向
part_type_color2(global.pt_shield_break, make_color_rgb(180, 230, 255), make_color_rgb(100, 180, 255));
part_type_alpha2(global.pt_shield_break, 0.8, 0);              // ★ 降低初始透明度
part_type_life(global.pt_shield_break, 40, 70);                // ★ 生命周期加长
part_type_blend(global.pt_shield_break, 0);

// ---------- 护盾破碎闪光（柔和，慢） ----------
global.pt_shield_flash = part_type_create();
part_type_shape(global.pt_shield_flash, pt_shape_sphere);
part_type_size(global.pt_shield_flash, 2, 4, -0.05, 0);        // ★ 缩小更慢
part_type_speed(global.pt_shield_flash, 0, 0, 0, 0);
part_type_direction(global.pt_shield_flash, 0, 359, 0, 0);
part_type_color2(global.pt_shield_flash, c_white, make_color_rgb(200, 240, 255));
part_type_alpha2(global.pt_shield_flash, 0.4, 0);              // ★ 从 0.9 降到 0.4
part_type_life(global.pt_shield_flash, 25, 95);                // ★ 生命周期加长
part_type_blend(global.pt_shield_flash, 1);

// 玩家受击
global.pt_player_hit = part_type_create();
part_type_shape(global.pt_player_hit, pt_shape_pixel);
part_type_size(global.pt_player_hit, 5, 9, -0.2, 0);
part_type_speed(global.pt_player_hit, 5, 9, -0.2, 0);
part_type_direction(global.pt_player_hit, 0, 359, 0, 0);
part_type_color2(global.pt_player_hit, make_color_rgb(0, 255, 255), c_white);
part_type_alpha2(global.pt_player_hit, 1, 0);
part_type_life(global.pt_player_hit, 15, 22);
part_type_blend(global.pt_player_hit, 1);

// 敌人受击
global.pt_enemy_hit = part_type_create();
part_type_shape(global.pt_enemy_hit, pt_shape_pixel);
part_type_size(global.pt_enemy_hit, 5, 8, -0.18, 0);
part_type_speed(global.pt_enemy_hit, 4, 8, -0.18, 0);
part_type_direction(global.pt_enemy_hit, 0, 359, 0, 0);
part_type_color2(global.pt_enemy_hit, c_black, make_color_rgb(80, 0, 100));
part_type_alpha2(global.pt_enemy_hit, 1, 0);
part_type_life(global.pt_enemy_hit, 18, 26);
part_type_blend(global.pt_enemy_hit, 0);

// ---------- 暴击（金色粒子，同普通受击形状） ----------
global.pt_critical = part_type_create();
part_type_shape(global.pt_critical, pt_shape_spark);
part_type_size(global.pt_critical, 2, 3, -0.25, 0);
part_type_speed(global.pt_critical, 3, 5, -0.3, 0);
part_type_direction(global.pt_critical, 0, 359, 0, 0);
part_type_color2(global.pt_critical, c_yellow, make_color_rgb(255, 180, 0));
part_type_alpha2(global.pt_critical, 1, 0);
part_type_life(global.pt_critical, 15, 22);
part_type_blend(global.pt_critical, 1);

// 暴击光晕（大、淡、加色混合）
global.pt_critical_glow = part_type_create();
part_type_shape(global.pt_critical_glow, pt_shape_sphere);
part_type_size(global.pt_critical_glow, 4, 5, -0.4, 0);      // 大，快速缩小
part_type_speed(global.pt_critical_glow, 0, 0, 0, 0);           // 不移动
part_type_direction(global.pt_critical_glow, 0, 359, 0, 0);
part_type_color2(global.pt_critical_glow, c_white, make_color_rgb(255, 240, 180));
part_type_alpha2(global.pt_critical_glow, 0.5, 0);
part_type_life(global.pt_critical_glow, 5, 35);                 // 短暂一闪
part_type_blend(global.pt_critical_glow, 1);

// ---------- 玩家死亡（数据消散，冷色调） ----------
global.pt_death_player = part_type_create();
part_type_shape(global.pt_death_player, pt_shape_pixel);
part_type_size(global.pt_death_player, 2, 6, -0.05, 0);           // 细长像素带
part_type_speed(global.pt_death_player, 1, 4, -0.02, 0);          // 缓慢移动
part_type_direction(global.pt_death_player, 80, 100, 0, 0);       // 主要向下（80~100°）
part_type_orientation(global.pt_death_player, 0, 0, 0, 0, true);  // 粒子朝向跟随方向
part_type_color3(global.pt_death_player,
    make_color_rgb(200, 240, 255),   // 白蓝
    make_color_rgb(0, 200, 255),     // 青
    make_color_rgb(0, 255, 100)      // 绿
);
part_type_alpha2(global.pt_death_player, 0.9, 0);
part_type_life(global.pt_death_player, 60, 120);
part_type_blend(global.pt_death_player, 1);

// ---------- 敌人死亡（数据消散，暖色调） ----------
global.pt_death_enemy = part_type_create();
part_type_shape(global.pt_death_enemy, pt_shape_pixel);
part_type_size(global.pt_death_enemy, 2, 6, -0.05, 0);
part_type_speed(global.pt_death_enemy, 1, 4, -0.02, 0);
part_type_direction(global.pt_death_enemy, 80, 100, 0, 0);
part_type_orientation(global.pt_death_enemy, 0, 0, 0, 0, true);
part_type_color3(global.pt_death_enemy,
    make_color_rgb(255, 255, 200),   // 白黄
    make_color_rgb(255, 200, 0),     // 黄
    make_color_rgb(255, 100, 0)      // 橙红
);
part_type_alpha2(global.pt_death_enemy, 0.9, 0);
part_type_life(global.pt_death_enemy, 60, 120);
part_type_blend(global.pt_death_enemy, 1);

// ---------- 枪口火花（传统橙黄，喷溅感） ----------
global.pt_muzzle_flash = part_type_create();
part_type_shape(global.pt_muzzle_flash, pt_shape_spark);
part_type_size(global.pt_muzzle_flash, 0.6, 1.4, -0.04, 0);        // 小，慢慢缩
part_type_speed(global.pt_muzzle_flash, 4, 9, -0.35, 0);           // 快，快速减速
part_type_direction(global.pt_muzzle_flash, 0, 359, 0, 0);         // 先全方向，脚本里会手动定向
part_type_color2(global.pt_muzzle_flash, c_yellow, make_color_rgb(255, 120, 0));  // 黄→橙红
part_type_alpha2(global.pt_muzzle_flash, 1, 0);
part_type_life(global.pt_muzzle_flash, 8, 16);
part_type_blend(global.pt_muzzle_flash, 1);                        // 加色，火光感

// ---------- 枪口渣子（暗色，比火花慢，不打光） ----------
global.pt_muzzle_debris = part_type_create();
part_type_shape(global.pt_muzzle_debris, pt_shape_pixel);
part_type_size(global.pt_muzzle_debris, 0.8, 1.6, -0.02, 0);       // 小方块
part_type_speed(global.pt_muzzle_debris, 2, 6, -0.2, 0);           // 比火花慢
part_type_direction(global.pt_muzzle_debris, 0, 359, 0, 0);
part_type_color1(global.pt_muzzle_debris, make_color_rgb(80, 60, 40));  // 暗棕，渣子
part_type_alpha2(global.pt_muzzle_debris, 0.9, 0);
part_type_life(global.pt_muzzle_debris, 10, 18);
part_type_blend(global.pt_muzzle_debris, 0);                       // 正常混合，不发光

// ===== 枪口烟雾 =====
global.pt_muzzle_smoke = part_type_create();
part_type_sprite(global.pt_muzzle_smoke, spr_particle, false, false, false);
part_type_size(global.pt_muzzle_smoke, 2.0, 3.2, 0.08, 0);      // ★ 0.5,0.8 → 2.0,3.2（放大 4 倍）
part_type_scale(global.pt_muzzle_smoke, 1, 1);
part_type_speed(global.pt_muzzle_smoke, 0, 0, -0.1, 0);
part_type_direction(global.pt_muzzle_smoke, 0, 359, 0, 0);
part_type_gravity(global.pt_muzzle_smoke, 0, 270);
part_type_orientation(global.pt_muzzle_smoke, 0, 359, 0, 0, false);
part_type_life(global.pt_muzzle_smoke, 30, 60);
part_type_alpha2(global.pt_muzzle_smoke, 0.6, 0.0);             // ★ part_type_alpha → part_type_alpha2
part_type_color3(global.pt_muzzle_smoke, make_color_rgb(200,200,200), make_color_rgb(150,150,150), make_color_rgb(100,100,100));
part_type_blend(global.pt_muzzle_smoke, false);