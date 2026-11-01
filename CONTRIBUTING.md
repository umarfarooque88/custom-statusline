# Contributing

Thanks for helping. Bug reports, design ideas and fixes are all welcome.

## Reporting a bug or suggesting a design

Open an [issue](https://github.com/umarfarooque88/custom-statusline/issues/new/choose) and pick a template. For rendering bugs, a screenshot of the status line and your terminal + font save a lot of back-and-forth.

## Working on the code

You need **Node.js**, **bash** (Git Bash on Windows) and **git**.

```bash
git clone https://github.com/umarfarooque88/custom-statusline
cd custom-statusline
```

### Try a design in your terminal

Pipe a sample session into the engine and choose the design with `STATUSLINE_DESIGN`:

```bash
echo '{"model":{"display_name":"Opus 4.8"},"workspace":{"current_dir":"'"$PWD"'"},"context_window":{"used_percentage":88},"rate_limits":{"five_hour":{"used_percentage":71},"seven_day":{"used_percentage":92}},"cost":{"total_cost_usd":3.1,"total_duration_ms":2820000,"total_lines_added":612,"total_lines_removed":208}}' \
  | STATUSLINE_DESIGN=9 bash statusline.sh; echo
```

Add `STATUSLINE_PLAIN=1` to check the plain-glyph fallback.

### How designs are organised

All designs live in the `DESIGNS` table inside [`statusline.sh`](statusline.sh), keyed by number. Each entry is a function that returns one line of ANSI text, built from the shared session data (`S.model`, `S.dir`, `S.branch`, `S.ctx`, `S.h5`, `S.d7`, …) and helpers such as `c()`, `fg()`, `bg()`, `pct()`, `mk()` and `tailTxt()`.

Rules every design follows:

1. **Show every field** when its data exists: model, directory, branch, context, 5h (with reset countdown), 7d, cost, time, lines added/removed. `tailTxt()` covers the last four.
2. **Hide gracefully** when data is missing. Never print empty brackets or `undefined`.
3. **Warn visibly.** A meter at 80% or more must look different from a calm one.
4. **Mark font needs.** If a design uses Powerline/Nerd Font glyphs, give it a plain fallback under `STATUSLINE_PLAIN=1` and mark it in the gallery's `CARDS` list (`badge: [..., 'font']`).

### Regenerate the gallery

The previews in `gallery.html` are generated from the engine. After **any** change to `statusline.sh`, run:

```bash
node tools/build-gallery.js
```

and commit the updated `gallery.html` with your change. CI fails if the previews are stale.

To change a design's name, group or description, edit the `CARDS` list near the top of the `<script>` in `gallery.html`. Never hand-edit the block between `PREVIEWS:BEGIN` and `PREVIEWS:END`.

### Line endings

The repo forces LF (`.gitattributes`). A CRLF `statusline.sh` breaks bash on Windows with `\r: command not found`, so don't override it.

## Pull requests

- Keep each PR to one change.
- Fill in the checklist in the PR template.
- Describe what you tested on (Windows Git Bash, macOS or Linux).

By contributing you agree that your work is released under the [MIT License](LICENSE).
