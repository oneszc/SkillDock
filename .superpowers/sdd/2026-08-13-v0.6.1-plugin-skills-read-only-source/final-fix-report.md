# V0.6.1 Final Fix Report

Status: DONE

## Implementation Commit

- `c2209797cce519c01958f1b5beaf57af28ac0660` - `fix: contain plugin manifest symlinks`

## Changed Files

- `Sources/SkillDockCore/Plugins/CodexPluginSkillSourceResolver.swift`
- `Tests/SkillDockCoreTests/CodexPluginSkillSourceResolverTests.swift`
- `Tests/SkillDockCoreTests/SkillLibraryBuilderTests.swift`
- `docs/superpowers/specs/2026-08-13-v0.6.1-plugin-skills-read-only-source-design.md`

## Verification

- `DEVELOPER_DIR=/Applications/Xcode-beta.app/Contents/Developer swift test --filter CodexPluginSkillSourceResolverTests` - passed: 7 tests, 0 failures.
- `DEVELOPER_DIR=/Applications/Xcode-beta.app/Contents/Developer swift test --filter SkillLibraryBuilderTests` - passed: 11 tests, 0 failures.
- `DEVELOPER_DIR=/Applications/Xcode-beta.app/Contents/Developer swift test` - passed: 192 tests total, 0 failures (Core: 154; App: 38).
- `git diff --check` - passed with no output.

## Finding Resolution

### Important 1: Symlink Escape

DONE. The resolver now applies `resolvingSymlinksInPath().standardizedFileURL` to both the Plugin version root and manifest-declared skills root before containment comparison. A new test creates a `skills-link` symlink inside the version root that targets an external directory containing `SKILL.md`; the resolver returns no location and therefore does not expose that external Skill directory for scanning.

### Important 2: Plugin Merge Coverage

DONE. Added coverage that a same-name, same-hash Personal, Plugin, and System set merges into one record retaining all three available sources without creating an installed copy. Added coverage that same-name Plugin Skills with different hashes remain separate records.

### Minor 1: Outdated Design Scope

DONE. The design specification now records that it began as a validation document and was expanded through the approved implementation plan. Its current scope includes manifest `skills` path read-only scanning, the Available Plugin filter, and source labels. Exclusions explicitly retain Plugin lifecycle, hooks/runtime/MCP/apps/permissions, full cache scanning, and automatic multi-version selection.

## Residual Risk

- Codex Plugin cache metadata is still an observed local structure rather than a guaranteed long-term public contract.
- When multiple Plugin versions are present, SkillDock intentionally skips that Plugin until a reliable active-version signal is available.
