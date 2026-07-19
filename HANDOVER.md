# HANDOVER — customize-status-line

Context handover for continuing work in this folder (previous session ran from
`D:\game`). Read this first; everything below is current as of 2026-07-19.

## What this project is

A Claude Code skill: **27 status line designs, selectable by number**. User
says `clone <repo-URL>` → Claude installs the skill → user runs
`/customize-status-line` → gallery.html opens in browser → user replies with a
number → engine installed, statusLine auto-enabled in settings.json, verified.
Changing designs later = run `/customize-status-line` again. That command is
deliberately taught in README, gallery banner + all 27 card chips, and the
skill's success message.

## File map

| File | Role |
|---|---|
| `statusline.sh` | Engine. All 27 designs as node-rendered ANSI; `DESIGN="${STATUSLINE_DESIGN:-N}"` on line 14 picks (env var wins). Parses statusLine stdin JSON with **node, not jq** (jq missing on Windows Git Bash). Git branch via `execFileSync` (no shell — cmd.exe broke `2>/dev/null \|\|` syntax). `STATUSLINE_PLAIN=1` swaps nerd-font glyphs (arrows ``, caps ``) for flat blocks. Renders graceful-degradation: every segment hides when its data is absent. |
| `gallery.html` | Visual catalog, 27 cards in 4 groups (Everyday / Expressive / Style studies / Game art styles), each calm + high-usage rows, font badges, per-card `/customize-status-line` command chips. Self-contained; opened as a **local file** in the browser (NOT as an artifact — artifact URLs need claude.ai sign-in). |
| `SKILL.md` | The skill. Workflow: open gallery locally → ask number (skip if user gave one) → install (cp engine, set DESIGN, merge settings.json — create as `{}` if absent, auto-enabling statusLine) → verify with sample payload. Has full design catalog table (1–27 — note row 14 Wabi-sabi sits alone at the bottom) and common-mistakes list. |
| `CLAUDE.md` | Instructions Claude follows when a user says "clone this repo": clone into `~/.claude/skills/customize-status-line` (mkdir -p skills; mv if cloned elsewhere), check node, then HAND OFF to `/customize-status-line` — do not install directly. |
| `README.md` | User-facing only (2-step install, data table, requirements, manual install). No Claude instructions here — that was deliberate (user request). |
| `.gitattributes` | Forces LF. **Critical:** CRLF checkout breaks `statusline.sh` under bash (`\r: command not found`). Verified a fresh clone has 0 CR bytes. |

## Deployment copies (keep in sync!)

1. `D:\customize-status-line` — this repo, source of truth
2. `C:\Users\UMAR FAROOQUE\.claude\skills\customize-status-line\` — installed skill (live for `/customize-status-line`)
3. `C:\Users\UMAR FAROOQUE\.claude\statusline-command.sh` — the user's LIVE status line: engine copy with **DESIGN=2 (Nightshade)** currently set
4. Artifact (gallery mirror): https://claude.ai/code/artifact/922ff4f0-5d67-4793-ad4a-55f5f04ddf90 — legacy/preview; local file is the canonical UX

After editing engine or gallery: cp to (2); if engine changed, also cp to (3) and re-set the DESIGN number.

## Design numbering (1–27)

1 Kiln Flow (nerd) · 2 Nightshade (nerd) · 3 Hairline · 4 Gauge · 5 Blocks ·
6 Claymorphic (nerd) · 7 Arcade HUD (emoji) · 8 Gradient Sweep · 9 Synthwave ·
10 Phosphor LCD · 11 Brutalist · 12 Bauhaus · 13 Swiss · 14 Wabi-sabi ·
15 Glassmorphic (nerd) · 16 Memphis · 17 Art Deco · 18 Nord · 19 Dracula ·
20 Terminal Rain · 21 Flat/Monument Valley · 22 Vector · 23 Geometric Art ·
24 Pixel/Stardew · 25 Cartoon/TF2 (nerd) · 26 Cel Shading/Wind Waker ·
27 Monochromatic/Inside

## Data contract (verified against official docs)

statusLine stdin JSON fields used: `model.display_name`,
`workspace.current_dir` (fallback `cwd`), `context_window.used_percentage`,
`rate_limits.five_hour.used_percentage`, `rate_limits.seven_day.used_percentage`
(both Pro/Max-only, absent until first response), `cost.total_cost_usd`
(Claude Code's own API-equivalent estimate — we only format it),
`cost.total_duration_ms`, `cost.total_lines_added`, `cost.total_lines_removed`.
Docs: https://code.claude.com/docs/en/statusline.md

**Invariant (user-demanded):** every design must render ALL fields when data is
present — model, dir, branch (repo only), ctx%, 5h%, 7d%, cost, time, +/-lines.
A shared `tailTxt()` helper in the engine and `tl()` in gallery.html enforce
the cost/time/lines tail. Bar-style designs must print the % beside bars.

## Testing conventions used

- Engine matrix: 27 designs × (full / high-pressure / minimal) payloads; strip
  ANSI with `sed 's/\x1b\[[0-9;]*m//g'`, assert tokens (case via `tr`, NOT
  `grep -i` — **grep -i SIGABRTs in this Git Bash**). Branch tests need a real
  repo: `git init -q -b dev "$TEMP/sl_gittest"` and pass its path as
  `workspace.current_dir`.
- Gallery: extract `<script>`, run under node with a stubbed `document`, split
  cards, assert calm (`0.23, 2.4, +0`) and hot (`3.10, 47, +612, 208`) tokens
  per card.
- Skill UX: cold-run subagents with a sandboxed fake `~/.claude` (see git log
  for what they caught: missing #14 in catalog, repo-wasn't-a-git-repo, CRLF).

## State / done

- All 27 designs complete-data verified (0 failures); gallery 27/27 cards
  complete; skill installed and exercised end-to-end multiple times (designs
  6, 15, 2 switched via the flow).
- Git repo initialized on branch `main`, 5 commits, clean tree.
- User's live line: Nightshade (2). User model: Fable 5 (shows as `F5`).

## TODO / next steps

1. **Push to GitHub** — repo has NO remote yet. After pushing, replace the
   `<repo-URL>` / `<this-repo-URL>` placeholders in README.md and CLAUDE.md
   with the real URL (they are intentionally placeholders now).
2. Consider GitHub Pages for gallery.html (browse designs before installing).
3. Optional ideas parked (user rejected auto-installer flows — do NOT add
   curl|bash / install.sh without asking): arg grammar (`/customize-status-line 14`
   direct-switch works via SKILL.md "skip straight to install"; `random`,
   `current`, `doctor` were proposed, not built).
4. `statusline.sh` line 3 has an empty `https://github.com/` comment — fill
   with real URL when pushed.

## Gotchas (hard-won, don't re-learn)

- jq: absent. node: required (v22 present here). PowerShell 5.1: no `&&`.
- `grep -qi` crashes (SIGABRT) in this environment; use `tr`+case or plain grep.
- Windows `execSync` spawns cmd.exe → never use shell redirection in the
  engine's git calls; keep `execFileSync`.
- Skill content is cached at session start: after editing SKILL.md, user needs
  `/reload-skills` (and the loaded copy in an old session may be stale).
- `D:\game` is NOT a git repo — branch segment correctly hides there.
- Artifact tool: same file path = same URL; the gallery artifact predates the
  local-file decision.
- User's home has a space (`UMAR FAROOQUE`) — always quote paths; `start "" "<path>"`.
