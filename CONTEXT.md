# CONTEXT — how this project came to be

Narrative context for a new session. HANDOVER.md has the technical state; this
file explains the history, the user, and the decisions — read both.

## The user

- Windows 11, Git Bash primary shell alongside PowerShell 5.1; home path has a
  space (`C:\Users\UMAR FAROOQUE`). Node v22 present, jq absent.
- Uses Claude Code with Pro/Max (rate-limit meters apply), model Fable 5.
- Terminal: Windows Terminal — nerd-font glyphs (powerline arrows/caps) render.
- Communicates tersely, often just a number or short phrase; wants fast,
  concrete action. Pushed back hard exactly twice — remember why:
  1. Rejected an elaborate installer/UX-flow proposal (curl|bash, install.sh,
     arg grammars) as over-engineering: "no fuck no stop that". The flow must
     stay: clone → /customize-status-line → number. Nothing more.
  2. Insisted README.md be user-facing only; Claude-directed instructions were
     moved to CLAUDE.md.

## Timeline (one session, 2026-07-19, run from D:\game)

1. Started as a simple /statusline setup; no PS1 existed, so a custom status
   line script was built at ~/.claude/statusline-command.sh.
2. Iterated: jq→node rewrite (jq missing), added context %, then 5h/7d rate
   limits (field paths verified against official statusline docs via a
   claude-code-guide agent), short model names (Opus 4.8 → O4.8), powerline
   styling ("Kiln Flow"), then a bug: git branch missing on Windows —
   execSync+shell-redirection died under cmd.exe; fixed with execFileSync.
3. User asked for design options → a gallery artifact grew from 5 → 10 → 20 →
   27 designs (Everyday, Expressive, Style studies, Game art styles — the last
   from a game-art-styles image the user provided: Flat/Vector/Geometric/
   Pixel/Cartoon/Cel-shading/Monochromatic).
4. User picked 2 (Nightshade, currently live), later test-drove 6 and 15.
5. All 27 designs were folded into ONE engine (statusline.sh, DESIGN=n) and
   wrapped as a skill with SKILL.md + gallery.html; skill was cold-tested by
   sandboxed subagents (caught: #14 missing from catalog table, source dir not
   yet a git repo, CRLF-would-break-bash → .gitattributes).
6. Major bug fixed on user report: many designs dropped cost/time/±lines.
   Now EVERY design renders the complete data set (enforced by tailTxt()/tl()
   helpers + token-matrix tests). This is a user-stated invariant.
7. Flow finalized: CLAUDE.md drives the clone step; SKILL.md drives
   gallery→number→install→verify; /customize-status-line is taught in README,
   gallery banner, all 27 card chips, and the install success message.
8. Repo initialized (main, 6+ commits). No remote yet.

## Why things are the way they are (decision log)

- **Local gallery.html, never an artifact link**: user hit artifact sign-in
  friction in a different browser. Local file works everywhere.
- **node -e for JSON everywhere** (engine + settings.json merges): jq absent on
  Windows Git Bash; PowerShell 5.1 lacks `&&` and ConvertFrom-Json is clumsy.
- **execFileSync for git**: node's execSync spawns cmd.exe on Windows; POSIX
  redirection silently killed branch detection.
- **DESIGN number inside the installed script** (not a config file): switching
  = one sed edit or STATUSLINE_DESIGN env override; zero extra files.
- **Skill lives in ~/.claude/skills/** (personal, all projects). It did not
  exist before this project; we created it.
- **Cost display**: cost.total_cost_usd is Claude Code's own API-equivalent
  estimate; we format only. User asked and was told this — if cost accuracy
  comes up again, that's the answer.
- **Testing style**: strip ANSI, token-assert; tr for case (grep -i SIGABRTs
  here); sandboxed fake-home subagents for skill UX changes.

## Current session-spanning facts

- Live status line: design 2 Nightshade; engine copy at
  ~/.claude/statusline-command.sh has DESIGN=2.
- Four copies to keep in sync (see HANDOVER.md "Deployment copies").
- The gallery artifact URL still exists (922ff4f0-…) but is legacy — the local
  file is canonical.

## Immediate next steps (user intent)

1. User will create a GitHub repo and push (likely under umarfaruk1026@gmail.com
   account). Then: fill `<repo-URL>` placeholders in README.md + CLAUDE.md and
   the empty URL comment at statusline.sh line 3; commit.
2. After push, optionally test the real end-to-end: fresh clone by URL on a
   sandboxed fake home (pattern in HANDOVER.md).
3. User's other project (Claycraft, D:\game) is unrelated — don't mix them.
