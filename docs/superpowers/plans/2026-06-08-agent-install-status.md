# Agent Install Status and Targets Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Replace Skill source labels with Agent Logo installation states, add Logo-based quick installation, and turn Install Targets into safe install/uninstall checkboxes.

**Architecture:** Add a narrowly constrained uninstall operation to Core, expose it through `SkillWorkspaceService`, and coordinate confirmation in `AppModel`. Add reusable app-only Agent Logo views backed by bundled SVG resources, then use them in the detail header and Install Targets rows. Existing install and overwrite-confirmation behavior remains unchanged.

**Tech Stack:** Swift 6.3, SwiftUI, SwiftPM resources, Foundation file operations, XCTest, macOS 26.

---

## File Structure

- Create `Sources/SkillDockApp/Views/AgentLogo.swift`
  - Loads bundled Codex / Claude SVG resources and applies installed/uninstalled appearance.
- Add `Sources/SkillDockApp/Resources/Agents/codex.svg`
  - Project-owned copy of `/Users/macbookpro/Desktop/codex.svg`.
- Add `Sources/SkillDockApp/Resources/Agents/claude.svg`
  - Project-owned copy of `/Users/macbookpro/Desktop/claude.svg`.
- Modify `Sources/SkillDockCore/Operations/SkillFileOperator.swift`
  - Add root-constrained removal for one installed Skill folder.
- Modify `Sources/SkillDockCore/Operations/SkillWorkspaceService.swift`
  - Resolve Agent target root and expose uninstall API.
- Modify `Sources/SkillDockApp/AppModel.swift`
  - Hold pending uninstall confirmation and execute confirmed uninstall.
- Modify `Sources/SkillDockApp/Views/RootView.swift`
  - Present destructive uninstall confirmation.
- Modify `Sources/SkillDockApp/Views/SkillDetailView.swift`
  - Replace source/status labels and Install Targets buttons.
- Modify `Tests/SkillDockCoreTests/SkillFileOperatorTests.swift`
  - Test safe removal constraints.
- Modify `Tests/SkillDockCoreTests/SkillWorkspaceServiceTests.swift`
  - Test Agent-specific uninstall behavior.

## Task 1: Add Safe Agent Skill Removal

**Files:**
- Modify: `Sources/SkillDockCore/Operations/SkillFileOperator.swift`
- Modify: `Tests/SkillDockCoreTests/SkillFileOperatorTests.swift`

- [ ] **Step 1: Write failing safe-removal tests**

Add tests covering:

```swift
func testRemoveSkillDeletesOnlyChildInsideExpectedRoot() async throws
func testRemoveSkillRejectsSystemSkill() async throws
func testRemoveSkillRejectsDestinationOutsideExpectedRoot() async throws
func testRemoveSkillDoesNothingWhenDestinationIsMissing() async throws
```

Expected API:

```swift
try await SkillFileOperator().removeSkill(
    named: "sample-skill",
    from: targetRoot,
    isSystemSkill: false
)
```

Also add:

```swift
case destinationOutsideRoot
```

to `SkillFileOperationError`.

- [ ] **Step 2: Run tests and verify RED**

Run:

```bash
swift test --filter SkillFileOperatorTests
```

Expected: FAIL because `removeSkill` and `destinationOutsideRoot` do not exist.

- [ ] **Step 3: Implement minimal root-constrained removal**

Implementation requirements:

```swift
public func removeSkill(
    named name: String,
    from root: URL,
    isSystemSkill: Bool = false
) throws
```

- Reject System Skills.
- Build destination only from `root.appendingPathComponent(name)`.
- Standardize root and destination paths.
- Require destination parent path to equal standardized root path.
- Return successfully when destination is missing.
- Delete only the resolved destination directory.

- [ ] **Step 4: Run tests and verify GREEN**

Run:

```bash
swift test --filter SkillFileOperatorTests
```

Expected: all `SkillFileOperatorTests` PASS.

- [ ] **Step 5: Commit**

```bash
git add Sources/SkillDockCore/Operations/SkillFileOperator.swift Tests/SkillDockCoreTests/SkillFileOperatorTests.swift
git commit -m "feat: safely remove installed skills"
```

## Task 2: Expose Agent-specific Uninstall Service

**Files:**
- Modify: `Sources/SkillDockCore/Operations/SkillWorkspaceService.swift`
- Modify: `Tests/SkillDockCoreTests/SkillWorkspaceServiceTests.swift`

- [ ] **Step 1: Write failing workspace uninstall tests**

Add:

```swift
func testUninstallRemovesOnlySelectedAgentCopy() async throws
func testUninstallDoesNotModifyLibraryOrNotes() async throws
func testUninstallRejectsSystemSkill() async throws
```

Expected API:

```swift
try await workspace.uninstallSkill(
    named: "sample-skill",
    target: .codex,
    settings: settings,
    isSystemSkill: false
)
```

The first test creates matching Library, Codex, and Claude copies, uninstalls Codex, then verifies Library and Claude remain.

- [ ] **Step 2: Run tests and verify RED**

Run:

```bash
swift test --filter SkillWorkspaceServiceTests
```

Expected: FAIL because `uninstallSkill` does not exist.

- [ ] **Step 3: Implement workspace uninstall**

Add:

```swift
public func uninstallSkill(
    named name: String,
    target: InstallTarget,
    settings: SkillSettings,
    isSystemSkill: Bool = false
) async throws
```

Resolve target root with the same `InstallTarget` switch used by `installSkill`, then call `fileOperator.removeSkill`.

- [ ] **Step 4: Run tests and full Core verification**

Run:

```bash
swift test --filter SkillWorkspaceServiceTests
swift test
```

Expected: all tests PASS.

- [ ] **Step 5: Commit**

```bash
git add Sources/SkillDockCore/Operations/SkillWorkspaceService.swift Tests/SkillDockCoreTests/SkillWorkspaceServiceTests.swift
git commit -m "feat: uninstall skills from agent targets"
```

## Task 3: Bundle and Render Agent Logos

**Files:**
- Add: `Sources/SkillDockApp/Resources/Agents/codex.svg`
- Add: `Sources/SkillDockApp/Resources/Agents/claude.svg`
- Create: `Sources/SkillDockApp/Views/AgentLogo.swift`

- [ ] **Step 1: Copy user-provided Logo resources**

Copy:

```text
/Users/macbookpro/Desktop/codex.svg
→ Sources/SkillDockApp/Resources/Agents/codex.svg

/Users/macbookpro/Desktop/claude.svg
→ Sources/SkillDockApp/Resources/Agents/claude.svg
```

Use `apply_patch` to add project-owned resource files; do not reference Desktop paths from app code.

- [ ] **Step 2: Add reusable Agent Logo view**

Create:

```swift
struct AgentLogo: View {
    let target: InstallTarget
    var installed = true
    var size: CGFloat = 20

    var body: some View {
        Image(resourceName, bundle: .module)
            .resizable()
            .scaledToFit()
            .frame(width: size, height: size)
            .grayscale(installed ? 0 : 1)
            .opacity(installed ? 1 : 0.28)
    }
}
```

Map `.codex` to `codex`, `.claude` to `claude`, and add shared Agent display names in the same focused file.

- [ ] **Step 3: Verify resource build**

Run:

```bash
swift build
```

Expected: app builds and SwiftPM copies both SVG files into `SkillDock_SkillDockApp.bundle`.

- [ ] **Step 4: Commit**

```bash
git add Sources/SkillDockApp/Resources/Agents/codex.svg Sources/SkillDockApp/Resources/Agents/claude.svg Sources/SkillDockApp/Views/AgentLogo.swift
git commit -m "feat: add agent logo resources"
```

## Task 4: Add Detail Header Agent Logo States

**Files:**
- Modify: `Sources/SkillDockApp/Views/SkillDetailView.swift`

- [ ] **Step 1: Replace source labels with Agent Logo state buttons**

Remove:

```swift
Label(record.skill.source.displayName, systemImage: "folder")
Label("Codex", ...)
Label("Claude", ...)
```

Add one button per `InstallTarget.allCases`:

```swift
Button {
    guard !installed else { return }
    Task { await model.requestInstall(to: target) }
} label: {
    AgentLogo(target: target, installed: installed, size: 22)
}
.buttonStyle(.plain)
.disabled(record.skill.isSystem || installed)
.help(installed ? "Installed in \(target.displayName)" : "Install to \(target.displayName)")
```

Keep `Read-only` text only for System Skills.

- [ ] **Step 2: Build and manually inspect**

Run:

```bash
swift build
./scripts/run-app.sh
```

Verify:

- No source Agent or Library label remains.
- Installed Logo is colored.
- Uninstalled Logo is gray.
- Clicking gray Logo installs and refreshes its state.
- Colored Logo has no action.

- [ ] **Step 3: Commit**

```bash
git add Sources/SkillDockApp/Views/SkillDetailView.swift
git commit -m "feat: show agent install logo states"
```

## Task 5: Add Install Targets Checkboxes and Uninstall Confirmation

**Files:**
- Modify: `Sources/SkillDockApp/AppModel.swift`
- Modify: `Sources/SkillDockApp/Views/RootView.swift`
- Modify: `Sources/SkillDockApp/Views/SkillDetailView.swift`

- [ ] **Step 1: Add pending uninstall state**

In `AppModel`, add:

```swift
var pendingUninstallTarget: InstallTarget?
```

Add:

```swift
func requestTargetState(_ installed: Bool, target: InstallTarget) async {
    if installed {
        await requestInstall(to: target)
    } else {
        pendingUninstallTarget = target
    }
}

func confirmUninstall() async {
    guard let target = pendingUninstallTarget, let record = selectedRecord else { return }
    pendingUninstallTarget = nil
    do {
        try await workspaceService.uninstallSkill(
            named: record.skill.path.lastPathComponent,
            target: target,
            settings: settings,
            isSystemSkill: record.skill.isSystem
        )
        operationMessage = "Removed from \(target.displayName)."
        await refresh()
    } catch {
        errorMessage = error.localizedDescription
    }
}
```

- [ ] **Step 2: Add destructive confirmation**

In `RootView`, add a confirmation dialog bound to `pendingUninstallTarget`:

```swift
.confirmationDialog(
    "Remove this Skill from \(target.displayName)?",
    isPresented: ...
) {
    Button("Remove", role: .destructive) {
        Task { await model.confirmUninstall() }
    }
    Button("Cancel", role: .cancel) {
        model.pendingUninstallTarget = nil
    }
}
```

Message must state that Library and other Agent copies remain unchanged.

- [ ] **Step 3: Replace Install Targets rows**

Replace action buttons with:

```swift
Toggle(
    isOn: Binding(
        get: { installed },
        set: { newValue in
            Task { await model.requestTargetState(newValue, target: target) }
        }
    )
) {
    HStack(spacing: 12) {
        AgentLogo(target: target, installed: true, size: 20)
        Text(target.displayName)
    }
}
.toggleStyle(.checkbox)
.disabled(record.skill.isSystem)
```

Remove `Install` / `Reinstall` buttons.

- [ ] **Step 4: Build, test, and manually verify**

Run:

```bash
swift build
swift test
./scripts/run-app.sh
```

Verify:

- Checked targets are installed.
- Checking an uninstalled target installs.
- Unchecking an installed target opens confirmation.
- Cancel keeps files and checkbox state.
- Confirm removes only that Agent copy and refreshes state.
- System Skill checkboxes are disabled.

- [ ] **Step 5: Commit**

```bash
git add Sources/SkillDockApp/AppModel.swift Sources/SkillDockApp/Views/RootView.swift Sources/SkillDockApp/Views/SkillDetailView.swift
git commit -m "feat: manage agent install targets with checkboxes"
```

## Task 6: Update Handoff and Final Verification

**Files:**
- Modify: `docs/CURRENT_STATE.md`
- Modify: `docs/DECISIONS.md`

- [ ] **Step 1: Record completed behavior**

Document:

- Detail header uses Agent Logo install states only.
- Install Targets uses checkboxes with Logo and name.
- Unchecking requires explicit uninstall confirmation.
- Uninstall removes only the selected Agent copy.

- [ ] **Step 2: Run release-level verification**

Run:

```bash
swift test
swift build -c release
./scripts/package-app.sh
./scripts/verify-app.sh dist/SkillDock.app
```

Expected:

- All tests PASS.
- Release build succeeds.
- App bundle verification succeeds.

- [ ] **Step 3: Commit docs**

```bash
git add docs/CURRENT_STATE.md docs/DECISIONS.md
git commit -m "docs: record agent install status behavior"
```

## Plan Self-review

- Spec coverage: detail source removal, colored/gray Logos, gray Logo quick install, Install Targets checkboxes, uninstall confirmation, System read-only behavior, bundled user-provided Logos, and root-constrained deletion are covered.
- Scope: no new Agents, automatic sync, batch actions, or colored Logo uninstall shortcut.
- Type consistency: all app actions use existing `InstallTarget`; uninstall service and file operator APIs use the same Skill folder name and target root.
- Test strategy: destructive file behavior is covered in Core tests; visual and confirmation behavior is covered by build and manual app verification.
