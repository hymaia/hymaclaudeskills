# PptxGenJS — hymaïa Brand Guide

> It shares the same section structure so you can read them side-by-side.
> For API details not covered here (sizing modes, chart options, slide masters…),
> refer to the generic file. Everything here takes precedence for brand decisions.

---

## Setup & Brand Constants

```javascript
const pptxgen = require("pptxgenjs");

const pres = new pptxgen();
pres.layout  = "LAYOUT_16x9";   // 10" × 5.625" — always use this
pres.author  = "hymaïa";
pres.title   = "Presentation Title";

// ─── Color palette ───────────────────────────────────────────────────────────
const C = {
  NAVY:    "252CA8",   // Deep indigo — title bg, primary accents
  NAVY2:   "1A2080",   // Darker indigo — background variant
  NAVY_LT: "3038C0",   // Light indigo — decorative shapes on dark bg
  LIME:    "C8FF00",   // Vivid yellow-green — highlights, badges, odd numbers
  LIME_DK: "9ABF00",   // Dark lime — LIME text on WHITE (contrast-safe)
  WHITE:   "FFFFFF",
  LGRAY:   "F7F7F7",   // Content slide background
  BODY:    "2D2D2D",   // Body text on light backgrounds
  MUTED:   "555555",   // Secondary / caption text
  BORDER:  "E0E0E0",   // Card borders
};

// ─── Shadow factory ──────────────────────────────────────────────────────────
// Always use the factory — PptxGenJS mutates objects in-place (converts to EMU).
// Reusing a shadow object across calls corrupts the second shape.
const makeShadow = () => ({
  type: "outer", color: "000000", blur: 6, offset: 2, angle: 135, opacity: 0.07,
});
```

**Color contract — read before writing a single line:**

| Combination | Result |
|---|---|
| `LIME` text on `NAVY` bg | ✅ high contrast |
| `LIME` text on `WHITE` bg | ❌ fails contrast — use `LIME_DK` instead |
| `WHITE` text on `NAVY` bg | ✅ |
| `NAVY` text on `LIME` bg | ✅ (highlight boxes) |
| No `#` prefix on any hex | ✅ — PptxGenJS silently corrupts on `#` |

---

## Typography

**Single font: Inter.** Pass `fontFace: "Inter"` on every `addText()` call — no exceptions.

| Element | Size | Weight | Case |
|---|---|---|---|
| Title slide — main title | 40–44pt | `bold: true` | UPPERCASE |
| Title slide — highlight box | 32–36pt | `bold: true` | UPPERCASE |
| Subtitle / date | 14pt | regular | Sentence |
| Chapter number (01, 02…) | 96pt | `bold: true` | — |
| Section badge (CONTENTS…) | 13pt | `bold: true` | UPPERCASE |
| Card title | 14–16pt | `bold: true` | Title Case |
| Card description | 11–12pt | regular | Sentence |
| Body / bullet text | 13–14pt | regular | Sentence |
| Footnotes / captions | 9–10pt | regular | Sentence |

```javascript
// Title prefix (white) + highlight box (lime) — always set margin: 0
// to align text precisely with the adjacent shape
sl.addText("REPORT", {
  x: 0.55, y: 2.3, w: 2.2, h: 0.72,
  fontSize: 40, fontFace: "Inter", color: C.WHITE,
  bold: true, margin: 0,
});

// Badge / label
sl.addText("CONTENTS", {
  x: 1.55, y: 0.22, w: 1.5, h: 0.42,
  fontSize: 13, fontFace: "Inter", color: C.NAVY,
  bold: true, align: "center", valign: "middle", margin: 0,
});
```

> **Tip:** Text boxes have internal margin by default. Set `margin: 0` whenever you
> need text to sit flush against a shape edge or align with an adjacent element.

---

## Layout — Slot Map

```
┌──────────────────────────────────────────────────────────────┐
│ 0"                                                       10" │
│ ┌──────┐ ─ 0"                                               │
│ │      │   Header bar (NAVY, h=0.62) — content slides only  │
│ │ TOPO │ ─ 0.62"                                            │
│ │      │                                                     │
│ │ col  │   Content zone  x=1.5"  w=8.3"                     │
│ │      │                                                     │
│ │1.35" │                                                     │
│ └──────┘ ─ 5.625"                                           │
└──────────────────────────────────────────────────────────────┘

Card grid (2 columns):
  col 1 → x=1.5   w=3.92
  col 2 → x=5.58  w=3.92
  gap   → 0.18" horizontal & vertical
  start → y=0.82  (below badge)
```

---

## Decorative Helpers

These two functions must be defined before any slide template. Call them once per slide.

### `addTitleBlobs` — Navy slides only

Three semi-transparent indigo ovals that create depth. Never use on white/light slides.

```javascript
function addTitleBlobs(sl, pres) {
  sl.addShape(pres.shapes.OVAL, {          // top-center
    x: 2.5, y: -1.8, w: 5.5, h: 5.5,
    fill: { color: C.NAVY_LT, transparency: 65 },
    line: { color: C.NAVY_LT, transparency: 60 },
  });
  sl.addShape(pres.shapes.OVAL, {          // bottom-right
    x: 7.2, y: 2.2, w: 4.2, h: 4.2,
    fill: { color: C.NAVY_LT, transparency: 60 },
    line: { color: C.NAVY_LT, transparency: 55 },
  });
  sl.addShape(pres.shapes.OVAL, {          // bottom-left (small)
    x: -0.8, y: 3.5, w: 3.0, h: 3.0,
    fill: { color: C.NAVY_LT, transparency: 68 },
    line: { color: C.NAVY_LT, transparency: 65 },
  });
}
```

### `addTopoPattern` — White/light slides only

Concentric oval rings in the left column, simulating topographic contour lines.
White background, C8C8C8 strokes. Column width must be exactly 1.35".

```javascript
function addTopoPattern(sl, pres) {
  // White column background — clips the rings that overflow
  sl.addShape(pres.shapes.RECTANGLE, {
    x: 0, y: 0, w: 1.35, h: 5.625,
    fill: { color: C.WHITE }, line: { color: C.WHITE },
  });

  const rings = [
    { cx: 0.35, cy: 1.5, rw: 2.6, rh: 2.8 },
    { cx: 0.35, cy: 1.5, rw: 2.0, rh: 2.2 },
    { cx: 0.35, cy: 1.5, rw: 1.4, rh: 1.5 },
    { cx: 0.35, cy: 1.5, rw: 0.8, rh: 0.9 },
    { cx: 0.6,  cy: 4.2, rw: 2.2, rh: 2.4 },
    { cx: 0.6,  cy: 4.2, rw: 1.6, rh: 1.8 },
    { cx: 0.6,  cy: 4.2, rw: 1.0, rh: 1.1 },
    { cx: 0.6,  cy: 4.2, rw: 0.5, rh: 0.55 },
  ];
  rings.forEach(r => {
    sl.addShape(pres.shapes.OVAL, {
      x: r.cx - r.rw / 2, y: r.cy - r.rh / 2, w: r.rw, h: r.rh,
      fill: { color: C.WHITE },
      line: { color: "C8C8C8", width: 0.6 },
    });
  });
}
```

---

## Slide Templates

### A — Title / Cover

```javascript
function makeTitleSlide(pres, {
  prefix    = "REPORT",         // White uppercase prefix
  highlight = "AUDIT MLOPS",    // Text inside lime box
  subtitle  = "March 2026",
  authors   = "",               // Optional — bottom-right
  period    = "",               // Optional — line below authors
} = {}) {
  const sl = pres.addSlide();
  sl.background = { color: C.NAVY };
  addTitleBlobs(sl, pres);

  // Qwant+ logo — top right (replace addText with addImage if PNG available)
  sl.addText("Qwant⁺", {
    x: 7.8, y: 0.18, w: 2.0, h: 0.5,
    fontSize: 22, fontFace: "Inter", color: C.WHITE,
    bold: true, align: "right", margin: 0,
  });

  // Title prefix — white
  // Estimate width: Inter ExtraBold 40pt ≈ 0.265" per character
  const prefW = prefix.length * 0.265;
  sl.addText(prefix, {
    x: 0.55, y: 2.3, w: prefW, h: 0.72,
    fontSize: 40, fontFace: "Inter", color: C.WHITE,
    bold: true, margin: 0,
  });

  // Highlight box — lime bg, navy text
  const hlW = highlight.length * 0.22 + 0.3;
  sl.addShape(pres.shapes.RECTANGLE, {
    x: 0.55 + prefW + 0.12, y: 2.3, w: hlW, h: 0.72,
    fill: { color: C.LIME }, line: { color: C.LIME },
  });
  sl.addText(highlight, {
    x: 0.55 + prefW + 0.12, y: 2.3, w: hlW, h: 0.72,
    fontSize: 36, fontFace: "Inter", color: C.NAVY,
    bold: true, align: "center", valign: "middle", margin: 0,
  });

  // Subtitle
  sl.addText(subtitle, {
    x: 0.55, y: 3.2, w: 6, h: 0.42,
    fontSize: 14, fontFace: "Inter", color: C.WHITE, margin: 0,
  });

  // hymaïa logo — bottom left (replace with addImage if PNG available)
  sl.addText("✦  hymaïa", {
    x: 0.4, y: 4.85, w: 2.2, h: 0.45,
    fontSize: 16, fontFace: "Inter", color: C.WHITE, bold: true, margin: 0,
  });

  // Authors — bottom right
  if (authors) {
    sl.addText(authors + (period ? "\n" + period : ""), {
      x: 6.5, y: 4.95, w: 3.3, h: 0.5,
      fontSize: 9, fontFace: "Inter", color: C.WHITE,
      align: "right", valign: "bottom", margin: 0,
    });
  }
  return sl;
}
```

### B — Table of Contents

```javascript
// sections = [
//   { num: "01", titre: "Context & Scope",        desc: "…", accent: "LIME" },
//   { num: "02", titre: "Data Scientists Focus",   desc: "…", accent: "NAVY" },
//   { num: "03", titre: "Recommendations",         desc: "…", accent: "LIME" },
//   { num: "04", titre: "Roadmap",                 desc: "…", accent: "NAVY" },
// ]
// accent alternates odd=LIME / even=NAVY — the number color follows the same logic
function makeSommaireSlide(pres, { title = "CONTENTS", sections = [] } = {}) {
  const sl = pres.addSlide();
  sl.background = { color: C.LGRAY };
  addTopoPattern(sl, pres);

  // Section badge
  const badgeW = title.length * 0.115 + 0.5;
  sl.addShape(pres.shapes.RECTANGLE, {
    x: 1.55, y: 0.22, w: badgeW, h: 0.42,
    fill: { color: C.LIME }, line: { color: C.LIME },
  });
  sl.addText(title, {
    x: 1.55, y: 0.22, w: badgeW, h: 0.42,
    fontSize: 13, fontFace: "Inter", color: C.NAVY,
    bold: true, align: "center", valign: "middle", margin: 0,
  });

  const cols   = [1.5, 5.58];
  const CARD_W = 3.92, CARD_H = 1.18, GAP_Y = 0.18;
  const startY = 0.82;

  sections.forEach((s, i) => {
    const col   = i % 2;
    const row   = Math.floor(i / 2);
    const x     = cols[col];
    const y     = startY + row * (CARD_H + GAP_Y);
    const isOdd = i % 2 === 0;   // 0-indexed: position 0,2,4… are "odd" visually

    const accentColor = isOdd ? C.LIME : C.NAVY;
    const numColor    = isOdd ? C.LIME_DK : C.NAVY;

    // Card background
    sl.addShape(pres.shapes.RECTANGLE, {
      x, y, w: CARD_W, h: CARD_H,
      fill: { color: C.WHITE },
      line: { color: C.BORDER, width: 0.5 },
      shadow: makeShadow(),
    });
    // Left accent bar — w=0.055", full card height, never rounded
    sl.addShape(pres.shapes.RECTANGLE, {
      x, y, w: 0.055, h: CARD_H,
      fill: { color: accentColor }, line: { color: accentColor },
    });
    // Section number
    sl.addText(s.num, {
      x: x + 0.14, y: y + 0.16, w: 0.55, h: 0.45,
      fontSize: 22, fontFace: "Inter", color: numColor,
      bold: true, margin: 0,
    });
    // Card title
    sl.addText(s.titre, {
      x: x + 0.72, y: y + 0.16, w: CARD_W - 0.85, h: 0.38,
      fontSize: 14, fontFace: "Inter", color: C.NAVY,
      bold: true, margin: 0,
    });
    // Description
    sl.addText(s.desc, {
      x: x + 0.14, y: y + 0.58, w: CARD_W - 0.25, h: 0.5,
      fontSize: 11, fontFace: "Inter", color: C.MUTED, margin: 0,
    });
  });
  return sl;
}
```

### C — Chapter Divider (dark)

```javascript
function makeSectionSlide(pres, { num = "01", title = "", desc = "" } = {}) {
  const sl = pres.addSlide();
  sl.background = { color: C.NAVY };
  addTitleBlobs(sl, pres);

  // Giant section number in lime
  sl.addText(num, {
    x: 0.55, y: 1.5, w: 2, h: 1.8,
    fontSize: 96, fontFace: "Inter", color: C.LIME,
    bold: true, margin: 0,
  });
  // Section title
  sl.addText(title, {
    x: 0.55, y: 3.3, w: 8.5, h: 0.65,
    fontSize: 32, fontFace: "Inter", color: C.WHITE,
    bold: true, margin: 0,
  });
  // Optional description — slightly dimmed
  if (desc) {
    sl.addText(desc, {
      x: 0.55, y: 4.05, w: 7, h: 0.5,
      fontSize: 14, fontFace: "Inter", color: C.WHITE,
      margin: 0, transparency: 15,
    });
  }
  return sl;
}
```

### D — Content Slide (bullet list)

```javascript
// items can be plain strings or { titre, desc } objects
// Example:
//   items = [
//     "Simple point without detail",
//     { titre: "Bold heading", desc: "Supporting sentence beneath it" },
//   ]
function makeContentSlide(pres, {
  sectionNum = "",   // e.g. "02" — shown in lime tab on header bar
  title      = "",
  items      = [],
  note       = "",   // Optional footnote bar at bottom
} = {}) {
  const sl = pres.addSlide();
  sl.background = { color: C.WHITE };
  addTopoPattern(sl, pres);

  // Navy header bar
  sl.addShape(pres.shapes.RECTANGLE, {
    x: 0, y: 0, w: 10, h: 0.62,
    fill: { color: C.NAVY }, line: { color: C.NAVY },
  });

  // Lime section-number tab on the far-left of the header
  if (sectionNum) {
    sl.addShape(pres.shapes.RECTANGLE, {
      x: 0, y: 0, w: 0.55, h: 0.62,
      fill: { color: C.LIME }, line: { color: C.LIME },
    });
    sl.addText(sectionNum, {
      x: 0, y: 0, w: 0.55, h: 0.62,
      fontSize: 13, fontFace: "Inter", color: C.NAVY,
      bold: true, align: "center", valign: "middle", margin: 0,
    });
  }

  // Slide title in header
  sl.addText(title, {
    x: 0.7, y: 0, w: 9.1, h: 0.62,
    fontSize: 18, fontFace: "Inter", color: C.WHITE,
    bold: true, valign: "middle", margin: 0,
  });

  // Bullet items — alternating lime / navy accent bars
  items.forEach((item, i) => {
    const barColor = i % 2 === 0 ? C.LIME : C.NAVY;
    sl.addShape(pres.shapes.RECTANGLE, {
      x: 1.5, y: 0.82 + i * 0.72, w: 0.06, h: 0.5,
      fill: { color: barColor }, line: { color: barColor },
    });
    sl.addText(item.titre ?? item, {
      x: 1.7, y: 0.82 + i * 0.72, w: 7.8, h: 0.28,
      fontSize: 13, fontFace: "Inter", color: C.NAVY,
      bold: true, margin: 0,
    });
    if (item.desc) {
      sl.addText(item.desc, {
        x: 1.7, y: 1.1 + i * 0.72, w: 7.8, h: 0.3,
        fontSize: 11, fontFace: "Inter", color: C.MUTED, margin: 0,
      });
    }
  });

  // Optional footnote bar
  if (note) {
    sl.addShape(pres.shapes.RECTANGLE, {
      x: 1.5, y: 5.1, w: 8.2, h: 0.38,
      fill: { color: C.LGRAY }, line: { color: C.BORDER },
    });
    sl.addText(note, {
      x: 1.6, y: 5.12, w: 8.0, h: 0.34,
      fontSize: 9, fontFace: "Inter", color: C.MUTED, italic: true, margin: 0,
    });
  }
  return sl;
}
```

---

## Charts in hymaïa Colors

Use these color arrays so charts integrate with the brand palette.
For full chart API options, see [pptxgenjs.md](pptxgenjs.md#charts).

```javascript
// Primary series — Navy + Lime + Light indigo
const CHART_COLORS_PRIMARY   = [C.NAVY, C.LIME_DK, C.NAVY_LT];

// Extended series — adds muted tones for 4-6 series charts
const CHART_COLORS_EXTENDED  = [C.NAVY, C.LIME_DK, C.NAVY_LT, "5C64D4", "A0A5E8", C.MUTED];

// Minimal — single-series or progress charts
const CHART_COLORS_SINGLE    = [C.NAVY];

// ── Bar chart example ──────────────────────────────────────────────────────
sl.addChart(pres.charts.BAR, [{
  name: "Coverage", labels: ["Q1", "Q2", "Q3", "Q4"], values: [62, 71, 78, 85],
}], {
  x: 1.5, y: 0.9, w: 8, h: 4.2, barDir: "col",

  chartColors: CHART_COLORS_SINGLE,
  chartArea:   { fill: { color: C.WHITE } },

  catAxisLabelColor: C.MUTED,
  valAxisLabelColor: C.MUTED,
  valGridLine: { color: C.BORDER, size: 0.5 },
  catGridLine: { style: "none" },

  showValue:         true,
  dataLabelPosition: "outEnd",
  dataLabelColor:    C.NAVY,
  showLegend:        false,
});

// ── Line chart example ─────────────────────────────────────────────────────
sl.addChart(pres.charts.LINE, [
  { name: "Model A", labels: ["Jan","Feb","Mar","Apr"], values: [0.71, 0.74, 0.78, 0.82] },
  { name: "Model B", labels: ["Jan","Feb","Mar","Apr"], values: [0.65, 0.68, 0.70, 0.73] },
], {
  x: 1.5, y: 0.9, w: 8, h: 4.2,
  chartColors:  [C.NAVY, C.LIME_DK],
  chartArea:    { fill: { color: C.WHITE } },
  lineSize:     2.5,
  lineSmooth:   true,
  catAxisLabelColor: C.MUTED,
  valAxisLabelColor: C.MUTED,
  valGridLine:  { color: C.BORDER, size: 0.5 },
  catGridLine:  { style: "none" },
  showLegend:   true,
  legendPos:    "b",
  legendColor:  C.BODY,
});
```

---

## Tables in hymaïa Style

```javascript
// Header row: Navy bg / white text — body rows alternate WHITE / LGRAY
const rows = [
  // Header
  [
    { text: "Model",    options: { bold: true, color: C.WHITE, fill: { color: C.NAVY } } },
    { text: "Accuracy", options: { bold: true, color: C.WHITE, fill: { color: C.NAVY } } },
    { text: "F1 Score", options: { bold: true, color: C.WHITE, fill: { color: C.NAVY } } },
  ],
  // Data rows — fill alternates automatically below
  ["Baseline",  "71.4%", "0.68"],
  ["Fine-tuned","84.2%", "0.81"],
  ["Ensemble",  "87.9%", "0.85"],
];

// Apply alternating fill to data rows
const styledRows = rows.map((row, i) => {
  if (i === 0) return row;  // header already styled
  const bg = i % 2 === 0 ? C.LGRAY : C.WHITE;
  return row.map(cell =>
    typeof cell === "string"
      ? { text: cell, options: { color: C.BODY, fill: { color: bg } } }
      : cell
  );
});

sl.addTable(styledRows, {
  x: 1.5, y: 1.0, w: 7.0,
  fontSize:  12,
  fontFace:  "Inter",
  border:    { pt: 0.5, color: C.BORDER },
  rowH:      0.42,
  colW:      [2.8, 2.1, 2.1],
  align:     "center",
  valign:    "middle",
});
```

---

## Images & Logos

```javascript
// Replace text placeholders with real PNGs when available:
// Qwant+ logo — top-right on title slide
sl.addImage({ path: "assets/qwant-plus-logo.png", x: 8.2, y: 0.15, w: 1.6, h: 0.5 });

// hymaïa logo — bottom-left on title slide
sl.addImage({ path: "assets/hymaia-logo.png", x: 0.35, y: 4.82, w: 1.8, h: 0.52 });

// Content image — right half of a two-column layout, aspect-ratio safe
sl.addImage({
  path: "assets/diagram.png",
  x: 5.6, y: 0.9, w: 4.0, h: 3.6,
  sizing: { type: "contain", w: 4.0, h: 3.6 },
});
```

---

## Brand-Specific Pitfalls

These extend the pitfalls in [pptxgenjs-hymaia.md](pptxgenjs-hymaia.md#common-pitfalls).
All pitfalls from the generic file still apply — read it too.

1. **LIME on WHITE fails contrast** — always use `LIME_DK` (`9ABF00`) for lime text on
   white or light-gray backgrounds. Reserve plain `LIME` for shapes/badges on Navy.

2. **Sentence-case titles** — badge labels (`CONTENTS`, `RECAP`…) and title slide
   main titles must be UPPERCASE. Card titles use Title Case. Descriptions use
   Sentence case. Never mix them up.

3. **Left accent bar must be `RECTANGLE`** — the bar is `w=0.055"`, full card height,
   flush against the card's left edge. Never round corners (`ROUNDED_RECTANGLE` won't
   align with a rectangular card background).

4. **Reused shadow objects corrupt shapes** — always call `makeShadow()` per shape,
   never store one shadow object and spread it across multiple `addShape()` calls.

5. **Topo column ≠ 1.35"** — if `addTopoPattern`'s white rectangle is wider or
   narrower, the content zone shifts. Keep it exactly `w: 1.35`.

6. **Missing `margin: 0`** — all text inside shapes (badges, header bars, highlight
   boxes) must have `margin: 0` to prevent the default internal padding from
   misaligning text with the shape boundary.

7. **No `#` on hex colors** — PptxGenJS silently corrupts the file. `"C8FF00"` ✅,
   `"#C8FF00"` ❌.

---

## Minimal Working Example

```javascript
const pptxgen = require("pptxgenjs");

// --- paste C, makeShadow, addTitleBlobs, addTopoPattern here ---

async function buildDeck() {
  const pres = new pptxgen();
  pres.layout = "LAYOUT_16x9";
  pres.title  = "MLOps Audit — hymaïa";

  makeTitleSlide(pres, {
    prefix:    "REPORT",
    highlight: "AUDIT MLOPS",
    subtitle:  "March 2026",
    authors:   "Jane Smith · John Doe",
    period:    "Q1 2026",
  });

  makeSommaireSlide(pres, {
    title: "CONTENTS",
    sections: [
      { num: "01", titre: "Context & Scope",       desc: "Project background and objectives.", accent: "LIME" },
      { num: "02", titre: "Data Scientists Focus",  desc: "Tooling and workflow analysis.",    accent: "NAVY" },
      { num: "03", titre: "Infrastructure",         desc: "Platform and deployment review.",   accent: "LIME" },
      { num: "04", titre: "Recommendations",        desc: "Prioritized action plan.",           accent: "NAVY" },
    ],
  });

  makeSectionSlide(pres, { num: "01", title: "Context & Scope" });

  makeContentSlide(pres, {
    sectionNum: "01",
    title: "Audit Perimeter",
    items: [
      { titre: "Three ML teams in scope", desc: "Data Science, MLOps, and Platform Engineering." },
      { titre: "40 models in production",  desc: "Covering recommendation, fraud detection, and NLP." },
      "Interviews conducted over 6 weeks",
    ],
  });

  await pres.writeFile({ fileName: "hymaia-presentation.pptx" });
  console.log("Done → hymaia-presentation.pptx");
}

buildDeck().catch(console.error);
```

---

## Quick Reference

| Constant | Value | Use |
|---|---|---|
| `C.NAVY` | `252CA8` | Title bg, accents |
| `C.LIME` | `C8FF00` | Badges, highlights on Navy |
| `C.LIME_DK` | `9ABF00` | Lime text on white |
| `C.LGRAY` | `F7F7F7` | Content slide bg |
| `C.MUTED` | `555555` | Captions, secondary text |
| `C.BORDER` | `E0E0E0` | Card borders, table lines |

| Slide type | Template | Background |
|---|---|---|
| Cover | `makeTitleSlide()` | Navy |
| Table of contents | `makeSommaireSlide()` | Light gray |
| Chapter divider | `makeSectionSlide()` | Navy |
| Content / bullets | `makeContentSlide()` | White |

| Shape | API constant |
|---|---|
| Rectangle | `pres.shapes.RECTANGLE` |
| Oval | `pres.shapes.OVAL` |
| Line | `pres.shapes.LINE` |


