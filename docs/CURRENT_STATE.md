# Current State

## Current Stage

V0.1 产品需求收敛与项目基础文档搭建。

## Current Goal

先做一个本地 Skill 资产台账：

- 扫描本机 skills。
- 查看 skill 内容。
- 收进主技能库。
- 同步到 Codex / Claude Code。
- 手动维护中文备注。

## Recently Completed

- 已阅读原始 PRD：`/Users/macbookpro/Downloads/SkillDock_PRD.md`。
- 已确认当前仓库基本为空，适合从零开发。
- 已确认第一版不建议二开现有项目。
- 已参考本机数据痕迹：
  - `~/.codex/skills`
  - `~/.claude/skills`
  - `~/.cc-switch`
  - `~/.skillsmanager`
  - `~/Library/Application Support/Skillz`

## Next Steps

1. 确认 V0.1 需求规格。
2. 确认技术栈。
3. 创建项目基础结构。
4. 开始实现本地扫描和详情查看。

## Current Product Decisions

- V0.1 先不做 GitHub 远程安装。
- V0.1 先不做 AI 自动生成中文解读。
- V0.1 先使用 copy folder 同步，不默认使用 symlink。
- Codex / Claude 的系统 skills 默认只读展示。
- 主技能库默认路径为 `~/AI-Skills`。

## Handoff Note

两台电脑协作时，开始工作前先读这个文件；结束工作前更新这个文件。

