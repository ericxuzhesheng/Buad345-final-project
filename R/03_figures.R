# ==============================================================================
# 03_figures.R
# Generates the ggplot figures used in the written report. Reads the aggregate
# CSVs from tableau_data/ and writes PNGs to figures/.
# ==============================================================================

suppressPackageStartupMessages({
  library(data.table)
  library(ggplot2)
})

fig_dir <- "figures"
dir.create(fig_dir, showWarnings = FALSE)

read_agg <- function(name) fread(file.path("tableau_data", name))

accent <- "#0571B0"   # Cainiao
grey   <- "#9AA0A6"   # Non-Cainiao
theme_set(theme_minimal(base_size = 12))

# ---- Fig 1: L1 main effect ---------------------------------------------------
a1 <- read_agg("agg_cainiao_overall.csv")
p1 <- ggplot(a1, aes(cainiao, avg_totaltime, fill = cainiao)) +
  geom_col(width = 0.55) +
  geom_text(aes(label = sprintf("%.1f h", avg_totaltime)), vjust = -0.4) +
  scale_fill_manual(values = c("Cainiao" = accent, "Non-Cainiao" = grey)) +
  labs(title = "Cainiao is faster overall",
       x = NULL, y = "Avg fulfillment time (hours)") +
  guides(fill = "none")
ggsave(file.path(fig_dir, "fig1_main_effect.png"), p1, width = 6, height = 4, dpi = 150)

# Note: the standalone punchline (fig2) and segment (fig3) charts were superseded
# by the composite dashboards in R/04_dashboards.R (dash1_story / dash2_mechanism).

# ---- Fig 4: review score echoes the punchline -------------------------------
# (Cities-passed does NOT explain the gap -- small carriers pass through *fewer*
#  cities -- so we show the customer-review echo instead, which DOES line up.)
rv <- read_agg("agg_review_by_group.csv")
p4 <- ggplot(rv, aes(LCsize, avg_review, fill = cainiao)) +
  geom_col(position = position_dodge(width = 0.7), width = 0.6) +
  geom_text(aes(label = sprintf("%.3f", avg_review)),
            position = position_dodge(width = 0.7), vjust = -0.3, size = 2.8) +
  facet_wrap(~ Citysize) +
  coord_cartesian(ylim = c(0, 5)) +
  scale_fill_manual(values = c("Cainiao" = accent, "Non-Cainiao" = grey)) +
  labs(title = "Customer reviews echo it: Cainiao's lowest score is Big-city x Small carrier",
       x = "Carrier size", y = "Avg logistics review", fill = NULL) +
  theme(legend.position = "top")
ggsave(file.path(fig_dir, "fig4_review.png"), p4, width = 8, height = 4.5, dpi = 150)

# ---- Fig 5: daily trend (descriptive) ---------------------------------------
dt <- read_agg("agg_daily_trend.csv")
dt[, day := as.Date(day)]
p5 <- ggplot(dt, aes(day, avg_totaltime, color = cainiao)) +
  geom_line(linewidth = 0.4, alpha = 0.55) +
  geom_smooth(se = FALSE, linewidth = 1, method = "loess", span = 0.3) +
  scale_color_manual(values = c("Cainiao" = accent, "Non-Cainiao" = grey)) +
  labs(title = "Cainiao stays faster across the whole period (Jan-Jul 2017)",
       x = NULL, y = "Avg fulfillment time (hours)", color = NULL) +
  theme(legend.position = "top")
ggsave(file.path(fig_dir, "fig5_daily_trend.png"), p5, width = 8, height = 3.8, dpi = 150)

message("Figures written to ", fig_dir, "/")
