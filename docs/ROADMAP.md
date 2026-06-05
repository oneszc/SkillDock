# Roadmap

## Version Strategy

先把 V0.1 做小、做稳、做完整，再根据真实使用感受展开 V0.2。

V0.2 及之后现在只保留方向，不写过细规格，避免过早锁死设计。

## V0.1 - Local Skill Library

目标：可靠读取和管理本机 skills。

必须完成：

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

候选方向：

- 拖拽文件夹导入。
- 更完整的导入预览。
- 中文备注编辑体验优化。
- 标签管理。
- 风险提示优化。
- 更好的搜索和筛选。

展开时机：

V0.1 可用后，根据实际使用体验再写 V0.2 规格。

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

