# Current State

## Current Stage

V0.2.1 已发布。V0.3 GitHub Remote Skills 产品方案、正式设计规格和详细实施计划均已完成。

## Current Goal

在独立 `codex/v0.3-development` 工作区开始 V0.3 第一阶段开发：GitHub 链接解析、Clone / ZIP 获取和仓库 Skill 扫描。

## Completed

### V0.1

- 已完成 SwiftUI 原生三栏界面。
- 已完成 Library、Codex、Claude Skill 扫描、合并和搜索。
- 已完成 `SKILL.md` 与文件列表查看。
- 已完成独立中文备注编辑和保存。
- 已完成本地导入、Codex / Claude 安装和冲突保护。
- 已完成 Finder 定位、复制路径和设置编辑。
- 已安装并切换到 Xcode 26.5。
- V0.1 手动验收已通过。
- 已生成并实际启动 `dist/SkillDock.app`。
- 已生成并解压验证 `dist/SkillDock-0.1.0.zip`。
- 当前应用使用临时本地签名，尚未进行 Apple Developer ID 签名和公证。
- `codex/v0.1-development` 已合并到 `main`。
- GitHub V0.1.0 Release 已发布：
  - `https://github.com/oneszc/SkillDock/releases/tag/v0.1.0`
  - Release ZIP 已重新下载并通过 SHA-256 校验。

### V0.2

- V0.2 已完成单文件夹拖拽导入和导入预览。
- V0.2 已完成脚本风险提示和同名冲突策略。
- V0.2 已完成中文备注分组表单、建议项和自动保存。
- V0.2 已固定使用原始 Skill 名称，中文描述仅作为辅助理解。
- V0.2 已移除 Overview，详情页默认打开 `SKILL.md`。
- 自动化测试共 42 项，全部通过。
- V0.2 产品负责人手动验收已通过。
- `codex/v0.2-development` 已合并并推送到 `main`。
- 已生成并验证 `dist/SkillDock-0.2.0.zip`。
- GitHub V0.2.0 Release 已发布。

### V0.2.1 Visual Polish

- 已统一主要页面字号和间距规则。
- 已放大 Skill 列表标题、副标题、图标和行高。
- 已提升详情页标题、描述和操作区域的阅读层级。
- 已为长文设置舒适阅读宽度。
- 已增加中文备注、导入预览和设置页留白。
- Settings 已改为“设置分类 + 设置内容”双栏结构，不再显示空白 Skill 列表中间栏。
- General 已增加 System、Light、Dark 外观模式选择，并支持立即生效和持久化。
- 旧版本设置文件缺少外观字段时默认跟随系统，保持兼容。
- 已使用产品负责人提供的蓝紫色角色图替换应用图标，并接入自动打包流程。
- Appearance 模式选择已使用产品负责人提供的三张模式图，采用标题左上、选项靠右的灰底布局。
- 外观切换改用 macOS 原生应用级外观，避免切回 System 时短暂出现混合配色。
- 已增加 `scripts/run-app.sh` 作为终端视觉测试入口，避免 `swift run SkillDockApp` 绕过 App 包后显示通用 Dock 图标。
- 已生成并启动 `dist/SkillDock.app` 进行视觉检查。
- 已生成、独立解压并验证 `dist/SkillDock-0.2.1.zip`。
- 自动化测试共 44 项，全部通过。
- 产品负责人最终视觉验收已通过。
- GitHub V0.2.1 Release 已发布。

### V0.2.1 设置页交互微调（2026-06-07）

已调整：

- Appearance 三个模式缩略图等比缩小约三分之一（104×68 → 70×46），圆角和选中描边同步收窄。
- Skill Locations 删除右侧重复的 Library / Codex / Claude 标签字段，每行只保留左侧一个标签。
- 删除底部 Save Settings 按钮，设置改为自动保存。
- 路径字段改为失焦或回车时才提交保存，且只有内容真正改变才写盘；Toggle 和 Picker 仍即时保存。
- 路径输入框宽度改为随内容撑开（`fixedSize`），不再固定宽度。

已验证：

- `swift build` 通过。
- `swift test` 44 项全部通过（2026-06-07）。
- 已重新启动应用进行视觉检查。

保留后续观察：

- 路径过长时输入框是否需要设宽度上限并内部滚动，可在真实使用中继续观察。

### V0.2.1 设置入口改为标准偏好窗口（2026-06-07）

已调整：

- Settings 从主窗口左侧栏移除，主侧栏只剩 Library / Installed / System。
- 设置入口改为 macOS 标准位置：苹果菜单旁的 SkillDockApp → Settings…（⌘,），用 SwiftUI 官方 `Settings {}` 场景实现。
- 设置窗口为左右结构：左侧导航（目前只有 General，预留 `SettingsSection` enum 方便后续扩展），右侧为对应内容。
- 用官方 modifier `.toolbar(removing: .sidebarToggle)` 去掉左上角展开/收起按钮。
- 用官方 modifier `.toolbar(removing: .title)` 去掉顶部窗口标题文字。
- 删除 `SettingsSidebarView.swift`，新增 `SettingsWindowView.swift`；`AppModel` 上移到 App 层，主窗口与设置窗口共享。

后续完善：

- 将 SwiftUI `Settings {}` 场景替换为单实例命名 `Window`，继续通过应用菜单 `Settings…` 和 `⌘,` 打开。
- 设置窗口采用系统 `NavigationSplitView` + sidebar，红绿灯位于左侧浮层侧栏。
- 保留 `Settings` 标题、系统侧栏开关和分类导航，为未来增加多个设置分类预留结构。
- 隐藏右侧无用的窗口工具栏背景分割线。
- 全部使用 SwiftUI 官方窗口、命令和侧栏 API，没有使用 AppKit hack。

已验证：

- `swift build` 通过。
- `swift test` 44 项全部通过（2026-06-07）。
- 已多轮重启应用并由产品负责人截图核对。

产品负责人已确认设置窗口整体观感没有问题。

### 协作原则补充（2026-06-07）

- 已确认并写入长期记忆：SkillDock 铁律——能用 Apple 官方组件或系统默认行为实现的界面，绝对不自己写自定义实现（不写 AppKit hack、不堆修饰符硬掰系统外观）。

### 产品 README 梳理（2026-06-08）

- GitHub README 已从开发说明调整为产品介绍。
- 顶部使用应用图标、双语定位、版本与平台标签，以及下载入口。
- 正文按产品价值、主要能力、产品体验、安装、隐私和当前状态组织。
- 暂未加入应用截图，避免公开展示本机 Skill 数据；后续可补充专用演示截图。

## Not Yet Completed

1. 实现远程仓库获取与 Skill 扫描核心。
2. 实现多选远程导入。
3. 实现远程来源记录与手动更新。
4. 完成 V0.3 UI 和验收。

V0.3 暂不包含：

- 私有 GitHub 仓库和登录。
- 自动后台更新和一键全部更新。
- 自动合并本地修改。
- 自动安装到 Codex / Claude Code。

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
- Skill 原始名称始终作为主名称；中文描述只作为辅助理解信息。
- 普通 Skill 浏览使用 Finder 式三栏；Settings 使用应用菜单中的独立单实例窗口（⌘,），窗口内为可扩展侧栏 + 内容结构。
- 应用支持跟随系统、浅色和深色三种外观模式。
- 设计铁律：能用 Apple 官方组件或系统默认行为实现的界面，绝对不自己写自定义实现。
- V0.3 公开 GitHub 仓库同时支持 Git Clone 和 ZIP；远程导入默认只进入主技能库，更新必须手动触发并确认。

## Current Environment Note

- Xcode 26.5 已安装并选中。
- Swift 6.3.2 已安装。
- `swift test`：44 项全部通过，最后验证于 2026-06-07。
- `swift build -c release`：通过，最后验证于 2026-06-07。
- V0.2.1 正式安装包 SHA-256：`e3e77eb13e2ba1046a78e24ef4d0780a0622b0679481677f936cedfba9f26f34`。
- 实现计划：`docs/superpowers/plans/2026-06-05-v0.1-local-skill-library.md`。
- V0.2 实现计划：`docs/superpowers/plans/2026-06-05-v0.2-local-import-and-notes-polish.md`。
- V0.2.1 设置页实现计划：`docs/superpowers/plans/2026-06-05-v0.2.1-settings-layout-and-appearance.md`。
- V0.3 设计规格：`docs/superpowers/specs/2026-06-08-v0.3-github-remote-skills-design.md`。
- V0.3 实施计划：`docs/superpowers/plans/2026-06-08-v0.3-github-remote-skills.md`。

## Handoff Note

当前接手分支：`main`。

截至 2026-06-08 的交接状态：

- 最新功能实现：Settings 使用独立单实例 SwiftUI 窗口，保留 `Settings…` / `⌘,`，红绿灯位于浮层侧栏，并为未来设置分类预留导航。
- 本地 `main` 与 GitHub `origin/main` 已同步。
- 工作区干净，没有未提交文件。
- 最新已发布版本：`v0.2.1`。
- V0.2.1 已完成并发布。V0.3 设计规格和实施计划已完成，下一步开始第一阶段开发。
- 产品负责人提供的应用图标和 System / Light / Dark 模式图均已复制进项目并提交，不依赖当前电脑桌面文件。

第二台电脑开始工作的步骤：

```bash
git clone https://github.com/oneszc/SkillDock.git
cd SkillDock
git switch main
git pull --ff-only origin main
swift test
./scripts/run-app.sh
```

如果另一台电脑已经克隆项目，可以跳过前两行。

开始工作前先读本文件；结束工作前更新本文件，提交并 push 到 GitHub。
