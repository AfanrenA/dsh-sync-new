// obj_character_base Create 事件
// 所有角色共有的变量（只声明，不赋值）
hp = 0;
max_hp = 0;
armor = 0;
move_speed = 0;
is_alive = false;
is_stunned = false;
stun_timer = 0;
is_hit_flashing = false;
hit_flash_timer = 0;
character_id = "";
entity_data = undefined;
active_weapon_slot = 0;
current_weapon = noone;
is_hit_flashing = false;
hit_flash_timer = 0;
is_stunned = false;
stun_timer = 0;
hit_pause_timer = 0;
hit_flash_duration = 0;
hit_stun_duration = 0;
character_type = "unknown";
//是否受到过伤害
is_attacked = false;
// ===== 死亡系统 =====
is_dead = false;
death_timer = 0;
// ===== 护盾闪烁 =====
is_shield_flashing = false;
shield_flash_timer = 0;
// 玩家专用
is_player = false;          // 由子类设置
is_reviving = false;        // 正在复活中
revive_input_timer = 0;     // 按键检测冷却

// 死亡动画参数
death_scale_target = 1.5;   // 膨胀目标
death_scale_speed = 0.02;   // 膨胀速度
death_fade_start = 0.3;     // 开始消散的时间点（比例）
death_fade_duration = 0.5;  // 消散持续时间（秒）
death_fade_progress = 0;    // 消散进度 0-1
death_particles = [];       // 火花粒子列表

// ===== 护盾系统 =====
shield = 0;//护盾初始值
max_shield = 0;//护盾上限
shield_regen_rate = 0;//恢复速度
shield_regen_delay = 0;//受伤后恢复冷却时间
shield_regen_timer = 0;//护盾恢复计时器归零后才会恢复
shield_charge_effect = false;// 是否播放充电特效
shield_charge_progress = 0;// 充电进度 0-1
shield_full_flash = 0;// 充满闪烁计时器
shield_was_full = false;// 上一帧是否满盾

// ===== 技能系统 =====
skill_slot = noone;        // 武技ID
skill_instance = noone;    // 武技实例（包含所有状态）
agility_slot = noone;      // 身法ID
agility_instance = noone;  // 身法实例

// ===== 武技蓄力 =====
skill_charging = false;
skill_charge = 0;
skill_charge_weapon = noone;
skill_charge_progress = 0;
skill_charge_distance = 0;
skill_charge_max_distance = 0;
skill_flash_timer = 0;
agility_flash_timer = 0;

// ===== 蛮牛冲撞 =====
is_rushing = false;
rush_dir = 0;
rush_distance = 0;
rush_traveled = 0;
rush_speed = 0;
rush_damage = 0;
rush_knockback = 0;
rush_owner = noone;
rush_hit_list = [];  // 已撞过的敌人，防止重复伤害
rush_damage_mult = 1;
is_invincible = false;
_charge_timer = 0;
skill_charge_target = 0;
skill_rarity = "common";  // 当前武技品质
agility_rarity = "common";    // 当前身法品质
is_attacking = false;
//relic_rarity = "common";      // 当前遗物品质（预留）

// ===== 发射后坐力（附件用）=====
fire_recoil_timer = 0;         // 剩余帧数
fire_recoil_vx = 0;            // 每帧位移 X
fire_recoil_vy = 0;            // 每帧位移 Y

aim_indicator_ref = noone;

//坐标统一
aim_target_x = 0;
aim_target_y = 0;

// ===== ★ 遗物倍率（默认 1.0）=====
// 放在 character_base：玩家/敌人都继承，避免"读不存在的变量直接崩"
relic_move_mult = 1.0;          // 直线移速倍率
relic_move_diag_mult = 1.0;     // 斜向移速倍率
relic_shield_mult = 1.0;        // 护盾倍率
relic_damage_mult = 1.0;        // 攻击力倍率
relic_attack_cd_mult = 1.0;     // 攻击冷却倍率（>1 = 变慢）
relic_agility_cd_mult = 1.0;    // 身法冷却倍率

// ===== ★ 遗物倍率的基准值（用于精确还原）=====
relic_base_max_shield = 0;      // 护盾上限基准（0 = 无覆盖）
relic_base_move_speed = 0;      // 移速基准（0 = 无覆盖）

// ===== ★ 本命遗物槽（通用形态：玩家/敌人都能装）=====
relic_slot = noone;
relic_slot_id = "";

// ===== ★ 蟹化状态（遗物）=====
is_crabbed = false;
_crab_orig_sprite = -1;
_crab_orig_xscale = 1;
_crab_orig_yscale = 1;
_crab_orig_blend = c_white;
_crab_orig_alpha = 1;

// ===== ★ 雷霆万钧状态 =====
is_thunder_active = false;
