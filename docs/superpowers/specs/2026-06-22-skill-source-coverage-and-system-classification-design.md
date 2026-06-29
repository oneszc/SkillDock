# Skill Source Coverage, System Classification, And Plugin Import Notice Design

## 1. Goal

修复 SkillDock 在合并重复 Skill 时丢失 Codex System 来源的问题，在 GitHub 导入 Agent Plugin 仓库时提示 Skill 与 Plugin 安装边界，并在下一版本扩展 Codex 可用 Skill 的来源覆盖，让用户能区分：

- 自己管理的 Skill 资产。
- 已安装到 Agent 的 Skill 副本。
- Codex 内置的 System Skill。
- GitHub 仓库中可导入的 Skill 文件夹。
- 需要 Agent 官方插件安装器处理的 Plugin 能力。
- Codex 通过个人共享目录或插件提供的可用 Skill。

目标不是强行让 SkillDock 的数字等于 Codex，而是让统计范围、来源和去重规则清楚、可解释。

## 2. Root Cause

本机诊断结果：

- Codex 客户端显示 `276 Skills`，代表 Codex 当前可调用的聚合能力。
- `~/.codex/skills` 中实际有 45 个 `SKILL.md`。
- `~/.agents/skills` 中有 53 个 `SKILL.md`。
- `~/.codex/plugins/cache` 中有约 200 个 `SKILL.md` 候选条目。
- SkillDock 当前只扫描主技能库和 Settings 中启用的 Agent Target，不扫描 `~/.agents/skills` 和 Codex 插件来源。
- SkillDock 按 `名称 + 内容 Hash` 合并相同副本，因此相同 Skill 在多个 Agent 中只显示一次。

System 分类还有一个独立问题：

- `~/.codex/skills/.system` 实际有 5 个 Skill。
- `skill-installer` 同时存在于 Library、Codex System 和 Claude，内容完全相同。
- 合并时记录优先选择 Library 副本，System 来源信息随之丢失，因此 System 页面只显示 4 个。

## 3. Version Split

### V0.5.1 — System Classification Hotfix And Plugin Import Notice

只修复已经确认的分类错误、统计说明和 GitHub Agent Plugin 导入提示，不扩大扫描目录。

### V0.6 — Codex Available Skills

扩展 Codex 可用 Skill 的来源模型和只读浏览能力，包括个人共享 Skill 和插件提供的 Skill。

两个版本必须分开，避免将小型分类修复与来源发现、插件生命周期和新界面混在一次发布中。

## 4. V0.5.1 Design

### 4.1 Preserve Physical Provenance

相同逻辑 Skill 可以继续合并显示，但合并后的记录必须保留全部物理副本来源，至少包括：

- 来源类型。
- Agent ID。
- 文件路径。
- 是否为 System Skill。
- 内容 Hash。

详情页展示使用的首选副本仍按现有优先级选择，但 Library 优先不能覆盖或删除其他副本的来源属性。

### 4.2 Section Membership

- `Library`：存在 Library 副本时显示。
- `Installed`：存在任一已启用 Agent Target 副本时显示。
- `System`：存在任一 Codex `.system` 副本时显示。

三个页面是不同视图，不要求数量相加等于总数。同一个 Skill 可以同时出现在多个页面。

### 4.3 System Detail Behavior

从 `System` 页面打开 Skill 时：

- 使用 System 副本展示内容和文件结构。
- 明确显示 `Read-only`。
- 禁止安装、卸载或修改 System 副本。

从 `Library` 页面打开同名 Skill 时，仍使用 Library 副本和原有可操作规则，不能因为存在 System 副本而把 Library 资产整体设为只读。

### 4.4 Count Semantics

- `Installed 45` 表示至少存在一个 Agent 副本的去重后逻辑 Skill 数。
- `System 5` 表示至少存在一个 Codex System 副本的去重后逻辑 Skill 数。
- System 是 Installed 的可重叠子集，侧边栏数字不相加。

界面暂不增加复杂统计面板，只保证各分区标题和空状态用词准确。

### 4.5 GitHub Agent Plugin Notice

GitHub 导入流程继续把包含 `SKILL.md` 的文件夹作为可导入对象，但需要额外识别常见 Agent Plugin 仓库结构。

识别条件：

- 仓库根目录存在 `.codex-plugin/plugin.json`。
- 仓库根目录存在 `.claude-plugin/plugin.json`。
- 仓库根目录存在其他已知 Agent 插件清单时，可后续追加，但 V0.5.1 先覆盖 Codex / Claude Code。

识别到插件包时，在导入页的仓库信息和 Skill 列表之间显示轻量提示卡：

```text
This repository is an Agent Plugin.
SkillDock can import the included Skills for reading, collection, manual sync, and manual update checks.
To preserve plugin hooks, runtime behavior, official registration, and plugin updates, install the full plugin through Codex / Claude Code.
```

提示卡必须表达两个边界：

- SkillDock 会保留：Skill 名称、`SKILL.md`、references / scripts / assets 等 Skill 文件、GitHub 来源记录、后续手动更新检查能力。
- SkillDock 不会保留：Agent plugin 注册信息、hooks、runtime / extension 配置、官方插件启用状态、官方插件更新流程。

导入行为不阻断：

- 用户仍可选择导入全部或部分 Skills。
- 如果用户只想收藏、阅读或手动同步某几个 Skills，当前流程仍然有效。
- 如果用户要完整安装插件，应根据提示去 Codex / Claude Code 使用官方插件安装方式。

多 Skill 插件包还需要补充批量选择入口：

- `Select All`：选择当前列表全部候选 Skills。
- `Deselect All`：取消当前列表全部候选 Skills。
- 如果用户输入的是仓库根链接，默认选择策略可以在实施计划中确认；V0.5.1 至少必须提供明确批量选择入口，避免用户误以为只识别到第一个 Skill。

V0.5.1 不做：

- 不安装 `.codex-plugin/plugin.json` 或 `.claude-plugin/plugin.json`。
- 不复制或注册 hooks。
- 不模拟 Codex / Claude Code 官方插件安装命令。
- 不管理插件级启用、禁用、卸载和升级。

## 5. V0.6 Design

### 5.1 Source Model

新增只读的 Codex Available 来源层，与现有 Agent Target 分开：

- `Personal`：Codex 可发现的个人共享 Skill，例如 `~/.agents/skills`。
- `Plugin`：由已安装 Codex 插件提供的 Skill。
- `System`：Codex 内置 Skill。
- `Agent Copy`：现有 `~/.codex/skills` 等安装目标中的普通副本。

来源发现使用独立 Provider 接口。详情页和列表不直接依赖具体目录结构，后续 Codex 改变来源机制时可以替换对应 Provider。

### 5.2 Plugin Safety Boundary

- 不把 `~/.codex/plugins/cache` 当作稳定的产品接口直接全量扫描。
- 优先寻找 Codex 提供的清单、插件元数据或稳定的已启用插件状态。
- 只展示当前已安装且启用的插件 Skill，避免缓存中的旧版本或未启用条目进入列表。
- 如果当前版本无法获得稳定清单，V0.6 可以先发布 Personal 来源，插件来源继续保留为未完成范围，不能用不可靠缓存凑数。

### 5.3 Information Architecture

主侧边栏用 `Available` 取代独立的 `System` 入口，避免同一只读来源在两个一级入口重复出现：

- 默认展示 Codex 当前可发现但不一定属于普通 Agent Target 安装副本的 Skill。
- 支持按 `Personal / Plugin / System` 过滤。
- 每个 Skill 显示来源标签，插件 Skill 显示插件名称。
- Plugin 和 System Skill 默认只读，不提供 SkillDock 的安装、卸载或更新操作。
- V0.5.1 修复后的 System 列表能力迁移为 Available 下的 System 筛选，不删除或遗漏原有 System Skill。

`Installed` 继续只表达配置的 Agent Target 中存在副本，不把插件提供的能力混入普通安装数量。

### 5.4 Deduplication

- 相同名称和内容的多个副本合并为一个逻辑 Skill。
- 合并后保留所有来源，不丢失 Personal、Plugin、System 或 Agent 信息。
- 同名但内容不同的 Skill 保持为不同版本，不能静默合并。
- 数量以当前视图中的逻辑 Skill 为准，并允许同一逻辑 Skill 出现在多个来源视图中。

### 5.5 Codex Count Relationship

SkillDock 不承诺与 Codex 的数字始终完全一致，原因包括：

- Codex 可能包含项目级、实验性或运行时注入的 Skill。
- Codex 可能按启用状态、插件命名空间或内部版本执行额外规则。
- SkillDock 会对内容相同的副本去重。

产品目标是覆盖用户可理解和可验证的来源，并在界面中说明统计口径。

## 6. Error Handling

- 来源目录不存在：该来源显示为空，不阻塞其他来源刷新。
- 单个 Skill 无效：跳过并记录可诊断错误，不使整个列表失败。
- 插件清单不可用：保留其他来源结果，并说明插件来源暂时无法读取。
- 同名多版本：分别展示，不自动选择覆盖。
- 来源刷新期间：继续显示上一次成功结果，完成后整体替换。

## 7. Testing

### V0.5.1

- 同一 Skill 同时存在 Library、Codex System 和 Claude 副本时，System 页面仍能显示。
- 从 System 页面打开时使用 System 路径并保持只读。
- 从 Library 页面打开时仍使用 Library 路径和正常操作权限。
- Installed 与 System 数量允许重叠。
- 现有名称 + Hash 去重行为不回退。
- GitHub 仓库存在 `.codex-plugin/plugin.json` 时，导入页显示 Agent Plugin 提示。
- GitHub 仓库存在 `.claude-plugin/plugin.json` 时，导入页显示 Agent Plugin 提示。
- `obra/superpowers` 这类多 Skill 插件包仍显示全部可导入 Skills，并提供批量选择入口。
- Agent Plugin 提示不阻断普通 Skill 导入，也不宣称 SkillDock 已完整安装插件。

### V0.6

- Personal、Plugin、System 和 Agent Copy 来源正确映射。
- 相同内容跨来源合并后保留全部来源标签。
- 同名不同内容保持独立。
- 禁用或旧版本插件 Skill 不进入 Available。
- 缺失目录、无效 Skill 和插件清单失败不会阻断其他来源。
- 所有测试使用临时目录和清单 Fixture，不依赖开发机真实 Home 目录。

## 8. Scope Boundaries

V0.5.1 不包含：

- 新扫描目录。
- Available 页面。
- Codex 插件读取。
- Agent 插件安装、注册、启用、禁用、卸载或升级。

V0.6 不包含：

- 修改或删除 Plugin / System Skill。
- 通过 SkillDock 启用或禁用 Codex 插件。
- 强制让 SkillDock 数量等于 Codex。
- 直接依赖 Codex 未承诺稳定的缓存结构。
