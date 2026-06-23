# BUAD 345 Final Project — Cainiao Fulfillment Analysis (R + Tableau)

**Cainiao is faster overall — but the advantage nearly vanishes (and reverses)
for big-city destinations handled by small carriers, and the bottleneck is
between-facility line-haul, not the last mile.**

Decision-analytics study of Alibaba's Cainiao logistics network using Tmall
order / logistics / merchant data (Jan–Jul 2017). Analysis in **R**,
visualization in **Tableau**. Audience: **Cainiao**.

## Headline result

| Destination | Carrier | Cainiao (h) | Non-Cainiao (h) | Cainiao hours saved |
|---|---|--:|--:|--:|
| Big city   | Large | 44.7 | 54.2 | +9.5 |
| Big city   | **Small** | **52.4** | **49.1** | **−3.3** |
| Small city | Large | 61.7 | 72.2 | +10.5 |
| Small city | Small | 67.1 | 75.2 | +8.0 |

## Repo layout

```
R/                     analysis pipeline (run from repo root)
  01_build_analysis_table.R   raw CSVs -> order-level table (times, segments, sizes)
  02_aggregate_and_export.R   -> tableau_data/*.csv + prints key numbers
  03_figures.R                -> figures/*.png
  run_all.R                   runs 01 -> 02 -> 03
tableau_data/          small, Tableau-ready aggregate CSVs (committed)
tableau/TABLEAU_BUILD_GUIDE.md   step-by-step dashboard/story build guide
figures/               ggplot figures used in the report
report/                report.tex / report.md / report.pdf + presentation_outline.md
Cainiao_Project.r      original starter script (kept for reference)
```

## Reproduce

Requires R (data.table, lubridate, ggplot2) and the three raw CSVs in the repo
root (not distributed — see Data note). From the repo root:

```bash
Rscript R/run_all.R
```

This regenerates `tableau_data/`, `figures/`, and `data/order_analysis.rds`
(intermediate, git-ignored). Then build the Tableau workbook by following
`tableau/TABLEAU_BUILD_GUIDE.md` against `tableau_data/`. Compile the report
with `pdflatex report.tex` (twice) in `report/`.

## Method (hierarchical, not parallel)

`totaltime = SIGNED − pay_timestamp` → Cainiao vs non-Cainiao → + carrier size
→ + destination-city size → segment decomposition (pre-delivery / line-haul /
last-mile). Definitions follow the course materials and the starter script
(Large carrier = >200k orders; big city = the two largest destination cities).

## Data note

The raw CSVs are a non-public M&SOM dataset ("Do NOT share the data") and the
logistics file is 969 MB (over GitHub's limit), so they are **git-ignored**.
Only derived **aggregate** tables (group-level statistics) and a de-identified,
sampled order extract are committed.
