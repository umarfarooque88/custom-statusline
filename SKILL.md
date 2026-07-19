---
name: custom-statusline
description: Use when the user wants to choose, change, restyle, or set up their Claude Code status line — e.g. "customize my status line", "change statusline design", "pick a statusline style", "make my status bar look better", or after they mention a design number from the status line gallery.
---

# Customize Status Line

## Overview

27 ready-made status line designs for Claude Code, selectable by number. A single
engine script (`statusline.sh` in this skill's directory) contains every design;
installing one = copy the engine + set one number. No design needs to be rebuilt
by hand, ever.

All designs show the same data, each in its own style: short model name, cwd
basename, git branch (auto-hidden outside repos), context %, 5-hour session
usage %, 7-day weekly usage %, session cost, active time, +lines/−lines.
Every segment degrades gracefully when its data is absent.

## Workflow

1. **Show the catalog.** Open the local `gallery.html` (in this skill's
   directory) in the user's default browser — do NOT publish an artifact
   (artifact URLs require being signed in to claude.ai in the active browser,
   which often isn't the case):
   - Windows: `start "" "<skill-dir>/gallery.html"` (Git Bash) or
     `Start-Process "<skill-dir>\gallery.html"` (PowerShell)
   - macOS: `open "<skill-dir>/gallery.html"`
   - Linux: `xdg-open "<skill-dir>/gallery.html"`
   The file is self-contained; updated designs ship with the repo, so the local
   copy is always the current catalog.
2. **Ask for a number** (1–27). The gallery shows each design in calm and
   high-usage states, with font requirements badged per card.
3. **Install** (see below).
4. **Verify** (see below). Only claim success after the verify step passes.

If the user already names a number ("give me 14"), skip straight to install.

## Install

```bash
cp <skill-dir>/statusline.sh ~/.claude/statusline-command.sh
```

Then set the chosen number in the copied file — edit the line near the top:

```sh
DESIGN="${STATUSLINE_DESIGN:-N}"   # replace N (ships as 2) with the chosen number
```

To merge `settings.json` safely on Windows, use node (jq is often absent):
a small `node -e` script that reads the file, sets the `statusLine` key, and
writes it back pretty-printed is the reliable route.

Ensure `~/.claude/settings.json` contains (merge, don't clobber other keys; if
the file doesn't exist — the user never ran `/statusline` — create it as `{}`
first, then merge; this auto-enables the status line):

```json
"statusLine": { "type": "command", "command": "bash ~/.claude/statusline-command.sh" }
```

**Requirements check before installing:** `node` must be on PATH (the engine
parses JSON with node because jq is often missing, especially on Windows Git
Bash). If node is absent, stop and tell the user to install Node.js first.

## Verify

Pipe a sample payload through the installed script and confirm non-empty,
error-free output:

```bash
echo '{"model":{"display_name":"Opus 4.8"},"workspace":{"current_dir":"'"$PWD"'"},"context_window":{"used_percentage":37},"rate_limits":{"five_hour":{"used_percentage":42},"seven_day":{"used_percentage":18}},"cost":{"total_cost_usd":0.84,"total_duration_ms":540000,"total_lines_added":58,"total_lines_removed":9}}' | bash ~/.claude/statusline-command.sh
```

ANSI escape soup is expected in captured output — failure looks like emptiness,
`jq: command not found`, or a node stack trace. Every design renders the full
data set (model, dir, ctx, 5h, 7d, cost, time, ±lines) when the payload provides
it — with the sample payload above, all those values must appear. The branch
segment additionally requires `current_dir` to be inside a git repo; it hides
elsewhere by design.
Success = non-empty output containing the sample values, no error text.

## Design catalog (numbers)

| # | Name | Font needs | | # | Name | Font needs |
|---|------|------------|-|---|------|------------|
| 1 | Kiln Flow | nerd-font | | 15 | Glassmorphic | nerd-font |
| 2 | Nightshade | nerd-font | | 16 | Memphis | safe |
| 3 | Hairline | safe | | 17 | Art Deco | safe |
| 4 | Gauge | safe | | 18 | Nord | safe |
| 5 | Blocks | safe | | 19 | Dracula | safe |
| 6 | Claymorphic | nerd-font | | 20 | Terminal Rain | safe |
| 7 | Arcade HUD | emoji | | 21 | Flat (Monument Valley) | safe |
| 8 | Gradient Sweep | safe | | 22 | Vector | stroke caps |
| 9 | Synthwave | safe | | 23 | Geometric Art | safe |
| 10 | Phosphor LCD | safe | | 24 | Pixel (Stardew) | safe |
| 11 | Brutalist | safe | | 25 | Cartoon (TF2) | nerd-font |
| 12 | Bauhaus | safe | | 26 | Cel Shading (Wind Waker) | safe |
| 13 | Swiss | safe | | 27 | Monochromatic (Inside) | safe |
| 14 | Wabi-sabi | safe | | | | |

"nerd-font" designs use powerline glyphs (arrows / round caps / branch).
Windows Terminal's default Cascadia Mono has them. "stroke caps" (Vector) uses
❬ ❭, present in Cascadia but not every legacy font. If glyphs render as boxes,
either pick a "safe" design or set `STATUSLINE_PLAIN=1` in the environment —
the engine falls back to plain-glyph equivalents with colors intact.

The gallery previews are generated from the engine's real output by
`tools/build-gallery.js` — run it after any change to a design so the gallery
never drifts from the terminal.

## Common mistakes

- **Overwriting settings.json wholesale** — always merge the `statusLine` key
  into the existing file; users have other settings there.
- **Rebuilding a design by hand from the gallery HTML** — never do this; the
  engine already implements all 27. Only copy + set the number.
- **Claiming success without the verify step** — rate-limit and cost segments
  only appear in real sessions; the sample-payload pipe is the only reliable
  pre-flight check.
- **Testing git detection from a non-repo directory** — the branch segment is
  meant to disappear there; that is not a bug.

## Changing designs later

The user runs `/custom-statusline` again — same flow (gallery → number →
install → verify). Always end a successful install by teaching this:
"Run `/custom-statusline` anytime to change your design."

Mechanically, a switch is just editing the `DESIGN=` line in
`~/.claude/statusline-command.sh` (or `STATUSLINE_DESIGN=<n>` in the
environment — env wins). No reinstall needed.
