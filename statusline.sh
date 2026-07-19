#!/bin/sh
# customize-status-line engine — 27 selectable designs for the Claude Code statusLine.
# https://github.com/umarfarooque88/customize-status-line  (part of the customize-status-line skill project)
#
# Design is picked by number (1-27), see gallery.html or SKILL.md for the catalog.
# Install: copy this file to ~/.claude/statusline-command.sh, set DESIGN below,
# and point settings.json at it:  "statusLine": {"type":"command","command":"bash ~/.claude/statusline-command.sh"}
#
# Requirements: node on PATH (JSON parsing; jq is often absent on Windows Git Bash).
# Git branch detection uses execFileSync (no shell) so it works on Windows too.
# Designs marked "nerd-font" use powerline glyphs (   ) — Windows Terminal's
# Cascadia Mono has them. STATUSLINE_PLAIN=1 swaps them for flat blocks.

DESIGN="${STATUSLINE_DESIGN:-2}"   # <<< set your design number here (1-27)

input=$(cat)

printf '%s' "$input" | DESIGN="$DESIGN" STATUSLINE_PLAIN="${STATUSLINE_PLAIN:-0}" node -e '
const fs = require("fs");
const { execFileSync } = require("child_process");

let d = {};
try { d = JSON.parse(fs.readFileSync(0, "utf8") || "{}"); } catch (e) {}
const g = (o, p) => p.split(".").reduce((a, k) => (a == null ? undefined : a[k]), o);

// ---------- shared data -----------------------------------------------------
const modelFull = g(d, "model.display_name") || "unknown";
const shortModel = (name) => {
  const n = name.replace(/^claude[\s-]*/i, "").trim();
  const tier = n.match(/opus|sonnet|haiku|fable/i);
  const ver = (n.match(/\d+(?:\.\d+)?/) || [])[0] || "";
  return tier ? tier[0][0].toUpperCase() + ver : n.split(/\s+/)[0];
};
const cwd = g(d, "workspace.current_dir") || d.cwd || "unknown";
const S = {
  model: shortModel(modelFull),
  dir: cwd.replace(/[\\/]+$/, "").split(/[\\/]/).pop() || cwd,
  branch: "",
  ctx: g(d, "context_window.used_percentage"),
  h5: g(d, "rate_limits.five_hour.used_percentage"),
  d7: g(d, "rate_limits.seven_day.used_percentage"),
  cost: g(d, "cost.total_cost_usd"),
  durMs: g(d, "cost.total_duration_ms"),
  add: g(d, "cost.total_lines_added"),
  del: g(d, "cost.total_lines_removed"),
};
try {
  const run = (args) => execFileSync("git", ["--no-optional-locks", "-C", cwd, ...args],
    { stdio: ["ignore", "pipe", "ignore"] }).toString().trim();
  try { S.branch = run(["symbolic-ref", "--short", "HEAD"]); }
  catch (e) { S.branch = run(["rev-parse", "--short", "HEAD"]); }   // detached HEAD
} catch (e) {}

const has = (v) => v != null && !isNaN(v);
const pct = (v) => Math.round(v) + "%";
const costS = has(S.cost) ? "$" + Number(S.cost).toFixed(2) : null;
const durS  = has(S.durMs) ? (S.durMs / 60000).toFixed(1) + "m" : null;
const hasLines = S.add != null || S.del != null;

// ---------- ANSI helpers ----------------------------------------------------
const hx = (h) => [1, 3, 5].map((i) => parseInt(h.slice(i, i + 2), 16));
const fg = (h) => { const [r, g2, b] = hx(h); return `\x1b[38;2;${r};${g2};${b}m`; };
const bg = (h) => { const [r, g2, b] = hx(h); return `\x1b[48;2;${r};${g2};${b}m`; };
const R = "\x1b[0m", B = "\x1b[1m", NB = "\x1b[22m";
const c = (h, t) => fg(h) + t;

const plain = process.env.STATUSLINE_PLAIN === "1";
const ARW = plain ? "" : "";           // powerline arrow
const CL = plain ? "" : "", CR = plain ? "" : ""; // round caps

// segment renderers shared by several designs
const flow = (segs, tailBg) => {          // flush arrows (Kiln)
  let out = "";
  segs.forEach((s2, i) => {
    out += bg(s2.bg) + s2.inner;
    const nx = i + 1 < segs.length ? segs[i + 1].bg : tailBg;
    out += (nx ? bg(nx) : R) + fg(s2.bg) + ARW;
  });
  return out + R;
};
const pills = (list, capify) => list.map((p) =>
  (capify ? fg(p.bg) + CL : "") + bg(p.bg) + p.inner + R + (capify ? fg(p.bg) + CR : "")
).join(" ") + R;
const blocks = (list) => list.map((p) => bg(p.bg) + p.inner + R).join("") + R;

// threshold color helper factory
const mk = (calm, warm, crit) => (p) => !has(p) ? calm : p >= 80 ? crit : p >= 50 ? warm : calm;

// full tail (cost, active time, +lines -lines) — EVERY design must render all data
const tailTxt = (mut, addC, delC, sep) => {
  sep = sep || " ";
  const bits = [costS, durS].filter(Boolean);
  let t = bits.length ? c(mut, bits.join(sep)) : "";
  if (hasLines) t += (t ? sep : "") + c(addC, "+" + (S.add || 0)) + " " + c(delC, "-" + (S.del || 0));
  return t || null;
};

// ---------- the 27 designs --------------------------------------------------
const DESIGNS = {

1: () => { // Kiln Flow — warm powerline (nerd-font)
  const W = { coral:"#D97757", slate:"#2E2A2A", clay:"#7A5A4A", ink:"#1E1B1A", cream:"#F2EFEA",
    sage:"#8A9A5B", amber:"#E0A84A", danger:"#C94A3E", add:"#96C878", del:"#D66E64", mut:"#A89E96" };
  const mc = mk(W.sage, W.amber, W.danger);
  const segs = [
    { bg: W.coral, inner: fg(W.ink) + ` ${B}◆ ${S.model}${NB} ` },
    { bg: W.slate, inner: fg(W.cream) + ` ${S.dir} ` },
    S.branch && { bg: W.clay, inner: fg(W.cream) + ` ⌥ ${S.branch} ` },
    has(S.ctx) && { bg: mc(S.ctx), inner: fg(W.ink) + ` ctx ${pct(S.ctx)} ` },
    (has(S.h5) || has(S.d7)) && { bg: W.slate, inner: " " +
      [has(S.h5) && c(W.mut,"5h ") + c(mc(S.h5), pct(S.h5)), has(S.d7) && c(W.mut,"7d ") + c(mc(S.d7), pct(S.d7))]
      .filter(Boolean).join(c(W.mut," · ")) + " " },
  ].filter(Boolean);
  const tailBits = [costS, durS].filter(Boolean).join("  ");
  let tail = null;
  if (tailBits || hasLines) tail = { bg: W.ink, inner: fg(W.mut) + " " + tailBits +
    (hasLines ? (tailBits ? "  " : "") + c(W.add, `+${S.add||0}`) + " " + c(W.del, `-${S.del||0}`) : "") + " " };
  return flow(segs.concat(tail ? [tail] : []), null);
},

2: () => { // Nightshade — floating round capsules (nerd-font)
  const K = { lav:"#B5A8FF", ink:"#181626", dir:"#34324A", dirfg:"#E8E6F5", br:"#443F66",
    tail:"#242336", mint:"#7FD1AE", amber:"#F0C36A", rose:"#F0798A", mut:"#8E8BAC" };
  const mc = mk(K.mint, K.amber, K.rose);
  const L = [
    { bg: K.lav, inner: fg(K.ink) + B + `◆ ${S.model}` + NB },
    { bg: K.dir, inner: fg(K.dirfg) + S.dir },
    S.branch && { bg: K.br, inner: fg(K.lav) + `⎇ ${S.branch}` },
    has(S.ctx) && { bg: K.tail, inner: c(K.mut, "ctx ") + c(mc(S.ctx), pct(S.ctx)) },
    (has(S.h5) || has(S.d7)) && { bg: K.tail, inner:
      [has(S.h5) && c(K.mut,"5h ") + c(mc(S.h5), pct(S.h5)), has(S.d7) && c(K.mut,"7d ") + c(mc(S.d7), pct(S.d7))]
      .filter(Boolean).join("  ") },
  ].filter(Boolean);
  const bits = [costS, durS].filter(Boolean).join("  ");
  if (bits || hasLines) L.push({ bg: K.tail, inner: fg(K.mut) + bits +
    (hasLines ? (bits ? "  " : "") + c(K.mint, `+${S.add||0}`) + " " + c(K.rose, `-${S.del||0}`) : "") });
  return pills(L, true);
},

3: () => { // Hairline — colored text + thin rules (font-safe)
  const W = { coral:"#D97757", mut:"#A89E96", sage:"#8A9A5B", amber:"#E0A84A", danger:"#C94A3E" };
  const mc = mk(W.sage, W.amber, W.danger);
  const div = c("#5a534c", "│");
  return [
    B + c(W.coral, "◆ " + S.model) + NB,
    c("#dcd6cc", S.dir),
    S.branch && c("#c69a54", "⌥ " + S.branch),
    has(S.ctx) && c(mc(S.ctx), "ctx " + pct(S.ctx)),
    (has(S.h5) || has(S.d7)) && [has(S.h5) && c(W.mut,"5h ")+c(mc(S.h5),pct(S.h5)), has(S.d7) && c(W.mut,"7d ")+c(mc(S.d7),pct(S.d7))].filter(Boolean).join(c("#6a625a"," · ")),
    (costS||durS||hasLines) && c("#7c736a", [costS,durS].filter(Boolean).join("  ") + (hasLines?`  +${S.add||0} -${S.del||0}`:"")),
  ].filter(Boolean).join(`  ${div}  `) + R;
},

4: () => { // Gauge — block-bar meters (font-safe)
  const W = { coral:"#D97757", cream:"#F2EFEA", clay:"#7A5A4A", mut:"#A89E96",
    sage:"#8A9A5B", amber:"#E0A84A", danger:"#C94A3E", track:"#3a342e" };
  const mc = mk(W.sage, W.amber, W.danger);
  const bar = (p, cells) => { const f = p<=0?0:Math.max(1,Math.round(p/100*cells));
    return c("#5b544c","▕") + c(mc(p), "█".repeat(f)) + c(W.track, "█".repeat(cells-f)) + c("#5b544c","▏"); };
  return [
    B + c(W.coral, "◆ " + S.model) + NB + " " + c(W.cream, S.dir) + (S.branch ? " " + c(W.clay, "⌥" + S.branch) : ""),
    has(S.ctx) && c(W.mut,"ctx ") + bar(S.ctx,8) + " " + c(mc(S.ctx), pct(S.ctx)),
    has(S.h5) && c(W.mut,"5h ") + bar(S.h5,4) + " " + c(mc(S.h5), pct(S.h5)),
    has(S.d7) && c(W.mut,"7d ") + bar(S.d7,4) + " " + c(mc(S.d7), pct(S.d7)),
    tailTxt("#7c736a", W.sage, W.danger),
  ].filter(Boolean).join("   ") + R;
},

5: () => { // Blocks — hard-edged bars, no glyphs (font-safe)
  const W = { coral:"#D97757", ink:"#1E1B1A", cream:"#F2EFEA", clay:"#7A5A4A",
    sage:"#8A9A5B", amber:"#E0A84A", danger:"#C94A3E", add:"#96C878", del:"#D66E64", mut:"#A89E96" };
  const mc = mk(W.sage, W.amber, W.danger);
  const L = [
    { bg: W.coral, inner: fg(W.ink) + ` ${B}◆ ${S.model}${NB} ` },
    { bg: "#403a34", inner: fg(W.cream) + ` ${S.dir} ` },
    S.branch && { bg: W.clay, inner: fg(W.cream) + ` ⌥ ${S.branch} ` },
    has(S.ctx) && { bg: mc(S.ctx), inner: fg(W.ink) + ` ctx ${pct(S.ctx)} ` },
    (has(S.h5)||has(S.d7)) && { bg:"#2a2622", inner: " " + [has(S.h5)&&c(W.mut,"5h ")+c(mc(S.h5),pct(S.h5)), has(S.d7)&&c(W.mut,"7d ")+c(mc(S.d7),pct(S.d7))].filter(Boolean).join(" ") + " " },
    (costS||durS||hasLines) && { bg: W.ink, inner: fg(W.mut) + " " + [costS,durS].filter(Boolean).join(" ") +
      (hasLines ? " " + c(W.add,`+${S.add||0}`) + " " + c(W.del,`-${S.del||0}`) : "") + " " },
  ].filter(Boolean);
  return blocks(L);
},

6: () => { // Claymorphic — pastel clay pills (nerd-font caps)
  const K = { terra:"#E0906E", sand:"#E7D3AC", brown:"#BE9A75", ink:"#4A3A2E", cream:"#FBF3E6",
    sage:"#AEC58C", warn:"#E6B24C", crit:"#DE7B63", mut:"#9C8B78" };
  const mc = mk(K.sage, K.warn, K.crit);
  const L = [
    { bg: K.terra, inner: fg(K.ink) + B + `◆ ${S.model}` + NB },
    { bg: K.sand, inner: fg(K.ink) + S.dir },
    S.branch && { bg: K.brown, inner: fg(K.cream) + `⌥ ${S.branch}` },
    has(S.ctx) && { bg: mc(S.ctx), inner: fg(K.ink) + `ctx ${pct(S.ctx)}` },
    (has(S.h5)||has(S.d7)) && { bg: K.sand, inner: [has(S.h5)&&c(K.mut,"5h ")+c(mc(S.h5),pct(S.h5)), has(S.d7)&&c(K.mut,"7d ")+c(mc(S.d7),pct(S.d7))].filter(Boolean).join("  ") },
    (costS||durS||hasLines) && { bg: K.brown, inner: tailTxt(K.cream, "#D8E8C0", "#F8D0C0", " · ") },
  ].filter(Boolean);
  return pills(L, true);
},

7: () => { // Arcade HUD — health/energy bars + emoji (emoji glyphs)
  const W = { cream:"#F2EFEA", mut:"#A89E96", sage:"#8A9A5B", amber:"#E0A84A", danger:"#C94A3E", track:"#3a342e" };
  const mc = mk(W.sage, W.amber, W.danger);
  const xp = (p, cells) => { const f = p<=0?0:Math.max(1,Math.round(p/100*cells));
    return c(mc(p), "▰".repeat(f)) + c(W.track, "▱".repeat(cells-f)); };
  return [
    c("#F0C36A","★") + " " + B + c(W.cream, S.model) + NB,
    c("#8fb0d6","▸") + " " + c(W.cream, S.dir),
    S.branch && c("#c69a54", "⑂ " + S.branch),
    has(S.ctx) && c(mc(S.ctx),"❤") + " " + xp(S.ctx,6) + " " + c(mc(S.ctx), pct(S.ctx)),
    (has(S.h5)||has(S.d7)) && c("#F0C36A","⚡") + " " + [has(S.h5)&&"5h "+xp(S.h5,4)+" "+c(mc(S.h5),pct(S.h5)), has(S.d7)&&"7d "+xp(S.d7,4)+" "+c(mc(S.d7),pct(S.d7))].filter(Boolean).join("  "),
    (costS||durS||hasLines) && c("#E7C15A","◈ ") + tailTxt(W.mut, W.sage, W.danger),
  ].filter(Boolean).join("   ") + R;
},

8: () => { // Gradient Sweep — per-character color flow (font-safe)
  const stops = ["#D97757","#E0A84A","#8A9A5B","#5AB0C0","#9B7BE0"].map(hx);
  const parts = [`◆ ${S.model}`, S.dir, S.branch, has(S.ctx)&&`ctx ${pct(S.ctx)}`,
    (has(S.h5)||has(S.d7)) && [has(S.h5)&&`5h ${pct(S.h5)}`, has(S.d7)&&`7d ${pct(S.d7)}`].filter(Boolean).join(" · "),
    (costS||durS||hasLines)&&[costS,durS,hasLines?("+"+(S.add||0)+" -"+(S.del||0)):null].filter(Boolean).join(" ")].filter(Boolean);
  const str = parts.join("  ›  ");
  const chars = [...str], n = chars.length;
  return chars.map((ch, i) => {
    if (ch === " ") return " ";
    const t = n <= 1 ? 0 : i / (n - 1), seg = t * (stops.length - 1),
      k = Math.min(stops.length - 2, Math.floor(seg)), f2 = seg - k, a = stops[k], b2 = stops[k + 1];
    const L2 = (x, y) => Math.round(x + (y - x) * f2);
    return `\x1b[38;2;${L2(a[0],b2[0])};${L2(a[1],b2[1])};${L2(a[2],b2[2])}m${ch}`;
  }).join("") + R;
},

9: () => { // Synthwave — neon on near-black (font-safe)
  const N = { cyan:"#3df0e6", mag:"#ff5fd2", pur:"#b48bff", dim:"#5a6a8a", warn:"#ffd166", crit:"#ff4d6d" };
  const mc = mk(N.cyan, N.warn, N.crit);
  return [
    B + c(N.cyan, "◆ " + S.model) + NB,
    c(N.pur, S.dir),
    S.branch && c(N.mag, "⌥ " + S.branch),
    has(S.ctx) && c(mc(S.ctx), "ctx " + pct(S.ctx)),
    (has(S.h5)||has(S.d7)) && [has(S.h5)&&c(N.dim,"5h ")+c(mc(S.h5),pct(S.h5)), has(S.d7)&&c(N.dim,"7d ")+c(mc(S.d7),pct(S.d7))].filter(Boolean).join(c(N.dim," · ")),
    tailTxt(N.dim, N.cyan, N.crit),
  ].filter(Boolean).join("  " + c(N.mag, "▸") + "  ") + R;
},

10: () => { // Phosphor LCD — amber mono (font-safe)
  const amb="#FFB000", dim="#8a5f12", hi2="#FFD36B";
  const bar = (p) => { const cells=5, f=p<=0?0:Math.max(1,Math.round(p/100*cells));
    return c(p>=80?"#FF7A45":amb, "▮".repeat(f)) + c("#3a2a08", "▮".repeat(cells-f)); };
  return [
    B + c(hi2, S.model) + NB,
    c(amb, S.dir.toUpperCase()),
    S.branch && c(amb, S.branch.toUpperCase()),
    has(S.ctx) && c(dim,"CTX ") + bar(S.ctx) + " " + c(amb, pct(S.ctx)),
    (has(S.h5)||has(S.d7)) && [has(S.h5)&&c(dim,"5H ")+bar(S.h5)+" "+c(amb,pct(S.h5)), has(S.d7)&&c(dim,"7D ")+bar(S.d7)+" "+c(amb,pct(S.d7))].filter(Boolean).join(" "),
    tailTxt(dim, amb, "#FF7A45"),
  ].filter(Boolean).join("  " + c("#6a4a10","//") + "  ") + R;
},

11: () => { // Brutalist — raw caps, red alarm (font-safe)
  const red="#FF3B1F", wh="#E8E4DC", gr="#6E6A62";
  const alert = (has(S.ctx)&&S.ctx>=80)||(has(S.d7)&&S.d7>=80);
  return [
    B + c(alert?red:wh, "[" + S.model.toUpperCase() + "]") + NB,
    c(wh, S.dir.toUpperCase()),
    S.branch && c(gr, "/" + S.branch.toUpperCase()),
    has(S.ctx) && c(alert?red:wh, "CTX_" + Math.round(S.ctx)),
    (has(S.h5)||has(S.d7)) && c(gr, [has(S.h5)&&"5H_"+Math.round(S.h5), has(S.d7)&&"7D_"+Math.round(S.d7)].filter(Boolean).join(" ")),
    (costS||durS||hasLines) && c(gr, [costS,durS].filter(Boolean).join(" ") + (hasLines?" +"+(S.add||0)+"/-"+(S.del||0):"")),
    alert ? B + c(red, "!! LIMIT") + NB : c(gr, "OK"),
  ].filter(Boolean).join(" ") + R;
},

12: () => { // Bauhaus — geometry encodes state (font-safe)
  const red="#D93A2B", yel="#E8B21E", blu="#2E5FA3", wh="#EDE8E0", gr="#8b857c";
  const shape = (p) => p>=80 ? c(red,"▲") : p>=50 ? c(yel,"■") : c(blu,"●");
  return [
    c(red,"●")+c(yel,"■")+c(blu,"▲") + " " + B + c(wh, S.model) + NB,
    c(wh, S.dir),
    S.branch && c(yel, S.branch),
    has(S.ctx) && shape(S.ctx) + " " + c(wh, "ctx " + pct(S.ctx)),
    (has(S.h5)||has(S.d7)) && [has(S.h5)&&shape(S.h5)+" "+c(gr,"5h "+pct(S.h5)), has(S.d7)&&shape(S.d7)+" "+c(gr,"7d "+pct(S.d7))].filter(Boolean).join("  "),
    tailTxt(gr, blu, red),
  ].filter(Boolean).join("   ") + R;
},

13: () => { // Swiss — grid, one red accent (font-safe)
  const red="#E30613", ink="#DEDBD4", gr="#78746c";
  const v = (p) => c(p>=80?red:ink, String(Math.round(p)).padStart(2) + "%");
  return [
    B + c(ink, S.model) + NB + c(red, "."),
    c(ink, S.dir) + (S.branch ? c(gr, " — " + S.branch) : ""),
    has(S.ctx) && c(gr,"ctx ") + v(S.ctx),
    has(S.h5) && c(gr,"5h ") + v(S.h5),
    has(S.d7) && c(gr,"7d ") + v(S.d7),
    tailTxt(gr, ink, red),
  ].filter(Boolean).join("    ") + R;
},

14: () => { // Wabi-sabi — moon-phase meters (font-safe)
  const moss="#8A9B7C", stone="#A8A296", ink="#D8D2C6", mist="#6b675e", och="#C2A36B", rust="#B0705C";
  const moon = (p) => p>=80 ? c(rust,"●") : p>=50 ? c(och,"◐") : p>0 ? c(moss,"◔") : c(mist,"○");
  return [
    c(moss,"◆") + " " + c(ink, S.model),
    c(stone, S.dir),
    S.branch && c(mist, S.branch),
    has(S.ctx) && moon(S.ctx) + " " + c(mist, "ctx ") + c(stone, pct(S.ctx)),
    (has(S.h5)||has(S.d7)) && [has(S.h5)&&moon(S.h5)+" "+c(mist,"5h ")+c(stone,pct(S.h5)), has(S.d7)&&moon(S.d7)+" "+c(mist,"7d ")+c(stone,pct(S.d7))].filter(Boolean).join("  "),
    tailTxt(mist, moss, rust),
  ].filter(Boolean).join("   ") + R;
},

15: () => { // Glassmorphic — tinted capsules (nerd-font caps)
  const wh="#EFF3FA", mut="#9FB0CC", pane="#2A3550", paneHi="#35426A";
  const mc = mk("#9BE8C8", "#FFD98E", "#FF8FA3");
  const L = [
    { bg: paneHi, inner: fg(wh) + B + `◆ ${S.model}` + NB },
    { bg: pane, inner: fg(wh) + S.dir },
    S.branch && { bg: pane, inner: fg(mut) + `⌥ ${S.branch}` },
    has(S.ctx) && { bg: pane, inner: c(mut,"ctx ") + c(mc(S.ctx), pct(S.ctx)) },
    (has(S.h5)||has(S.d7)) && { bg: pane, inner: [has(S.h5)&&c(mut,"5h ")+c(mc(S.h5),pct(S.h5)), has(S.d7)&&c(mut,"7d ")+c(mc(S.d7),pct(S.d7))].filter(Boolean).join(" ") },
    (costS||durS||hasLines) && { bg: pane, inner: tailTxt(mut, "#9BE8C8", "#FF8FA3") },
  ].filter(Boolean);
  return pills(L, true);
},

16: () => { // Memphis — 80s pop, zigzags (font-safe)
  const pk="#FF6FB5", te="#2EC4B6", ye="#FFD23F", pu="#9B5DE5", wh="#F5F0E8";
  const mc = mk(te, ye, pk);
  return [
    B + c(pk,"◆") + c(te, S.model) + NB,
    c(ye, S.dir),
    S.branch && c(pu, "⌥" + S.branch),
    has(S.ctx) && c(wh,"ctx") + c(mc(S.ctx), pct(S.ctx)),
    (has(S.h5)||has(S.d7)) && [has(S.h5)&&c(wh,"5h")+c(mc(S.h5),pct(S.h5)), has(S.d7)&&c(wh,"7d")+c(mc(S.d7),pct(S.d7))].filter(Boolean).join(" "),
    tailTxt(wh, te, pk),
  ].filter(Boolean).join(" " + c(pu,"▚") + " ") + R;
},

17: () => { // Art Deco — champagne gold (font-safe)
  const gold="#D4AF6A", hi2="#F0DCA8", gr="#8a7d5e", em="#5FA88C", ruby="#C25B5B";
  const mc = mk(em, gold, ruby);
  return [
    c(gold,"❯❯") + " " + B + c(hi2, S.model.toUpperCase()) + NB + " " + c(gold,"❮❮"),
    c(hi2, S.dir),
    S.branch && c(gr, "§ " + S.branch),
    has(S.ctx) && c(gr,"CTX ") + c(mc(S.ctx), pct(S.ctx)),
    (has(S.h5)||has(S.d7)) && [has(S.h5)&&c(gr,"5H ")+c(mc(S.h5),pct(S.h5)), has(S.d7)&&c(gr,"7D ")+c(mc(S.d7),pct(S.d7))].filter(Boolean).join(c(gold," ∙ ")),
    tailTxt(gr, em, ruby),
  ].filter(Boolean).join("  " + c(gold,"━") + "  ") + R;
},

18: () => { // Nord — arctic quiet (font-safe)
  const frost="#88C0D0", snow="#ECEFF4", blue="#81A1C1", gray="#616E88", grn="#A3BE8C", yel="#EBCB8B", red="#BF616A";
  const mc = mk(grn, yel, red);
  return [
    B + c(frost, "◆ " + S.model) + NB,
    c(snow, S.dir),
    S.branch && c(blue, "⌥ " + S.branch),
    has(S.ctx) && c(gray,"ctx ") + c(mc(S.ctx), pct(S.ctx)),
    has(S.h5) && c(gray,"5h ") + c(mc(S.h5), pct(S.h5)),
    has(S.d7) && c(gray,"7d ") + c(mc(S.d7), pct(S.d7)),
    tailTxt(gray, grn, red),
  ].filter(Boolean).join("  ") + R;
},

19: () => { // Dracula — the editor theme (font-safe)
  const pur="#BD93F9", pk="#FF79C6", grn="#50FA7B", yel="#F1FA8C", org="#FFB86C", red="#FF5555", fg2="#F8F8F2", com="#6272A4";
  const mc = mk(grn, org, red);
  return [
    B + c(pur, "◆ " + S.model) + NB,
    c(fg2, S.dir),
    S.branch && c(pk, "⌥ " + S.branch),
    has(S.ctx) && c(com,"ctx ") + c(mc(S.ctx), pct(S.ctx)),
    (has(S.h5)||has(S.d7)) && [has(S.h5)&&c(com,"5h ")+c(mc(S.h5),pct(S.h5)), has(S.d7)&&c(com,"7d ")+c(mc(S.d7),pct(S.d7))].filter(Boolean).join(" "),
    tailTxt(yel, grn, red),
  ].filter(Boolean).join(" " + c(com,"∷") + " ") + R;
},

20: () => { // Terminal Rain — Matrix greens (font-safe)
  const hi2="#AAFFAA", md="#33FF66", lo="#0E8A3E", dim="#0A5C2A", warn="#CCFF33", crit="#FF6B4A";
  const mc = mk(md, warn, crit);
  return [
    B + c(hi2, "▌" + S.model + "▐") + NB,
    c(md, S.dir),
    S.branch && c(lo, "⌥" + S.branch),
    has(S.ctx) && c(dim,"ctx") + c(mc(S.ctx), pct(S.ctx)),
    (has(S.h5)||has(S.d7)) && [has(S.h5)&&c(dim,"5h")+c(mc(S.h5),pct(S.h5)), has(S.d7)&&c(dim,"7d")+c(mc(S.d7),pct(S.d7))].filter(Boolean).join(" "),
    tailTxt(dim, md, crit),
  ].filter(Boolean).join(" " + c(dim,"⋮") + " ") + R;
},

21: () => { // Flat (Monument Valley) — pastel blocks (font-safe blocks)
  const rose="#E8A0A8", teal="#7FC8C4", sandy="#F0D8B8", peach="#F2B98A", ink="#4A3D55", lav="#9B8AB8";
  const mc = mk(teal, peach, "#D97788");
  const L = [
    { bg: rose, inner: fg(ink) + ` ${B}◆ ${S.model}${NB} ` },
    { bg: sandy, inner: fg(ink) + ` ${S.dir} ` },
    S.branch && { bg: lav, inner: fg("#F5F0FA") + ` ⌥ ${S.branch} ` },
    has(S.ctx) && { bg: mc(S.ctx), inner: fg(ink) + ` ctx ${pct(S.ctx)} ` },
    (has(S.h5)||has(S.d7)) && { bg: teal, inner: fg(ink) + " " + [has(S.h5)&&"5h "+pct(S.h5), has(S.d7)&&"7d "+pct(S.d7)].filter(Boolean).join(" · ") + " " },
    (costS||durS||hasLines) && { bg: peach, inner: fg(ink) + " " + [costS,durS,hasLines?("+"+(S.add||0)+" -"+(S.del||0)):null].filter(Boolean).join(" · ") + " " },
  ].filter(Boolean);
  return blocks(L);
},

22: () => { // Vector — outlined, stroke is state (font-safe)
  const cy="#35C4F0", mg="#F050A8", ye="#F0E040", wh="#EDEDF5", gr="#6a7080";
  const mc = mk(cy, ye, mg);
  const box = (t, col) => c(col, "❬") + c(col, t) + c(col, "❭");
  return [
    box(B + "◆ " + S.model + NB, cy),
    box(S.dir, wh),
    S.branch && box("⌥ " + S.branch, gr),
    has(S.ctx) && box("ctx " + pct(S.ctx), mc(S.ctx)),
    (has(S.h5)||has(S.d7)) && box([has(S.h5)&&"5h "+pct(S.h5), has(S.d7)&&"7d "+pct(S.d7)].filter(Boolean).join(" "), mc(Math.max(S.h5||0, S.d7||0))),
    (costS||durS||hasLines) && box([costS,durS,hasLines?("+"+(S.add||0)+" -"+(S.del||0)):null].filter(Boolean).join(" "), gr),
  ].filter(Boolean).join(" ") + R;
},

23: () => { // Geometric Art (Geometry Wars) — neon particles (font-safe)
  const cy="#40F0FF", li="#C8FF40", mg="#FF40C8", or="#FFA040", wh="#F0F8FF";
  const mc = mk(li, or, mg);
  return [
    c(cy,"✦") + " " + B + c(wh, S.model) + NB,
    c(cy, S.dir),
    S.branch && c(li, "⌬ " + S.branch),
    has(S.ctx) && c(mc(S.ctx), "◇ ctx " + pct(S.ctx)),
    (has(S.h5)||has(S.d7)) && [has(S.h5)&&c(mc(S.h5),"△"+pct(S.h5)), has(S.d7)&&c(mc(S.d7),"▽"+pct(S.d7))].filter(Boolean).join(" "),
    tailTxt("#6080b0", li, mg),
  ].filter(Boolean).join(" " + c("#1a2a4a","┆") + " ") + R;
},

24: () => { // Pixel (Stardew) — chunky farm bars (font-safe)
  const wood="#B8763E", leaf="#5FA838", sky="#68A8E0", wheat="#E8C860", berry="#D05868", cream="#F8E8C8";
  const mc = mk(leaf, wheat, berry);
  const pbar = (p, cells) => { const f = p<=0?0:Math.max(1,Math.round(p/100*cells));
    return c(mc(p), "▓".repeat(f)) + c("#4a3828", "░".repeat(cells-f)); };
  return [
    bg(wood) + fg(cream) + `${B}◆${S.model}${NB}` + R,
    c(cream, S.dir),
    S.branch && c(sky, "⌥" + S.branch),
    has(S.ctx) && c("#9a7a58","CTX") + pbar(S.ctx,6) + c(mc(S.ctx),pct(S.ctx)),
    (has(S.h5)||has(S.d7)) && [has(S.h5)&&c("#9a7a58","5H")+pbar(S.h5,3)+c(mc(S.h5),pct(S.h5)), has(S.d7)&&c("#9a7a58","7D")+pbar(S.d7,3)+c(mc(S.d7),pct(S.d7))].filter(Boolean).join(" "),
    (costS||durS||hasLines) && c(wheat,"⛁") + tailTxt(wheat, leaf, berry),
  ].filter(Boolean).join(" ") + R;
},

25: () => { // Cartoon (TF2) — RED vs BLU chips (nerd-font caps)
  const red="#B8383B", blu="#5885A2", crm="#F0E6D2", tan="#C5AF91", ink="#2A2226";
  const hot = (has(S.ctx)&&S.ctx>=80)||(has(S.d7)&&S.d7>=80);
  const L = [
    { bg: red, inner: fg(crm) + B + `◆ ${S.model}` + NB },
    { bg: tan, inner: fg(ink) + S.dir },
    S.branch && { bg: blu, inner: fg(crm) + `⌥ ${S.branch}` },
    has(S.ctx) && { bg: hot?red:blu, inner: fg(crm) + (hot ? B+`ctx ${pct(S.ctx)} !`+NB : `ctx ${pct(S.ctx)}`) },
    (has(S.h5)||has(S.d7)||costS||durS||hasLines) && { bg: ink, inner: fg(tan) +
      [has(S.h5)&&"5h "+pct(S.h5), has(S.d7)&&"7d "+pct(S.d7), costS, durS, hasLines?("+"+(S.add||0)+" -"+(S.del||0)):null].filter(Boolean).join(" · ") },
  ].filter(Boolean);
  return pills(L, true);
},

26: () => { // Cel Shading (Wind Waker) — flats with ink seams (font-safe)
  const sea="#2E9AC4", grass="#7AC74F", sand="#F5E29A", sail="#F0384A", ink="#17323E", foam="#EAF8FA";
  const mc = mk(grass, "#F0A830", sail);
  const seam = bg(ink) + " " + R;
  const L = [
    { bg: sail, inner: fg(foam) + ` ${B}◆ ${S.model}${NB} ` },
    { bg: sea, inner: fg(foam) + ` ${S.dir} ` },
    S.branch && { bg: grass, inner: fg(ink) + ` ⌥ ${S.branch} ` },
    has(S.ctx) && { bg: mc(S.ctx), inner: fg(ink) + ` ctx ${pct(S.ctx)} ` },
    (has(S.h5)||has(S.d7)) && { bg: sand, inner: fg(ink) + " " + [has(S.h5)&&"5h "+pct(S.h5), has(S.d7)&&"7d "+pct(S.d7)].filter(Boolean).join(" · ") + " " },
    (costS||durS||hasLines) && { bg: foam, inner: fg(ink) + " " + [costS,durS,hasLines?("+"+(S.add||0)+" -"+(S.del||0)):null].filter(Boolean).join(" · ") + " " },
  ].filter(Boolean);
  return L.map((p) => bg(p.bg) + p.inner + R).join(seam) + R;
},

27: () => { // Monochromatic (Inside) — grayscale, one red at critical (font-safe)
  const wh="#E8E8E8", lt="#9A9A9A", md="#6A6A6A", dk="#454545", red="#C03030";
  const mc = (p) => !has(p) ? md : p>=80 ? red : p>=50 ? lt : md;
  return [
    B + c(wh, S.model) + NB,
    c(lt, S.dir),
    S.branch && c(md, S.branch),
    has(S.ctx) && c(dk,"ctx ") + c(mc(S.ctx), pct(S.ctx)),
    (has(S.h5)||has(S.d7)) && [has(S.h5)&&c(dk,"5h ")+c(mc(S.h5),pct(S.h5)), has(S.d7)&&c(dk,"7d ")+c(mc(S.d7),pct(S.d7))].filter(Boolean).join("  "),
    tailTxt(dk, lt, lt),
  ].filter(Boolean).join("  " + c("#333333","│") + "  ") + R;
},
};

const n = parseInt(process.env.DESIGN, 10);
const render = DESIGNS[n] || DESIGNS[2];
try { process.stdout.write(render()); }
catch (e) { process.stdout.write(S.model + "  " + S.dir + (S.branch ? "  " + S.branch : "")); }
'
