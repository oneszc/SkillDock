<div align="center">

<img src="Resources/SkillDock-AppIcon.png" width="128" alt="SkillDock app icon">

# SkillDock

### A native macOS workspace for your local AI Skills

统一查看、理解、整理和同步 Codex / Claude Code / 自定义 Agent Skills

Keep your personal Skill library clear, local, and under your control.

<p>
  <img src="https://img.shields.io/badge/version-v0.5.1_release-0A84FF?style=flat-square" alt="Version v0.5.1 release">
  <img src="https://img.shields.io/badge/v0.5.1-latest-5856D6?style=flat-square" alt="V0.5.1 latest">
  <img src="https://img.shields.io/badge/macOS-26%2B-111111?style=flat-square&logo=apple&logoColor=white" alt="macOS 26 or later">
  <img src="https://img.shields.io/badge/SwiftUI-native-F05138?style=flat-square&logo=swift&logoColor=white" alt="Native SwiftUI">
  <img src="https://img.shields.io/badge/local--first-private-34C759?style=flat-square" alt="Local-first and private">
  <img src="https://img.shields.io/badge/Codex-supported-111111?style=flat-square" alt="Codex supported">
  <img src="https://img.shields.io/badge/Claude_Code-supported-D97757?style=flat-square" alt="Claude Code supported">
</p>

[下载最新版](https://github.com/oneszc/SkillDock/releases/latest) · [功能介绍](#主要能力) · [安装与运行](#安装与运行) · [开发文档](docs/CURRENT_STATE.md)

</div>

---

## SkillDock 是什么

SkillDock 是一个原生 macOS AI Skill 管理器。

它把散落在不同工具目录中的 Skills 汇总到一个清晰的工作区，让你快速判断每个 Skill 的用途、查看原始内容、生成独立中文译文，并安装到 Codex、Claude Code 或自定义 Agent 目录。

SkillDock 不修改原始 Skill，也不试图成为 Skill 市场。它服务的是你自己的本地 Skill 资产。

## 主要能力

| 能力 | 说明 |
| --- | --- |
| 统一浏览 | 扫描主技能库、Codex 和 Claude Code 中的 Skills |
| 快速理解 | 查看原始名称、英文描述、`SKILL.md` 和文件结构，并按需生成中文译文 |
| 安全导入 | 导入前预览文件、脚本风险和同名冲突 |
| GitHub 导入 | 从公开 GitHub 仓库发现多个 Skills，并批量导入主技能库 |
| 手动更新 | 对 GitHub 导入的 Skill 手动检查更新、预览文件变化并确认替换 |
| AI 中文译文 | 使用 DeepSeek 手动生成 Skill 介绍和完整 `SKILL.md` 中文译文 |
| 多工具安装 | 使用 Agent Logo、复选框和 Agent 筛选管理 Codex / Claude Code / 自定义 Agent 安装状态 |
| 安全卸载 | 仅移除所选 Agent 的精确 Skill 副本，保护主技能库和其他副本 |
| 原始内容保护 | API Key 存入 macOS Keychain，译文独立保存，不修改原始 Skill |

## 产品体验

- Finder 式三栏结构，适合持续浏览和管理大量 Skills。
- 列表优先显示原始 Skill 名称，保留跨工具识别的一致性。
- 中文译文只作为辅助阅读内容，不替代原始 Skill 名称和身份。
- 支持 System、Light、Dark 三种外观模式。
- Settings 使用 macOS 标准独立偏好窗口，可通过 `⌘,` 打开。
- 所有常规界面图标使用 Apple 官方 SF Symbols。

## 默认目录

SkillDock 默认扫描以下位置：

```text
~/AI-Skills
~/.codex/skills
~/.claude/skills
```

`~/AI-Skills` 是用户维护的主技能库；Codex 和 Claude Code 目录作为默认安装目标。V0.4.0 开始，Settings 中可添加并启用更多自定义 Agent Targets。

## 安装与运行

### 下载应用

1. 前往 [GitHub Releases](https://github.com/oneszc/SkillDock/releases/latest)。
2. 下载 `SkillDock-0.5.1.zip`。
3. 解压并打开 `SkillDock.app`。

> 当前版本使用本地临时签名，尚未进行 Apple Developer ID 签名与公证。

### 本地开发

环境要求：

- macOS 26+
- Xcode 26+
- Swift 6.2+

```bash
git clone https://github.com/oneszc/SkillDock.git
cd SkillDock
swift test
./scripts/run-app.sh
```

`run-app.sh` 会构建并打开完整的 `SkillDock.app`，确保应用名称、图标和 Bundle 设置正确。

## 隐私与数据

SkillDock 采用 local-first 方式管理 Skill。只有用户主动生成译文时，当前 `SKILL.md` 才会发送给 DeepSeek。

AI 译文保存在：

```text
~/Library/Application Support/SkillDock/
```

DeepSeek API Key 保存在 macOS Keychain；译文始终与原始 Skill 分离，不会污染第三方仓库或用户自制 Skill。

## 当前状态

- 最新发布版本：[`v0.5.1`](https://github.com/oneszc/SkillDock/releases/tag/v0.5.1)
- 自动化测试：148 项通过
- 当前发布版本：V0.5.1，修复 System Skill 分类并补充 GitHub Agent Plugin 导入提示
- V0.5.1 待产品负责人验收
- 后续方向：批量同步、多工具同步增强、AI 中文解读

查看完整进度：

- [当前状态](docs/CURRENT_STATE.md)
- [产品路线图](docs/ROADMAP.md)
- [产品决策](docs/DECISIONS.md)

## 设计与开发原则

- 从零开发，不依赖现有 Skill 管理器二次开发。
- 优先使用 SwiftUI 官方组件和 macOS 系统默认行为。
- 界面遵循 macOS 26 风格，并参考 Apple 官方组件库。
- 功能图标统一使用 SF Symbols。
- 第一优先级是稳定、清楚、可控。
