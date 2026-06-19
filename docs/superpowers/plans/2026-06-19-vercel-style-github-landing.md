# Vercel-Style GitHub Landing Page Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Rebuild the standalone SkillDock landing page in the approved Product Grid direction with a code-native product hero and responsive Vercel-inspired visual system.

**Architecture:** Keep the existing single-file static page and bilingual dictionary. Replace the visual tokens, page sections, and screenshot-based preview in place, using semantic HTML and scoped CSS for the simplified three-column product interface. Preserve existing links and lightweight JavaScript interactions without adding dependencies.

**Tech Stack:** HTML5, CSS, vanilla JavaScript, existing GSAP reveal behavior, local Chrome visual verification.

---

### Task 1: Establish the Product Grid visual system

**Files:**
- Modify: `/Users/zhaoning/Desktop/SkillDock/skilldock-landing.html`

- [ ] **Step 1: Record the current rendered baseline**

Run a local HTTP server and capture `1440 × 1024` and `390 × 844` screenshots before editing.

Expected: the current serif-led split hero and screenshot-based product preview are visible.

- [ ] **Step 2: Replace visual tokens and typography**

Update root tokens to a white, black, cool-gray, thin-divider system. Replace Playfair and decorative italic styling with Inter Tight / Inter and neutral monospace metadata. Reduce radii, shadows, and bright-blue usage.

- [ ] **Step 3: Rebuild the navigation and hero layout**

Use a compact divided navigation and centered hero with the headline `Your AI Skills. One place.`, concise supporting copy, and download / GitHub actions.

- [ ] **Step 4: Verify the first viewport**

Run: `curl -s -o /dev/null -w '%{http_code}' http://127.0.0.1:4173/skilldock-landing.html`

Expected: `200`.

### Task 2: Replace the screenshot with a code-native product visual

**Files:**
- Modify: `/Users/zhaoning/Desktop/SkillDock/skilldock-landing.html`
- Stop referencing: `/Users/zhaoning/Desktop/SkillDock/skilldock-app-screenshot.png`

- [ ] **Step 1: Add semantic product-preview markup**

Create a simplified three-column interface with `.product-sidebar`, `.product-list`, and `.product-detail`. Populate it with truthful SkillDock navigation, realistic Skill rows, SKILL.md content, Original / Translation state, and Agent status labels.

- [ ] **Step 2: Style the product visual**

Use thin borders, grouped rows, restrained selected states, and a single subtle blue-purple accent. Avoid screenshot imagery, nested cards, and heavy shadows.

- [ ] **Step 3: Add responsive states**

At tablet width, narrow the columns. At mobile width, stack sidebar summary, Skill list, and detail preview without horizontal scrolling.

- [ ] **Step 4: Verify screenshot dependency removal**

Run: `rg -n 'skilldock-app-screenshot\.png' /Users/zhaoning/Desktop/SkillDock/skilldock-landing.html`

Expected: no matches.

### Task 3: Flatten feature, download, install, and FAQ sections

**Files:**
- Modify: `/Users/zhaoning/Desktop/SkillDock/skilldock-landing.html`

- [ ] **Step 1: Replace feature cards with divided cells**

Keep the six current truthful capabilities while removing floating-card shadows, arrow decorations, and unnecessary icon chrome.

- [ ] **Step 2: Restyle download and install sections**

Keep the GitHub Release ZIP flow, V0.5.0, and macOS 26+ requirements. Use neutral black / white surfaces and clear hierarchy.

- [ ] **Step 3: Preserve FAQ and bilingual behavior**

Keep FAQ expansion, language switching, smooth anchors, and accurate DeepSeek privacy wording.

- [ ] **Step 4: Add accessibility and motion safeguards**

Add visible focus states and a `prefers-reduced-motion` rule that disables nonessential transitions and reveal movement.

### Task 4: Visual QA and handoff

**Files:**
- Create: `/Users/zhaoning/Desktop/SkillDock/design-qa.md`
- Modify: `/Users/zhaoning/Desktop/Ones Projects/SkillDock/docs/CURRENT_STATE.md`

- [ ] **Step 1: Run static accuracy checks**

Run:

```bash
rg -n -i 'homebrew|brew install|dmg|registry|v0\.3\.0|macOS 15' /Users/zhaoning/Desktop/SkillDock/skilldock-landing.html
```

Expected: no matches.

- [ ] **Step 2: Capture desktop and mobile screenshots**

Capture the implementation at `1440 × 1024` and `390 × 844` in Chrome.

Expected: the implementation matches the approved Product Grid hierarchy, uses the code-native preview, and has no horizontal overflow.

- [ ] **Step 3: Verify interactions and console health**

Check English / Chinese switching, FAQ expansion, download link, GitHub link, keyboard focus, and browser console warnings / errors.

Expected: controls respond correctly and no relevant page errors appear.

- [ ] **Step 4: Complete design QA**

Compare the approved reference and implementation at the same desktop viewport. Record issues and fixes in `/Users/zhaoning/Desktop/SkillDock/design-qa.md`; finish only when the file says `final result: passed`.

- [ ] **Step 5: Update handoff state**

Append the redesign summary, validation evidence, and remaining maintenance note to `docs/CURRENT_STATE.md`.
