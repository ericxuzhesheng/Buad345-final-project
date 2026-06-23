# ==============================================================================
# 02_aggregate_and_export.R
# Produces the small, Tableau-ready aggregate CSVs in tableau_data/ and prints
# the exact numbers used in the report. Reads data/order_analysis.rds.
# ==============================================================================

suppressPackageStartupMessages({
  library(data.table)
})

out_dir <- "tableau_data"
dir.create(out_dir, showWarnings = FALSE)

odat <- as.data.table(readRDS(file.path("data", "order_analysis.rds")))
d <- odat[valid == TRUE]                 # analysis subset
setorder(d, cainiao)

w <- function(dt, name) {
  fwrite(dt, file.path(out_dir, name))
  message("wrote ", name, " (", nrow(dt), " rows)")
}

cat("\n=================== KEY NUMBERS (for the report) ===================\n")

# ---- 0. Motivation / overview KPIs ------------------------------------------
overview <- data.table(
  metric = c("total_orders", "valid_orders", "cainiao_share_pct",
             "avg_totaltime_hours", "median_totaltime_hours"),
  value = c(nrow(odat),
            nrow(d),
            round(100 * mean(odat$if_cainiao == 1L, na.rm = TRUE), 1),
            round(mean(d$totaltime), 2),
            round(median(d$totaltime), 2))
)
print(overview)
w(overview, "agg_overview.csv")

# ---- 1. L1: Cainiao vs Non-Cainiao ------------------------------------------
agg_overall <- d[, .(
  n_orders         = .N,
  avg_totaltime    = round(mean(totaltime), 2),
  median_totaltime = round(median(totaltime), 2)
), by = cainiao]
cat("\n-- L1: Cainiao vs Non-Cainiao --\n"); print(agg_overall)
w(agg_overall, "agg_cainiao_overall.csv")

# Control: drop promised orders (promise != 0) to compare apples-to-apples.
agg_no_promise <- d[promise == 0, .(
  n_orders      = .N,
  avg_totaltime = round(mean(totaltime), 2)
), by = cainiao]
cat("\n-- Control: promise == 0 only --\n"); print(agg_no_promise)
w(agg_no_promise, "agg_cainiao_nopromise.csv")

# ---- 2. L2: + carrier size ---------------------------------------------------
agg_lc <- d[, .(
  n_orders      = .N,
  avg_totaltime = round(mean(totaltime), 2)
), by = .(cainiao, LCsize)]
setorder(agg_lc, cainiao, LCsize)
cat("\n-- L2: Cainiao x LCsize --\n"); print(agg_lc)
w(agg_lc, "agg_cainiao_lcsize.csv")

# ---- 3. L3: + destination city size (the punchline 2x2x2) -------------------
agg_full <- d[!is.na(Citysize) & !is.na(LCsize), .(
  n_orders      = .N,
  avg_totaltime = round(mean(totaltime), 2),
  avg_review    = round(mean(suppressWarnings(as.numeric(review)), na.rm = TRUE), 3)
), by = .(Citysize, LCsize, cainiao)]
setorder(agg_full, Citysize, LCsize, cainiao)
cat("\n-- L3: Citysize x LCsize x Cainiao (PUNCHLINE) --\n"); print(agg_full)
w(agg_full, "agg_cainiao_lcsize_citysize.csv")

# Cainiao "speed gain" = Non-Cainiao avg - Cainiao avg, per City x LC cell.
gain <- dcast(agg_full, Citysize + LCsize ~ cainiao, value.var = "avg_totaltime")
setnames(gain, make.names(names(gain)))
if (all(c("Cainiao", "Non.Cainiao") %in% names(gain))) {
  gain[, cainiao_hours_saved := round(Non.Cainiao - Cainiao, 2)]
}
cat("\n-- Cainiao hours saved by cell (higher = bigger advantage) --\n"); print(gain)
w(gain, "agg_cainiao_gain_by_cell.csv")

# ---- 4. Time-segment decomposition ------------------------------------------
seg <- d[!is.na(Citysize) & !is.na(LCsize),
  .(pre_delivery = round(mean(pre_delivery, na.rm = TRUE), 2),
    line_haul    = round(mean(line_haul,    na.rm = TRUE), 2),
    last_mile    = round(mean(last_mile,    na.rm = TRUE), 2)),
  by = .(Citysize, LCsize, cainiao)]
seg_long <- melt(seg, id.vars = c("Citysize", "LCsize", "cainiao"),
                 variable.name = "segment", value.name = "avg_hours")
cat("\n-- Time segments (avg hours) by cell --\n"); print(seg)
w(seg_long, "agg_time_segments.csv")

# ---- 5. Cities passed --------------------------------------------------------
cities <- d[!is.na(n_city), .(
  avg_cities_passed = round(mean(n_city), 2),
  n_orders          = .N
), by = .(cainiao, LCsize)]
setorder(cities, cainiao, LCsize)
cat("\n-- Avg cities passed --\n"); print(cities)
w(cities, "agg_cities_passed.csv")

# ---- 6. Review by group ------------------------------------------------------
d[, review_num := suppressWarnings(as.numeric(review))]
review <- d[!is.na(review_num), .(
  avg_review = round(mean(review_num), 3),
  n_reviews  = .N
), by = .(Citysize, LCsize, cainiao)]
setorder(review, Citysize, LCsize, cainiao)
w(review, "agg_review_by_group.csv")

# ---- 7. Daily trend (time series) -------------------------------------------
daily <- d[, .(
  n_orders      = .N,
  avg_totaltime = round(mean(totaltime), 2)
), by = .(day, cainiao)]
setorder(daily, day, cainiao)
w(daily, "agg_daily_trend.csv")

# ---- 8. De-identified order-level sample for Tableau distributions ----------
set.seed(345)
samp <- d[sample(.N, min(.N, 100000L))]
samp <- samp[, .(order_id, day, item_qty, pay_amount, promise, review = review_num,
                 cainiao, LCsize, Citysize, n_city,
                 totaltime, pre_delivery, line_haul, last_mile)]
w(samp, "order_sample.csv")

cat("\nAll aggregates exported to ", out_dir, "/\n", sep = "")
