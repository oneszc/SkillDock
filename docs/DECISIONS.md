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
