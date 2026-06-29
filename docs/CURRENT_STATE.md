# Current State

## Current Stage

V0.5.1 System Skill 分类修复和 GitHub Agent Plugin 导入提示已开启开发，当前分支为 `codex/v0.5.1-development`。

## Current Goal

按实施计划完成 V0.5.1 两个小范围修复：保留合并 Skill 的全部物理来源、在 GitHub Agent Plugin 仓库导入时提示边界并提供批量选择入口；完成后再进入 V0.6 Codex Available Skills 规划与开发。

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

### V0.3.1 Agent 安装状态与卸载管理（2026-06-11）

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
- 已使用产品负责人提供的彩色与独立灰色 Codex / Claude Logo。
- 顶部 Agent Logo 保持原始颜色，不受 System Skill 只读状态自动降透明度影响。

已验证：

- `swift test`：91 项全部通过（2026-06-11）。
- `swift build`：通过（2026-06-11）。

发布状态：

- 已完成产品负责人视觉调整。
- 已生成、独立解压并验证 `dist/SkillDock-0.3.1.zip`。
- GitHub V0.3.1 Release 已发布。

### V0.3.1 卸载确认修复（2026-06-11）

- 已修复点击卸载确认弹窗 `Remove` 后删除请求被弹窗关闭事件清空的问题。
- 删除操作现在会保存本次确认对象，再异步执行真实卸载并刷新勾选状态。
- 同步修复了使用相同确认结构的覆盖安装操作。
- 已增加 App 层回归测试，覆盖弹窗状态清空后仍能完成卸载的场景。
- 本修复作为 V0.3.2 补丁版本发布。
- 已生成、独立解压并验证 `dist/SkillDock-0.3.2.zip`。
- GitHub V0.3.2 Release 已发布。

### V0.3.3 Manual Updates And Agent Filter（2026-06-16）

已完成：

- GitHub 导入到 Library 的 Skill 会在详情页显示来源仓库与分支。
- 已增加手动 `Check Update` 入口，不做后台自动检查。
- 已实现远程版本与本地 Library Skill 的内容 Hash 对比。
- 已实现文件变化预览：新增、修改、删除。
- 已实现本地修改保护：本地内容已变更时，不允许静默替换。
- 已实现明确确认后替换 Library Skill，并同步更新来源记录中的 commit 和内容 Hash。
- Library 和 Installed 第二栏已增加 Agent 筛选，默认 All Agents，可筛选 Codex / Claude。
- System 页面不显示 Agent 筛选。
- 已新增 V0.3.3 验收清单：`docs/testing/V0.3.3_ACCEPTANCE.md`。
- 已新增 V0.3.3 Release notes：`docs/releases/v0.3.3.md`。

已验证：

- `swift test`：103 项全部通过（2026-06-16）。
- `./scripts/package-app.sh`：已生成并验证 `dist/SkillDock.app` 和 `dist/SkillDock-0.3.3.zip`。
- 独立解压 `dist/SkillDock-0.3.3.zip` 后运行 `./scripts/verify-app.sh`：通过。

当前安装包：

- `dist/SkillDock-0.3.3.zip`
- SHA-256：`35a74249bdabe8a4e8791a106d07b97f851ebb95183bb374d9e50e5a96545a80`

V0.3.3 暂不包含：

- 私有 GitHub 仓库和登录。
- 后台自动更新。
- 自动合并本地修改。
- 新增 Codex / Claude 之外的 Agent 类型。

### V0.4.0 Multi-Agent Targets（2026-06-17）

已完成：

- 已新增 `AgentTarget` 设置模型，Codex / Claude 默认启用。
- 已将 `SkillSource` 从固定 Codex / Claude 扩展为动态 `.agent(id)`。
- 已将安装状态从固定布尔值扩展为 `agentIDs` 集合。
- Library 刷新会扫描设置中已启用的 Agent Targets，禁用项不扫描。
- Library / Installed 筛选已从固定 Codex / Claude 改为动态 Agent ID。
- 详情页顶部 Agent Logo 已动态渲染已启用 Agent Targets。
- Install Targets 列表已动态渲染已启用 Agent Targets。
- Skill 列表行右侧优先显示 Codex / Claude，其他已安装 Agent 折叠为 `+N`。
- 安装和卸载核心服务已支持自定义 `AgentTarget` 路径。
- Settings 已新增 Agent Targets 管理，可启用 / 禁用并编辑路径。
- Settings 已新增常用 Agent 建议项：Grok、Gemini、OpenCode、Antigravity、Hermes，默认禁用。
- 产品负责人提供的 Grok、Gemini、OpenCode、Antigravity、Hermes 彩色和灰色品牌 Logo 已复制进项目资源，不依赖桌面文件。
- Antigravity 已改用 PNG 品牌资源，避免 SVG 渐变在小尺寸下出现马赛克。
- 已新增 V0.4 验收清单：`docs/testing/V0.4_ACCEPTANCE.md`。
- 已新增 V0.4 Release notes：`docs/releases/v0.4.0.md`。
- 打包脚本默认版本已更新为 `0.4.0`。

已验证：

- `swift test --filter AgentTargetSettingsTests`：通过。
- `swift test --filter SkillScannerTests`：通过。
- `swift test --filter SkillLibraryBuilderTests`：通过。
- `swift test --filter SkillLibraryServiceTests`：通过。
- `swift test --filter SkillWorkspaceServiceTests`：通过。
- `swift test --filter AppModel`：通过。
- `swift build --target SkillDockApp`：通过。
- `swift test`：111 项全部通过。
- `./scripts/package-app.sh`：已生成并验证 `dist/SkillDock.app` 和 `dist/SkillDock-0.4.0.zip`。
- 独立解压 `dist/SkillDock-0.4.0.zip` 后运行 `./scripts/verify-app.sh`：通过。

当前安装包：

- `dist/SkillDock-0.4.0.zip`
- SHA-256：`fb7905fdc52976ac18d0e1d47ca7b709f4488b07141c75bf9202c5b665815fd8`

验收 / 发布状态：

- 产品负责人已按 `docs/testing/V0.4_ACCEPTANCE.md` 手动验收。
- 已合并到 `main`。
- GitHub V0.4.0 Release 已发布：
  - `https://github.com/oneszc/SkillDock/releases/tag/v0.4.0`

### V0.4.0 列表 Agent 展示修复（2026-06-17）

- 已修复 Skill 列表右侧 Agent Logo 折叠规则。
- 当已安装 Agent 数量小于等于 2 个时，无论是否 Codex / Claude，都直接展示对应 Logo。
- 当已安装 Agent 数量大于 2 个时，优先展示 Codex / Claude，其余 Agent 折叠为 `+N`。
- 已增加 `SkillRowInstallBadgesTests` 回归测试，避免非 Codex / Claude 的 1-2 个安装状态被误折叠，并覆盖超过 2 个非默认 Agent 的补位展示。
- 已验证：`swift test --filter SkillRowInstallBadgesTests` 3 项通过。

### V0.4.0 Git 元数据更新误判修复（2026-06-17）

- 已修复从 GitHub 克隆来的 Skill 在 `Check Update` 时把 `.git/logs/HEAD` 误判为 Skill 本地修改的问题。
- `SkillHasher` 现在会忽略 `.git` 目录，Git 管理元数据不再影响 Skill 内容 Hash。
- `RemoteUpdateService` 的文件变化预览现在会忽略 `.git` 目录，更新弹窗不会再显示 `.git/logs/HEAD` 这类仓库内部文件。
- `.skill-config` 等重要隐藏文件仍会参与 Hash，不会因为跳过 `.git` 而忽略真实 Skill 配置。
- 已增加回归测试：
  - `SkillMarkdownParserTests/testHashIgnoresGitMetadataDirectory`
  - `RemoteUpdateServiceTests/testCheckIgnoresGitMetadataChangesInsideSkillDirectory`
- 已验证：
  - `swift test --filter RemoteUpdateServiceTests`：7 项通过。
  - `swift test --filter SkillMarkdownParserTests`：6 项通过。
  - `swift build --target SkillDockApp`：通过。

### V0.5 DeepSeek Skill Translation 设计确认（2026-06-18）

已确认：

- 第一版界面只开放 DeepSeek，通过 Settings 配置 API Key、模型和连接测试。
- 底层使用可扩展 Translation Provider 接口，避免在详情页、存储和翻译状态中写死 DeepSeek。
- 详情页删除 `Chinese Notes`，保留 `SKILL.md / Files / Install`。
- `原文 / 译文` 与内容导航同排但左右分组，只在 `SKILL.md` 页面显示。
- Skill 名称始终显示原文；译文同时覆盖顶部介绍和完整 `SKILL.md` 正文。
- 译文只读、独立保存，可重新生成；原文变化后保留旧译文并提示更新。
- 不修改原始 Skill，不后台自动翻译，不翻译其他文件。
- 旧中文备注数据保留，但 V0.5 不再展示或用于生成译文。

设计规格：

```text
docs/superpowers/specs/2026-06-18-v0.5-deepseek-skill-translation-design.md
```

### V0.5 Development Progress（2026-06-18）

已完成：

- 已建立 `codex/v0.5-development` 开发分支。
- 已新增实施计划：`docs/superpowers/plans/2026-06-18-v0.5-deepseek-skill-translation.md`。
- 已新增 Provider 中立的翻译设置，旧 `settings.json` 可兼容加载，API Key 不进入普通配置。
- 已新增 macOS Keychain 凭据存储，并按 Provider ID 隔离 API Key。
- 已新增 Translation Provider 接口、DeepSeek 请求实现、JSON 输出解析和安全错误映射。
- 已新增独立 `translations.json` 存储、内容 Hash 过期识别和有效译文中文搜索。
- 旧 `notes.json` 保留不删除，V0.5 新流程不再用旧备注作为搜索数据。
- 已完成翻译服务与 AppModel 状态，生成中切换 Skill 不会写错译文。
- Settings 已新增 AI Translation、Keychain 凭据编辑、模型选择和连接测试。
- 详情页已移除 Chinese Notes，并新增原文 / 译文、空状态、失败重试、过期提醒和重新生成。
- 列表和搜索仅使用当前有效译文，过期译文回退原始介绍。

已验证：

- `swift test`：140 项全部通过。
- `swift build -c release --product SkillDockApp`：通过。
- `git diff --check`：通过。

验收结果：

- 产品负责人已使用真实 DeepSeek API Key 完成连接与单 Skill 翻译验收。
- 详情页语言控件、Markdown 译文、错误状态和 Keychain 交互验收通过。
- 原始 Skill 内容保护、译文独立存储和切换 Skill 后结果归属验收通过。
- 验收清单：`docs/testing/V0.5_ACCEPTANCE.md`。

### V0.5.0 Release（2026-06-18）

- 产品负责人已完成 V0.5 功能与视觉验收。
- 详情页完成导航左右对齐、GitHub 来源展示和更新入口布局优化。
- Skill 列表保持展示原始英文介绍，中文译文只在详情页按需切换。
- Markdown、Files 列表、Agent 筛选和窗口工具栏间距已完成视觉微调。
- `README.md`、路线图、验收清单和 Release notes 已同步到 V0.5.0。
- 打包脚本默认版本已更新为 `0.5.0`。
- `swift test`：140 项全部通过。
- `dist/SkillDock-0.5.0.zip` 已生成并独立解压验证通过。
- 包内版本：`0.5.0`。
- SHA-256：`4469b69998934f1c04024096b24a0f0893021b9075c7332f7b46457d7068c0b5`。
- `codex/v0.5-development` 已合并到 `main`。
- GitHub Release：`https://github.com/oneszc/SkillDock/releases/tag/v0.5.0`

### V0.4.1 Maintenance Release（2026-06-18）

发布范围：

- Skill 安装到不超过 2 个 Agent 时直接展示全部 Logo；超过 2 个时优先 Codex / Claude 并折叠其余 Agent。
- `.git` 元数据不再参与 Skill 内容 Hash 和远程更新 diff，避免无真实内容变化时误报本地修改。
- 已新增 Release notes：`docs/releases/v0.4.1.md`。
- 打包脚本默认版本已更新为 `0.4.1`。
- V0.5 规划文档已纳入主分支，但本安装包不包含 V0.5 功能。
- GitHub Release 已发布：`https://github.com/oneszc/SkillDock/releases/tag/v0.4.1`

已验证：

- `swift test`：116 项全部通过。
- `./scripts/package-app.sh`：已生成并验证 `dist/SkillDock.app` 和 `dist/SkillDock-0.4.1.zip`。
- 独立解压后运行 `./scripts/verify-app.sh`：通过。
- 包内版本：`0.4.1`。

当前安装包：

- `dist/SkillDock-0.4.1.zip`
- SHA-256：`dd7dfee5dbe3280d1aff99e4991012c4fb820576cd0994aad58eff2deb71aca9`

V0.4.0 暂不包含：

- 批量同步。
- Symlink 模式。
- 后台自动同步。
- AI 自动中文解读。
- 私有 GitHub 仓库和登录。

## Not Yet Completed

1. 后续补充正式 Developer ID 签名和公证。
2. V0.4.x 继续优化多 Agent 下的真实使用细节，例如批量同步入口、更多 Agent 的展示密度和设置页可读性。

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
- V0.3.1 发布 Agent 安装状态与安全卸载；V0.3.2 修复确认操作；V0.3.3 完成手动更新检查和 Agent 筛选。
- V0.5.1 修复重复 Skill 合并后丢失 System 来源的问题，并补充 GitHub Agent Plugin 导入提示；不扩大扫描范围，不接管 Agent 官方插件安装流程。
- V0.6 区分 Installed 与 Codex Available，逐步覆盖 Personal、Plugin 和 System 来源。

## Current Environment Note

- Xcode 26.5 已安装并选中。
- Swift 6.3.2 已安装。
- `swift test`：139 项全部通过，最后验证于 2026-06-18。
- `swift build -c release --product SkillDockApp`：通过，最后验证于 2026-06-18。
- `swift test --filter RemoteUpdateServiceTests`：7 项通过，最后验证于 2026-06-17。
- `swift test --filter SkillMarkdownParserTests`：6 项通过，最后验证于 2026-06-17。
- `swift build --target SkillDockApp`：通过，最后验证于 2026-06-17。
- V0.2.1 正式安装包 SHA-256：`e3e77eb13e2ba1046a78e24ef4d0780a0622b0679481677f936cedfba9f26f34`。
- V0.3.0 正式安装包 SHA-256：`e7b2edf2020846c48577aa629425002c92be648bd4d76dbbc93a4988c82dc26a`。
- V0.3.1 正式安装包 SHA-256：`1d3cf5137c4f5fcd0b5f388138f9f3eb6aaa1ac00e97053767066fd753b8157d`。
- V0.3.2 正式安装包 SHA-256：`6f657b077134e63201525683f957bac76f152ab56422c10712cdc4c14e5530b6`。
- V0.3.3 正式安装包 SHA-256：`35a74249bdabe8a4e8791a106d07b97f851ebb95183bb374d9e50e5a96545a80`。
- V0.4.0 正式安装包 SHA-256：`fb7905fdc52976ac18d0e1d47ca7b709f4488b07141c75bf9202c5b665815fd8`。
- V0.4.1 正式安装包 SHA-256：`dd7dfee5dbe3280d1aff99e4991012c4fb820576cd0994aad58eff2deb71aca9`。
- 实现计划：`docs/superpowers/plans/2026-06-05-v0.1-local-skill-library.md`。
- V0.2 实现计划：`docs/superpowers/plans/2026-06-05-v0.2-local-import-and-notes-polish.md`。
- V0.2.1 设置页实现计划：`docs/superpowers/plans/2026-06-05-v0.2.1-settings-layout-and-appearance.md`。
- V0.3 设计规格：`docs/superpowers/specs/2026-06-08-v0.3-github-remote-skills-design.md`。
- V0.3 实施计划：`docs/superpowers/plans/2026-06-08-v0.3-github-remote-skills.md`。
- V0.3.3 实施计划：`docs/superpowers/plans/2026-06-16-v0.3.3-manual-updates-and-agent-filter.md`。
- V0.4.0 实施计划：`docs/superpowers/plans/2026-06-16-v0.4-multi-agent-targets.md`。
- V0.5.1 实施计划：`docs/superpowers/plans/2026-06-29-v0.5.1-system-classification-and-plugin-import-notice.md`。

## Handoff Note

当前开发分支：`codex/v0.5.1-development`。

截至 2026-06-22 的交接状态：

- 最新功能实现：V0.5 DeepSeek Skill Translation，已完成自动化验证和产品负责人手动验收。
- V0.4.0 已通过产品负责人验收，已合并并发布到 `main`。
- 最新已发布版本为 `v0.5.0`，安装包、Release notes 和发布验证均已完成。
- V0.4.0 发布后的小修复：列表中已安装 Agent 数量小于等于 2 个时直接展示 Logo，超过 2 个才折叠为 `+N`。
- V0.4.0 发布后的小修复：GitHub 克隆 Skill 的 `.git` 元数据不再参与 Hash 和更新 diff，避免无真实内容变化时误报 `Local changes detected`。
- V0.5 已完成 Provider、Keychain、译文存储、Settings 和详情页 Original / Translation 体验。
- V0.5.0 已合并到 `main` 并发布 GitHub Release；V0.5.1 已从 `main` 开启开发分支。
- 已确认 V0.5.1 System 分类修复、GitHub Agent Plugin 导入提示和 V0.6 Codex Available Skills 分阶段方案，实施计划已写入 `docs/superpowers/plans/2026-06-29-v0.5.1-system-classification-and-plugin-import-notice.md`。
- 当前诊断：SkillDock 的 Installed 数量按配置 Agent Target 去重统计；Codex 客户端数量还包含 Personal、Plugin 等可用来源。
- 当前已知 Bug：`skill-installer` 的 Library、Codex System、Claude 副本内容相同，合并后丢失 System 标记，导致 System 只显示 4 个而不是 5 个。
- 当前 GitHub 导入体验待优化：`obra/superpowers` 这类 Agent Plugin 仓库可识别出 14 个 Skills，但 SkillDock 只导入 Skill 文件内容，不保留插件级 hooks、runtime / extension 配置、官方注册状态和官方更新流程；V0.5.1 需要在导入页明确提示用户如需完整插件能力，应走 Codex / Claude Code 官方插件安装方式。
- 产品负责人提供的应用图标和 System / Light / Dark 模式图均已复制进项目并提交，不依赖当前电脑桌面文件。
- 产品负责人提供的 Codex / Claude Logo 已复制进项目并提交，不依赖当前电脑桌面文件。
- 产品负责人提供的 Grok / Gemini / OpenCode / Antigravity / Hermes Logo 已复制进项目资源，不依赖当前电脑桌面文件。

### GitHub 介绍页真实性修正（2026-06-19）

- 已修正独立介绍页 `/Users/zhaoning/Desktop/SkillDock/skilldock-landing.html`。
- 头部和界面预览已替换为当前 V0.5.0 真实软件截图 `skilldock-app-screenshot.png`。
- 已删除不支持的 Homebrew、DMG 和 Skill Registry 表述，下载入口改为 GitHub 最新 Release ZIP。
- 已同步修正版本、macOS 26+、多 Agent、GitHub 导入、手动更新和 DeepSeek 翻译说明。
- 已校准中英文文案，并明确翻译功能会把所选 `SKILL.md` 内容发送给 DeepSeek。
- 已检查 1440×900 桌面端和 390×844 移动端，无横向溢出；语言切换与页面控制台检查通过。

### GitHub 介绍页 Product Grid 视觉升级（2026-06-19）

- 已使用 Product Design 工作流并选定 Vercel 风格的 `Product Grid` 方向。
- 独立介绍页已改为白底、强排版、细网格和轻量分隔线的产品化视觉系统。
- Hero 从左右结构改为居中结构，主文案为 `Your AI Skills. One place.`。
- 已用 HTML / CSS 实现简化版三栏 SkillDock 界面，页面不再引用真实软件截图，避免暴露本机数据并降低后续维护成本。
- 功能区域已从浮层卡片改为平面分隔网格；下载、安装和 FAQ 保留当前 V0.5.0 真实内容。
- 已补充键盘焦点和 `prefers-reduced-motion` 支持。
- 已完成 1440×1024 视觉对比和 390×844 移动端验证；语言切换、FAQ、下载链接及控制台检查通过。
- 设计 QA：`/Users/zhaoning/Desktop/SkillDock/design-qa.md`，结果为 `passed`。

第二台电脑开始工作的步骤：

```bash
git clone https://github.com/oneszc/SkillDock.git
cd SkillDock
git fetch origin
git switch main
git pull --ff-only origin main
swift test --filter RemoteUpdateServiceTests
swift test --filter SkillMarkdownParserTests
./scripts/run-app.sh
```

如果另一台电脑已经克隆项目，可以跳过前两行。

开始工作前先读本文件；结束工作前更新本文件，提交并 push 到 GitHub。
