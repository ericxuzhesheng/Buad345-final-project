# Tableau Build Guide — Cainiao Fulfillment Story

> **Note on `Cainiao_Story.twbx`:** the auto-generated packaged workbook does **not
> load** in Tableau Desktop (internal error `501CF476` — its worksheet internals
> were hand-authored by a script). Build the workbook natively instead: the CSVs in
> `../tableau_data/` are clean and tiny, so the per-sheet steps below take ~15 min
> and produce real, polished visuals. For the five exact views the report and slides
> need (and their export filenames), follow **`TABLEAU_EXPORT_CHECKLIST.md`**. After
> building, `File ▸ Export Packaged Workbook` over `Cainiao_Story.twbx` to get a
> working `.twbx`.


This guide rebuilds the dashboards/story from the aggregate CSVs in
`../tableau_data/`. Each sheet lists the data source, shelf placement, calculated
fields, filters, and color. The whole thing assembles into one **Story** that
delivers the punchline:

> **Cainiao is faster overall — BUT the advantage nearly disappears for
> big-city destinations handled by small carriers, and the bottleneck is
> pickup + line-haul, not the last mile.**

**Audience:** Cainiao (the logistics platform).

---

## 0. Connect the data

Connect to each CSV as a **separate Text File** data source (they are already
aggregated, so no joins are needed):

| Data source | File |
|---|---|
| Overall | `agg_cainiao_overall.csv` |
| Cainiao × LCsize × Citysize | `agg_cainiao_lcsize_citysize.csv` |
| Hours saved per cell | `agg_cainiao_gain_by_cell.csv` |
| Time segments | `agg_time_segments.csv` |
| Cities passed | `agg_cities_passed.csv` |
| Daily trend | `agg_daily_trend.csv` |
| Overview KPIs | `agg_overview.csv` |
| Order sample (distributions) | `order_sample.csv` |

**Shared color rule** (set once, apply to every sheet via *Edit Colors*):
`Cainiao = #0571B0` (blue), `Non-Cainiao = #9AA0A6` (grey).

---

## Sheet 1 — Motivation KPIs

- **Data:** `agg_overview.csv`
- **Build:** Drag `Metric` to Rows, `Value` to Text (or use individual
  worksheets / a simple text table). Format as big BANs (Big Ass Numbers).
- **Show:** total orders, Cainiao share %, avg fulfillment time, median.
- **Purpose:** establish that delivery speed matters and Cainiao handles the
  majority of orders.

## Sheet 2 — Cainiao vs Non-Cainiao (the headline)

- **Data:** `agg_cainiao_overall.csv`
- **Columns:** `cainiao` · **Rows:** `avg_totaltime`
- **Marks:** Bar. **Color:** `cainiao` (shared rule). **Label:** `avg_totaltime`.
- **Title:** "Cainiao is faster overall".
- Optional companion: a histogram of `totaltime` from `order_sample.csv`
  (Columns = `totaltime` binned, Color = `cainiao`, Marks = area/transparent).

## Sheet 3 — Hierarchical breakdown (PUNCHLINE)

- **Data:** `agg_cainiao_lcsize_citysize.csv`
- **Columns:** `Citysize` then `LCsize` · **Rows:** `avg_totaltime`
- **Marks:** Bar. **Color:** `cainiao`. **Label:** `avg_totaltime`.
- This produces a small-multiple 2×2 grid (BigCity/SmallCity × Large/Small
  carrier) with the Cainiao vs Non-Cainiao pair in each cell.
- **Highlight the punchline cell** (BigCity × Small carrier): add an annotation,
  or create a calculated field to outline it:

  ```
  // Field: Punchline cell
  IF [Citysize] = "BigCity" AND [LCsize] = "Small" THEN "Focus" ELSE "Other" END
  ```
  Put `Punchline cell` on Detail and use a darker border / annotation there.

- **Companion — "Cainiao hours saved":** new sheet on `agg_cainiao_gain_by_cell.csv`,
  Columns `Citysize` + `LCsize`, Rows `cainiao_hours_saved`, Marks = Bar.
  Lower bars (= smaller advantage) make the punchline cell pop.

## Sheet 4 — Time-segment decomposition (the mechanism)

- **Data:** `agg_time_segments.csv`
- **Columns:** `cainiao` · **Rows:** `avg_hours`
- **Color:** `segment` (`pre_delivery` red `#CA0020`, `line_haul` `#F4A582`,
  `last_mile` `#92C5DE`) → stacked bar.
- **Detail/rows facets:** drag `Citysize` and `LCsize` to create a grid.
- **Sort segment** stack order pre_delivery → line_haul → last_mile.
- **Purpose:** show the extra time in the punchline cell comes from
  pre-delivery (pickup) and line-haul, not last mile.

## Sheet 5 — Cities passed & review (support)

- **Data:** `agg_cities_passed.csv`
- **Columns:** `LCsize` · **Rows:** `avg_cities_passed` · **Color:** `cainiao` →
  small carriers route through more cities (a plausible mechanism for the delay).
- **Review companion:** new sheet on `agg_review_by_group.csv`, Rows
  `avg_review`, Columns `Citysize`/`LCsize`, Color `cainiao` — check whether
  the customer experience echoes the speed story.

## (Optional) Sheet 6 — Daily trend

- **Data:** `agg_daily_trend.csv`
- **Columns:** `day` (continuous) · **Rows:** `avg_totaltime` · **Color:**
  `cainiao` → line chart over Jan–Jul 2017 for context.

---

## Calculated fields used

```
// On-time-ish proxy (order_sample.csv): does total time beat the promise window?
// promise: 0 none, 1 = 1 business day, 2 = 2 days, 3 = 3 days
[Met promise] =
IF [promise] = 0 THEN NULL
ELSEIF [totaltime] <= [promise]*24 THEN 1 ELSE 0 END

// Average promise-met rate
[Promise met rate] = AVG([Met promise])
```

---

## Assemble the Story

Create a **Story** (not just a dashboard) with these captioned points, in order:

1. **"Speed matters, and Cainiao runs most of it"** → Sheet 1.
2. **"Cainiao is faster overall"** → Sheet 2.
3. **"...but not everywhere"** → Sheet 3 (highlight BigCity × Small carrier).
4. **"Where the time goes"** → Sheet 4 (pickup + line-haul dominate the gap).
5. **"Why: more stops on small carriers"** → Sheet 5.
6. **"So what — three moves for Cainiao"** → text slide:
   strengthen ties with large carriers; make smart-routing carrier-capability
   aware; pilot pickup lockers / consolidation in big cities for small carriers.

Keep one accent color (Cainiao blue) consistent throughout; grey everything
that isn't the focus so the punchline cell carries the eye.
