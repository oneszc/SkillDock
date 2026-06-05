# Open Questions

## Product

- V0.1 是否需要“启用 / 禁用”概念，还是只显示“已安装 / 未安装”？
- 主技能库是否必须强制分类目录，还是允许平铺？
- 中文备注是跟随 skill 写入 `.skilldock.json`，还是统一保存在 App 数据目录？

## UX

- 首次启动时，是自动创建 `~/AI-Skills`，还是先让用户确认？
- 列表页优先显示英文名称还是中文名称？
- 系统 skills 是否默认显示，还是放在筛选项里？

## Technical

- 技术栈选择：SwiftUI 原生 macOS，还是 Tauri / Electron？
- V0.1 是否需要 SQLite，还是先用 JSON 文件即可？
- 文件扫描是否需要实时监听，还是手动刷新即可？

