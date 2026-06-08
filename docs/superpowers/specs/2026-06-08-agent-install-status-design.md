# Agent Install Status and Targets Design

## Goal

让 Skill 详情页只表达“哪些 Agent 已安装这个 Skill”，不再展示“这个 Skill 来自哪个 Agent”。同时使用 Agent Logo 提升识别效率，并让 Install Targets 成为明确的安装与卸载管理页面。

## Confirmed Product Rules

- 详情页顶部不展示 Skill 来源，例如 `Library`、`Codex`、`Claude` 来源文字或文件夹图标。
- 详情页顶部只展示当前支持的 Agent Logo：Codex、Claude。
- 彩色 Logo 表示该 Agent 已安装当前 Skill。
- 灰色 Logo 表示该 Agent 未安装当前 Skill。
- 点击灰色 Logo，直接发起安装到对应 Agent。
- 彩色 Logo 只表达已安装状态，不触发重装或卸载。
- System Skill 继续显示 `Read-only`，所有安装和卸载操作禁用。

## Detail Header

在英文描述、中文描述之后展示紧凑 Agent Logo 状态栏：

```text
[Codex 彩色 Logo]  [Claude 灰色 Logo]  [Read-only，仅系统 Skill]
```

交互：

- Logo 使用约 20–22pt 的稳定点击区域。
- 悬停提示必须显示 Agent 名称与状态：
  - `Installed in Codex`
  - `Install to Claude`
- 点击灰色 Logo复用现有安装冲突规则；需要覆盖时继续显示确认。
- 安装成功后刷新 Library，Logo 立即由灰色变为彩色。
- 不在状态栏显示 Agent 名称、来源名称、勾选图标或额外状态文字。

## Install Targets

保留现有 Install Targets 页面和列表结构，改成：

```text
[复选框] [Agent Logo] Codex
[复选框] [Agent Logo] Claude
```

规则：

- 勾选表示当前 Skill 已安装到该 Agent。
- 未勾选表示尚未安装。
- 勾选未安装 Agent，发起安装。
- 取消已安装 Agent，先弹出卸载确认框；用户确认后才删除该 Agent 目录中的 Skill 副本。
- 取消确认或关闭弹窗时，不修改任何文件。
- 卸载只删除对应 Agent 的安装副本，不删除 Library、其他 Agent 副本或中文备注。
- System Skill 的所有复选框禁用。
- 列表不再显示 `Install` / `Reinstall` 按钮。

## Agent Logos

使用用户提供的文件：

- `/Users/macbookpro/Desktop/codex.svg`
- `/Users/macbookpro/Desktop/claude.svg`

实施时复制到项目资源目录，项目不能依赖桌面文件。

显示规则：

- 使用原始彩色 Logo 表示已安装。
- 使用降低透明度并灰度化的 Logo 表示未安装。
- Logo 保持原始比例，不裁切、不重新绘制。
- Agent Logo 属于品牌标识，是项目 SF Symbols 常规功能图标规则的允许例外。

## Uninstall Safety

新增卸载能力时必须满足：

- 只允许删除配置的 Codex / Claude 安装目录下，与当前 Skill 文件夹同名的目标目录。
- 删除前确认目标路径位于对应 Agent 根目录内。
- 不允许删除 System Skill。
- 不允许通过卸载操作删除主技能库目录。
- 删除失败时保留当前状态并显示错误。
- 删除成功后刷新记录和当前选择。

## Architecture

- 新增可复用的 `AgentLogo` SwiftUI 组件，负责 Agent Logo、彩色/灰色状态和稳定尺寸。
- `SkillDetailView` 使用 Agent Logo 状态栏，并复用 `AppModel.requestInstall(to:)`。
- Install Targets 使用复选框绑定安装状态；勾选调用安装，取消勾选进入卸载确认。
- `AppModel` 增加待确认卸载状态与卸载动作。
- `SkillWorkspaceService` 增加卸载目标 Skill 的安全 API。
- `SkillFileOperator` 增加受根目录约束的安全删除能力。

## Testing

自动化测试覆盖：

- 卸载只删除指定 Agent 的安装副本。
- 卸载不修改 Library、其他 Agent 副本和中文备注。
- System Skill 无法卸载。
- 非 Agent 根目录内的目标路径无法删除。
- 取消卸载确认不会执行删除。
- 安装和卸载后状态刷新正确。

手动视觉验收：

- 详情页不再显示 Skill 来源。
- 已安装 Logo 彩色，未安装 Logo 灰色。
- 点击灰色 Logo 可以安装。
- Install Targets 使用复选框 + Logo + Agent 名称。
- 取消勾选时出现卸载确认，确认后状态正确更新。

## Out of Scope

- 点击彩色 Logo 直接卸载。
- 一键安装或卸载所有 Agent。
- Codex、Claude 之外的新 Agent。
- 自动同步与后台安装。
