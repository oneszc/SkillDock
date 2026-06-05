# Current State

## Current Stage

V0.1 核心功能、手动验收和本地应用打包已完成。

## Current Goal

开始规划 V0.2 日常可用性优化。

- 扫描本机 skills。
- 查看 skill 内容。
- 收进主技能库。
- 同步到 Codex / Claude Code。
- 手动维护中文备注。

## Recently Completed

- 已完成 SwiftUI 原生三栏界面。
- 已完成 Library、Codex、Claude Skill 扫描、合并和搜索。
- 已完成 `SKILL.md` 与文件列表查看。
- 已完成独立中文备注编辑和保存。
- 已完成本地导入、Codex / Claude 安装和冲突保护。
- 已完成 Finder 定位、复制路径和设置编辑。
- 已安装并切换到 Xcode 26.5。
- 自动化测试共 35 项，全部通过。
- 产品负责人已确认手动测试没有问题。
- 已生成并实际启动 `dist/SkillDock.app`。
- 已生成并解压验证 `dist/SkillDock-0.1.0.zip`。
- 当前应用使用临时本地签名，尚未进行 Apple Developer ID 签名和公证。
- `codex/v0.1-development` 已合并到 `main`。
- GitHub V0.1.0 Release 已发布：
  - `https://github.com/oneszc/SkillDock/releases/tag/v0.1.0`
  - Release ZIP 已重新下载并通过 SHA-256 校验。

## Next Steps

1. 编写 V0.2 需求规格。
2. 决定是否配置 Apple Developer ID，用于后续公开版本签名与公证。
3. 根据 V0.2 规格开始开发。

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
- 应用内所有常规界面图标统一使用 Apple 官方 SF Symbols。

## Current Environment Note

- Xcode 26.5 已安装并选中。
- Swift 6.3.2 已安装。
- `swift test`：35 项全部通过。
- `swift build`：通过。
- 实现计划：`docs/superpowers/plans/2026-06-05-v0.1-local-skill-library.md`。

## Handoff Note

当前稳定分支：`main`。

第二台电脑的下一步：

```bash
git fetch origin
git switch main
git pull
swift test
swift run SkillDockApp
```

开始工作前先读本文件；结束工作前更新本文件并 push。
