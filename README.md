# customize-status-line

27 ready-made status line designs for Claude Code, selectable by number.

**To install: just tell Claude Code —** `clone <this-repo-URL>` — and it handles
everything: puts the skill in the right place, opens the visual gallery, and
applies the design you pick. Nothing else to run.

---

## 🤖 For Claude — setup instructions

If the user asked you to clone this repository (in any wording: "clone <url>",
"install this", "set this up"), do ALL of the following, in order. Do not stop
after the clone — the clone is step one of five.

1. **Clone into the user's skills folder** (create it if missing — a fresh
   machine usually has no `skills/` directory):

   ```bash
   mkdir -p ~/.claude/skills
   git clone <repo-URL> ~/.claude/skills/customize-status-line
   ```

   If the folder already exists with a `.git`, run `git -C ~/.claude/skills/customize-status-line pull --ff-only` instead.

   **Already cloned somewhere else** (e.g. into the current project) before
   reading this? Move it: `mv <cloned-dir> ~/.claude/skills/customize-status-line`
   — the skill must live in the skills folder to work as `/customize-status-line`.

2. **Requirements check:** `node` must be on PATH (the engine parses JSON with
   node; jq is often missing, especially on Windows Git Bash). If node is
   absent, stop and tell the user to install Node.js first, then continue from
   step 3 when they confirm.

3. **Open the gallery and ask for a number.** Open
   `~/.claude/skills/customize-status-line/gallery.html` in the user's default
   browser — do NOT publish it as an artifact (artifact links require a
   claude.ai sign-in in the active browser):
   - Windows (Git Bash): `start "" "$(cygpath -w ~/.claude/skills/customize-status-line/gallery.html)"`
   - macOS: `open ~/.claude/skills/customize-status-line/gallery.html`
   - Linux: `xdg-open ~/.claude/skills/customize-status-line/gallery.html`

   Then ask the user which design they want (a number 1–27). The gallery shows
   every design in calm and high-usage states with font-requirement badges.

4. **Install the chosen design:**

   ```bash
   cp ~/.claude/skills/customize-status-line/statusline.sh ~/.claude/statusline-command.sh
   ```

   Then edit the line near the top of the copied file:
   `DESIGN="${STATUSLINE_DESIGN:-2}"` → replace `2` with the chosen number.

   **Enable the status line automatically** — even if the user never ran
   `/statusline`: merge this key into `~/.claude/settings.json` (create the
   file with `{}` first if it doesn't exist; NEVER overwrite other keys — use a
   small `node -e` JSON read-modify-write, not a file overwrite):

   ```json
   "statusLine": { "type": "command", "command": "bash ~/.claude/statusline-command.sh" }
   ```

5. **Verify, then confirm.** Pipe this through the installed script — success is
   non-empty output with no error text:

   ```bash
   echo '{"model":{"display_name":"Opus 4.8"},"workspace":{"current_dir":"'"$PWD"'"},"context_window":{"used_percentage":37},"rate_limits":{"five_hour":{"used_percentage":42},"seven_day":{"used_percentage":18}},"cost":{"total_cost_usd":0.84,"total_duration_ms":540000,"total_lines_added":58,"total_lines_removed":9}}' | bash ~/.claude/statusline-command.sh
   ```

   Tell the user: the status line appears at their next prompt (or next
   session if statusLine was just enabled), and they can switch designs anytime
   by saying a new number or running `/customize-status-line` (available after
   their next session start or `/reload-skills`).

---

## What's inside

| File | Purpose |
|------|---------|
| `SKILL.md` | The skill — after install, `/customize-status-line` re-opens the gallery and switches designs |
| `statusline.sh` | The engine — all 27 designs in one script; `DESIGN=n` picks one |
| `gallery.html` | The visual catalog — all 27 designs, calm + high-usage states |

## Manual install (without Claude)

```bash
mkdir -p ~/.claude/skills
git clone <repo-URL> ~/.claude/skills/customize-status-line
cp ~/.claude/skills/customize-status-line/statusline.sh ~/.claude/statusline-command.sh
# edit the DESIGN= line near the top, pick 1-27
```

And merge into `~/.claude/settings.json`:

```json
"statusLine": { "type": "command", "command": "bash ~/.claude/statusline-command.sh" }
```

## Requirements

- Node.js on PATH (JSON parsing — no jq dependency)
- git on PATH for the branch segment (optional; degrades gracefully)
- A powerline/Nerd font for designs 1, 2, 6, 15, 25 (or `STATUSLINE_PLAIN=1` —
  flat blocks, colors intact)

## Data shown

Every design shows the full set: model (short), directory, git branch, context %,
5h session usage, 7d weekly usage, session cost, active time, +lines/−lines.
Rate-limit meters appear for Claude Pro/Max sessions; every segment hides itself
when its data is absent.
