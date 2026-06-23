# Presentation Outline — Cainiao Fulfillment Story (BUAD 345)

~11 slides. One takeaway per slide; each maps to a Tableau sheet from
`tableau/TABLEAU_BUILD_GUIDE.md`. Audience: **Cainiao**. Replace `XX` with the
exact numbers printed by `R/02_aggregate_and_export.R`.

| # | Slide | One-line takeaway | Visual |
|---|---|---|---|
| 1 | Title | "Is Cainiao actually faster — and where isn't it?" | — |
| 2 | Motivation | Delivery speed drives e-commerce satisfaction; Cainiao runs ~XX% of orders. | Sheet 1 (KPIs) |
| 3 | Main idea | Test whether Cainiao makes overall fulfillment faster. | text |
| 4 | Headline finding | Cainiao orders arrive ~XX h faster on average. | Sheet 2 |
| 5 | Fair comparison | Holds even after dropping promised-speed orders (`promise=0`). | Sheet 2 / control |
| 6 | Dig 1: carrier size | The gap is much smaller on small carriers. | Sheet 3 (Cainiao × LCsize) |
| 7 | Dig 2: + city size (PUNCHLINE) | For **big-city destinations on small carriers**, Cainiao's edge nearly vanishes. | Sheet 3 (2×2 grid, focus cell) |
| 8 | Mechanism | The extra time is **pickup + line-haul**, not last-mile. | Sheet 4 (segments) |
| 9 | Why | Small carriers route packages through ~XX more cities (extra consolidation stops). | Sheet 5 |
| 10 | So what | Three moves for Cainiao. | text |
| 11 | Two-sentence summary | S1 + S2 (below). | text |

## Three practical moves (slide 10)
1. **Strengthen relationships with large carriers** for reliable performance —
   while watching the concentration risk this creates.
2. **Make smart-routing carrier-capability-aware** (size, coverage, experience)
   so small carriers aren't handed routes they can't execute efficiently.
3. **Pilot pickup lockers / local consolidation in big cities** for small-carrier
   shipments to cut the pickup and line-haul penalty.

## Two-sentence summary (slide 11)
- **S1 (overall):** Cainiao significantly shortens order fulfillment time across
  the marketplace.
- **S2 (punchline):** But that advantage largely disappears for big-city
  destinations served by small carriers, and the bottleneck sits in pickup and
  line-haul rather than the last mile.

## Limitations to acknowledge verbally
Observational data — assignment to Cainiao is not random (selection/causality);
"cities passed" and segment times have missing milestones in a real-world feed;
big-city flag is a coarse two-city proxy.
