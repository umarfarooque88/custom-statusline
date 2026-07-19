# customize-status-line

27 ready-made status line designs for Claude Code, selectable by number.

**Install in two steps:**

1. Tell Claude Code: `clone <this-repo-URL>` — it puts the skill in the right place.
2. Run **`/customize-status-line`** — the gallery opens, you pick a number, done.

**That's also the only command to remember:** run `/customize-status-line`
anytime to change your design. Same command, same flow, forever.

---

## 🤖 For Claude — setup instructions

If the user asked you to clone this repository (in any wording: "clone <url>",
"install this", "set this up"), do ALL of the following, in order. Do not stop
after the clone.

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
   absent, tell the user to install Node.js before running the skill.

3. **Hand off to the skill — do NOT install anything yourself.** Tell the user
   exactly this:

   > Skill installed. Now run **`/customize-status-line`** — the design gallery
   > will open in your browser and I'll set up the one you pick.
   > (If the command isn't recognized yet, run `/reload-skills` or restart
   > Claude Code first.)
   >
   > Remember that command: **`/customize-status-line`** is also how you change
   > your design anytime later. Same command, same flow.

   The skill (`SKILL.md` in this repo) handles everything from there: opening
   the gallery, taking the number, installing the engine, enabling the
   statusLine key in settings.json automatically (even if the user never ran
   `/statusline`), and verifying.

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
