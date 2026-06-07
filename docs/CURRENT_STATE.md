# Current State

## Current Stage

V0.2 已发布。V0.2.1 视觉舒适度、设置页结构、外观模式、应用图标，以及两轮设置页交互微调（路径字段交互 + 设置入口改为标准偏好窗口）均已实现并验证，尚未发布，等待产品负责人最终体验确认。

## Current Goal

下一次继续体验 V0.2.1 的整体观感。设置入口已改为苹果菜单旁的 SkillDockApp → Settings…（⌘,）标准偏好窗口，左右结构。遗留待议：红绿灯能否嵌入左侧浮起卡片（纯 SwiftUI 做不到，需 AppKit，与「绝不自己写」原则有张力，产品负责人已决定先维持现状）。确认其余视觉是否还需微调。

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
- 自动化测试共 44 项，全部通过。

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

未调整 / 待确认：

- 路径过长时输入框是否需要设宽度上限并内部滚动，待产品负责人体验后决定。
- 产品负责人尚未对本轮微调做最终体验确认。

### V0.2.1 设置入口改为标准偏好窗口（2026-06-07）

已调整：

- Settings 从主窗口左侧栏移除，主侧栏只剩 Library / Installed / System。
- 设置入口改为 macOS 标准位置：苹果菜单旁的 SkillDockApp → Settings…（⌘,），用 SwiftUI 官方 `Settings {}` 场景实现。
- 设置窗口为左右结构：左侧导航（目前只有 General，预留 `SettingsSection` enum 方便后续扩展），右侧为对应内容。
- 用官方 modifier `.toolbar(removing: .sidebarToggle)` 去掉左上角展开/收起按钮。
- 用官方 modifier `.toolbar(removing: .title)` 去掉顶部窗口标题文字。
- 删除 `SettingsSidebarView.swift`，新增 `SettingsWindowView.swift`；`AppModel` 上移到 App 层，主窗口与设置窗口共享。

已验证：

- `swift build` 通过。
- `swift test` 44 项全部通过（2026-06-07）。
- 已多轮重启应用并由产品负责人截图核对。

未调整 / 待确认（重要遗留决策）：

- 产品负责人希望红绿灯像 Xcode 设置窗口一样嵌在左侧浮起卡片顶部。
- 现状：SwiftUI 官方 `Settings {}` 场景自带「红绿灯在顶部条 + 标题居中」的窗口外壳，红绿灯无法嵌入侧栏卡片。
- 查证结论：Xcode 那种「侧栏承载红绿灯」效果业界普遍用 AppKit 的 `NSSplitViewController` 实现，纯 SwiftUI Settings 场景做不到。
- 这与项目原则「能用 Apple 官方样式就绝不自己写」存在张力：纯 SwiftUI 达不到该效果，AppKit 虽是官方框架但偏离声明式风格。
- 产品负责人当前决定：先维持现状（去掉标题与展开按钮后的纯官方 SwiftUI 方案），红绿灯位置问题暂不强求，后续再议。

### 协作原则补充（2026-06-07）

- 已确认并写入长期记忆：SkillDock 铁律——能用 Apple 官方组件或系统默认行为实现的界面，绝对不自己写自定义实现（不写 AppKit hack、不堆修饰符硬掰系统外观）。

## Not Yet Completed

1. 产品负责人体验并确认 V0.2.1 视觉调整。
2. 根据体验反馈进行一轮小幅微调，或确认完成。
3. 确认完成后，再决定是否发布 V0.2.1 GitHub Release。

下一阶段暂不开始：

- V0.3 GitHub 远程 Skills。
- 批量同步。
- AI 自动中文解读。

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
- 普通 Skill 浏览使用 Finder 式三栏；Settings 改为苹果菜单旁的标准偏好窗口（⌘,），窗口内为左右导航 + 内容结构。
- 应用支持跟随系统、浅色和深色三种外观模式。
- 设计铁律：能用 Apple 官方组件或系统默认行为实现的界面，绝对不自己写自定义实现。

## Current Environment Note

- Xcode 26.5 已安装并选中。
- Swift 6.3.2 已安装。
- `swift test`：44 项全部通过，最后验证于 2026-06-07。
- `swift build -c release`：通过，最后验证于 2026-06-05。
- 实现计划：`docs/superpowers/plans/2026-06-05-v0.1-local-skill-library.md`。
- V0.2 实现计划：`docs/superpowers/plans/2026-06-05-v0.2-local-import-and-notes-polish.md`。
- V0.2.1 设置页实现计划：`docs/superpowers/plans/2026-06-05-v0.2.1-settings-layout-and-appearance.md`。

## Handoff Note

当前接手分支：`main`。

截至 2026-06-07 的交接状态：

- 最新功能实现提交：本轮设置入口改造（Settings 移到 ⌘, 标准偏好窗口、左右结构、去掉展开按钮与标题）。
- 本地 `main` 与 GitHub `origin/main` 已同步。
- 工作区干净，没有未提交文件。
- 最新已发布版本：`v0.2.0`。
- V0.2.1 已实现但尚未发布，当前任务是继续视觉体验确认，不开始 V0.3。
- 产品负责人提供的应用图标和 System / Light / Dark 模式图均已复制进项目并提交，不依赖当前电脑桌面文件。
- 遗留待议：设置窗口红绿灯嵌入侧栏卡片的诉求，纯 SwiftUI 做不到，已决定先维持现状，详见上文「V0.2.1 设置入口改为标准偏好窗口」小节。

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
