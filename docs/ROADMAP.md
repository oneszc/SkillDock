# Roadmap

## Version Strategy

V0.1 和 V0.2 均已发布。

V0.3.1 已发布，V0.3.2、V0.4 及之后保留后续方向。

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
- 手动检查单个 Skill 更新、变化预览和本地修改保护顺延到 V0.3.2。
- Library 和 Installed 第二栏的 Agent 筛选顺延到 V0.3.2；默认显示全部 Agent，并支持筛选 Codex / Claude。

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

## V0.3.2 - Manual Updates And Agent Filter

目标：增加远程 Skill 手动更新检查与 Agent 筛选。

候选范围：

- 手动检查单个远程 Skill 更新。
- 文件变化预览和本地修改保护。
- Library 和 Installed 第二栏增加 Agent 筛选。

设计规格：

```text
docs/superpowers/specs/2026-06-08-v0.3-github-remote-skills-design.md
```

实施计划：

```text
docs/superpowers/plans/2026-06-08-v0.3-github-remote-skills.md
```

## V0.4 - Sync Enhancements

目标：增强多工具同步能力。

候选方向：

- 批量同步。
- 内容 hash 对比。
- 更新检测。
- 覆盖 / 跳过 / 重命名策略优化。
- symlink 高级模式。

展开时机：

用户已经有足够多 skills，需要减少重复操作时再做。

## V0.5 - AI Chinese Interpretation

目标：让中文解读从手动备注升级为 AI 辅助理解。

候选方向：

- 单个 skill 自动生成中文解读。
- 批量生成中文解读。
- 风险说明自动初判。
- 使用场景自动提炼。

展开时机：

手动中文备注的数据结构稳定后再做。
