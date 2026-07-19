# custom-statusline

**27 ready-made status line designs for Claude Code.** Pick one by number from
a visual gallery — your status line shows your model, directory, git branch,
context usage, session & weekly rate limits (with a countdown to when the
5-hour window resets), cost, active time, and lines changed, styled the way you
like it.

**▶ [Browse all 27 designs online](https://umarfarooque88.github.io/custom-statusline/)** — previews are rendered from the real engine output, no install needed.

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
| Git branch | `▸ main` — only inside a git repo |
| Context used | `ctx 37%` — green → amber → red as it fills |
| Session limit (5-hour) | `5h 42% (2h13m)` — usage %, and time until the window resets; Pro/Max sessions |
| Weekly limit (7-day) | `7d 18%` — Pro/Max sessions |
| Session cost | `$0.84` — API-equivalent estimate |
| Active time | `00:09` — hours:minutes |
| Lines changed | `+58 -9` |

The `(2h13m)` reset countdown appears once the 5-hour window has a reset time
(Pro/Max, after the first response); it hides until then. Nerd-font designs
draw the branch with a powerline glyph rather than `▸`.

## Requirements

- **Node.js** on PATH (the engine parses JSON with node — no jq needed)
- **git** on PATH for the branch segment (optional — hides gracefully without it)
- A **powerline/Nerd font** for designs 1, 2, 6, 15, 25 (and the ❬ ❭ stroke
  caps of 22); Windows Terminal's default Cascadia Mono has them. Seeing boxes?
  Pick any design badged *font-safe* in the gallery, or set `STATUSLINE_PLAIN=1`
  for plain-glyph fallbacks with colors intact.

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
| `gallery.html` | The visual catalog (opens locally, no sign-in needed) — previews are generated from real engine output |
| `tools/` | `build-gallery.js` regenerates the gallery previews from the engine (run after editing a design); `ansi2html.js` converts terminal output to preview HTML |
| `CLAUDE.md` | Setup instructions Claude follows when you say "clone this repo" |
