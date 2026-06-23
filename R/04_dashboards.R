# ==============================================================================
# 04_dashboards.R
# Polished, Tableau-style dashboard composites for the slides and report.
# Unified design system: Cainiao blue accent, grey for non-focus, red for the
# reversal cell. Built with ggplot2 + gridExtra (no extra installs).
# Reads tableau_data/*.csv ; writes figures/dash*.png
# ==============================================================================

suppressPackageStartupMessages({
  library(data.table)
  library(ggplot2)
  library(grid)
  library(gridExtra)
})

fig_dir <- "figures"
dir.create(fig_dir, showWarnings = FALSE)
rd <- function(n) fread(file.path("tableau_data", n))

## ---- design tokens ----------------------------------------------------------
BLUE  <- "#0571B0"   # Cainiao
GREY  <- "#B8BCC2"   # Non-Cainiao
RED   <- "#CA0020"   # reversal / warning
INK   <- "#1A2330"
CARD  <- "#EEF2F6"
fill_cn <- c("Cainiao" = BLUE, "Non-Cainiao" = GREY)

theme_dash <- function(base = 13) {
  theme_minimal(base_size = base) +
    theme(
      text             = element_text(color = INK),
      plot.title       = element_text(face = "bold", size = base + 2),
      plot.subtitle    = element_text(color = "#52606D", size = base - 1),
      plot.title.position = "plot",
      panel.grid.minor = element_blank(),
      panel.grid.major.x = element_blank(),
      axis.title       = element_text(color = "#52606D", size = base - 2),
      strip.text       = element_text(face = "bold", color = INK),
      legend.position  = "top",
      legend.title     = element_blank(),
      plot.margin      = margin(10, 14, 8, 14)
    )
}

## ---- KPI strip --------------------------------------------------------------
kpi <- data.table(
  x   = 1:4,
  big = c("1.29M", "30.2%", "+9.2 h", "-3.3 h"),
  lab = c("orders analysed", "handled by Cainiao",
          "Cainiao faster overall", "Cainiao SLOWER:\nbig city x small carrier"),
  col = c(INK, BLUE, BLUE, RED)
)
kpi_panel <- ggplot(kpi, aes(x, 0)) +
  annotate("rect", xmin = kpi$x - 0.46, xmax = kpi$x + 0.46,
           ymin = -1, ymax = 1, fill = CARD) +
  geom_text(aes(y = 0.32, label = big, color = I(col)),
            fontface = "bold", size = 9) +
  geom_text(aes(y = -0.55, label = lab), color = "#52606D", size = 3.4,
            lineheight = 0.9) +
  scale_x_continuous(limits = c(0.4, 4.6)) +
  scale_y_continuous(limits = c(-1, 1)) +
  theme_void()

## ---- Panel A: punchline 2x2 -------------------------------------------------
a3 <- rd("agg_cainiao_lcsize_citysize.csv")
a3[, hl := Citysize == "BigCity" & LCsize == "Small"]
note <- a3[hl == TRUE & cainiao == "Cainiao"]
pA <- ggplot(a3, aes(LCsize, avg_totaltime, fill = cainiao)) +
  geom_col(position = position_dodge(0.72), width = 0.62) +
  geom_text(aes(label = sprintf("%.0f", avg_totaltime)),
            position = position_dodge(0.72), vjust = -0.35, size = 3.1,
            color = INK) +
  geom_text(data = data.frame(Citysize = "BigCity", LCsize = "Small",
                              yy = max(a3$avg_totaltime) * 1.16),
            aes(x = LCsize, y = yy, label = "reversal cell"),
            inherit.aes = FALSE, color = RED, fontface = "bold", size = 3.4) +
  facet_wrap(~ Citysize) +
  scale_fill_manual(values = fill_cn) +
  scale_y_continuous(expand = expansion(mult = c(0, 0.22))) +
  labs(title = "Cainiao is faster everywhere...",
       subtitle = "Avg fulfillment time (hours), lower is better",
       x = NULL, y = NULL)  +
  theme_dash()

## ---- Panel B: hours saved per cell ------------------------------------------
g <- rd("agg_cainiao_gain_by_cell.csv")
g[, cell := paste0(Citysize, "\n", LCsize, " carrier")]
g[, pos := cainiao_hours_saved >= 0]
setorder(g, cainiao_hours_saved)
g[, cell := factor(cell, levels = cell)]
pB <- ggplot(g, aes(cainiao_hours_saved, cell, fill = pos)) +
  geom_col(width = 0.62) +
  geom_vline(xintercept = 0, color = "#52606D", linewidth = 0.4) +
  geom_text(aes(label = sprintf("%+.1f h", cainiao_hours_saved),
                hjust = ifelse(pos, -0.15, 1.15)), size = 3.3, color = INK) +
  scale_fill_manual(values = c(`TRUE` = BLUE, `FALSE` = RED), guide = "none") +
  scale_x_continuous(expand = expansion(mult = c(0.18, 0.18))) +
  labs(title = "...but the advantage REVERSES in one cell",
       subtitle = "Hours Cainiao saves vs non-Cainiao (negative = slower)",
       x = NULL, y = NULL) +
  theme_dash() +
  theme(panel.grid.major.y = element_blank())

## ---- assemble dash1 ---------------------------------------------------------
title1 <- textGrob("Cainiao is Fast - But Not Everywhere",
                   gp = gpar(fontface = "bold", fontsize = 20, col = INK),
                   x = 0.012, hjust = 0)
cap1 <- textGrob(
  "Cainiao saves 8-10 hours in 3 of 4 cells - but for big-city destinations on small carriers it is 3.3 h slower, with the lowest reviews.",
  gp = gpar(fontsize = 10, col = "#52606D"), x = 0.012, hjust = 0)

dash1 <- arrangeGrob(
  title1, kpi_panel,
  arrangeGrob(pA, pB, ncol = 2, widths = c(1.05, 1)),
  cap1,
  heights = c(0.07, 0.20, 0.66, 0.07)
)
ggsave(file.path(fig_dir, "dash1_story.png"), dash1,
       width = 12.5, height = 7.2, dpi = 150, bg = "white")

## ---- dash2: mechanism -------------------------------------------------------
seg <- rd("agg_time_segments.csv")
seg[, segment := factor(segment, levels = c("pre_delivery", "line_haul", "last_mile"),
                        labels = c("Pickup", "Line-haul", "Last-mile"))]
seg[, cell := paste0(Citysize, " / ", LCsize)]
seg[, hl := Citysize == "BigCity" & LCsize == "Small"]
pSeg <- ggplot(seg, aes(segment, avg_hours, fill = cainiao)) +
  geom_col(position = position_dodge(0.72), width = 0.62) +
  facet_wrap(~ cell) +
  scale_fill_manual(values = fill_cn) +
  labs(title = "Where the time goes: it's line-haul, not the last mile",
       subtitle = "Avg hours per segment. Cainiao's line-haul edge vanishes for big-city / small-carrier orders.",
       x = NULL, y = "Avg hours") +
  theme_dash()
ggsave(file.path(fig_dir, "dash2_mechanism.png"), pSeg,
       width = 10.5, height = 6, dpi = 150, bg = "white")

message("Dashboards written: dash1_story.png, dash2_mechanism.png")
