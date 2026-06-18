# Roadmap

## Version Strategy

V0.1 和 V0.2 均已发布。

V0.3.3 已完成并发布 GitHub Release。V0.4.0 已完成、验收并发布；V0.4.1 维护更新已发布 GitHub Release。

## V0.1 - Local Skill Library

目标：可靠读取和管理本机 skills。

状态：已完成并发布 GitHub V0.1.0 Release。

已完成：

- 设置主技能库路径。
- 扫描 `~/AI-Skills`。
- 扫描 `~/.codex/skills`。
- 扫描 `~/.claude/skills`。
- 识别包含 `SKILL.md` 的文件夹。
- 查看 `SKILL.md` 原文。
- 查看文件结构。
- 导入本地 skill 文件夹到主技能库。
- 安装到 Codex。
- 安装到 Claude Code。
- 同名冲突处理。
- 手动编辑中文备注。
- 中文搜索。
- Reveal in Finder。
- Copy Path。

暂不做：

- GitHub 远程安装。
- AI 自动生成中文解读。
- 批量同步。
- symlink 高级模式。
- 自动更新检测。
- zip 导入。
- 内置代码编辑器。

规格文件：

```text
docs/specs/v0.1-local-skill-library.md
```

## V0.2 - Local Import and Notes Polish

目标：让自制 skill 的导入、备注和管理更顺。

状态：已完成并发布 GitHub V0.2.0 Release。

确认范围：

- Skill 列表支持拖拽单个文件夹导入。
- 拖拽或选择文件夹后显示导入预览模态窗口。
- 预览名称、说明、文件结构、脚本风险和同名冲突。
- 同名冲突默认跳过，可主动替换或重命名。
- 中文备注使用单页分组表单。
- 标签和适用场景支持已有建议与自由新增。
- 中文备注停止输入约 1 秒后自动保存。
- 显示保存状态。
- 列表和详情页始终显示原始 Skill 名称。
- 列表优先显示中文描述，没有时显示英文描述。
- 详情页顶部显示原始名称、英文描述和可选中文描述。
- 移除重复的 Overview，详情页默认打开 `SKILL.md`。

暂不做：

- 高级搜索和筛选。
- 批量导入。
- GitHub 远程安装。
- AI 自动中文解读。

设计规格：

```text
docs/superpowers/specs/2026-06-05-v0.2-local-import-and-notes-polish-design.md
```

## V0.2.1 - Visual Polish

目标：提升长期浏览和阅读时的舒适度。

状态：已完成并发布 GitHub V0.2.1 Release。

发布状态：产品负责人视觉验收已通过。

确认范围：

- 放大列表标题、副标题、图标和行高。
- 提升详情页标题与描述层级。
- 增加主要页面内容留白。
- 限制长文阅读宽度。
- 保留 Finder 式三栏效率，不改为 App Store 营销卡片。
- Settings 使用“设置分类 + 设置内容”双栏，不显示空白 Skill 列表。
- 增加 System、Light、Dark 外观模式选择并持久化。
- 替换应用图标并接入自动打包与验证流程。

## V0.3 - GitHub Remote Skills

目标：支持从公开 GitHub 仓库发现和安装 skills。

状态：V0.3.0 已完成并发布 GitHub Release。

确认范围：

- 支持公开仓库，无需 GitHub 登录。
- 同时支持 Git Clone 和 ZIP 下载。
- 支持仓库链接和仓库内 Skill 文件夹链接。
- 扫描仓库内多个 Skills，并支持多选一次导入。
- 远程 Skill 默认只进入主技能库，不自动安装到智能体。
- 保存仓库、分支、Skill 路径、提交版本和内容 Hash。
- 手动检查单个 Skill 更新、变化预览和本地修改保护已在 V0.3.3 完成。
- Library 和 Installed 第二栏的 Agent 筛选已在 V0.3.3 完成；默认显示全部 Agent，并支持筛选 Codex / Claude。

## V0.3.1 - Agent Install Management

目标：让用户清楚查看并安全管理 Skill 在 Codex / Claude Code 中的安装状态。

状态：已完成并发布 GitHub Release。

确认范围：

- 详情页顶部使用 Agent Logo 表示安装状态。
- 彩色 Logo 表示已安装，独立灰色 Logo 表示未安装。
- 点击未安装 Logo 可发起安装。
- Install Targets 使用复选框、Agent Logo 和名称管理安装与卸载。
- 卸载前必须确认，只移除所选 Agent 的精确副本。
- 保护主技能库、其他 Agent 副本、中文备注和 System Skill。

## V0.3.2 - Confirmation Hotfix

目标：修复卸载与覆盖安装确认弹窗关闭后操作请求丢失的问题。

状态：已完成并发布 GitHub Release。

确认范围：

- 点击卸载确认 `Remove` 后真实删除所选 Agent 副本。
- 删除完成后刷新安装状态与复选框。
- 修复使用相同确认结构的覆盖安装操作。
- 增加 App 层回归测试。

## V0.3.3 - Manual Updates And Agent Filter

目标：增加远程 Skill 手动更新检查与 Agent 筛选。

状态：已完成并发布 GitHub Release。

确认范围：

- 手动检查单个远程 Skill 更新。
- 文件变化预览和本地修改保护。
- 明确替换确认，不自动合并、不后台自动更新。
- Library 和 Installed 第二栏增加 Agent 筛选。

已验证：

- `swift test`：103 项全部通过。
- `dist/SkillDock-0.3.3.zip` 已生成并独立解压验证通过。

设计规格：

```text
docs/superpowers/specs/2026-06-08-v0.3-github-remote-skills-design.md
```

实施计划：

```text
docs/superpowers/plans/2026-06-16-v0.3.3-manual-updates-and-agent-filter.md
```

## V0.4 - Multi-Agent Targets

目标：让 SkillDock 的安装、扫描和筛选能力从固定 Codex / Claude 扩展为可配置 Agent Targets。

状态：V0.4.0 已完成、已通过产品负责人验收，并已发布 GitHub Release。

V0.4.0 确认方向：

已完成：

- 将 Codex / Claude 写死逻辑改为动态 Agent Targets。
- Codex / Claude 默认启用，旧设置可迁移。
- Settings 支持启用 / 禁用 Agent Target 和编辑路径。
- Settings 支持添加常用 Agent 建议项，默认禁用。
- Library / Installed 筛选读取动态 Agent Target。
- 详情页顶部 Agent Logo 和 Install Targets 动态渲染。
- Skill 列表行优先显示 Codex / Claude，其他已安装 Agent 折叠为 `+N`。
- 安装 / 卸载逻辑支持自定义 Agent 目标。
- Grok、Gemini、OpenCode、Antigravity、Hermes 使用产品负责人提供的彩色和灰色品牌 logo。
- V0.4.0 发布后已补充列表 Agent 展示修复：已安装 Agent 数量小于等于 2 个时直接展示 Logo，超过 2 个才优先 Codex / Claude 并折叠其余为 `+N`。
- V0.4.0 发布后已补充 GitHub 克隆 Skill 的更新误判修复：`.git` 元数据不参与内容 Hash 和更新 diff，避免无真实内容变化时误报本地修改。

V0.4.1 发布范围：

- 收录列表 Agent 展示规则修复。
- 收录 GitHub 克隆 Skill 的 `.git` 元数据更新误判修复。
- 不包含 V0.5 AI 中文译文功能。

已验证：

- `swift test`：111 项全部通过。
- `dist/SkillDock-0.4.0.zip` 已生成并独立解压验证通过。
- `swift test --filter SkillRowInstallBadgesTests`：3 项全部通过。
- `swift test --filter RemoteUpdateServiceTests`：7 项全部通过。
- `swift test --filter SkillMarkdownParserTests`：6 项全部通过。
- V0.4.1 发布前完整验证：`swift test` 116 项全部通过，`dist/SkillDock-0.4.1.zip` 已独立解压验证通过。

后续候选方向：

- V0.4.1 批量安装 / 批量同步。
- V0.4.2 多 Agent 同步 review table。
- symlink 高级模式继续后置。

展开时机：

用户已经有足够多 skills，需要减少重复操作时再做。

实施计划：

```text
docs/superpowers/plans/2026-06-16-v0.4-multi-agent-targets.md
```

## V0.5 - AI Chinese Interpretation

目标：使用 DeepSeek 为单个 Skill 生成可切换查看的中文译文。

状态：功能开发和自动化验证已完成，等待产品负责人按 V0.5 验收清单测试真实 API 与界面。

V0.5 确认范围：

- Settings 新增 `AI Translation` 分类。
- 第一版界面只开放 DeepSeek，配置 API Key、模型和连接测试。
- 底层使用可扩展 Translation Provider 接口，不把 DeepSeek 写死在详情页、存储或翻译状态逻辑中。
- API Key 使用 macOS Keychain 保存。
- 详情页删除 `Chinese Notes`，内容导航调整为 `SKILL.md / Files / Install`。
- `SKILL.md` 页面在内容导航右侧增加独立的 `原文 / 译文` 切换。
- Skill 名称始终显示原文，不参与翻译。
- 译文同时覆盖顶部介绍文案和完整 `SKILL.md` 正文。
- 译文只读，支持手动生成、重新生成和内容变化后的失效提示。
- 译文保存在 SkillDock 应用数据目录，不修改原始 Skill。
- 旧中文备注数据保留，但不再展示或参与新译文生成。

V0.5 暂不包含：

- 批量或后台自动翻译。
- 手动编辑译文。
- 其他模型供应商的界面接入、自定义 API 地址和自定义 Prompt。
- 翻译 Skill 名称或 `SKILL.md` 之外的文件。
- AI 风险评级、标签和使用建议扩写。

设计规格：

```text
docs/superpowers/specs/2026-06-18-v0.5-deepseek-skill-translation-design.md
```
