# project13_v4 开发日志（跨会话/跨机器交接）

> **用法**：换电脑或开新会话时，第一句话就说：
> 「读 `D:\project13_v4\DEVLOG.md`，然后继续」
>
> 新会话的 AI 读完这个文件即可接上，**不需要重新描述需求**。
>
> **维护规则**：每完成一个功能，让 AI 在本文件**追加**一段（约 50-100 token），不要重写全文。

---

## 零、沟通约定（★ 最重要，先读这一节）

### 用户风格

- **说话直接**。不耐烦时说「别BB赖赖」→ **立刻给结论 + 代码，停止解释**
- **会贴超长日志（几千行）** → **只挑关键行，不逐行分析**
- **会质疑判断**（「你确定？」「这才几个对话」）→ **承认错误、重新算，别嘴硬**
- **不懂代码细节时会急** → **问「具体现象是什么」，不要猜**
- **要「接续」不要「重置」** → **不问「你之前做了什么」，直接接着干**
- **会质疑方案是否过度设计**（「这会不会太麻烦」）→ 认真对待，给更省的替代方案
- **不主动报「Token 剩余百分比」**（之前瞎估被怼过）

### 铁律

1. **先诊断再开药**。现象不明时先加 `show_debug_message`，让用户跑一遍贴日志。
2. **一次只改一处**，改完让用户跑，看现象，再决定下一步。不同时改多个文件。
3. **给完整可替换代码，不给片段**。尤其改过多轮的文件，**直接给整文件覆盖**，不要说「找到某段改成 X」——用户拼接时容易错位（已经因此出过 bug）。
4. **同一问题改 3 次没解决 → 停下反思诊断方向**，不是继续改代码。
5. **不要重复让用户试同一个方向**。每次试之前想清楚「这次能验证什么假设」。
6. **用户说「还是不对」超过 3 次 → 停下重新看数据**。
7. **多说「改成这样，跑一次，告诉我 X」，少说「你可能需要……」**。

### AI 的失误模式（不要重犯）

| 失误 | 实例 | 教训 |
|---|---|---|
| **只照抄不抽象** | 漂浮代码在 4 个对象里抄了 4 遍才想到上移 `obj_item_base` | 看到重复就问「该不该上移」 |
| **指令不明确导致用户拼错** | 说「在末尾追加」，用户加到了函数外面 → 全局作用域报错 | 追加类改动必须给锚点，或直接给整文件 |
| **不验证就下结论** | 用 `Invoke-WebRequest` 失败误判「网络不通」，实际是工具自身问题 | 用目标运行时（Node）复现，而不是替代工具 |
| **忘了检查已有机制** | 遗物漏了拾取/背包/丢弃链路，因为「武器武技身法都有」 | 新增物品类型时，检查全链路：工厂/拾取/背包/装备/卸下/丢弃/排序/提示 |

---

## 一、项目基本信息

- **引擎**：GameMaker 2026
- **工程路径**：`D:\project13_v4`（**两台电脑路径一致**）
- **角色定位**：V4 项目技术合伙人，**不是顺从助手**。从「可维护、可扩展、可上线」视角思考
- **沟通要求**：先结论后理由；给完整可替换代码；一次只改一个文件；不猜、先诊断

### 核心宗旨（不可违背）

1. 数据驱动 —— 数值在数据表，代码只读
2. 模块化 —— 每功能独立脚本
3. 工厂模式 —— 所有对象通过工厂创建
4. 父对象轻薄 —— 只声明变量，不初始化
5. 行为与对象分离 —— 行为是纯函数，对象只调度
6. 单一职责
7. 插槽化设计 —— 武器/技能/遗物/伴生体/身法统一接口

### 长期目标

> **不论什么角色（玩家/敌人/NPC），装什么能力只要逻辑没问题就能随意调用。**
> 即：能力（Ability）与持有者（Owner）解耦。

---

## 二、当前进度

### ✅ 已完成：主动遗物（本命遗物）系统

**架构决策（重要）：**

- **遗物不建子对象**，全部共用 `obj_relic_base`；差异由 `data_relic.active_script` 决定
  - 理由：遗物在地上一模一样（图标+光晕），区别只在按 R 之后发生什么 → 属于"行为"，不属于"对象"
  - 对比：`obj_skill_grenade` 必须独立，因为它有对象级状态（`ammo_current`/`aiming`）
- **本命遗物**：单槽（`relic_slot`），主动，按 R 触发，可拆卸
- **被动遗物**：待做，设计为右上角 HUD 池 + 角色身上小图标

**已建立的资源：**

| 资源 | 说明 |
|---|---|
| `obj_relic_base` | 本命遗物基类（Parent = `obj_item_base`） |
| `data_relic` | 本命遗物数据表（`relic_crabification` / `relic_thunder`） |
| `scr_factory_relic_create` | 工厂 |
| `scr_relic_equip` | 装备（通用形态，支持任意 owner；旧的回背包） |
| `scr_relic_activate` / `scr_relic_try_activate` / `scr_relic_deactivate` | 激活/入口/还原 |
| `scr_relic_crabification` | 蟹化效果脚本 |
| `scr_relic_thunder` | 雷霆万钧效果脚本（含 `scr_relic_thunder_burst`） |
| `obj_relic_lightning_bolt` | 爆发电弧（跟随玩家） |
| `obj_relic_lightning_trail` | 闪避尾迹（连续闪电曲线，每点独立寿命） |
| `scr_item_pickup_relic` | 拾取 |
| `scr_is_item_type` | ★ 通用类型判断（见"关键坑"） |

**两个遗物的效果：**

- **蟹化**：直线移速 ×0.3 / 斜向 ×3 / 护盾 ×3 / 伤害 ×2 / 攻击冷却 ×3.3333（持续 12 秒，冷却 60 秒）
- **雷霆万钧**：按 R 爆发 12 条电弧（1.5~2 秒）+ 身法冷却减半 + 闪避时留闪电尾迹并再爆发一次（持续 15 秒，冷却 45 秒）

**遗物倍率机制（数据驱动）：**

```
玩家/敌人身上有 6 个倍率变量（声明在 obj_character_base）：
  relic_move_mult / relic_move_diag_mult / relic_shield_mult
  relic_damage_mult / relic_attack_cd_mult / relic_agility_cd_mult

scr_relic_activate 把 data_relic.effect 里的值搬进去
scr_relic_deactivate 全部还原成 1.0（幂等，直接赋值不做除法，避免浮点误差累积）
各系统读倍率：scr_character_move_execute / scr_attack_melee|hack|ranged / scr_agility_dash / scr_skill_cast
```

**已接通的 UI：**

- 装备栏第 4 槽（`scr_draw_equipment_slots`）
- tooltip（`scr_draw_item_tooltip`，含遗物 + 身法分支）
- infocard（`scr_draw_ui_infocards`，读 `relic_slot`）
- 卸下（`scr_inventory_ui_try_unequip`，含 `scr_relic_deactivate` 防倍率残留）
- 拾取提示（`scr_item_pickup_check`，含遗物扫描）
- 漂浮/光晕上移到 `obj_item_base` 的 Step（随机相位，避免同步）

### ✅ 已完成：被动遗物系统（见下方「二·补3」）

**原定案（已实现，仅"四个遗物"扩成五个）：**

| 项 | 定案 |
|---|---|
| 位置 | 右上角 HUD 池（**已做**）；角色身上小图标（未做） |
| 生效 | 被动，不按键 |
| 格数 | 初始 4 格，满了只提示不弹窗 |
| 叠加 | **同名可叠加 `count`** |
| 卸下 | 有代价 = 卸下即永久销毁 |
| 存储 | **纯数据 struct，不建对象**：`relic_pool = [{ id, count, rarity, quality_index }]` |

**四个遗物（数值待调）：**

| ID | 名称 | 效果 | 状态 |
|---|---|---|---|
| `relic_solar_panel` | 太阳能板 | 脱战（10 秒无攻击/受击）+1.5% 最大电量/秒 | 待做 |
| `relic_wind_turbine` | 风力发电机 | 移动时 +0.8 电/秒 ×(当前移速/5) | 待做 |
| `relic_expand_battery` | 扩容电池 | 最大电量 +15（上限和当前值同时加） | 待做 |
| `relic_overload_capacitor` | 过载电容 | 攻击消耗 8 电，伤害 +消耗×1.5%/层；**电量低于 8 禁止攻击** | 待做 |

**术语约定（重要）：**

- **游戏内显示叫「电量」，代码内部仍用 `hp` / `max_hp`**
- **只改显示层文案，不改变量名**（改变量名风险大、零收益）
- **电量归零会死**（被敌人打到 0），不是被自己扣死

**待做文件：** `data_relic_passive` / `scr_relic_pool_add|query|remove|get_count` / `obj_relic_hud`

### 📋 后续路线（用户定的）

```
1. 主动遗物 ×2                    ✅ 完成
2. 被动遗物 ×4                    ← 进行中
3. 身法 +1
4. 武器类型补全（每类型 1 把）
5. 武技 +1
6. 伴生体 ×2
7. 敌人各类型
8. 建筑
9. 关卡
```

---

## 二·补3 新功能：被动遗物系统（5 个，流派 Build 核心）

**文件：**
- `scripts/scr_relic_passive/` —— 存储 + 战斗状态 + 5 个效果脚本 + 工厂 + 拾取（32 个函数）
- `scripts/scr_draw_relic_passive_hud/` —— 右上角 HUD + 背包被动遗物栏
- `scripts/data_relic/data_relic.gml` —— **追加** 被动遗物数据表 `data_relic_passive_get`

**调用链：**
- `obj_player_base/Step_0` → `scr_relic_passive_update(self)`（每帧驱动所有被动遗物 + 脱战计时）
- `obj_ui_manager/Draw_64` → `scr_draw_relic_passive_hud(player_ref)`（右上角）
- `scr_inventory_ui_draw` → `scr_draw_passive_relic_panel(ui, _player)`（背包右侧）

### 架构决策

| 项 | 定案 | 理由 |
|---|---|---|
| 存储 | **纯数据** `relic_pool = [{id,count,rarity,quality_index}]` | 不建对象；背包/屏幕外的遗物没有"存在感" |
| 生效 | 每帧调 `active_script`（数据表指定） | 对齐主动遗物的写法，**加遗物不改主循环** |
| 叠加 | 数值型效果 ×count（公式在各效果脚本里） | 数据驱动 |
| 不可叠加 | `stackable: false`，重复拾取返回 `max_stack` | 风力发电机 |
| 地面载体 | **复用 `obj_relic_base`** + `is_passive = true` | 掉在地上需要可见载体，拾取时转池数据并销毁 |
| 脱战 | `combat_last_action_timer` + `scr_combat_has_threat()` | 攻击/被打清零；扫描敌人 `_aggro_target` |

### 五个遗物（数值全在 `params` 里，改数字不用改代码）

| ID | 效果 | 叠加 | 注入点 |
|---|---|---|---|
| `relic_solar_panel` | 脱战回电 | ✅ | `Step` 每帧 |
| `relic_wind_turbine` | 面朝≈移动方向，按移速回电 | ❌ | `Step` 每帧 |
| `relic_overload_capacitor` | 攻击耗电换伤害 | ✅ | `scr_attack_melee/hack/ranged` |
| `relic_kinetic_recovery` | 被迫位移回电 | ✅ | `scr_damage_feedback`(击退) / `scr_fire_recoil_execute`(后坐力) |
| `relic_overclock_particle` | 扣血强放右键技能 | ✅ | `scr_weapon_try_skill` 冷却分支 |

**关键实现细节：**
- **脱战三条件**：`combat_last_action_timer >= 15s` + `!scr_combat_has_threat()`。
  攻击在 `scr_weapon_try_attack`（统一入口）标记；被打在 `scr_damage_feedback` 标记。
- **回血累积小数**：每帧回复量很小（~0.0x），直接 `heal()` 会被舍掉 → 用 `_solar_accum`
  累积到 0.05 再结算，否则**永远不回血**。
- **风力发电机方向判定**：面朝 = 鼠标方向；移动方向用**本帧实际位移**算（比读输入可靠），
  `abs(angle_difference(...)) <= 45°`。必须真的在动（位移 < `min_move_speed` 不算）。
- **过载电容**：伤在扣弹/挥砍**之前**结算，不允许就整个中止；`_overload_mult` 乘进伤害。
- **动能回收**：按 `source` 过滤（`knockback`/`recoil` 算，`dash`/`rush` **不算**）。
- **超频颗粒**：用户定案"**先检查、能放才扣**" → `can_pay()` 检查，`pay()` 才扣血。
  兜底 `hp >= 1`，超频不能把自己扣死。

### 精灵占位（★ 重要）

`spr_relic_solar_panel` 等 5 个精灵**还没做**。
**数据表里直接写精灵名会导致编译失败** → 所以 `sprite: noone`，并加了 TODO 注释。
**用户做好图后，把 `data_relic.gml` 里 5 处 `noone` 改成对应精灵名即可。**
没精灵时 HUD/背包栏会自动画**主题色方块**占位，功能照样能测。

### 测试热键（临时，测完删）

| 键 | 作用 |
|---|---|
| `F5` | 太阳能板 ×1 |
| `F6` | 风力发电机 ×1 |
| `F7` | 动能回收器 ×1 |
| `F8` | 超频颗粒 ×1 |
| `F9` | 过载电容 ×1 |
| `F10` | 打印池状态 + 脱战判定结果 |

### 待做（用户后续）

- 密钥解锁槽位：`scr_relic_passive_unlock_slot(owner, n)` **已就绪**，接密钥系统即可
- 主动遗物的 `unlocked_relics` 与被动遗物**共用**，注意区分

### ★ 被动遗物 UI 完善（用户提的 7 项）

**1. 测试代码已删** —— `obj_player_base/Step_0` 里的 F2/F5~F11 热键全部移除。

**2. 测试数据移到 `obj_test_data/Create_0`**（新增 `"relic_passive"` 类型到 `scr_item_create_on_ground`）：

| 遗物 | 坐标 | 数量 | 用途 |
|---|---|---|---|
| 太阳能板 | 1200, 800 | ×3 | 叠加测试 |
| 风力发电机 | 1200, 950 | ×2 | **不可叠加**验证 |
| 过载电容 | 1400, 800 | ×3 | 叠加测试 |
| 动能回收器 | 1400, 950 | ×3 | 叠加测试 |
| 超频颗粒 | 1600, 800 | ×3 | 叠加测试 |

> **品质用「轮换 7 档」而不是加权随机**：测试目的是看品质色对不对，
> `data_rarity_roll` 加权后大部分出 common，看不全。轮换能一次看遍所有品质色。

**3. 被动遗物栏背景 = 品质色**（`scr_draw_passive_relic_panel`）：
- 先铺深色底（保证图标/文字可读），再叠品质色
- **未选中 → 静态 alpha 0.25**（不闪）
- **选中 → 呼吸闪烁 alpha 0.25~0.60**（`sin(current_time * 0.006)`）
- 悬浮 → alpha 0.34 提亮

**4. 左键选中**（`scr_passive_relic_panel_update`）：
- 点一下选中（青色粗边 `c_aqua`，与装备栏一致），再点取消
- 新增字段 `ui.selected_passive` / `ui.hover_passive`

**5. 悬浮说明窗**（`scr_draw_passive_relic_tooltip`）：

> **★ 不能复用 `scr_draw_item_tooltip`** —— 那个依赖**物品实例**（`entity_data`/`sprite_index`），
> 而被动遗物是**纯数据没有实例**。所以按同样视觉风格单独实现。
> 内容：品质 / 层数 / 可叠加性 / 描述（CJK 折行）/ 操作提示。

**6. 拆卸 = 碎裂销毁**（`scr_passive_relic_dismantle`）：
- **右键 或 Q**，**只作用于选中的格**（防误拆）
- **整条移除**（不是减一层）—— "碎裂"就是整件销毁，符合"卸下有代价"
- 碎裂反馈：碎片粒子（复用 `pt_enemy_hit`）+ 提示文字

**7. 右上角 HUD 放大**：图标格 **40 → 56**，叠层数字用**四向描边**更清晰。
（用户反馈"叠加时右下角数字太大"→ 格子放大后数字自然融入，不用缩字体）
HUD 背景也改成**品质色**，与背包栏一致。

#### ⚠️ 键位冲突（已处理）

`Q` 在原代码里已有两个用途：**确认框确认**（Step L113）和**装备槽卸下/背包丢弃**（L140）。
新增的"拆卸"也用 Q，靠**空间隔离 + 提前 return** 解决：
- 被动遗物栏在 x=1340+（背包右侧），与其他面板**X 范围不重叠**
- `scr_passive_relic_panel_update` 在 Step L130 **先于**通用点击逻辑执行
- 通用 Q / 右键逻辑加 `!_mouse_on_passive` 守卫，避免双触发
- 确认框打开时 L126 `exit` 会先拦住，不会冲突

### ★ 被动遗物 UI 第二轮（用户提的 5 项）

**1. 提示不再堆叠（★ 通用改进，影响全游戏）**

**根因：** `scr_show_hint` 每次都 `instance_create_depth` **新建** obj_hint，
多个实例画在**同一坐标**（100 / 150）→ 连续操作几次就糊成一团。

**解法：** 新建前先销毁场上所有 obj_hint。
```gml
// ★ 倒序销毁，不要在 with 里销毁自己（GM 会跳过元素）
var _n = instance_number(obj_hint);
for (var i = _n - 1; i >= 0; i--) {
    var _old = instance_find(obj_hint, i);
    if (instance_exists(_old)) instance_destroy(_old);
}
```

**2. HUD 图标格再放大：56 → 68**（`_gap` 8 → 10）

**3. 去掉「单」角标** —— 不可叠加的信息改由**悬浮说明窗**的「不可叠加」一行承担。

**4. 拆卸加确认框（两阶段状态机）**

```
选中格 → 右键/Q → 阶段0 警告「拆卸后该遗物将格式化 / 是否拆卸？」[是][否]
                    ↓ 点「是」
               count > 1  → 阶段1 数量选择
               count == 1 → 直接拆
```

**阶段1 数量选择（用户要求）：**
| 按钮 | 行为 |
|---|---|
| 单个 ×1 | 拆 1 层，剩余保留 |
| 指定 ×N | 拆 N 层（**← → 调整**，回车确认） |
| 全部 ×N | 整条移除 |
| 返回 | 退回警告阶段 |

ESC = 取消整个流程。框开着时 Step 里 `exit` → **屏蔽其它所有背包交互**。

新增 UI 字段：`pd_active / pd_stage / pd_relic_id / pd_relic_name / pd_relic_color / pd_max_count / pd_chosen_count`

**5. 拆分数量时的一个坑（已修）**

数据层 `scr_relic_passive_remove` **只有两种语义**：「减 1 层」和「整条删」，**没有"减 N 层"**。
所以 `scr_passive_relic_dismantle` 里对"拆 N 个"要**循环调用** `remove(remove_all=false)`。
第一版只减了 1 层（写错了），已修正为循环。

> **教训：调用既有函数前先确认它的语义粒度，别假设"参数叫 amount 就能减 N"。**

### ★ 被动遗物 UI 第三轮（用户提的 4 项）

**1. 悬浮说明窗删掉底部的「[右键/Q] 拆卸即碎裂」提示行**，框高同步收缩（去掉 `_hint_h = 22`）。

**2. 警告图标 `⚠` → `！`**（`draw_text_transformed(_cxm, _cy + 36, "！ 警告", 1.3, 1.3, 0)`）

**3. 警告框文字重叠（已修）**

**根因：** 阶段0 框高只有 240，各行挤在一起：
```
'是否拆卸？'      y = 140
'回车=是 ESC=否'  y = 144   ← ★ 只差 4px，视觉上重叠
```

**修法：** 框高 **240 → 290**，重排各行，并把键盘提示移到**按钮正上方**（`_by - 34`）：
```
标题36 / 遗物名74 / '将格式化'118 / '是否拆卸？'152 / 键盘提示186 / [是][否]220~266
间距：34px / 34px  ← 不再重叠
```

**4. 数量选择流程改造（★ 核心改动）**

**用户要求：** 选完「单个/指定/全部」按钮后，**还要再点一次「是」才执行**（防误操作）；
数量调整**改用鼠标滚轮**（上滚 +1 / 下滚 -1）。

**改造后的流程：**
```
阶段0 警告  [是] → count>1 进阶段1 / count==1 直接拆
              [否] / ESC → 关闭
阶段1 数量选择
  ├ [单个×1] [指定×N] [全部×N]   ← 点击**只切模式**，不执行
  ├ 滚轮上下 → 调 pd_chosen_count（自动切到「指定」模式）
  ├ [是] → 按当前模式执行  ★ 必须再点一次
  ├ [否] → 退回阶段0（保留选择）
  └ ESC  → 关闭整个框
```

**新增字段：** `pd_mode`（0=单个 / 1=指定 / 2=全部）
**滚轮行为：** 超上限环绕回 1，低于 1 环绕到上限；滚轮一动自动切「指定」
**键盘保留：** ← → 同样可调（无滚轮时用），回车 = 是

阶段1 框高 **300 → 380**（多了一行「是/否」确认按钮）。

### ★ 被动遗物 UI 第四轮（用户提的 2 项）

**1. 滚轮不再抢模式（已修）**

**问题：** 选到「单个」后一滚滚轮，模式被自动抢回「指定」。

**根因：** 第三轮我加了 `ui.pd_mode = 1;`（"滚轮一动就切指定，符合直觉"）——
**这是画蛇添足**，违背用户意图。

**修法：** 删掉滚轮 / ← → 里的所有 `pd_mode` 赋值。
现在 `pd_mode` **只在点击三个按钮时改变**（`scr_draw_relic_passive_hud.gml` L772）。
滚轮只改数字，切回「指定」就能用新数字。

**2. 提示文案改成「滚轮选择数量」**（用户指定），并把执行说明拆成第二行。

> **过程中我犯了一个错，记录一下：**
> 我怀疑「滚轮」二字在 `font_chinese` 里缺字（该字体是逐字手工勾选 range 的），
> 写了个正则去查 `ranges`，结论是"20 个字全缺"。
> **但用界面上明明正常显示的字（"警告""拆卸"）一验，也全被判为缺字
> → 说明是我的检测正则写错了，结论作废。**
> **教训：诊断脚本本身要先自证有效**（拿已知正确的样本回归），
> 否则会得出一个看起来很像样、实际完全错误的结论。

### ★ 第五轮（用户提的 4 项，含 2 个真数据 bug）

#### 1. 滚轮只在「指定」模式生效

**用户要求：** 只有选中「指定」按钮时滚轮才改数量；选「单个」/「全部」时不动。

**修法：** 整个滚轮 + ← → 逻辑包进 `if (ui.pd_mode == 1) { ... }`。

#### 2. 数量界面点「否」不再跳回警告界面

**问题：** 点「否」→ `ui.pd_stage = 0` → 又回到第一个"是否拆卸"界面（用户觉得多余）。

**修法：** 点「否」直接 `ui.pd_active = false` **关掉整个框**（与 ESC 同效）。

#### 3. 背包打开时角色完全不响应（★ 全局输入屏蔽）

**问题：** 打开背包后按左右键，角色照样移动/攻击/放技能。

**根因：** 输入收集和消费**完全不看 `inventory_ui_open`**。

**修法（4 处，全链路拦截）：**

| 位置 | 拦什么 |
|---|---|
| `scr_player_input_update` | 移动输入 → `move_dir_x/y = 0` 后 return |
| `scr_player_attack_input_update` | 攻击输入 → `input_left/right = false` 后 return |
| `obj_weapon_ranged_base/Step_0` | 远程**单发模式**（它直连 `mouse_check_button_pressed`，不走 input_left） |
| `obj_player_base/Step_0` | R 放遗物 / 1 2 切武器 / 空格闪避 / F 拾取 → `if (inventory_ui_open) exit;` |

> **顺序要点：** `scr_relic_passive_update`（脱战计时/回血）必须放在 `exit` **之前** ——
> 开背包不该让脱战计时和回血停摆。

#### 4. 护盾两个 bug（★ 真数据 bug，都能对上用户描述）

**症状 A：护盾被打掉两格，发光描边特效就没了**

**根因：** `obj_character_base/Draw_0` 的条件是 `shield >= max_shield` —— **必须满盾才发光**。

**修法：** 改成**按剩余比例**决定亮度（`0.04 + 0.16 * ratio`），盾越满越亮、空了才熄灭；
满盾时额外叠一层呼吸。描边宽度也随比例微调（盾少 → 更"虚弱"）。

**症状 B：蟹化结束，原来被打碎的护盾又回来了**

**这是两个 bug 叠加：**

① **蟹化激活时把盾拉满**（`scr_relic_activate`）：
```gml
owner.shield = owner.max_shield;   // ← 丢弃了玩家蟹化前的真实盾值
```
蟹化前一开白送满盾，**结束时又"还原"成满盾**。

② **结束时只夹紧上限，不还原当前值**（`scr_relic_deactivate`）：
```gml
if (owner.shield > owner.max_shield) owner.shield = owner.max_shield;
// 盾碎时 shield=0，0 > 100 不成立 → 什么都不做
```

**修法：用「盾值比例」贯穿全程。**
- 激活：记 `relic_shield_ratio = shield / max_shield`，上限 ×mult，当前值 = 新上限 × ratio
- 结束：先用**放大后**的上限算 ratio，还原上限，再 `shield = max_shield * ratio`

**验算（原 30/100，蟹化 ×3）：**

| 阶段 | 旧行为 | 新行为 |
|---|---|---|
| 蟹化激活 | 300/300（白送满盾） | 90/300（比例 0.3 保持） |
| 蟹化中挨打 | → 0/300 | → 0/300 |
| 蟹化结束 | 0/100，但满血后会朝 100 回充 → **"盾回来了"** | 0/100（**确实碎了**） |
| 没挨打时 | 100/100（凭空回满） | 30/100（**正确还原**） |

> **语义纠正：蟹化是「护盾变厚 ×3」，不是「护盾回满」。**

---

### ★ 修复：超频颗粒 × 附件型武技（榴弹炮）

**现象：** 超频对榴弹炮完全不生效。

**根因 1（路径）：** `scr_weapon_try_skill` 第 32-35 行，附件型武技**提前 return 走另一条路**
（`scr_attachment_try_skill`），压根到不了超频分支。

**根因 2（语义，更关键）：附件的 `cooldown_timer` 是「装填进度」，不是「技能冷却」。**
直接 `cooldown_timer = 0` 强行就绪 = 强行装填完成 → **白嫖弹药 + 打断装填判定**
（`scr_character_state_update` 用 `floor(_progress * ammo_max)` 重算弹数）。

> **解法（用户定案）：附件型走「扣血补一发弹药」，只动 `ammo_current`，绝不碰 `cooldown_timer`。**
> 换弹逻辑**零改动**，天然不会白嫖。
> 两个安全闸：① 弹已满 → 不许扣血（不花钱买空气）；② 补完弹**不自动继续瞄准**，
> 让玩家再按一次，避免"一帧内补弹+瞄准"绕过装填节奏。

#### ★★ 二次修复：弹满了但装填没完 → 卡死（用户实测发现）

**现象：** 榴弹炮**弹是满的**，但装填计时还没走完 → 打不出去，也补不了弹 → **彻底卡死**。

**根因：** 拦住发射的条件是 `cooldown_timer > 0 || ammo_current <= 0`（**或**关系）。
补弹只解决了 `ammo_current`，`cooldown_timer` 还在跑 → 照样拦住。
更糟的是这种"弹满 + 装填中"的状态**真实存在**：
装填判定用 `floor(_progress * ammo_max)` 会**先把弹数补上来**，而计时器还在走。

**修法：引入「放行通行证」`_oc_ready_shot`，而不是清 `cooldown_timer`。**

> **⚠️ 为什么绝对不能 `cooldown_timer = 0`：**
> 附件的 `cooldown_timer` **同时被装填判定使用**
> （`scr_character_state_update`: `_elapsed = _total - cooldown_timer`）。
> 清零 → `_elapsed = _total` → `_should_have = ammo_max` → **弹数被算错**，
> 且"装填完成闪烁/装满"会提前触发。
> 所以：**不动计时器**，只发一张"这一发现在能打"的通行证。

**通行证设计（4 条规则）：**
1. 弹没满 + 装填中 → **补 1 发 + 放行**
2. 弹已满 + 装填中 → **不补弹，只放行**（这就是卡死场景的解）
3. 弹已满 + 装填完成 → **不触发超频**（本来就能打，别白扣血）
4. 放行证 **5 秒超时作废**（防止"买了不打"永久挂着），**用完即清**（只放行一发）

**已推演的全部状态**（ammo_max=2）：`0/装填中`、`2满/装填中`、`2满/完成`、
`无超频颗粒`、`电量不足` —— 五种都不会卡死，行为符合预期。

#### 普通武技（蛮牛/剑气）**未受影响**（用户确认保持现状）

两条路径完全独立，不会互相污染：
- **普通武技** → `scr_weapon_try_skill` L54：`cooldown_timer = 0` **清冷却**（纯冷却语义，正确）
- **附件型** → L32 **提前 return** 走 `scr_attachment_try_skill`：只补弹/放行，**从不清冷却**

> **教训：同一个字段（`cooldown_timer`）承载两种语义时（冷却 vs 装填进度），
> 所有写操作必须先分清是哪种，绝不能一处改法套用到另一处。**

### ★ 修复：动能回收器「单次事件上限」被逐帧调用绕过（数值 bug）

**现象：** `max_hp_per_event` 形同虚设。

**根因：** 后坐力是**逐帧**推进的（榴弹 120px / 25 帧 = 4.8px/帧），
而 `scr_fire_recoil_execute` **每帧**都调 `kinetic_on_shift` → 一次后坐力被当成 **25 次独立事件**
→ 上限从"5 血"实际变成 **125 血**。

> **解法：引入 `event_id` 概念，同一次连续位移共用一个回收额度。**
> - `scr_fire_recoil_execute`：event_id 由 `scr_attachment_fire` 在**开始后坐力时**自增
> - `scr_damage_feedback`：每次击退用全局递增序号（每次挨打 = 独立事件）
> - 额度记账用「**发放量**」而非「实际回血量」→ 血满时不会攒额度以后白送

**修完的收支曲线（保守数值：`hp_cost=8` / `pixels_per_hp=120` / `max_hp_per_event=3`）：**

| 动能层数 | 单次后坐力回血 | 放 1 次超频需要 |
|---|---|---|
| 1 层 | 1.00 | 8.0 次后坐力 |
| 2 层 | 2.00 | 4.0 次 |
| **4 层+** | **3.00（撞上限）** | **2.7 次** |

> **★ 上限截断是这套流派的安全阀**：无论堆多少层，单次最多回 3 血，
> **永远不可能"1 次后坐力回本"** → 循环不会无限加速。
> 用户要的"叠加多了能一直用"体现在：层数越高越接近自循环，但**始终需要 2.7 次**。
> 想要更爽就把 `max_hp_per_event` 调高，但**别调过 `hp_cost`**，否则会变成真无限。

---

**文件：** `scripts/scr_draw_relic_hud/`（★ 独立脚本，**用户自己在 IDE 里建的**，已正确登记进 `.yyp`）
**调用：** `obj_ui_manager/Draw_64` 第 5 段

> **★ 工作约定（用户明确要求）：UI 脚本单独放一个文件，不要塞进别的脚本里。**
> 上一版我把它追加进了 `scr_draw_ui_hpbar.gml`，用户说「乱」。
> **正确做法：新建独立脚本目录 `scr_draw_xxx/`。**
> 但注意 —— 手写文件系统建目录 `.yyp` 不认（见下文「重大坑」），
> **必须让用户在 GameMaker IDE 里 Create → Script**，我再改内容。
> 或者我改 `.yyp` 补条目（可行但不如 IDE 建干净）。

**解决的问题（用户要求）：「一眼看出装了什么遗物 / 用了之后还剩多久」**

**版式（右下角贴边，110×122）：**
```
┌─────────────────┐
│    [图标 64px]   │  ← 品质色描边；冷却中压暗去色
│  ▓▓▓▓▓░░░░░░░░  │  ← 进度条
│   剩余 8 秒      │  ← 状态文字
└─────────────────┘
```
> ★ **不显示遗物名字**（用户要求：「不好看」）。
> 玩家认图标就行 —— 遗物图标是唯一的，图标本身就是身份标识。
> 名字只在**背包 tooltip** 里显示。

**背景（用户后续追加要求）：**
- 背景 = **当前遗物品质色**（`scr_get_rarity_color(rarity)`，**不是** `active_color` 主题色）
- 先铺半透明黑（保证文字可读），再叠品质色
- **平时固定 alpha 0.30（不闪）**；**R 激活期间 0.30→0.62 呼吸渐变**（sin 驱动，柔和非硬闪）
- ⚠️ 平时刻意不闪 —— 否则会和「就绪状态呼吸边框」打架，满屏在闪反而看不清

**高度踩坑：** 一开始设 128，导致「状态文字」和「遗物名」只差 **13px**（中文会视觉重叠）。
**改成 142** → 间距 27px，舒展。（后来名字整段删掉，框高收到 **122**）

### ★ 图标色差坑（用户反馈「矩形透明背景跟框内背景有色差」）

**两个独立原因叠加，都修了：**

**原因 1：图标垫底画的是矩形。**
遗物精灵画布是 **64×64 矩形**，但**图案本身是圆形**（螃蟹、闪电都是圆的）。
原来在图标下面画 `draw_rectangle(35,35,35)` 当垫底 → **四个角露在圆形轮廓外**，
和品质色背景拼在一起就是一圈明显的方块色差。

> **解法：** 垫底改成**圆形柔光**（`draw_circle` 同心圆叠 7 层近似径向渐变）。
> 跟随图案轮廓走，不露方角。（`draw_circle` 在 GM2026 可用，工程里已有多处使用）

**原因 2：非整数倍缩放导致重采样。**
原来是 `_scale = min(...) * 0.86` → **0.86 倍**，像素画非整数缩放会重采样，
在图案边缘产生半透明杂边 → 又是一层"色差"。

> **解法：** 优先取**整数倍缩放**（`floor(_fit)`，至少 1.0）。
> 精灵正好 64×64、图标框也 64 → `scale = 1.0`，**像素完美，零重采样**。

> **通用教训：像素画精灵尽量用整数倍缩放；画布矩形 ≠ 图案形状，
> 垫底/描边要用形状贴合的函数（circle/ellipse），别用 rectangle。**

**三状态 × 四重编码**（不只靠颜色，色盲也能分辨）：

| 状态 | 图标 | 边框 | 进度条 | 文字 |
|---|---|---|---|---|
| **冷却中** | 去色压暗 | 灰色细边 | **从左往右长** | `冷却 32 秒` |
| **已就绪** | 全亮 | 主题色**呼吸** | 整条拉满 | `R 就绪`（脉冲） |
| **生效中** | 偏染+高亮脉冲 | 主题色粗边 + **外发光** | **从右往左缩** | `剩余 8 秒` |

> **★ 核心设计点：进度条方向相反**（冷却=增长 / 剩余=缩短）。
> 这是"一眼分辨"的关键 —— 光靠颜色深浅，玩家要盯着看才分得清。

**其它细节：**
- 未装遗物 → 整个 HUD 不显示（不占屏幕）
- 主题色读 `data_relic.active_color`，拿不到退回品质色
- 秒数用 `ceil()` 向上取整，避免"显示 0 秒但还在生效"
- 遗物名过长用 `scr_text_wrap_cjk` 截断，不溢出
- 进入战斗的 **引导感**：就绪时文字颜色脉冲（`merge_color` + `sin(current_time)`）

---

**修复日期：** 本会话。三条都是真 bug，已定位到具体行。

### BUG 4 — 中文描述溢出框（★ 高价值坑）

**根因：GameMaker 的 `draw_text_ext` / `string_height_ext` 自动换行**只按空格断词**。
中文没有空格 → 整段找不到断点 → **一个字都不换** → 直接溢出框。
（已知官方 issue：YoYoGames/GameMaker-Bugs #11569）

**解法：** 把 `scr_text_wrap_cjk` 追加到**已登记的** `scr_get_type_name_cn.gml` 里 ——
按**实际字符宽度**逐字累加折行，CJK 可任意字间断行；`respect_spaces=true` 时英文按空格断词。
tooltip 改为 `scr_text_wrap_cjk` 折行后 `draw_text` 逐行画，高度按**行数 × 行高**算。

> **以后凡是中文长文本要折行，一律用 `scr_text_wrap_cjk`，不要用 `draw_text_ext`。**

#### ⚠️ 重大坑：不能在磁盘上"直接新建脚本"，GameMaker 不认

**现象：** 新建了 `scripts/scr_text_wrap_cjk/`（`.gml` + `.yy` 都在），
运行却报：
```
Variable obj_inventory_ui.scr_text_wrap_cjk(100778, -2147483648) not set before reading it.
```
—— 它把函数名当**实例变量**去找了，说明编译时**根本没这个函数**。

**根因：`project13_v4.yyp` 是资源总清单。**
`scr_get_type_name_cn` 在里面有登记：
```
{"id":{"name":"scr_get_type_name_cn","path":"scripts/scr_get_type_name_cn/scr_get_type_name_cn.yy",},},
```
新脚本在磁盘上存在，但 **`.yyp` 里没有对应条目 → GM 不编译它**。
（光有 `.gml`+`.yy` 不够，`.yyp` 才是真相来源。）

**两种解法：**
1. **（推荐，省事）不要新增资源** —— 把新函数**追加到已存在的脚本 `.gml` 文件末尾**。
   同一个 `.gml` 里可以放多个 `function`，共享一个资源条目。
2. 必须新增资源时 → **在 GameMaker IDE 里** File → New → Script 建，让 IDE 自己写 `.yyp` 条目。
   **不要用文件系统手动建目录。**

> **给 AI 的约束：改 GML 时优先"改已有文件"，不要"新建脚本文件"。**
> 手动建的脚本会静默不编译，报错还极具误导性（伪装成"变量未定义"）。

### BUG 5 — 蟹化持续时间远远超过设定（★ 我自己引入的回归）

**根因：我在 `obj_relic_base/Step_0` 里**重复递减**了 `active_timer`。**

`obj_player_base/Step_0` 本来就是唯一责任方：
```gml
if (relic_slot.is_active) { active_timer--; if (<=0) scr_relic_deactivate(...) }
```
差别在于：**那里到期会调 `scr_relic_deactivate` 还原倍率 + 外观**。
我在 relic 的 Step 里也减一次，结果是：
1. 我那份先跑到 0 → 只把 `is_active` 置 `false`
2. player 那段 `if (is_active)` 再也不成立 → **`scr_relic_deactivate` 永不执行**
3. → 移速/护盾/蟹化外观**永久残留** = "持续时间远远超过设定"

**已回滚**该段，并在原处留了警告注释。

> **铁律：一个状态只允许一个地方负责「推进 + 收尾」。**
> 只推进不收尾，比不推进更糟 —— 会静默变成永久 buff。

### BUG 1 — 换下再装备会重置冷却（武技/遗物/身法 三种都有）

**根因：** 冷却本来就存在**物品实例**上（`cooldown_timer`），回背包时实例也没销毁
（`scr_inventory_add` 只是 array_push）。是"装备函数里的无条件清零"把它擦掉了：

| 文件 | 原代码 |
|---|---|
| `scr_relic_equip` L54 | `relic_inst.cooldown_timer = 0;` |
| `scr_agility_equip` L27 | `agility_inst.cooldown_timer = 0;` |
| `scr_skill_equip` L47 | `skill_inst.cooldown_timer = 0;`（else 分支） |

**做法（对齐成熟商用游戏）：冷却绑定物品实例，不绑定槽位。**
1. 删掉三处清零，冷却自动继承。
2. 补"背包/地面也走表"：`obj_skill_base/Step_0`、`obj_agility_base/Step_0` 加未装备时的
   递减（用 `owner_id.xxx_instance == id` 做互斥，避免与 `scr_character_state_update` 重复递减）。
   `obj_relic_base/Step_0` 原本就有，改为**无条件**递减（覆盖槽内/地面/背包），并补 `active_timer` 兜底。
3. 附件（榴弹）特例：`cooldown_timer` 语义是"装填进度"，同样不重置；
   瞄准指示器是装备态资源，被销毁过就重建。

**⚠️ 顺手修掉一个隐藏 bug：身法冷却以 2 倍速回。**
`obj_player_base/Step_0` L89-92 与 `scr_character_state_update` L68-69 **都在**递减
`agility_instance.cooldown_timer`。已删掉前者，冷却统一由 `scr_character_state_update` 管。

### BUG 2 — INFOCARD 遗物槽不显示名字和冷却

**两个独立错误：**
1. `scr_draw_ui_infocards` L27 读 `_player.relics[0]` —— **这个变量全工程不存在**
   （只有这一处引用）。实际是单槽 `_player.relic_slot`，名字字段是 `display_name`（**不是** `relic_name`）。
2. L121 传死值 `..., 1, 0, false` —— 冷却写死 1、**禁止闪烁**，所以冷却永远不显示、也不闪。

**做法：** 改读 `relic_slot`，按 `data_relic.cooldown × quality_cooldown_mult` 算冷却进度，
传入 `relic_flash_timer` 让它与武技/身法完全一致。
新增字段 `obj_character_base.relic_flash_timer`，在 `scr_character_state_update` 第 3c 段
用**降沿检测**（`_relic_prev_cd`）触发闪烁 —— 不写死 `==1`，否则遗物 Step 先跑时会漏闪。

### BUG 3 — 背包预览框不按文字自适应

**根因：** `scr_draw_item_tooltip` 的属性分支只有武器/武技，
**遗物和身法完全没有分支** → 遗物只显示名字+描述，框宽算不出内容宽度。

**做法：**
1. 补**遗物分支**（类型/冷却/持续/效果摘要/按键）和**身法分支**（距离/冷却），效果摘要从
   `data_relic.effect` 数据驱动读取，不写死具体遗物。
2. **框宽定案（用户拍板）：只看「名字 + 属性行」，描述永不参与撑宽。**
   公式 = `max(名字宽, 最长属性行宽, 240) + 内边距×2`，上限 500 保护。
   - 240 是描述折行的**下限**，防止短物品框太窄、描述挤成竖排
   - ⚠️ 曾写成"短描述可以把框撑开"，结果描述**仍然**影响框宽 → 用户反馈"还是没适应"。
     **别再让描述参与宽度计算。**
3. `scr_draw_ui_card` 的截断从**死写 6 个字**改为**按实际字体宽度 + 框宽**逐字回退。
4. **tooltip 边缘翻转**：靠右放不下时翻到鼠标左侧、靠下时上贴，避免被屏幕裁掉
   （被裁掉时用户会误判成"框宽不对"）。
   另：tooltip 内的 `mouse_x/mouse_y` 是**函数形参名**（调用方传的是 GUI 坐标），
   不是内置变量，别被 DEVLOG 那条"绝不混用 mouse_x"误导 —— 这条仍然成立。

**⚠️ 单位坑：** `data_agility.cooldown` 是**帧**（90 / 600），`scr_agility_dash` 直接当帧用；
`data_relic.cooldown` 是**秒**（45 / 60）。tooltip 里身法做了 `/60` 换算，**别再搞混**。

---

## 三、关键坑（血泪，不要重蹈）

### 1. `object_is_ancestor(A, A)` 返回 `false`

**这是遗物系统最大的坑。**

`object_is_ancestor(子类, 基类)` 判断"子类是不是基类的后代"，**自己不是自己的后代**。

- 武器/武技/身法都有子类对象（`obj_sword_basic` → `obj_weapon_base`），所以以前没暴露
- **遗物直接用 `obj_relic_base` 当实体** → `object_is_ancestor(obj_relic_base, obj_relic_base)` = **false**

**解法：统一用 `scr_is_item_type(obj_index, base_obj)`：**

```gml
function scr_is_item_type(obj_index, base_obj) {
    if (obj_index == base_obj) return true;
    return object_is_ancestor(obj_index, base_obj);
}
```

**已改的 5 处：** `scr_item_pickup` / `scr_check_first_pickup` / `scr_inventory_ui_equip_auto` / `scr_inventory_sort`（2 处）

### 2. GM2061「变量已定义」的诡异触发

`if (_trail_data == undefined) _trail_data = ...` 复用已 `var` 声明的变量，GM 2026 有时会报 2061。

**解法：换一个新变量名，不复用。**

### 3. 拼接代码时容易粘错位置

**教训：** 给"在某个 `}` 之前追加"的指令时，必须明确锚点（前后各 2 行）。**改过多轮的文件，直接给整文件覆盖，不给"找到某段改"。**

曾因此把大括号位置搞错，导致函数提前闭合、代码跑到全局作用域（报 `Variable <unknown_object>.owner not set`）。

### 4. 其它常踩的

- GML 读不存在的键**直接崩**，用 `variable_struct_exists` / `variable_instance_exists` 兜底
- `draw_arc` 在 GM 2026.0.0.23 不存在；`gui_height` 不是内置变量
- 鼠标坐标统一用 `device_mouse_x_to_gui(0)` 反算，**绝不混用 `mouse_x`**
- 子类设值会被父类覆盖（父只声明不赋值）
- `scr_character_move_execute` **只有玩家调用**（敌人不走），所以改它不影响敌人

---

## 四、跨机器工作流

### 环境事实

- 两台电脑工程路径**一致**：`D:\project13_v4`
- 会话同步用 `dsh-github-sync` 插件（GitHub 仓库 `AfanrenA/dsh-sync`）
- **API Key 不同步**（`.credentials.yaml` 在 gitignore 里），每台机器各自配置

### ⚠️ 已知问题：超长会话不能跨机恢复

**现象：** 某会话在公司电脑正常，家里恢复后发消息报
`DeepSeek API stream from https://api.deepseek.com failed`（伴随"重试延迟 7288 毫秒"）

**根因：** 该会话 916 KB（其他会话只有 3.8 KB / 71 KB）。跨机恢复时一次性重建全部历史 →
超出模型上下文限制 → API 拒绝 → 被包装成 stream 错误。

**已验证：** 家里电脑新开会话、读工程文件**完全正常** → 环境无问题。

**结论：**

- 超长会话**留在原机器用**，不要跨机恢复
- **跨机接续靠本文件（DEVLOG.md）**，不靠会话同步

### ★ 标准工作流（严格照做，不要用老会话）

**核心认知：**

> **代码 + 本文件 = 唯一真相来源**
> **会话只是临时工作台，用完就丢，不要回头用**

**每次换机器/换天的操作：**

```
1. DSH 网页 → 设置 → GitHub 同步 → 「恢复」      （拉最新代码）
2. 新开一个会话（★ 永远开新的，不要用旧的）
3. 第一句话：「读 D:\project13_v4\DEVLOG.md，然后继续」
4. 干活
5. 做完一件事 → 跟 AI 说「记一下」          （AI 追加约 50-100 token）
6. 离开前 → 设置 → GitHub 同步 → 「立即备份」
```

**为什么不用老会话：**

| 问题 | 说明 |
|---|---|
| 跨机恢复会挂 | 超长会话在家里恢复后报 stream failed |
| Token 成本线性增长 | 每轮都带全部历史，越用越贵 |
| 记忆滞后 | 家里会话 B 做的事，公司会话 A 不知道 → 会基于过期上下文给建议 |

**注意：** API Key 不同步（`.credentials.yaml` 在 gitignore 里），两台机器各自配置，这正常。

---

## 五、待清理项

- 各文件里的 debug 输出（`show_debug_message`）
- `obj_custom_cursor`（自绘指针，已验证不需要）
- `obj_game_controller` 的 `window_set_cursor(cr_none)` 恢复默认
- `obj_player_base/Step_0` 的临时测试代码（F2 生成遗物、F3 状态打印、排序测试）
- `obj_test_data/Create_0` 的地面物品测试列表
- `obj_gun_pulse/Create_0` 里写死的 `weapon_id`（多余，工厂会覆盖；删了以后多把枪可共用对象）
- `storages/session_projcache` 里的 7 个孤儿缓存（指向不存在的会话）

---

## 六、架构债（P0，遗物做完后处理）

**目标：能力与持有者解耦（"随用随调"）**

**根因：同一个概念，玩家和敌人用了两套字段名。**

| 概念 | 玩家字段 | 敌人字段 | 应统一为 |
|---|---|---|---|
| 武技实例 | `skill_instance` | `enemy_skill_instance` | `skill_instance` |
| 武技 ID | `skill_slot` | `enemy_skill_id` | `skill_slot` |
| 武技冷却 | `skill_instance.cooldown_timer` | `enemy_skill_cooldown` | `skill_instance.cooldown_timer` |
| 身法实例 | `agility_instance` | **不存在** | `agility_instance` |

**5 个拦路虎（精确位置）：**

1. `scr_weapon_try_skill` L9 —— `if (!object_is_ancestor(_owner.object_index, obj_player_base)) return;`（敌人永远无法通过武器放武技）
2. `scr_agility_dash` L4 —— 身法硬锁玩家
3. `scr_skill_cast` L19/L73 —— 冷却读两个字段
4. `scr_skill_get_final_distance` L12-30 —— 敌人恒 `quality_index = 0`
5. `scr_character_skill_state_update` L13-23 —— 蓄力状态读两套

**改造方案（分步）：**

- **第一步**：在 `obj_enemy_base` 加"别名"字段（不删旧字段），工厂同时写两套
- **第二步**：统一入口 `scr_ability_grant(owner, ability_type, ability_id, rarity)`
- **第三步**：敌人用身法（约 3 处改动）

**用户已明确：遗物做完后再动这块。**

---

*最后更新：被动遗物系统完成（5 个遗物 + 右上角 HUD + 背包栏 + 脱战判定 + 3 条注入链路）。*
*下一步：5 个精灵图（用户做）→ 密钥解锁槽位 → 被动遗物卸下代价。*
