# GitHub Landing Page Accuracy Design

## Goal

Make the standalone GitHub introduction page accurately represent SkillDock V0.5 without redesigning its visual system.

## Scope

- Keep the current page structure, typography, colors, responsive behavior, and bilingual toggle.
- Replace the fictional hero interface with a real SkillDock application screenshot.
- Update version references from V0.3.0 to V0.5.0.
- Replace outdated Codex / Claude-only positioning with configurable multi-Agent support.
- Describe current capabilities accurately: local library management, local and public GitHub import, safe Agent installation and removal, manual remote update checks, and optional DeepSeek translation.
- Remove unsupported Registry, enable/disable toggle, Homebrew, and DMG claims.
- Replace installation instructions with a direct GitHub Release ZIP download flow.
- Keep privacy and local-first messaging; clarify that translation is optional and requires the user's own API key.

## Hero

Use a real application screenshot inside a restrained macOS-style frame. The screenshot should show the Finder-like three-column layout and real Skill management UI. Avoid fabricated version badges, registry rows, and generic dashboard states.

The primary action opens the latest GitHub Release. The secondary action opens the repository.

## Content Accuracy

The feature section should prioritize what helps a prospective user decide quickly:

1. See Skills from the main library and enabled Agent directories in one place.
2. Import a local folder or public GitHub repository.
3. Install or remove a Skill safely across supported Agent targets.
4. Check GitHub-sourced Skill updates manually with change preview and local-change protection.
5. Read the original `SKILL.md` or an optional Chinese translation.
6. Keep Skill files and notes local by default.

## Download Experience

Remove the Homebrew command and DMG button. Show one primary ZIP download route through GitHub Releases, followed by short macOS instructions: download ZIP, unzip, move SkillDock to Applications, and launch it. State the actual minimum system requirement: macOS 26 or later.

## Validation

- Verify there are no remaining Homebrew, DMG, Registry, V0.3.0, or Codex / Claude-only claims.
- Verify both English and Chinese copy remain aligned.
- Check desktop and mobile layouts for overflow and readable hierarchy.
- Confirm download and repository links point to the correct GitHub destinations.

## Out of Scope

- Full visual redesign.
- New framework or build tooling.
- Changes to the SkillDock macOS application.
