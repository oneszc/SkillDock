# Current State

## Current Stage

V0.3.0 已发布；Agent 安装状态与卸载管理优化已完成开发，等待产品负责人手动验收。

## Current Goal

完成 Agent 安装状态交互验收后，进入 V0.3.1，实现手动更新检查、文件变化预览和安全替换确认。

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

### Agent 安装状态与卸载管理（2026-06-11）

已完成：

- 详情页顶部不再显示 Skill 来源，只显示 Codex / Claude Agent Logo 安装状态。
- 彩色 Logo 表示已安装；灰色 Logo 表示未安装，点击灰色 Logo 可发起安装。
- Agent Logo 已复制到项目资源中，不依赖桌面文件。
- Install Targets 改为原生复选框 + Agent Logo + Agent 名称。
- 取消勾选会先显示卸载确认；取消确认不会修改文件。
- 卸载只移除所选 Agent 的精确 Skill 副本，不修改 Library、其他 Agent 副本或中文备注。
- 卸载会按 Skill 名称和内容 Hash 精确定位，支持 Agent 副本文件夹名称不同的情况。
- 已增加路径穿越、符号链接、Library 路径重叠、System Skill 和文件变化保护。
- System Skill 的安装与卸载控件继续保持禁用和只读。
- Logo 状态已增加 VoiceOver 可访问性说明。

已验证：

- `swift test`：91 项全部通过（2026-06-11）。
- `swift build`：通过（2026-06-11）。

待验收：

- 手动确认详情页 Logo 尺寸、灰色状态和间距。
- 手动确认勾选安装、取消勾选弹窗、取消与确认卸载体验。
- 手动确认 System Skill 的控件禁用状态。

## Not Yet Completed

1. 产品负责人手动验收 Agent 安装状态与卸载管理交互。
2. 实现远程版本与本地主技能库的文件变化比较。
3. 实现本地修改保护和明确替换确认。
4. 在 Skill 详情页展示 GitHub 来源与手动检查更新入口。
5. 在 Library 和 Installed 第二栏增加 Agent 筛选，默认全部，可筛选 Codex / Claude。
6. 完成 V0.3.1 验收和发布准备。

### V0.3.0 GitHub Remote Import（2026-06-08）

已完成：

- 解析公开 GitHub 仓库链接。
- 解析仓库内 Skill 文件夹链接，并保留分支与路径。
- 规范化 `www.github.com` 和 `.git` 链接。
- 拒绝非 GitHub、无效和不完整链接。
- 建立受控命令执行层。
- Git Clone 仓库保存到 SkillDock 管理目录。
- 已 Clone 仓库支持 Fetch 和刷新提交版本。
- 扫描一个仓库内多个 Skills。
- 文件夹链接对应 Skill 自动预选。
- 扫描结果包含文件、scripts 风险、内容 Hash 和主技能库冲突。
- 支持 ZIP 下载和临时解压，并通过公开 GitHub 信息记录分支和提交版本。
- Automatic 模式优先 Git Clone，Clone 失败后回退 ZIP；明确选择 Clone 或 ZIP 时不自动切换。
- 支持勾选多个 Skills 一次导入，每个 Skill 可单独选择冲突策略。
- 远程导入只进入主技能库，不自动安装到 Codex 或 Claude。
- 成功导入后独立记录仓库、分支、仓库内路径、获取方式、提交版本和内容 Hash。
- 主窗口工具栏已增加 Add from GitHub 入口，支持链接输入、获取方式、批量选择、风险提示和导入结果。
- 已生成并启动 `dist/SkillDock.app` 检查应用包。
- 自动化测试从 44 项增加到 64 项，全部通过。
- 已生成并验证 `dist/SkillDock-0.3.0.zip`。

V0.3.0 暂不包含：

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
- `swift test`：64 项全部通过，最后验证于 2026-06-08。
- Agent 安装状态功能分支 `swift test`：91 项全部通过，最后验证于 2026-06-11。
- `swift build -c release`：通过，最后验证于 2026-06-11。
- V0.2.1 正式安装包 SHA-256：`e3e77eb13e2ba1046a78e24ef4d0780a0622b0679481677f936cedfba9f26f34`。
- V0.3.0 正式安装包 SHA-256：`e7b2edf2020846c48577aa629425002c92be648bd4d76dbbc93a4988c82dc26a`。
- 实现计划：`docs/superpowers/plans/2026-06-05-v0.1-local-skill-library.md`。
- V0.2 实现计划：`docs/superpowers/plans/2026-06-05-v0.2-local-import-and-notes-polish.md`。
- V0.2.1 设置页实现计划：`docs/superpowers/plans/2026-06-05-v0.2.1-settings-layout-and-appearance.md`。
- V0.3 设计规格：`docs/superpowers/specs/2026-06-08-v0.3-github-remote-skills-design.md`。
- V0.3 实施计划：`docs/superpowers/plans/2026-06-08-v0.3-github-remote-skills.md`。

## Handoff Note

当前发布分支：`main`。

截至 2026-06-11 的交接状态：

- 最新功能实现：详情页使用 Agent Logo 表示安装状态，Install Targets 使用复选框管理安装与安全卸载。
- 安全卸载只处理所选 Agent 的精确副本，并保护 Library、其他 Agent 副本、中文备注和 System Skill。
- Agent 安装状态功能已合并到 `main` 并推送 GitHub。
- `main` 工作区干净，没有未提交文件。
- 最新发布版本：`v0.3.0`。
- 下一步先手动验收 Agent 安装状态与卸载管理；验收通过后开始 V0.3.1 手动更新检查与 Agent 筛选。
- 产品负责人提供的应用图标和 System / Light / Dark 模式图均已复制进项目并提交，不依赖当前电脑桌面文件。
- 产品负责人提供的 Codex / Claude Logo 已复制进项目并提交，不依赖当前电脑桌面文件。

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
