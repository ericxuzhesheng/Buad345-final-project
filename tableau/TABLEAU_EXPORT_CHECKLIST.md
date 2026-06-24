# Tableau — Build & Export the 5 Figures (self-contained)

The report (`report/report.tex`) and slides (`report/slides.tex`) embed five
**Tableau** images: `figures/tab_headline.png`, `tab_trend.png`, `tab_punchline.png`,
`tab_reviews.png`, `tab_segments.png`. This page builds each view from the clean
aggregate CSVs in `../tableau_data/` and exports it to the matching filename.

> **Why build fresh instead of opening `Cainiao_Story.twbx`?** The auto-generated
> packaged workbook fails to load in Tableau Desktop (hand-authored worksheet
> internals — internal error `501CF476`). The CSVs themselves are perfectly clean,
> so building the five sheets natively (~15 min) is the reliable path and produces
> real, polished Tableau visuals. After you build, `File ▸ Export Packaged Workbook`
> to overwrite `Cainiao_Story.twbx` with a working version.

## One-time setup

1. Open Tableau Desktop ▸ **Connect ▸ Text file** ▸ pick a CSV in `tableau_data/`.
   Repeat **Data ▸ New Data Source** for each CSV listed below (no joins needed —
   they are already aggregated).
2. **Shared colors** — set once, reuse on every sheet (`Color ▸ Edit Colors`):
   `Cainiao = #0571B0` (blue), `Non-Cainiao = #9AA0A6` (grey).
3. Export any sheet with **Worksheet ▸ Export ▸ Image… ▸ PNG**, saving into
   `figures/` with the exact filename below (overwrite the placeholder).

---

## 1 — `tab_headline.png`  ("Cainiao is faster overall")

- **Data:** `agg_cainiao_overall.csv`  (cols: `cainiao, n_orders, avg_totaltime, median_totaltime`)
- **Columns:** `cainiao`   **Rows:** `SUM(avg_totaltime)` → switch Measure to **Average** if it doubles; values are already averages, so use `AVG` or `MIN` to show them as-is (44–71 h range).
- **Marks:** Bar · **Color:** `cainiao` · **Label:** `avg_totaltime`.
- **Title:** "Cainiao is faster overall (61.9 h vs 71.0 h)".
- Export → `figures/tab_headline.png`  (min width ~900 px).

## 2 — `tab_trend.png`  ("Stable over time")

- **Data:** `agg_daily_trend.csv`  (cols: `day, cainiao, n_orders, avg_totaltime`)
- **Columns:** `day` (set to **continuous / exact date or week**)   **Rows:** `AVG(avg_totaltime)`.
- **Marks:** Line · **Color:** `cainiao`.
- Cainiao line should sit below Non-Cainiao across Jan–Jul 2017.
- Export → `figures/tab_trend.png`  (min width ~1400 px).

## 3 — `tab_punchline.png`  (the 2×2 punchline — centerpiece)

- **Data:** `agg_cainiao_lcsize_citysize.csv`
  (cols: `Citysize, LCsize, cainiao, n_orders, avg_totaltime, avg_review`)
- **Columns:** `Citysize` then `LCsize`   **Rows:** `AVG(avg_totaltime)`   →
  a 2×2 grid (BigCity/SmallCity × Large/Small).
- **Color:** `cainiao` · **Label:** `avg_totaltime`.
- **Highlight the reversal cell:** create calc field
  `Punchline = IF [Citysize]="BigCity" AND [LCsize]="Small" THEN "Focus" ELSE "Other" END`,
  drop on **Detail**, give the Focus cell a dark border / annotation.
- Export → `figures/tab_punchline.png`  (min width ~1600 px).
- *(Optional companion before exporting — a second sheet on
  `agg_cainiao_gain_by_cell.csv`, Columns `Citysize`+`LCsize`, Rows
  `AVG(cainiao_hours_saved)`; the BigCity×Small bar goes negative/red. Combine the
  two on a dashboard and export the dashboard instead if you want the KPI+bars look
  from the report caption.)*

## 4 — `tab_reviews.png`  ("Customers feel it too")

- **Data:** `agg_review_by_group.csv`  (cols: `Citysize, LCsize, cainiao, avg_review, n_reviews`)
- **Columns:** `Citysize` then `LCsize`   **Rows:** `AVG(avg_review)`   **Color:** `cainiao`.
- **Label:** `avg_review`. Truncate axis to ~4.7–4.9 so the gaps are visible.
- The BigCity×Small Cainiao bar (4.764) is the lowest; non-Cainiao beside it (4.860) the highest.
- Export → `figures/tab_reviews.png`  (min width ~1200 px).

## 5 — `tab_segments.png`  (mechanism: line-haul, not last mile)

- **Data:** `agg_time_segments.csv`  (cols: `Citysize, LCsize, cainiao, segment, avg_hours`)
- **Columns:** `Citysize` then `LCsize`   **Rows:** `SUM(avg_hours)`   →
  **Color:** `segment`  (stacked bar: `pre_delivery #CA0020`, `line_haul #F4A582`, `last_mile #92C5DE`).
- Optionally put `cainiao` on Columns too, to show Cainiao vs Non-Cainiao side by side per cell.
- Line-haul (orange) dominates; it shrinks for Cainiao everywhere **except** BigCity×Small.
- Export → `figures/tab_segments.png`  (min width ~1500 px).

---

## After exporting all five

```bash
cd report
pdflatex report.tex && pdflatex report.tex
pdflatex slides.tex && pdflatex slides.tex
```

The PDFs then show your real Tableau views. Until you export, both PDFs compile with
content-identical placeholder images, so nothing is blocked.

**Tip:** once the five sheets exist, assemble them into a **Story** (per
`TABLEAU_BUILD_GUIDE.md`) and `File ▸ Export Packaged Workbook` over
`Cainiao_Story.twbx` — that gives you a working `.twbx` to submit and to present live.
