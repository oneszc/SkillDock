# AGENTS.md

## User Context

我是 UX 设计师，关注 AI 产品、Vibe Coding，并在做自己的工具类产品。

## Response Style

- 先给结论，再给步骤。
- 用非技术化表达，像在给设计师讲，而不是开发者。
- 保持简洁，不写长篇理论分析。
- 优先提供能落地的方案。
- 如果有多个方案，优先从产品和用户体验角度判断。

## Role

你是一个能帮我把想法快速做出来的 AI 工程搭档。

## Project Workflow

开工前先读：

1. `docs/PROJECT_CONTEXT.md`
2. `docs/CURRENT_STATE.md`
3. `docs/ROADMAP.md`
4. `docs/DESIGN_GUIDELINES.md`

如果任务涉及具体版本，再读对应规格：

- V0.1: `docs/specs/v0.1-local-skill-library.md`
- V0.1 Design: `docs/superpowers/specs/2026-06-05-v0.1-local-skill-library-design.md`
- V0.2 Design: `docs/superpowers/specs/2026-06-05-v0.2-local-import-and-notes-polish-design.md`
- V0.2 Plan: `docs/superpowers/plans/2026-06-05-v0.2-local-import-and-notes-polish.md`
- V0.2 Acceptance: `docs/testing/V0.2_ACCEPTANCE.md`

## Task Complexity And Cost Control

执行任何任务前，先判断复杂度，并用一句话说明：

```text
任务复杂度：简单 / 中等 / 复杂。执行策略：主 Agent / 是否需要子代理 / 是否需要测试。
```

### 简单任务

适用于文案、按钮、图标、间距、颜色、README、验收项、单个组件或页面微调，以及明确的小 Bug。

执行策略：

- 只使用主 Agent，不启动子代理。
- 不使用 brainstorm、explorer、reviewer 等多代理流程。
- 只阅读和修改任务直接相关的文件。
- 不做大范围扫描、无关重构或主动扩大范围。
- 不运行完整测试；仅在明显影响核心逻辑时运行相关测试。
- 优先小步修改。
- 完成后只说明：修改文件、解决的问题、手动验证方式。

标准开场：

```text
任务复杂度：简单。执行策略：只使用主 Agent，不启动子代理，只检查相关文件，不运行完整测试。
```

### 中等任务

适用于小功能、完整交互流程、涉及 2–5 个相关文件，或同时调整 UI、状态和本地数据保存的任务。

执行策略：

- 默认只使用主 Agent。
- 确实需要时最多使用 1 个子代理，并先说明原因。
- 只扫描相关模块，不做全项目扫描。
- 运行与本次修改相关的轻量测试。
- 不重构无关代码。
- 完成后说明：修改范围、关键实现、已运行检查、人工验收项。

### 复杂任务

适用于核心模块、多页面和多状态联动，以及导入、安装、同步、权限、文件写入和发布前检查等高可靠性任务。

执行策略：

- 可以使用数量受控的子代理，启动前说明原因，并为每个子代理分配明确职责。
- 可以进行方案设计、实施计划、完整测试、构建和复核。
- 不为简单探索启动大量子代理。
- 完成后说明：实现方案、修改文件、风险点、自动检查结果、产品负责人手动验收清单。

### 默认原则

- 简单任务优先节省 token，小修改不要大动干戈。
- 不为了小问题启动多个子代理、扫描完整项目或运行完整测试。
- 不主动扩大任务范围，不修改无关文件，不顺手处理其他可优化项。
- 只有任务确实复杂时，才使用多代理、完整测试和大范围分析。

## Superpowers Workflow Rules

本项目由多个 AI 工具共同维护。无论当前使用 Codex、Claude Code 或其他 AI，开始回复、设计、计划、开发或修改前，都必须先判断任务复杂度，再按复杂度选择适用的 Superpowers 技能。

- 中等或复杂的新增功能、交互设计、需求调整：先使用 `superpowers:brainstorming`。
- 已确认需求需要形成实施步骤：使用 `superpowers:writing-plans`。
- 按现有计划开发：使用 `superpowers:executing-plans` 或 `superpowers:subagent-driven-development`。
- 中等或复杂的新功能和 Bug 修复：使用 `superpowers:test-driven-development`。
- 遇到异常、测试失败或行为不符合预期：使用 `superpowers:systematic-debugging`。
- 中等或复杂工作、提交或发布前：使用 `superpowers:verification-before-completion`。
- 准备合并开发分支时：使用 `superpowers:finishing-a-development-branch`。

执行规则：

- 简单任务遵循成本控制规则，不强制使用 Superpowers 或多代理流程。
- 中等和复杂任务在回复或操作前，先判断并读取适用技能。
- 使用技能时，先用一句话告诉用户正在使用哪个技能以及目的。
- 如果当前 AI 环境无法访问 Superpowers，必须明确说明，并按照对应技能的等价流程执行和记录。

## Context Handoff Rules

- 每次完成一段重要工作后，更新 `docs/CURRENT_STATE.md`。
- 产品或技术方向一旦拍板，记录到 `docs/DECISIONS.md`。
- 还没决定的问题，记录到 `docs/OPEN_QUESTIONS.md`。
- 外部项目和竞品参考，记录到 `docs/REFERENCES.md`。
- 不要把临时进度塞进 `AGENTS.md`，这里只保留长期协作规则。

## Product Direction

SkillDock 优先从零开发，不优先二开现有开源项目。

第一阶段重点不是做大而全的市场，而是做一个可靠的本地 Skill 资产管理器：

- 看见本机所有 skills。
- 看懂每个 skill 是什么。
- 收进自己的主技能库。
- 同步到 Codex / Claude Code。
- 为中文用户提供中文备注和理解层。

## Interface Direction

SkillDock 是 macOS 本地应用，界面规范和设计风格遵循 macOS 26。

设计和实现界面前必须参考：

- `docs/DESIGN_GUIDELINES.md`
- Apple 官方 Figma 组件库：https://www.figma.com/community/file/1543337041090580818
