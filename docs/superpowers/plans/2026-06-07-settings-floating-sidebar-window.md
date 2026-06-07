# Settings Floating Sidebar Window Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Replace the standard SwiftUI Settings scene with a single-instance SwiftUI window whose sidebar extends into the titlebar, while preserving the Settings menu command and `⌘,` shortcut.

**Architecture:** Declare a named `Window` scene for settings and open it through `openWindow(id:)`. Add a focused SwiftUI commands type that replaces the standard app settings command with a command that opens or focuses the named window. Keep the existing shared `AppModel`, `SettingsWindowView`, and `NavigationSplitView`.

**Tech Stack:** Swift 6.3, SwiftUI, macOS 26, SwiftPM

---

### Task 1: Add the Settings menu command

**Files:**
- Create: `Sources/SkillDockApp/SettingsCommands.swift`

- [ ] **Step 1: Create the focused settings command**

```swift
import SwiftUI

struct SettingsCommands: Commands {
    @Environment(\.openWindow) private var openWindow

    var body: some Commands {
        CommandGroup(replacing: .appSettings) {
            Button("Settings…") {
                openWindow(id: "settings")
            }
            .keyboardShortcut(",", modifiers: .command)
        }
    }
}
```

- [ ] **Step 2: Build to verify the command API compiles**

Run:

```bash
swift build
```

Expected: build succeeds.

- [ ] **Step 3: Commit the command**

```bash
git add Sources/SkillDockApp/SettingsCommands.swift
git commit -m "feat: add settings window command"
```

### Task 2: Replace the Settings scene with a named Window

**Files:**
- Modify: `Sources/SkillDockApp/SkillDockApp.swift`

- [ ] **Step 1: Replace the Settings scene**

Change:

```swift
Settings {
    SettingsWindowView(model: model)
}
```

to:

```swift
Window("Settings", id: "settings") {
    SettingsWindowView(model: model)
}
.defaultSize(width: 980, height: 650)
.commands {
    SettingsCommands()
}
```

- [ ] **Step 2: Build to verify the named window and commands compile**

Run:

```bash
swift build
```

Expected: build succeeds.

- [ ] **Step 3: Commit the scene change**

```bash
git add Sources/SkillDockApp/SkillDockApp.swift
git commit -m "feat: use floating sidebar settings window"
```

### Task 3: Tune the settings window for the floating sidebar structure

**Files:**
- Modify: `Sources/SkillDockApp/Views/SettingsWindowView.swift`

- [ ] **Step 1: Keep the system split view and remove the unnecessary minimum size**

Remove:

```swift
.frame(minWidth: 800, minHeight: 540)
```

Use a system sidebar and keep its navigation title:

```swift
.listStyle(.sidebar)
.navigationTitle("Settings")
```

Do not remove the title or sidebar toggle. They preserve the system sidebar/titlebar integration and support future settings categories.

- [ ] **Step 2: Build to verify**

Run:

```bash
swift build
```

Expected: build succeeds.

- [ ] **Step 3: Commit the sizing adjustment**

```bash
git add Sources/SkillDockApp/Views/SettingsWindowView.swift
git commit -m "refine: tune settings window sizing"
```

### Task 4: Verify real-window behavior

**Files:**
- Modify: `docs/CURRENT_STATE.md`

- [ ] **Step 1: Run automated tests**

Run:

```bash
swift test
```

Expected: 44 tests pass with 0 failures.

- [ ] **Step 2: Build and launch the packaged app**

Run:

```bash
./scripts/run-app.sh
```

Expected: package verification succeeds and `SkillDock.app` opens.

- [ ] **Step 3: Manually verify settings behavior**

Check:

- `SkillDock` application menu contains `Settings…`.
- `⌘,` opens the settings window.
- Repeated menu clicks or shortcuts focus the same settings window.
- The settings sidebar extends into the titlebar.
- The traffic lights visually sit within the sidebar region.
- Changing appearance, paths, toggle, and picker still saves correctly.
- The main browser window remains unchanged.

- [ ] **Step 4: Update the handoff record**

In `docs/CURRENT_STATE.md`:

- Replace the prior red-light-position limitation with the completed named-window solution.
- Record the latest test and packaged-app verification date.
- Keep V0.2.1 marked as awaiting final visual confirmation.

- [ ] **Step 5: Verify the final diff**

Run:

```bash
git diff --check
git status --short
```

Expected: no whitespace errors; only intended files are modified.

- [ ] **Step 6: Commit final verification and docs**

```bash
git add docs/CURRENT_STATE.md
git commit -m "docs: record floating settings window"
```

- [ ] **Step 7: Push**

Run:

```bash
git push origin main
```

Expected: `main` is synchronized with `origin/main`.
