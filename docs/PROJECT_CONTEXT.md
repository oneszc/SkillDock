# SkillDock Project Context

## One-line Product

SkillDock 是一个 macOS 上的 AI Skill 管理器，帮助用户统一查看、导入、管理和同步 Codex / Claude Code 等 AI 编程工具的 Skills。

## Core Positioning

SkillDock 不替代 Codex 官方 Skills 页面，也不做官方 Skill 市场。

它解决的是用户自己的 Skill 资产管理问题：

- Skills 分散在不同工具目录。
- 英文 skill 很难快速判断用途。
- 自制 skill 缺少统一收藏和同步方式。
- 多台电脑、多工具之间容易版本混乱。

## Target Users

- 同时使用 Codex、Claude Code、Gemini CLI、OpenCode 等 AI 工具的人。
- 会自己写 Skill，并希望沉淀个人工作流的人。
- 希望用中文快速理解英文 Skill 的中文用户。

## Product Value

SkillDock 的核心价值是：

1. 统一管理本地所有 AI Skills。
2. 查看 Skill 文件结构和 `SKILL.md` 原文。
3. 把外部 skill 收进自己的主技能库。
4. 同步到 Codex / Claude Code。
5. 在不修改原始 Skill 的前提下，提供可切换查看的中文译文。

## Main Concepts

### Main Library

用户自己的主技能库，默认路径：

```text
~/AI-Skills
```

主技能库是用户真正维护的源头。

### Tool Skill Directories

不同 AI 工具自己的运行目录：

```text
~/.codex/skills
~/.claude/skills
```

这些目录是安装目标，不是资产源头。

### Valid Skill

只要某个文件夹包含 `SKILL.md`，就识别为一个 skill。

常见结构：

```text
my-skill/
  SKILL.md
  scripts/
  references/
  assets/
  examples/
```

## Product Principle

第一版优先做稳定、清楚、可控。

先让用户放心管理本地 skills，再逐步做远程安装、AI 自动解读、批量同步和更新检测。

## Design Principle

SkillDock 是 macOS 本地工具，界面应遵循 macOS 26 的系统规范和 Apple 官方 Figma 组件库。

设计重点：

- 像一个原生 macOS 工具，而不是网页后台。
- 信息密度适中，方便长期管理和频繁查看。
- 优先使用系统常见结构：侧边栏、列表、详情面板、工具栏、设置页。
- 控件、间距、层级、状态表达尽量贴近 Apple 官方组件。
- 应用内所有常规功能图标使用 Apple 官方 SF Symbols，不引入第三方图标库。

设计参考：

```text
https://www.figma.com/community/file/1543337041090580818
https://developer.apple.com/cn/sf-symbols/
```
