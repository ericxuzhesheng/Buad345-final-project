#!/usr/bin/env python3
"""Generate English-only report charts.

The Tableau screenshots previously embedded in the report included localized
footer text. This script rebuilds those chart PNGs directly from the exported
aggregate CSVs so report/slides images are reproducible and English-only.
"""

from pathlib import Path

import matplotlib.pyplot as plt
import pandas as pd
from matplotlib.patches import Patch


ROOT = Path(__file__).resolve().parents[1]
DATA_DIR = ROOT / "tableau_data"
DATA = DATA_DIR / "agg_cainiao_lcsize_citysize.csv"
FIG_DIR = ROOT / "figures"

BLUE = "#0571B0"
GREY = "#9AA0A6"
ORANGE = "#F28E2B"


def load_reviews() -> pd.DataFrame:
    df = pd.read_csv(DATA)
    df["cainiao"] = pd.Categorical(
        df["cainiao"], categories=["Cainiao", "Non-Cainiao"], ordered=True
    )
    df["LCsize"] = pd.Categorical(
        df["LCsize"], categories=["Large", "Small"], ordered=True
    )
    df["Citysize"] = pd.Categorical(
        df["Citysize"], categories=["BigCity", "SmallCity"], ordered=True
    )
    return df.sort_values(["Citysize", "LCsize", "cainiao"])


def style_axes(ax, y_max=None, y_ticks=None):
    if y_max is not None:
        ax.set_ylim(0, y_max)
    if y_ticks is not None:
        ax.set_yticks(y_ticks)
    ax.grid(axis="y", color="#E6E6E6", linewidth=1)
    ax.set_axisbelow(True)
    ax.spines["top"].set_visible(False)
    ax.spines["right"].set_visible(False)
    ax.spines["left"].set_color("#D0D0D0")
    ax.spines["bottom"].set_color("#D0D0D0")
    ax.tick_params(colors="#555555")


def generate_headline() -> Path:
    out = FIG_DIR / "tab_headline.png"
    df = pd.read_csv(DATA_DIR / "agg_cainiao_overall.csv")
    fig, ax = plt.subplots(figsize=(8.4, 6.2))
    colors = [BLUE if g == "Cainiao" else ORANGE for g in df["cainiao"]]
    bars = ax.bar(df["cainiao"], df["avg_totaltime"], color=colors, width=0.55)
    for bar, value in zip(bars, df["avg_totaltime"]):
        ax.text(bar.get_x() + bar.get_width() / 2, value + 1.5, f"{value:.1f} h", ha="center", fontsize=13)
    style_axes(ax, y_max=80, y_ticks=[0, 20, 40, 60, 80])
    ax.set_title("Cainiao is faster overall", fontsize=20, pad=18)
    ax.set_ylabel("Avg fulfillment time (hours)", fontsize=13)
    ax.set_xlabel("")
    fig.tight_layout()
    fig.savefig(out, dpi=150, bbox_inches="tight", facecolor="white")
    plt.close(fig)
    return out


def generate_punchline(df: pd.DataFrame) -> Path:
    out = FIG_DIR / "tab_punchline.png"
    fig, ax = plt.subplots(figsize=(14.4, 8.6))
    combos = [
        ("BigCity", "Large"),
        ("BigCity", "Small"),
        ("SmallCity", "Large"),
        ("SmallCity", "Small"),
    ]
    base_x = [0, 2.3, 4.6, 6.9]
    width = 0.75
    colors = {"Cainiao": BLUE, "Non-Cainiao": ORANGE}

    for x, (city, carrier) in zip(base_x, combos):
        part = df[(df["Citysize"] == city) & (df["LCsize"] == carrier)].set_index("cainiao")
        for offset, group in [(-0.45, "Cainiao"), (0.45, "Non-Cainiao")]:
            value = float(part.loc[group, "avg_totaltime"])
            ax.bar(x + offset, value, width=width, color=colors[group], edgecolor="white")
            ax.text(x + offset, value + 1.2, f"{value:.1f}", ha="center", va="bottom", fontsize=12)
            ax.text(x + offset, -3.2, group, ha="center", va="top", fontsize=11, color="#666666", clip_on=False)
        ax.text(x, -9.0, f"{city}\n{carrier}", ha="center", va="top", fontsize=12, color="#444444", clip_on=False)

    style_axes(ax, y_max=82, y_ticks=[0, 20, 40, 60, 80])
    ax.set_xlim(-1.1, 8.0)
    ax.set_xticks([])
    ax.set_ylabel("Avg fulfillment time (hours)", fontsize=13)
    ax.set_title("Cainiao is fast, but not everywhere", fontsize=22, loc="left", pad=28, color="#444444")
    ax.text(0.0, 1.03, "Average fulfillment hours by destination city size and carrier size", transform=ax.transAxes, fontsize=13, color="#666666")
    for x in [1.15, 3.45, 5.75]:
        ax.axvline(x, color="#D0D0D0", linewidth=1)
    ax.legend(
        handles=[Patch(facecolor=colors["Cainiao"], label="Cainiao"), Patch(facecolor=colors["Non-Cainiao"], label="Non-Cainiao")],
        loc="upper right",
        bbox_to_anchor=(1.0, 1.14),
        frameon=False,
        ncol=2,
        fontsize=12,
    )
    fig.tight_layout(rect=[0, 0.06, 1, 0.94])
    fig.savefig(out, dpi=150, bbox_inches="tight", facecolor="white")
    plt.close(fig)
    return out


def generate_trend() -> Path:
    out = FIG_DIR / "tab_trend.png"
    df = pd.read_csv(DATA_DIR / "agg_daily_trend.csv", parse_dates=["day"])
    fig, ax = plt.subplots(figsize=(14, 6.6))
    colors = {"Cainiao": BLUE, "Non-Cainiao": ORANGE}
    for group, part in df.groupby("cainiao", sort=False):
        part = part.sort_values("day")
        ax.plot(part["day"], part["avg_totaltime"], color=colors[group], alpha=0.28, linewidth=0.8)
        smooth = part["avg_totaltime"].rolling(14, center=True, min_periods=3).mean()
        ax.plot(part["day"], smooth, color=colors[group], linewidth=2.4, label=group)
    y_max = int(df["avg_totaltime"].max() / 50 + 1) * 50
    style_axes(ax, y_max=y_max, y_ticks=list(range(0, y_max + 1, 50)))
    ax.set_title("Cainiao stays faster across the whole period", fontsize=22, loc="left", pad=18, color="#444444")
    ax.set_ylabel("Avg fulfillment time (hours)", fontsize=13)
    ax.set_xlabel("")
    ax.legend(loc="upper right", frameon=False, ncol=2, fontsize=12)
    fig.autofmt_xdate(rotation=0)
    fig.tight_layout()
    fig.savefig(out, dpi=150, bbox_inches="tight", facecolor="white")
    plt.close(fig)
    return out


def generate_ggplot_style(df: pd.DataFrame) -> Path:
    out = FIG_DIR / "fig4_review.png"
    fig, axes = plt.subplots(1, 2, figsize=(12, 6.75), sharey=True)
    fig.suptitle(
        "Customer reviews echo it: Cainiao's lowest score is Big-city x Small carrier",
        fontsize=20,
        y=0.96,
    )
    handles = [
        Patch(facecolor=BLUE, edgecolor="none", label="Cainiao"),
        Patch(facecolor=GREY, edgecolor="none", label="Non-Cainiao"),
    ]
    fig.legend(handles=handles, loc="upper center", ncol=2, frameon=False, bbox_to_anchor=(0.52, 0.90), fontsize=12)

    for ax, city in zip(axes, ["BigCity", "SmallCity"]):
        part = df[df["Citysize"] == city]
        x_positions = [0, 1]
        width = 0.30
        for i, carrier in enumerate(["Large", "Small"]):
            vals = part[part["LCsize"] == carrier].set_index("cainiao")["avg_review"]
            bars = ax.bar(
                [x_positions[i] - width / 1.7, x_positions[i] + width / 1.7],
                [vals["Cainiao"], vals["Non-Cainiao"]],
                width=width,
                color=[BLUE, GREY],
            )
            for bar, value in zip(bars, [vals["Cainiao"], vals["Non-Cainiao"]]):
                ax.text(
                    bar.get_x() + bar.get_width() / 2,
                    value + 0.035,
                    f"{value:.3f}",
                    ha="center",
                    va="bottom",
                    fontsize=10,
                )

        style_axes(ax, y_max=5.0, y_ticks=[0, 1, 2, 3, 4, 5])
        ax.set_title(city, fontsize=13, pad=8)
        ax.set_xticks(x_positions, ["Large", "Small"], fontsize=12)
        ax.set_xlabel("")

    axes[0].set_ylabel("Avg logistics review", fontsize=13)
    fig.supxlabel("Carrier size", fontsize=14, y=0.06)
    fig.tight_layout(rect=[0.04, 0.08, 1, 0.84], w_pad=2.0)
    fig.savefig(out, dpi=150, bbox_inches="tight", facecolor="white")
    plt.close(fig)
    return out


def generate_tableau_review(df: pd.DataFrame, out_name: str = "tab_reviews.png") -> Path:
    out = FIG_DIR / out_name
    fig, ax = plt.subplots(figsize=(18.34, 13.10))
    fig.suptitle(
        "Customer reviews mirror the punchline: lowest for Cainiao in big-city/small-carrier",
        fontsize=26,
        color="#4D4D4D",
        x=0.01,
        y=0.985,
        ha="left",
    )

    combos = [
        ("BigCity", "Large"),
        ("BigCity", "Small"),
        ("SmallCity", "Large"),
        ("SmallCity", "Small"),
    ]
    base_x = [0, 2.2, 4.4, 6.6]
    bar_width = 0.82
    colors = {"Cainiao": "#4E79A7", "Non-Cainiao": ORANGE}

    for x, (city, carrier) in zip(base_x, combos):
        part = df[(df["Citysize"] == city) & (df["LCsize"] == carrier)].set_index("cainiao")
        for offset, group in [(-0.55, "Cainiao"), (0.55, "Non-Cainiao")]:
            value = float(part.loc[group, "avg_review"])
            ax.bar(x + offset, value, width=bar_width, color=colors[group], edgecolor="white")
            ax.text(
                x + offset,
                value + 0.035,
                f"{value:.5f}",
                ha="center",
                va="bottom",
                fontsize=15,
                color="#303030",
            )
            ax.text(
                x + offset,
                -0.09,
                group,
                ha="center",
                va="top",
                fontsize=13,
                color="#777777",
                clip_on=False,
            )

    style_axes(ax, y_max=5.0, y_ticks=[0, 1, 2, 3, 4, 5])
    ax.set_xlim(-1.1, 7.7)
    ax.set_ylabel("Avg Review", fontsize=15)
    ax.set_xticks([])
    ax.tick_params(axis="y", labelsize=14)

    for x in [1.1, 3.3, 5.5]:
        ax.axvline(x, color="#D0D0D0", linewidth=1)
    for x, (_, carrier) in zip(base_x, combos):
        ax.text(x, 5.03, carrier, ha="center", va="bottom", fontsize=15, color="#777777", clip_on=False)
    ax.text(1.1, 5.18, "BigCity", ha="center", va="bottom", fontsize=15, color="#777777", clip_on=False)
    ax.text(5.5, 5.18, "SmallCity", ha="center", va="bottom", fontsize=15, color="#777777", clip_on=False)
    ax.text(
        3.3,
        5.34,
        "Citysize / Carrier size / Cainiao",
        ha="center",
        va="bottom",
        fontsize=15,
        color="#303030",
        fontweight="bold",
        clip_on=False,
    )

    handles = [
        Patch(facecolor=colors["Cainiao"], label="Cainiao"),
        Patch(facecolor=colors["Non-Cainiao"], label="Non-Cainiao"),
    ]
    ax.legend(
        handles=handles,
        title="Cainiao",
        loc="upper left",
        bbox_to_anchor=(1.01, 1.0),
        frameon=False,
        fontsize=14,
        title_fontsize=15,
    )

    fig.tight_layout(rect=[0, 0.05, 0.93, 0.94])
    fig.savefig(out, dpi=150, bbox_inches="tight", facecolor="white")
    plt.close(fig)
    return out


def generate_segments() -> Path:
    out = FIG_DIR / "tab_segments.png"
    df = pd.read_csv(DATA_DIR / "agg_time_segments.csv")
    segment_order = ["pre_delivery", "line_haul", "last_mile"]
    segment_labels = {
        "pre_delivery": "Pre-delivery",
        "line_haul": "Line-haul",
        "last_mile": "Last-mile",
    }
    segment_colors = {
        "pre_delivery": "#D62728",
        "line_haul": ORANGE,
        "last_mile": BLUE,
    }
    combos = [
        ("BigCity", "Large"),
        ("BigCity", "Small"),
        ("SmallCity", "Large"),
        ("SmallCity", "Small"),
    ]
    base_x = [0, 2.35, 4.70, 7.05]
    width = 0.75

    fig, ax = plt.subplots(figsize=(14.8, 8.4))
    for x, (city, carrier) in zip(base_x, combos):
        for offset, group in [(-0.45, "Cainiao"), (0.45, "Non-Cainiao")]:
            bottom = 0.0
            part = df[(df["Citysize"] == city) & (df["LCsize"] == carrier) & (df["cainiao"] == group)].set_index("segment")
            for segment in segment_order:
                value = float(part.loc[segment, "avg_hours"])
                ax.bar(x + offset, value, bottom=bottom, width=width, color=segment_colors[segment], edgecolor="white")
                bottom += value
            ax.text(x + offset, bottom + 0.9, f"{bottom:.1f}", ha="center", fontsize=11)
            ax.text(x + offset, -2.5, group, ha="center", va="top", fontsize=11, color="#666666", clip_on=False)
        ax.text(x, -7.1, f"{city}\n{carrier}", ha="center", va="top", fontsize=12, color="#444444", clip_on=False)

    style_axes(ax, y_max=65, y_ticks=[0, 15, 30, 45, 60])
    ax.set_xlim(-1.1, 8.1)
    ax.set_xticks([])
    ax.set_ylabel("Avg segment time (hours)", fontsize=13)
    ax.set_title("The bottleneck is line-haul, not the last mile", fontsize=22, loc="left", pad=28, color="#444444")
    ax.text(0.0, 1.03, "Stacked average hours by destination city size, carrier size, and Cainiao status", transform=ax.transAxes, fontsize=13, color="#666666")
    for x in [1.175, 3.525, 5.875]:
        ax.axvline(x, color="#D0D0D0", linewidth=1)
    handles = [Patch(facecolor=segment_colors[s], label=segment_labels[s]) for s in segment_order]
    ax.legend(handles=handles, loc="upper right", frameon=False, ncol=3, fontsize=12)
    fig.tight_layout(rect=[0, 0.06, 1, 0.94])
    fig.savefig(out, dpi=150, bbox_inches="tight", facecolor="white")
    plt.close(fig)
    return out


def main():
    FIG_DIR.mkdir(exist_ok=True)
    df = load_reviews()
    paths = [
        generate_headline(),
        generate_trend(),
        generate_punchline(df),
        generate_ggplot_style(df),
        generate_tableau_review(df),
        generate_tableau_review(df, "tab_reviews_zero_axis.png"),
        generate_segments(),
    ]
    # Compatibility output from the user's first request.
    zero_axis = FIG_DIR / "fig4_review_zero_axis.png"
    zero_axis.write_bytes((FIG_DIR / "fig4_review.png").read_bytes())
    paths.append(zero_axis)
    for path in paths:
        print(path)


if __name__ == "__main__":
    main()
