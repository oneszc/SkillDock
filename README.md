# SkillDock

SkillDock is a native macOS app for viewing, organizing, and installing local AI Skills.

## V0.1 Features

- Scan `~/AI-Skills`, `~/.codex/skills`, and `~/.claude/skills`.
- Browse Skills in a Finder-style three-column interface.
- Preview `SKILL.md` and the Skill file tree.
- Search English content and Chinese notes.
- Import a local Skill into the main library.
- Install a Skill to Codex or Claude.
- Reveal a Skill in Finder and copy its path.
- Keep system Skills read-only.

## V0.2 Development Features

- Drop one Skill folder onto the Library list.
- Review metadata, files, scripts, and conflicts before importing.
- Default conflicts to Skip, with explicit Replace and Rename choices.
- Edit Chinese notes in one grouped form.
- Reuse tag and use-case suggestions or add custom values.
- Auto-save Chinese notes after about one second.

## Privacy Rule

Chinese notes and future AI summaries never modify the original Skill. SkillDock stores them separately in:

```text
~/Library/Application Support/SkillDock/
```

## Requirements

- macOS 26
- Xcode 26 or later
- Swift 6.2 or later

## Build And Run

```bash
swift test
./scripts/run-app.sh
```

`run-app.sh` builds and opens the packaged `SkillDock.app`, so macOS uses the configured app name, icon, and bundle settings. Avoid `swift run SkillDockApp` for normal visual testing because it launches a raw executable without the app bundle icon.

## Create A Double-clickable App

```bash
./scripts/package-app.sh
open dist/SkillDock.app
```

This creates:

```text
dist/SkillDock.app
dist/SkillDock-0.2.1.zip
```

The local package uses an ad-hoc signature. Public distribution through GitHub Release should add Developer ID signing and Apple notarization.

The first launch creates or scans these default locations:

```text
~/AI-Skills
~/.codex/skills
~/.claude/skills
```

## Development Workflow

Before working from either computer:

```bash
git pull
```

Read `AGENTS.md` and `docs/CURRENT_STATE.md`, then continue from the exact next action recorded there.
