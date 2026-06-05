# Current State

## Current Stage

V0.1 设计与实现计划已确认，准备开始 SwiftUI 开发。

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
- 已新增设计规则：界面规范和设计风格遵循 macOS 26，并参考 Apple 官方 Figma 组件库。
- 已确认 SwiftUI 原生开发，最低支持 macOS 26。
- 已确认通过 GitHub Release / 本地安装发布。
- 已确认 Finder 式三栏主界面。
- 已确认中文备注和未来 AI 总结完全独立，不修改原始 Skill。
- 已参考本机数据痕迹：
  - `~/.codex/skills`
  - `~/.claude/skills`
  - `~/.cc-switch`
  - `~/.skillsmanager`
  - `~/Library/Application Support/Skillz`

## Next Steps

1. 安装完整 Xcode，并切换 `xcode-select` 到 Xcode。
2. 按实现计划 Task 1 创建 Swift Package 和 SwiftUI 应用基础结构。
3. 使用 TDD 实现本地 Skill 解析和扫描。
4. 每完成一个 Task 后 commit 并 push。

## Current Product Decisions

- V0.1 先不做 GitHub 远程安装。
- V0.1 先不做 AI 自动生成中文解读。
- V0.1 先使用 copy folder 同步，不默认使用 symlink。
- Codex / Claude 的系统 skills 默认只读展示。
- 主技能库默认路径为 `~/AI-Skills`。
- 界面规范和设计风格遵循 macOS 26，参考 Apple 官方 Figma 组件库。
- V0.1 使用 SwiftUI 原生开发，最低支持 macOS 26。
- V0.1 使用 GitHub Release / 本地安装，不上 Mac App Store。
- 主界面采用 Finder 式三栏布局。
- 中文理解数据保存在 SkillDock 应用数据目录，不写入任何 Skill 文件夹。

## Current Environment Note

- Swift 6.3.1 已安装，目标为 macOS 26。
- 当前仅启用 Command Line Tools。
- `xcodebuild` 暂不可用，需要安装完整 Xcode。
- 实现计划：`docs/superpowers/plans/2026-06-05-v0.1-local-skill-library.md`。

## Handoff Note

两台电脑协作时，开始工作前先读这个文件；结束工作前更新这个文件。
