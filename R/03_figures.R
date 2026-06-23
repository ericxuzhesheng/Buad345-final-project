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

# ---- Fig 2: L3 punchline 2x2x2 ----------------------------------------------
a3 <- read_agg("agg_cainiao_lcsize_citysize.csv")
p2 <- ggplot(a3, aes(LCsize, avg_totaltime, fill = cainiao)) +
  geom_col(position = position_dodge(width = 0.7), width = 0.6) +
  geom_text(aes(label = sprintf("%.0f", avg_totaltime)),
            position = position_dodge(width = 0.7), vjust = -0.3, size = 3) +
  facet_wrap(~ Citysize) +
  scale_fill_manual(values = c("Cainiao" = accent, "Non-Cainiao" = grey)) +
  labs(title = "...BUT the advantage shrinks for Big-city destinations on Small carriers",
       x = NULL, y = "Avg fulfillment time (hours)", fill = NULL) +
  theme(legend.position = "top")
ggsave(file.path(fig_dir, "fig2_punchline.png"), p2, width = 8, height = 4.5, dpi = 150)

# ---- Fig 3: time-segment decomposition --------------------------------------
seg <- read_agg("agg_time_segments.csv")
seg[, segment := factor(segment, levels = c("pre_delivery", "line_haul", "last_mile"))]
p3 <- ggplot(seg, aes(cainiao, avg_hours, fill = segment)) +
  geom_col() +
  facet_grid(Citysize ~ LCsize) +
  scale_fill_manual(values = c(pre_delivery = "#CA0020",
                               line_haul = "#F4A582",
                               last_mile = "#92C5DE")) +
  labs(title = "Where the time goes: segment decomposition",
       x = NULL, y = "Avg hours", fill = "Segment") +
  theme(axis.text.x = element_text(angle = 20, hjust = 1))
ggsave(file.path(fig_dir, "fig3_segments.png"), p3, width = 8, height = 5.5, dpi = 150)

# ---- Fig 4: review score echoes the punchline -------------------------------
# (Cities-passed does NOT explain the gap -- small carriers pass through *fewer*
#  cities -- so we show the customer-review echo instead, which DOES line up.)
rv <- read_agg("agg_review_by_group.csv")
p4 <- ggplot(rv, aes(LCsize, avg_review, fill = cainiao)) +
  geom_col(position = position_dodge(width = 0.7), width = 0.6) +
  geom_text(aes(label = sprintf("%.3f", avg_review)),
            position = position_dodge(width = 0.7), vjust = -0.3, size = 2.8) +
  facet_wrap(~ Citysize) +
  coord_cartesian(ylim = c(4.7, 4.9)) +
  scale_fill_manual(values = c("Cainiao" = accent, "Non-Cainiao" = grey)) +
  labs(title = "Customer reviews echo it: Cainiao's lowest score is Big-city x Small carrier",
       x = "Carrier size", y = "Avg logistics review", fill = NULL) +
  theme(legend.position = "top")
ggsave(file.path(fig_dir, "fig4_review.png"), p4, width = 8, height = 4.5, dpi = 150)

message("Figures written to ", fig_dir, "/")
