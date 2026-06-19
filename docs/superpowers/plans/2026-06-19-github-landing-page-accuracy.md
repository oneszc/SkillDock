# GitHub Landing Page Accuracy Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Make the standalone GitHub introduction page accurately describe and show SkillDock V0.5.

**Architecture:** Keep the existing single-file bilingual landing page and its current visual system. Add one real application screenshot asset, replace inaccurate marketing copy and download instructions in place, then validate the static page at desktop and mobile sizes.

**Tech Stack:** Static HTML, CSS, vanilla JavaScript, GSAP, macOS screenshot capture, browser visual verification.

---

### Task 1: Capture the real product interface

**Files:**
- Create: `/Users/zhaoning/Desktop/SkillDock/skilldock-app-screenshot.png`

- [ ] **Step 1: Launch the current packaged SkillDock app**

Run: `./scripts/run-app.sh`

Expected: SkillDock V0.5 opens with its real Finder-like three-column interface.

- [ ] **Step 2: Prepare a representative product state**

Show the Library view with a selected Skill, visible Agent status, and the `SKILL.md` or Translation detail. Avoid exposing private paths, API keys, or personal Skill content.

- [ ] **Step 3: Capture and crop the application window**

Save the window-only image as `/Users/zhaoning/Desktop/SkillDock/skilldock-app-screenshot.png`.

Expected: The screenshot contains only the SkillDock window and remains readable in a wide hero crop.

### Task 2: Correct the page content and hero

**Files:**
- Modify: `/Users/zhaoning/Desktop/SkillDock/skilldock-landing.html`

- [ ] **Step 1: Replace the fabricated hero preview**

Replace the `.app-preview` rows with an `<img>` using `skilldock-app-screenshot.png`, preserving rounded corners, shadow, and responsive sizing.

- [ ] **Step 2: Correct product and release information**

Update English and Chinese dictionaries and visible fallback copy to V0.5.0, macOS 26+, configurable multi-Agent targets, local and GitHub import, safe install/remove, manual update checks, and optional DeepSeek translation.

- [ ] **Step 3: Correct download and installation actions**

Remove Homebrew command and DMG language. Point the primary download action to `https://github.com/oneszc/SkillDock/releases/latest` and describe the ZIP download, unzip, Applications move, and launch flow.

- [ ] **Step 4: Remove unsupported claims**

Remove or rewrite Registry, one-click enable/disable, zero-configuration detection, automatic updates, and Codex / Claude-only statements.

### Task 3: Verify content and responsive presentation

**Files:**
- Verify: `/Users/zhaoning/Desktop/SkillDock/skilldock-landing.html`
- Verify: `/Users/zhaoning/Desktop/SkillDock/skilldock-app-screenshot.png`

- [ ] **Step 1: Run the accuracy scan**

Run: `rg -n -i 'homebrew|brew install|dmg|registry|v0\.3\.0|macOS 15|automatic updates' /Users/zhaoning/Desktop/SkillDock/skilldock-landing.html`

Expected: no matches in user-facing copy.

- [ ] **Step 2: Verify required current content**

Run: `rg -n 'v0\.5\.0|macOS 26|releases/latest|DeepSeek|GitHub' /Users/zhaoning/Desktop/SkillDock/skilldock-landing.html`

Expected: matches exist in both visible fallback content and bilingual dictionaries where applicable.

- [ ] **Step 3: Inspect desktop and mobile layouts**

Open the page at 1440×900 and 390×844.

Expected: hero screenshot is legible, buttons are clear, no horizontal overflow appears, and English/Chinese switching keeps the layout stable.

- [ ] **Step 4: Update project handoff state**

Append a short note to `docs/CURRENT_STATE.md` recording the corrected standalone GitHub landing page, changed asset, and validation completed.
