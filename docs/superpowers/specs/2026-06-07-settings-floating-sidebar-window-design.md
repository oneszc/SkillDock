# Settings Floating Sidebar Window Design

## Goal

保留 macOS 顶部应用菜单中的 `Settings…` 和 `⌘,` 快捷键，同时让设置窗口与 SkillDock 主窗口使用一致的 macOS 26 双层结构：左侧浮层侧栏延伸到窗口顶部，红绿灯视觉上位于侧栏区域内。

## Problem

当前设置入口使用 SwiftUI `Settings {}` 场景。它自动提供标准设置菜单和 `⌘,`，但同时固定使用独立顶部标题栏，导致：

- 红绿灯位于最外层白色窗口顶部，而不是侧栏浮层内。
- 左侧侧栏从标题栏下方开始。
- 设置窗口与主窗口的视觉语言不一致。

问题来自 `Settings {}` 场景的窗口外壳，而不是设置内容或 `NavigationSplitView`。

## Chosen Direction

使用单实例 SwiftUI `Window` 替代 `Settings {}` 场景。

- 设置窗口继续使用 `NavigationSplitView`。
- 普通窗口让系统侧栏延伸到标题栏区域，形成与主窗口一致的浮层侧栏结构。
- 使用 SwiftUI 官方窗口和命令 API，不使用 AppKit hack，不手动绘制红绿灯。

## Interaction

- 应用菜单继续显示 `Settings…`。
- `⌘,` 继续打开设置窗口。
- 重复触发只聚焦已有设置窗口，不创建多个窗口。
- 设置窗口关闭后，再次触发会重新打开。
- 设置窗口与主窗口共享同一个 `AppModel`，设置立即生效并自动保存。

## Window Structure

- Scene：`Window("Settings", id: "settings")`
- 内容：现有 `SettingsWindowView`
- 左侧：General 导航，保留后续新增分类能力
- 右侧：现有 Appearance、Skill Locations、Behavior 内容
- 默认尺寸比当前设置窗口更紧凑，减少空旷感
- 保留系统窗口控制、系统侧栏材质和系统分隔关系

## Menu Structure

由于移除 `Settings {}` 后系统不会自动生成设置菜单项，应用通过 SwiftUI `Commands` 增加：

- 名称：`Settings…`
- 快捷键：`⌘,`
- 行为：调用 `openWindow(id: "settings")`

该菜单项放在应用菜单的标准设置位置附近，保持用户预期。

## Non-goals

- 不使用 AppKit 修改 `NSWindow`。
- 不手动绘制或移动红绿灯。
- 不重新设计设置内容。
- 不新增设置分类。
- 不开始 V0.3 功能。

## Acceptance

- 从应用菜单点击 `Settings…` 可以打开设置窗口。
- `⌘,` 可以打开设置窗口。
- 多次触发不会创建多个设置窗口。
- 设置窗口侧栏延伸到顶部，红绿灯视觉上位于侧栏区域。
- 设置修改仍会自动保存并立即生效。
- 主窗口行为不受影响。
- `swift test`、打包和 App 包验证通过。
