// ansi2html — converts one line of the engine's ANSI output into gallery
// preview HTML, so gallery.html shows exactly what the terminal shows.
//
// Handles the SGR subset the engine emits: 38;2 (fg), 48;2 (bg), 1/22 (bold),
// 39/49 (fg/bg-only reset), 0 (reset). Powerline glyphs U+E0B0 (arrow),
// U+E0B6/U+E0B4 (round caps) and U+E0A0 (branch) are emulated with CSS/SVG
// shapes — the browser may not have a nerd font, and the shapes are drawn as
// the terminal font draws them. Every other character passes through verbatim.
"use strict";

const ARW = "", CAP_L = "", CAP_R = "", BRANCH = "";
const escHtml = (t) => t.replace(/&/g, "&amp;").replace(/</g, "&lt;").replace(/>/g, "&gt;");

function ansi2html(line) {
  let fg = null, bg = null, bold = false;
  let out = "", buf = "";
  const flush = () => {
    if (!buf) return;
    const st = [];
    if (fg) st.push("color:" + fg);
    if (bg) st.push("background:" + bg);
    if (bold) st.push("font-weight:700");
    out += '<span class="r"' + (st.length ? ' style="' + st.join(";") + '"' : "") + ">" + escHtml(buf) + "</span>";
    buf = "";
  };
  const glyph = (ch) => {
    flush();
    if (ch === ARW)
      out += `<span class="g arw" style="background:${bg || "transparent"}"><i style="background:${fg || "currentColor"};clip-path:polygon(0 0,0 100%,100% 50%)"></i></span>`;
    else if (ch === CAP_L)
      out += `<span class="g cap"><i style="background:${fg || "currentColor"};border-radius:999px 0 0 999px"></i></span>`;
    else if (ch === CAP_R)
      out += `<span class="g cap"><i style="background:${fg || "currentColor"};border-radius:0 999px 999px 0"></i></span>`;
    else if (ch === BRANCH)
      out += `<span class="g br"${bg ? ` style="background:${bg}"` : ""}><svg viewBox="0 0 10 13" style="display:block;width:100%;height:100%"><g stroke="${fg || "currentColor"}" fill="none" stroke-width="1.1"><circle cx="2.7" cy="2.8" r="1.4"/><circle cx="2.7" cy="10.2" r="1.4"/><circle cx="7.3" cy="4.4" r="1.4"/><path d="M2.7 4.2v4.6M7.3 5.8c0 2.6-4.6 1.9-4.6 4.4"/></g></svg></span>`;
  };
  const text = (t) => {
    for (const ch of t) {
      if (ch === ARW || ch === CAP_L || ch === CAP_R || ch === BRANCH) glyph(ch);
      else buf += ch;
    }
  };
  const re = /\x1b\[([0-9;]*)m/g;
  let last = 0, m;
  while ((m = re.exec(line))) {
    text(line.slice(last, m.index));
    last = re.lastIndex;
    const p = (m[1] || "0").split(";").map(Number);
    for (let i = 0; i < p.length; i++) {
      const code = p[i];
      if (code === 0) { flush(); fg = null; bg = null; bold = false; }
      else if (code === 1) { if (!bold) flush(); bold = true; }
      else if (code === 22) { if (bold) flush(); bold = false; }
      else if (code === 38 && p[i + 1] === 2) { flush(); fg = `rgb(${p[i + 2]},${p[i + 3]},${p[i + 4]})`; i += 4; }
      else if (code === 48 && p[i + 1] === 2) { flush(); bg = `rgb(${p[i + 2]},${p[i + 3]},${p[i + 4]})`; i += 4; }
      else if (code === 39) { flush(); fg = null; }
      else if (code === 49) { flush(); bg = null; }
    }
  }
  text(line.slice(last));
  flush();
  return out;
}

if (require.main === module) {
  const fs = require("fs");
  const input = fs.readFileSync(process.argv[2] ?? 0, "utf8").replace(/\r?\n$/, "");
  process.stdout.write(ansi2html(input));
}
module.exports = { ansi2html };
