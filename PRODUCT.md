# Product

<!-- impeccable:product-schema 1 -->

## Platform

web

## Users

Claude Code users who just ran `/custom-statusline` (or run it again to switch). They open the gallery once, compare status line previews, and reply in Claude Code with a design number. Success: they pick confidently and type the number.

## Product Purpose

custom-statusline is a Claude Code skill offering 27 ready-made status line designs, selectable by number. The gallery is the decision surface: browse, compare calm vs high-use rendering, pick a number. The skill then installs the engine and enables the status line automatically.

## Positioning

Every preview is the real engine's output (ANSI rendered to HTML by `tools/build-gallery.js`), not a mockup, and every design shows all fields (model, dir, branch, ctx%, 5h%, 7d%, cost, time, +/- lines) in both a calm and a high-use state. Picking is one number; changing later is the same command.

## Operating Context

- The gallery is opened as a local file (`gallery.html`) by the skill, in the user's default browser, next to a Claude Code terminal.
- Flow: `/custom-statusline` → gallery opens → user replies with a number → engine installed → verified.
- Designs are grouped: Everyday (1–5), Expressive (6–10), Style studies (11–20), Game art styles (21–27). Some need a Nerd Font / emoji ("font" badge), the rest are font-safe.

## Capabilities and Constraints

- Previews are generated, never hand-edited: `tools/build-gallery.js` rewrites the block between `PREVIEWS:BEGIN/END` markers.
- Must keep: number keys / arrows / Enter navigation, copy-number button, `?pick=N` deep links, font-safe filter.
- Single self-contained offline HTML file: no CDN fonts, no network requests.

## Brand Commitments

- Command name `/custom-statusline` is taught everywhere and stays.
- Author credit in the page: Umar Farooque, GitHub (github.com/umarfarooque88), LinkedIn (linkedin.com/in/umar-farooque88).

## Evidence on Hand

- 27 engine-rendered previews (calm + high use) in `gallery.html`.
- Screenshots in `docs/images/`.
- No testimonials, user counts or benchmarks exist; do not invent any.

## Product Principles

- The previews are the product; the page exists to make comparing them easy.
- Truthful rendering over flattering mockups.
- One number, one command: picking and changing must stay effortless.
