# ==============================================================================
# 01_build_analysis_table.R
# BUAD 345 Final Project - Cainiao logistics analysis
#
# Builds one order-level analysis table from the three raw CSVs:
#   - total fulfillment time and its three segments (pre-delivery / line-haul /
#     last-mile)
#   - logistic-company size (Large/Small), destination-city size (Big/Small)
#   - number of distinct cities a package passes through
# Output: data/order_analysis.rds  (intermediate, git-ignored)
#
# Reuses the verified joins/definitions from Cainiao_Project.r (starter script):
#   totaltime = SIGNED - pay_timestamp ; LCsize threshold = 200,000 orders ;
#   BigCity = destination city_id in {234, 133}.
# ==============================================================================

suppressPackageStartupMessages({
  library(data.table)
  library(lubridate)
})

# Use all but one core for data.table grouped ops on the ~18M-row logistics file.
setDTthreads(0L)

# ---- paths -------------------------------------------------------------------
order_csv     <- "CourseProject_Order.csv"
logistics_csv <- "CourseProject_Logistics.csv"
out_dir       <- "data"
dir.create(out_dir, showWarnings = FALSE)

LC_LARGE_THRESHOLD <- 200000L          # orders; top carriers above this are "Large"
BIG_CITY_IDS       <- c(234L, 133L)    # destination cities flagged as big in starter

# ---- 1. Order data -----------------------------------------------------------
message("Reading order data ...")
odat <- fread(order_csv)
odat[, pay_timestamp := ymd_hms(pay_timestamp)]
# Keep one row per order_id (orders csv is already order-level, but guard anyway).
setkey(odat, order_id)

# ---- 2. Logistics data: read only the columns we need ------------------------
message("Reading logistics data (large file) ...")
ld <- fread(
  logistics_csv,
  select = c("order_id", "action", "city_id", "logistic_company_id", "timestamp")
)

# ---- 2a. Event timestamps per order -----------------------------------------
# Parse timestamps only on the milestone rows we actually need (smaller subset).
message("Extracting milestone timestamps ...")
ev <- ld[action %in% c("CONSIGN", "GOT", "SENT_SCAN", "SIGNED")]
ev[, ts := ymd_hms(timestamp)]

cons <- ev[action == "CONSIGN",   .(CONSIGN   = min(ts, na.rm = TRUE)), by = order_id]
got  <- ev[action == "GOT",       .(GOT       = min(ts, na.rm = TRUE)), by = order_id]
sent <- ev[action == "SENT_SCAN", .(SENT_SCAN = min(ts, na.rm = TRUE)), by = order_id]
sig  <- ev[action == "SIGNED",    .(SIGNED    = max(ts, na.rm = TRUE)), by = order_id]

# ---- 2b. Cities passed, destination city, carrier ----------------------------
message("Computing cities-passed, destination city, carrier ...")
city_cnt <- ld[!is.na(city_id), .(n_city = uniqueN(city_id)), by = order_id]
dest     <- ld[action == "SIGNED" & !is.na(city_id),
               .(dest_city = city_id[1]), by = order_id]
lc       <- ld[!is.na(logistic_company_id),
               .(lc = logistic_company_id[1]), by = order_id]

# Carrier size: orders handled per carrier across the whole dataset.
lc_size <- lc[, .(lc_norder = .N), by = lc]
lc_size[, LCsize := fifelse(lc_norder > LC_LARGE_THRESHOLD, "Large", "Small")]
lc <- merge(lc, lc_size[, .(lc, LCsize)], by = "lc", all.x = TRUE)

rm(ld, ev); gc()

# ---- 3. Assemble order-level analysis table ----------------------------------
message("Merging into order-level table ...")
for (dt in list(cons, got, sent, sig, city_cnt, dest, lc)) {
  odat <- merge(odat, dt, by = "order_id", all.x = TRUE)
}

# Non-finite (Inf/-Inf from empty min/max) -> NA
for (col in c("CONSIGN", "GOT", "SENT_SCAN", "SIGNED")) {
  set(odat, i = which(!is.finite(odat[[col]])), j = col, value = as.POSIXct(NA))
}

# ---- 4. Derived metrics (hours) ----------------------------------------------
odat[, totaltime    := as.numeric(SIGNED    - pay_timestamp) / 3600]
odat[, pre_delivery := as.numeric(GOT       - pay_timestamp) / 3600]  # order -> picked up
odat[, line_haul    := as.numeric(SENT_SCAN - GOT)           / 3600]  # transit between facilities
odat[, last_mile    := as.numeric(SIGNED    - SENT_SCAN)     / 3600]  # final delivery

odat[, Citysize  := fifelse(dest_city %in% BIG_CITY_IDS, "BigCity", "SmallCity")]
odat[, cainiao   := fifelse(if_cainiao == 1L, "Cainiao", "Non-Cainiao")]

# Analysis flag: keep orders with a valid, positive, plausible total time.
odat[, valid := is.finite(totaltime) & totaltime > 0 & totaltime < 24 * 30]

message(sprintf("Total orders: %s | with valid fulfillment time: %s",
                format(nrow(odat), big.mark = ","),
                format(sum(odat$valid, na.rm = TRUE), big.mark = ",")))

saveRDS(odat, file.path(out_dir, "order_analysis.rds"))
message("Saved ", file.path(out_dir, "order_analysis.rds"))
