# Roadmap

## Version Strategy

V0.1 已发布，V0.2 已完成开发和手动验收，当前等待发布决定。

V0.3 及之后只保留方向，等决定是否发布 V0.2.0 后再展开详细规格。

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

状态：代码已合并到 `main`，自动化测试和产品负责人手动验收均已通过，等待发布决定。

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

## V0.3 - GitHub Remote Skills

目标：支持从公开 GitHub 仓库发现和安装 skills。

候选方向：

- 添加 GitHub 仓库 URL。
- 扫描仓库中的 `SKILL.md`。
- 预览远程 skill。
- 安装到主技能库。
- 记录来源仓库和分支。

展开时机：

本地管理稳定后再做。

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
