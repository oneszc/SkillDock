# Current State

## Current Stage

V0.2 已发布。V0.2.1 视觉舒适度、设置页结构、外观模式和应用图标优化已实现并验证，尚未发布，等待产品负责人最终体验确认。

## Current Goal

下一次继续体验 V0.2.1 的字号、间距、阅读宽度、设置页双栏结构、外观模式和应用图标，确认是否还需小幅微调。

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
- 已生成并启动 `dist/SkillDock.app` 进行视觉检查。
- 自动化测试共 44 项，全部通过。

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
- 普通 Skill 浏览使用 Finder 式三栏；Settings 使用“设置分类 + 设置内容”双栏。
- 应用支持跟随系统、浅色和深色三种外观模式。

## Current Environment Note

- Xcode 26.5 已安装并选中。
- Swift 6.3.2 已安装。
- `swift test`：44 项全部通过，最后验证于 2026-06-06。
- `swift build -c release`：通过，最后验证于 2026-06-05。
- 实现计划：`docs/superpowers/plans/2026-06-05-v0.1-local-skill-library.md`。
- V0.2 实现计划：`docs/superpowers/plans/2026-06-05-v0.2-local-import-and-notes-polish.md`。
- V0.2.1 设置页实现计划：`docs/superpowers/plans/2026-06-05-v0.2.1-settings-layout-and-appearance.md`。

## Handoff Note

当前接手分支：`main`。

截至 2026-06-06 的交接状态：

- 最新功能实现提交：`a70848e fix: polish appearance mode picker`。
- 本地 `main` 与 GitHub `origin/main` 已同步。
- 工作区干净，没有未提交文件。
- 最新已发布版本：`v0.2.0`。
- V0.2.1 已实现但尚未发布，当前任务是继续视觉体验确认，不开始 V0.3。
- 产品负责人提供的应用图标和 System / Light / Dark 模式图均已复制进项目并提交，不依赖当前电脑桌面文件。

第二台电脑开始工作的步骤：

```bash
git clone https://github.com/oneszc/SkillDock.git
cd SkillDock
git switch main
git pull --ff-only origin main
swift test
swift run SkillDockApp
```

如果另一台电脑已经克隆项目，可以跳过前两行。

开始工作前先读本文件；结束工作前更新本文件，提交并 push 到 GitHub。
