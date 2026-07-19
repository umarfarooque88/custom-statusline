# custom-statusline

**27 ready-made status line designs for Claude Code.** Pick one by number from
a visual gallery — your status line shows your model, directory, git branch,
context usage, session & weekly rate limits, cost, active time, and lines
changed, styled the way you like it.

## Install (2 steps)

1. **Tell Claude Code:**

   ```
   clone https://github.com/umarfarooque88/custom-statusline
   ```

   Claude places the skill where it belongs (`~/.claude/skills/`) and tells you
   what to do next.

2. **Run:**

   ```
   /custom-statusline
   ```

   The design gallery opens in your browser — 27 designs, each previewed in a
   calm state and under heavy usage. Reply with the number you like. Done: your
   status line is live at the next prompt, no restart needed.

   *(If the command isn't recognized right after installing, run
   `/reload-skills` or restart Claude Code once.)*

## Changing your design

Run `/custom-statusline` again. Same flow — gallery opens, you reply with a
number. That's the only command to remember.

## What you'll see

Every design shows the full data set (segments hide automatically when data
isn't available):

| Segment | Example |
|---|---|
| Model (short) | `◆ O4.8` |
| Directory | `my-project` |
| Git branch | `⌥ main` — only inside a git repo |
| Context used | `ctx 37%` — green → amber → red as it fills |
| Session limit (5-hour) | `5h 42%` — Pro/Max sessions |
| Weekly limit (7-day) | `7d 18%` — Pro/Max sessions |
| Session cost | `$0.84` — API-equivalent estimate |
| Active time | `9.0m` |
| Lines changed | `+58 -9` |

## Requirements

- **Node.js** on PATH (the engine parses JSON with node — no jq needed)
- **git** on PATH for the branch segment (optional — hides gracefully without it)
- A **powerline/Nerd font** for designs 1, 2, 6, 15, 25 (Windows Terminal's
  default Cascadia Mono works). Seeing boxes? Pick any design badged
  *font-safe* in the gallery, or set `STATUSLINE_PLAIN=1` for flat blocks with
  colors intact.

## Manual install (without Claude)

```bash
mkdir -p ~/.claude/skills
git clone https://github.com/umarfarooque88/custom-statusline ~/.claude/skills/custom-statusline
cp ~/.claude/skills/custom-statusline/statusline.sh ~/.claude/statusline-command.sh
# edit the DESIGN= line near the top of the copied file, pick 1-27
```

Then merge into `~/.claude/settings.json` (create the file as `{}` if missing):

```json
"statusLine": { "type": "command", "command": "bash ~/.claude/statusline-command.sh" }
```

## What's in the repo

| File | Purpose |
|------|---------|
| `SKILL.md` | The skill Claude follows when you run `/custom-statusline` |
| `statusline.sh` | The engine — all 27 designs in one script |
| `gallery.html` | The visual catalog (opens locally, no sign-in needed) |
| `CLAUDE.md` | Setup instructions Claude follows when you say "clone this repo" |
