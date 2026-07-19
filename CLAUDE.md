# Instructions for Claude — custom-statusline setup

If the user asked you to clone or install this repository (any wording: "clone
<url>", "install this", "set this up"), do ALL of the following. Do not stop
after the clone.

1. **Clone into the user's skills folder** (create it if missing):

   ```bash
   mkdir -p ~/.claude/skills
   git clone https://github.com/umarfarooque88/custom-statusline ~/.claude/skills/custom-statusline
   ```

   Already exists with a `.git`? `git -C ~/.claude/skills/custom-statusline pull --ff-only` instead.
   Already cloned somewhere else (e.g. into the current project)? Move it:
   `mv <cloned-dir> ~/.claude/skills/custom-statusline` — the skill must
   live in the skills folder to work as `/custom-statusline`.

2. **Requirements check:** `node` must be on PATH (the engine parses JSON with
   node; jq is often missing, especially on Windows Git Bash). If absent, tell
   the user to install Node.js before running the skill.

3. **Hand off to the skill — do NOT install anything yourself.** Tell the user
   exactly this:

   > Skill installed. Now run **`/custom-statusline`** — the design gallery
   > will open in your browser and I'll set up the one you pick.
   > (If the command isn't recognized yet, run `/reload-skills` or restart
   > Claude Code first.)
   >
   > Remember that command: **`/custom-statusline`** is also how you change
   > your design anytime later. Same command, same flow.

   The skill (`SKILL.md` in this repo) handles everything from there: opening
   the gallery, taking the number, installing the engine, enabling the
   statusLine key in settings.json automatically (even if the user never ran
   `/statusline`), and verifying.
