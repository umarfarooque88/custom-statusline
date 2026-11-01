# Changelog

All notable changes to this project are listed here. The format follows [Keep a Changelog](https://keepachangelog.com/en/1.1.0/), and versions follow [Semantic Versioning](https://semver.org/).

## [2.0.0] - 2026-11-01

### Changed
- **New gallery design.** The picker is now a tropical scrapbook: numbered tabs 1–27 along the top, the chosen design's colour on a taped number block, and its calm and high-use previews on full-width taped strips. Still one offline file, with fonts embedded.
- README rewritten with new screenshots, configuration, troubleshooting, update and uninstall sections.

### Added
- MIT license.
- CI: checks the engine parses, every design renders, and gallery previews match the engine.
- Contributing guide, issue templates (bug report, design idea) and a pull request template.
- `PRODUCT.md` with product context for design work on the gallery.

## [1.0.0] - 2026-07-19

### Added
- 27 status line designs in one engine (`statusline.sh`), selectable by number with `/custom-statusline`.
- Visual gallery with calm and high-use previews generated from real engine output (`tools/build-gallery.js`).
- Every design shows model, directory, git branch, context, 5h limit with reset countdown, 7d limit, cost, active time and lines changed.
- Node-based JSON parsing (no `jq`), shell-free git branch detection, `STATUSLINE_PLAIN=1` glyph fallback.
- Automatic `settings.json` merge that enables the status line without overwriting other settings.
- `?pick=N` deep links and a GitHub Pages copy of the gallery.

[2.0.0]: https://github.com/umarfarooque88/custom-statusline/compare/2b89eaf...v2.0.0
[1.0.0]: https://github.com/umarfarooque88/custom-statusline/tree/2b89eaf
