# Cainiao is Fast — But Not Everywhere

*When does Alibaba's logistics network stop delivering its speed advantage?*

**BUAD 345: Decision Analytics and Visualization — Final Project (Summer 2026)**

> Markdown mirror of `report.tex` / `report.pdf`. The PDF is the formal submission.

**Audience:** Cainiao (Alibaba's logistics platform).
**Data:** Tmall order, logistics, and merchant records, Jan 1 – Jul 31, 2017
(1,291,197 orders; 1,288,438 with a valid fulfillment time).

---

## 1. Motivation
In Chinese e-commerce, delivery speed is a primary driver of customer
satisfaction and repeat purchase, and it is where logistics platforms compete
most visibly.[^1] Cainiao's pitch is that its smart-routing platform makes
fulfillment *faster*. Cainiao handles **30.2%** of all orders here, so any
systematic weakness in its speed advantage is material.

## 2. Main Idea
One focused question: **does Cainiao actually make fulfillment faster, and is
that advantage uniform?** Outcome = total fulfillment time
(`SIGNED timestamp − pay_timestamp`, hours). We dig *hierarchically*: carrier
size → destination-city size → segment decomposition.

## 3. Findings

**3.1 Overall, Cainiao is faster.** 61.9 h vs 71.0 h (~**9.2 h faster**; medians
53.7 vs 66.3). It survives a fair-comparison control (orders with no promised
window): 62.5 vs 71.0 h. *(Figure: `fig1_main_effect.png`)*

**3.2 The advantage is uneven across carriers.** Cainiao's edge is larger on
large carriers than on small ones.

**3.3 Punchline — big-city destinations on small carriers.** Cainiao saves
8–10.5 h in three of four cells, but for **big-city destinations on small
carriers it is 3.3 h *slower*** than non-Cainiao. *(Figure: `fig2_punchline.png`)*

| Destination | Carrier | Cainiao | Non-Cainiao | **Cainiao hours saved** |
|---|---|--:|--:|--:|
| Big city   | Large | 44.7 | 54.2 | **+9.5** |
| Big city   | Small | 52.4 | 49.1 | **−3.3** |
| Small city | Large | 61.7 | 72.2 | **+10.5** |
| Small city | Small | 67.1 | 75.2 | **+8.0** |

**Customer reviews echo it.** That cell is Cainiao's lowest logistics review
(4.764) vs non-Cainiao's highest (4.860). *(Figure: `fig4_review.png`)*

## 4. Mechanism: where does the time go?
Decomposing into pre-delivery / line-haul / last-mile, the gap is in
**line-haul (between-facility transit), not the last mile** (which is ~4–6 h and
similar everywhere). Cainiao's usual edge is faster line-haul (e.g. 38.4 vs
47.8 h on small-city/large-carrier orders); in the punchline cell that edge
disappears (27.0 vs 26.9 h). *(Figure: `fig3_segments.png`)*

**Honest non-result.** Small carriers do **not** make more stops — they pass
through slightly *fewer* cities (~2.9–3.1) than large ones (3.4–3.7). The penalty
is per-leg transit/dwell, not more hops.

## 5. Potential Reasons
1. Big cities concentrate trunk-line volume; large carriers run dedicated,
   high-frequency line-haul while small carriers wait to consolidate loads,
   adding transit/dwell on exactly the high-expectation big-city lanes.[^2]
2. Small carriers likely cannot execute Cainiao's smart-routing as designed, so
   the optimization does not convert into time saved.[^3]

## 6. Practical Implications (So What?)
1. **Deepen ties with large carriers** on big-city lanes (watch concentration risk).
2. **Make smart-routing carrier-capability-aware** (size, coverage, experience).
3. **Pilot big-city consolidation / pickup lockers for small-carrier shipments**
   to attack the line-haul + pickup penalty where it occurs.[^4]

## 7. Limitations & Causality
Observational data — Cainiao assignment is not random (association, not proven
causation). Some milestone records are missing, so segment means use slightly
different subsets than totals. Big-city is a coarse two-city proxy. These temper
the magnitudes, not the qualitative punchline.

## Two-Sentence Summary
1. Cainiao significantly shortens fulfillment time across the marketplace (~9 h).
2. But that advantage largely disappears — and even reverses — for big-city
   destinations served by small carriers, with the bottleneck in line-haul
   rather than the last mile.

[^1]: Replace with an assigned reference (e.g. Cainiao/Alizila item or an OM study on delivery speed and retention).
[^2]: Replace with an assigned reference on Chinese logistics infrastructure / carrier line-haul economics.
[^3]: Replace with an assigned reference on routing performance under heterogeneous carrier capability.
[^4]: Replace with an assigned reference on pickup-point / locker effects.
