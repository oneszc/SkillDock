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
swift run SkillDockApp
```

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
