# Decisions

## 2026-06-05 - Build From Scratch

决定：SkillDock 优先从零开发，不优先二开现有开源项目。

原因：

- 现有项目各有可参考点，但产品重心不同。
- SkillDock 的核心是个人 Skill 资产管理和中文理解层。
- 从零开发更容易保持产品边界清晰。

## 2026-06-05 - V0.1 Scope

决定：V0.1 聚焦本地 Skill 管理，不做 GitHub 远程安装和 AI 自动中文解读。

原因：

- 第一版最重要的是可靠扫描、查看、收纳、同步。
- 远程安装和 AI 解读会显著增加复杂度。
- 先验证本地工作流，再扩展远程和智能能力。

## 2026-06-05 - Copy First, Symlink Later

决定：V0.1 使用复制文件夹同步 skills，不默认使用 symlink。

原因：

- 复制更直观、风险更低。
- 用户更容易理解。
- symlink 容易带来权限、路径迁移和误删问题，适合作为后续高级模式。

## 2026-06-05 - Manual Chinese Notes First

决定：V0.1 中文解读先做手动备注，不接 AI 自动生成。

原因：

- 手动备注更容易控制质量。
- 数据结构先稳定下来。
- AI 自动生成可以在后续版本基于同一套字段增强。

## 2026-06-05 - Follow macOS 26 Interface Guidelines

决定：SkillDock 的界面规范和设计风格遵循 macOS 26，并以 Apple 官方 Figma 组件库作为主要设计参考。

参考链接：

```text
https://www.figma.com/community/file/1543337041090580818
```

原因：

- SkillDock 是 macOS 本地工具，原生感比强品牌视觉更重要。
- 用户会频繁查看、筛选和同步 skills，界面需要稳定、克制、清晰。
- 采用系统组件逻辑，可以减少设计和实现分歧。

## 2026-06-05 - Use SF Symbols For All Interface Icons

决定：SkillDock 应用内所有常规界面图标统一使用 Apple 官方 SF Symbols。

参考链接：

```text
https://developer.apple.com/cn/sf-symbols/
```

实现规则：

- SwiftUI 使用 `Image(systemName:)` 或 `Label(_:systemImage:)`。
- 不引入第三方图标库，不为常规操作自绘图标。
- 只有应用图标、品牌 Logo 或 SF Symbols 无法表达的 SkillDock 专属概念允许单独设计。

原因：

- 保持 macOS 原生体验和视觉一致性。
- 系统图标更容易被用户理解。
- 自动适配系统字号、强调状态和无障碍表现。

## 2026-06-05 - SwiftUI and macOS 26

决定：V0.1 使用 SwiftUI 原生开发，最低支持 macOS 26。

原因：

- 最符合 SkillDock 的原生 macOS 工具定位。
- 可以直接使用最新系统控件和交互。
- 减少旧系统兼容成本，加快 V0.1 验证。

## 2026-06-05 - GitHub Release Distribution

决定：V0.1 通过 GitHub Release 或本地安装发布，不上 Mac App Store。

原因：

- 更适合快速验证。
- 访问 Codex 和 Claude 隐藏目录更直接。
- 暂时避免商店审核和沙盒限制。

## 2026-06-05 - Finder-style Three-column Layout

决定：V0.1 主界面采用 Finder 式三栏布局。

结构：

- 左栏：一级导航。
- 中栏：Skill 列表。
- 右栏：Skill 详情和操作。

原因：

- 符合 macOS 原生工具使用习惯。
- 适合快速浏览大量 Skills。
- 列表和详情可以同时查看。

## 2026-06-05 - Chinese Understanding Never Modifies Skills

决定：中文备注和未来 AI 中文总结完全独立于原始 Skill，SkillDock 永远不修改原始 Skill 内容。

保存位置：

```text
~/Library/Application Support/SkillDock/
```

原因：

- 中文理解只服务 SkillDock 使用者。
- 保证导入、安装和同步的是原始 Skill。
- 避免污染第三方仓库和用户自制 Skill。

## 2026-06-05 - V0.1 Uses Installation Status and Manual Refresh

决定：

- V0.1 只展示已安装 / 未安装状态，不引入启用 / 禁用状态。
- V0.1 在启动和用户手动刷新时扫描，不做实时文件监听。

原因：

- 保持第一版状态模型简单清楚。
- 避免不同 AI 工具对启用状态支持不一致。
- 手动刷新更容易验证和排查扫描结果。

## 2026-06-05 - Preserve Original Skill Identity

决定：

- Skill 原始英文名称始终作为列表和详情页主名称。
- 不提供中文名称修改。
- 中文描述只作为辅助理解信息，不替换或修改原始 Skill。

原因：

- 保留原 Skill 的身份标志，方便用户记忆、搜索和跨工具识别。
- 避免中文名称造成同一 Skill 在不同位置显示不一致。

## 2026-06-05 - Settings Uses A Dedicated Two-column Layout

决定：

- 普通 Skill 浏览继续使用 Finder 式三栏。
- 进入 Settings 后使用“设置分类 + 设置内容”双栏，不显示 Skill 列表中间栏。
- Settings 当前只有 General 分类，后续新增设置时再扩展分类。

原因：

- 设置状态下的 Skill 列表没有作用，会形成明显空白栏。
- 双栏设置结构更接近 macOS 系统应用，信息关系更清楚。

## 2026-06-05 - Support System, Light, And Dark Appearance

决定：SkillDock 提供 System、Light、Dark 三种外观模式，并保存用户选择。

原因：

- 跟随系统保持默认原生体验。
- 明确的浅色和深色选择方便用户按使用环境调整。
- 外观选择属于应用级偏好，应立即生效并独立持久化。

## 2026-06-08 - V0.3.0 Releases GitHub Remote Import First

决定：

- V0.3.0 发布公开 GitHub 仓库导入、Git Clone / ZIP、批量选择和来源记录。
- 手动检查远程更新、变化预览和本地修改保护顺延到 V0.3.1。

原因：

- 当前远程导入流程已经形成可独立使用和验收的完整能力。
- 将更新能力单独迭代，可以避免 V0.3.0 发布范围含糊。

## 2026-06-08 - All AI Collaborators Follow Superpowers Workflows

决定：

- SkillDock 由多个 AI 工具共同维护，Superpowers 工作流对 Codex、Claude Code 和其他接手项目的 AI 同样生效。
- 新增功能、交互和需求调整先 brainstorming；开发使用计划与 TDD；异常使用系统化调试；完成、提交和发布前必须验证。
- 当前环境无法访问 Superpowers 时，AI 必须明确说明，并执行对应的等价流程。

原因：

- 避免不同 AI 接手项目时采用不一致的设计和开发流程。
- 确保方案讨论、小改动、开发、测试和发布都有清晰的质量门槛。

## 2026-06-08 - Agent Filter Moves To V0.3.1

决定：

- 当前版本不开发 Agent 筛选。
- V0.3.1 在 Library 和 Installed 的第二栏增加 Agent 筛选。
- 默认显示全部 Agent，首批支持筛选 Codex 和 Claude。
- System 页面暂不显示 Agent 筛选。

原因：

- 当前版本先收口已完成的视觉和阅读体验调整。
- Agent 筛选属于独立的信息架构能力，放入下个版本更适合单独设计和验收。
