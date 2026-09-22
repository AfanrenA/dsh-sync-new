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

### ⏳ 待办：被动遗物

**设计已定案：**

| 项 | 定案 |
|---|---|
| 位置 | 右上角 HUD 池 + **角色身上小图标**（土豆兄弟 + 雨中冒险结合） |
| 生效 | 被动，不按键 |
| 格数 | 初始 4 格，满了只提示不弹窗 |
| 叠加 | **同名可叠加 `count`** |
| 卸下 | 有代价 = 卸下即永久销毁 |
| 存储 | **纯数据 struct，不建对象**：`relic_pool = [{ id, count, rarity }]` |

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

*最后更新：主动遗物系统完成，被动遗物未开始。DEVLOG 已升级为三层结构（沟通层 / 项目层 / 工作流层）。*
