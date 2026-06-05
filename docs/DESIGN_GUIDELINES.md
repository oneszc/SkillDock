# Design Guidelines

## Design Baseline

SkillDock 的界面规范和设计风格遵循 macOS 26。

主要参考：

```text
Apple official Figma component library
https://www.figma.com/community/file/1543337041090580818
```

## Product Feel

SkillDock 应该像一个原生 macOS 工具，而不是网页 SaaS 后台。

关键词：

- 清楚。
- 克制。
- 稳定。
- 信息密度适中。
- 适合长期管理。
- 适合频繁查看和同步。

## Layout Principles

优先使用 macOS 常见结构：

- Sidebar：一级导航，例如 Library、Installed、Settings。
- List：skills 列表，支持搜索、筛选和状态展示。
- Detail Pane：展示 `SKILL.md`、文件树、中文备注和安装状态。
- Toolbar：放刷新、导入、同步、打开文件夹等高频操作。
- Settings Form：集中管理路径、显示选项、同步策略。

避免：

- 营销式首页。
- 大面积装饰图形。
- 过度卡片化。
- 网页后台式复杂表格。
- 强烈品牌色压过系统界面。

## Component Principles

优先复用或模拟 macOS 26 系统组件逻辑：

- 系统按钮。
- 分段控制。
- 搜索框。
- 侧边栏。
- 列表行。
- 弹窗和确认框。
- 设置项表单。
- 状态标签。
- 工具栏图标按钮。

状态表达要清楚：

- 已安装 / 未安装。
- 只读 / 可编辑。
- 系统 skill / 个人 skill。
- 有中文备注 / 无中文备注。
- 有 scripts 风险提示。

## Visual Style

整体视觉应保持轻量，不追求强烈装饰。

建议：

- 使用系统背景和分隔层级。
- 控件圆角、间距、字号贴近 macOS 26。
- 保留足够留白，但不要做成低信息密度展示页。
- 中文说明要短，优先帮助用户判断。
- 风险提示要明确，但不要制造焦虑。

## SkillDock-specific UI Rules

列表页优先帮助用户快速判断：

- 这个 skill 是什么。
- 来自哪里。
- 是否已安装到 Codex / Claude。
- 是否有中文备注。
- 是否可能有风险。

详情页优先帮助用户完成动作：

- 查看 `SKILL.md`。
- 查看文件结构。
- 编辑中文备注。
- Reveal in Finder。
- Copy Path。
- 安装 / 同步到目标工具。

## Figma Usage

后续做 Figma 设计稿时：

- 优先使用 Apple 官方组件库作为基础。
- 不从零发明基础控件。
- 如果需要自定义组件，先说明它解决了哪个 SkillDock 特有问题。
- 设计稿和实现要保持页面结构一致，避免 Figma 好看但开发落地困难。

