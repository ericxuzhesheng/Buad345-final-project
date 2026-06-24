# Speaker Script — Cainiao is Fast, But Not Everywhere

**Group 12 · Yingqi Tan · Hao Yang · Zhesheng Xu · BUAD 345 · Defense talk
(~9–10 minutes).**
One block per slide in `report/slides.pdf`. `[advance]` = move to the next slide.
Numbers match `report/report.pdf` and the R output. The main visuals are built in
**Tableau** (Cainiao = blue, non-Cainiao = orange); two composite **R dashboards**
pull each half of the story onto a single screen.

---

### Slide 1 — Title
Good [morning/afternoon], everyone. We're Group 12: Yingqi Tan, Hao Yang, and
Zhesheng Xu. Our project asks a simple question with a not-so-simple answer:
*Cainiao is fast — but is it fast everywhere?* We looked at 1.3 million Tmall
orders from 2017 to find out. `[advance]`

### Slide 2 — The question
Our audience is Cainiao itself, Alibaba's logistics platform. Why care about
delivery speed? Because it pays. Fisher and colleagues found online sales rise
about 1.45% for every business day you shave off delivery, and Rao and colleagues
showed the flip side — miss a promised date and you lose loyal customers. Cainiao
handles 30% of all the orders in our data, so if there's any pocket where its
speed promise breaks, that matters a lot. So we asked: does Cainiao deliver
faster — and does it do so everywhere? `[advance]`

### Slide 3 — Method
Our outcome is total fulfillment time: when the customer signs for the package
minus when they paid, in hours. The key to our approach is that we dig
*hierarchically*, not in parallel. We start with Cainiao versus non-Cainiao, then
add carrier size, then destination-city size, and finally we break the time into
segments. Each layer is added only when the previous result makes us ask the next
question. One focused story, not ten disconnected charts. `[advance]`

### Slide 4 — Headline
Here's the headline, and it's good news for Cainiao. Cainiao orders take about
62 hours; non-Cainiao take 71 — Cainiao is roughly **nine hours faster**. And
this isn't a trick of which orders Cainiao handles: if we keep only orders with no
promised-speed window, the gap barely moves. So far, Cainiao's promise holds.
`[advance]`

### Slide 5 — Stable over time
And it holds *all the time*. This is daily average fulfillment time across the
whole seven-month window. The blue line — Cainiao — sits below the orange line —
non-Cainiao — every single month, including the busy spring. So the advantage is
real and stable. That's what lets us pool the data and zoom in. `[advance]`

### Slide 6 — The punchline
But here's where it gets interesting. When we split by both carrier size and city
size, the picture cracks. In three of the four cells the blue Cainiao bar is
shorter — Cainiao saves 8 to 10 hours. But look at the big-city, small-carrier
cell — there the blue bar is *taller*: Cainiao is actually **3.3 hours slower**
than non-Cainiao. The advantage doesn't just shrink; it reverses. `[advance]`

### Slide 7 — The whole story on one screen
Before the numbers, let me show you the whole thing on one screen. Up top, the
headline KPIs: 1.3 million orders, 30% on Cainiao, nine hours faster overall — but
minus 3.3 in the problem cell. The 2×2 on the left and the hours-saved bars on the
right both point to the same place: every cell is blue and positive *except*
big-city, small-carrier, which dips into the red. If you take one picture away from
this talk, take this one. `[advance]`

### Slide 8 — The reversal cell in numbers
Now the numbers. Big city, large carrier: Cainiao saves nine and a half hours.
Small city, either carrier: eight to ten and a half hours saved. But big city,
small carrier: minus 3.3 hours. And this isn't a tiny corner of the data — that
cell has almost 23,000 orders. It's a real, reliable reversal. `[advance]`

### Slide 9 — Customers feel it
And customers notice. This is the logistics review score, and I've zoomed the axis
in so you can see the gaps. That same big-city, small-carrier cell is Cainiao's
*lowest* score anywhere — 4.76 — while the non-Cainiao option right next to it is
the *highest* — 4.86. So this isn't just an operations curiosity; it's hurting the
customer experience exactly where Cainiao underperforms. `[advance]`

### Slide 10 — Mechanism
So *where* does the extra time come from? We split fulfillment into pickup,
line-haul — that's transit between facilities — and the last mile. The last mile
is small and basically the same everywhere, four to six hours. Cainiao's real edge
is faster line-haul — for example, 38 hours versus 48 on a typical lane. But in
the reversal cell that edge disappears: 27 hours versus 27. The lost advantage is
a lost *line-haul* advantage — not the last mile. `[advance]`

### Slide 11 — Mechanism, faceted
Here's that same mechanism broken out cell by cell. Notice the last-mile bars are
short and nearly identical in every panel — that is *not* the problem. It's the
line-haul bars that move, and they stay stubbornly high for the big-city,
small-carrier Cainiao orders. That's the leg to fix. `[advance]`

### Slide 12 — An honest non-result
Now, we want to be honest about one thing. The obvious guess is that small
carriers make more stops. We checked — and it's *not* true. Small carriers
actually pass through *fewer* cities than large ones. So the problem isn't the
number of hops; it's the time spent on each leg. Reporting that keeps our
explanation disciplined. `[advance]`

### Slide 13 — Why
Why would that happen? Two reasons consistent with the evidence. First, big cities
concentrate trunk-line volume — large carriers run dedicated, high-frequency
line-haul into them, while small carriers wait to consolidate loads, which adds
dwell time on exactly the lanes where customers expect speed. Second, small
carriers likely can't execute Cainiao's one-size-fits-all smart routing — and the
routing literature shows that ignoring carrier capability degrades performance.
`[advance]`

### Slide 14 — So what
So what should Cainiao do? Three moves. One: deepen ties with large carriers on
big-city lanes, where speed actually shows up — while watching the concentration
risk. Two: make smart routing carrier-capability-aware, so small carriers aren't
handed routes they can't run. Three: pilot big-city consolidation hubs or parcel
lockers for small-carrier shipments, to attack the line-haul penalty where it
lives. And because the weakness is concentrated, the fix is cheap compared to a
platform-wide change. `[advance]`

### Slide 15 — Two-sentence summary
If you remember two sentences: First — Cainiao makes fulfillment about nine hours
faster across the marketplace, and that's robust. Second — but that advantage
disappears, and reverses, for big-city destinations on small carriers, with the
bottleneck in line-haul, not the last mile. And a caveat: this is observational
data, so we're showing strong association, not proven causation. `[advance]`

### Slide 16 — Thank you
That's our story: Cainiao is fast — just not everywhere — and now we know exactly
where to look. Thank you. We're happy to take questions.

---

## Timing & delivery notes
- Target ~9–10 min; slides 6–11 (punchline → faceted mechanism) are the core — slow down there.
- Slides 7 and 11 are the two composite R dashboards — use them to *recap* a half of
  the story in one glance; don't read every bar, just point to the one cell that breaks.
- Hand-off cues: if presenting as a team, natural splits are 1–5 / 6–11 / 12–16.
- Likely Q&A: *Is it causal?* (no — selection into Cainiao, see slide 15);
  *Why two big cities only?* (top-2 signing cities by volume, a coarse proxy);
  *Do segments add up?* (directional only — missing milestones, different subsets);
  *Tableau or R?* (analysis + aggregation in R; the story visuals in Tableau, with two
  R composite dashboards as one-screen recaps).
