"""Genera figuras/00_diagrama_bloques.png (Figura 1 del informe)."""

from __future__ import annotations

from pathlib import Path

import matplotlib.pyplot as plt
from matplotlib.patches import FancyArrowPatch, FancyBboxPatch, Circle
from matplotlib.lines import Line2D


ROOT = Path(__file__).resolve().parents[1]
OUT = ROOT / "figuras" / "00_diagrama_bloques.png"

# Colores alineados con la figura existente
INK = "#1a2744"
MUTED = "#5a6578"
BOX_EDGE = "#2f3f66"
BOX_FACE = "#ffffff"
TITLE_C = "#1a2744"
SUM_EDGE = "#2f3f66"
QL_C = "#c0392b"
TAMB_C = "#1e7a45"
ARROW_C = "#1a2744"
FOOT_C = "#4a5568"


def box(ax, x, y, w, h, title, lines, title_size=10.5, body_size=8.2):
    patch = FancyBboxPatch(
        (x, y),
        w,
        h,
        boxstyle="round,pad=0.012,rounding_size=0.04",
        linewidth=1.35,
        edgecolor=BOX_EDGE,
        facecolor=BOX_FACE,
        mutation_aspect=0.6,
        zorder=3,
    )
    ax.add_patch(patch)
    ax.text(
        x + w / 2,
        y + h - 0.18,
        title,
        ha="center",
        va="top",
        fontsize=title_size,
        fontweight="bold",
        color=INK,
        zorder=4,
    )
    body = "\n".join(lines)
    ax.text(
        x + w / 2,
        y + h / 2 - 0.08,
        body,
        ha="center",
        va="center",
        fontsize=body_size,
        color=MUTED,
        linespacing=1.35,
        zorder=4,
    )
    return x, y, w, h


def arrow(ax, x0, y0, x1, y1, color=ARROW_C, lw=1.35):
    arr = FancyArrowPatch(
        (x0, y0),
        (x1, y1),
        arrowstyle="-|>",
        mutation_scale=11,
        linewidth=lw,
        color=color,
        zorder=2,
        shrinkA=0,
        shrinkB=0,
    )
    ax.add_patch(arr)


def label(ax, x, y, text, size=8.0, color=INK, ha="center", va="bottom"):
    ax.text(x, y, text, ha=ha, va=va, fontsize=size, color=color, zorder=5)


def main():
    fig, ax = plt.subplots(figsize=(11.2, 4.55), dpi=180)
    ax.set_xlim(0, 11.2)
    ax.set_ylim(0, 4.55)
    ax.axis("off")
    fig.patch.set_facecolor("white")
    ax.set_facecolor("white")

    ax.text(
        5.6,
        4.28,
        "Arquitectura funcional y niveles de señal",
        ha="center",
        va="center",
        fontsize=13.5,
        fontweight="bold",
        color=TITLE_C,
    )

    # Summing junction
    sx, sy, sr = 0.95, 2.15, 0.22
    circ = Circle((sx, sy), sr, fill=False, linewidth=1.4, edgecolor=SUM_EDGE, zorder=3)
    ax.add_patch(circ)
    ax.text(sx - 0.07, sy + 0.05, "+", fontsize=10, color=INK, ha="center", va="center")
    ax.text(sx + 0.02, sy - 0.12, "−", fontsize=11, color=INK, ha="center", va="center")

    # Blocks (x, y, w, h)
    pi = box(
        ax,
        1.55,
        1.55,
        1.55,
        1.25,
        "Controlador PI",
        [r"$K_p=0{,}025$", r"$T_i=600\,\mathrm{s}$"],
    )
    sat = box(
        ax,
        3.55,
        1.40,
        2.05,
        1.55,
        "Saturación",
        [
            r"$u=\mathrm{sat}(u_0+v^*,0,1)$",
            r"$v=u-u_0$",
            r"$u\in[0,1]$ p.u.  ·  0–100 %",
        ],
        body_size=7.6,
    )
    act = box(
        ax,
        6.05,
        1.55,
        1.55,
        1.25,
        "Actuador",
        [r"$G_a(s)$", r"$500\,\mathrm{kW/p.u.}$; $10\,\mathrm{s}$"],
    )
    th = box(
        ax,
        8.05,
        1.55,
        1.55,
        1.25,
        "Zona térmica",
        [r"$G_{th}(s)$", r"$C_{th}$; $UA$"],
    )
    sens = box(
        ax,
        9.95,
        1.45,
        1.05,
        1.45,
        "Sensor + TX + AI",
        [r"PT100 0–250 °C", r"4–20 mA → 1–5 V"],
        title_size=8.5,
        body_size=7.0,
    )

    # Horizontal chain mid-height
    mid = sy

    # r -> sum
    arrow(ax, 0.18, mid, sx - sr - 0.02, mid)
    label(ax, 0.42, mid + 0.12, r"$r$ [°C]", size=8.5)

    # sum -> PI
    arrow(ax, sx + sr + 0.02, mid, pi[0] - 0.02, mid)
    label(ax, sx + sr + 0.28, mid + 0.12, r"$e$ [°C]", size=8.5)

    # PI -> sat
    arrow(ax, pi[0] + pi[2] + 0.02, mid, sat[0] - 0.02, mid)
    label(ax, pi[0] + pi[2] + 0.22, mid + 0.12, r"$v^*$ [p.u.]", size=8.2)

    # sat -> act
    arrow(ax, sat[0] + sat[2] + 0.02, mid, act[0] - 0.02, mid)
    label(ax, sat[0] + sat[2] + 0.22, mid + 0.12, r"$v$ [p.u.]", size=8.5)

    # also annotate u near sat output area (physical command)
    label(
        ax,
        sat[0] + sat[2] / 2,
        sat[1] - 0.12,
        r"$u$ [p.u.] · 4–20 mA",
        size=7.4,
        color=MUTED,
        va="top",
    )

    # act -> thermal
    arrow(ax, act[0] + act[2] + 0.02, mid, th[0] - 0.02, mid)
    label(ax, act[0] + act[2] + 0.22, mid + 0.12, r"$q_h$ [kW]", size=8.5)

    # thermal -> sensor
    arrow(ax, th[0] + th[2] + 0.02, mid, sens[0] - 0.02, mid)
    label(ax, th[0] + th[2] + 0.18, mid + 0.12, r"$\theta_z$ [°C]", size=8.5)

    # Disturbances into thermal zone (top)
    th_cx = th[0] + th[2] / 2
    th_top = th[1] + th[3]

    def disturbance(x, color, sign, caption, caption_dx=0.0):
        # Stem into the block, with a signed badge at the entry
        ax.add_line(Line2D([x, x], [3.55, th_top + 0.22], color=color, lw=1.45, zorder=2))
        arrow(ax, x, th_top + 0.22, x, th_top + 0.01, color=color, lw=1.45)
        badge = Circle(
            (x, th_top + 0.34),
            0.12,
            facecolor="white",
            edgecolor=color,
            linewidth=1.25,
            zorder=6,
        )
        ax.add_patch(badge)
        ax.text(
            x,
            th_top + 0.34,
            sign,
            color=color,
            fontsize=11,
            fontweight="bold",
            ha="center",
            va="center",
            zorder=7,
        )
        label(ax, x + caption_dx, 3.72, caption, size=7.6, color=color, va="bottom")

    # q_L enters the thermal balance with NEGATIVE sign
    disturbance(th_cx - 0.38, QL_C, "−", r"$q_L$ [kW] (carga agrupada)", caption_dx=-0.05)
    disturbance(th_cx + 0.38, TAMB_C, "+", r"$T_{amb}$ [°C]")

    # Feedback path: sensor bottom -> left -> up into sum
    sx_out = sens[0] + sens[2] / 2
    y_fb = 0.72
    ax.add_line(Line2D([sx_out, sx_out], [sens[1], y_fb], color=ARROW_C, lw=1.35, zorder=2))
    ax.add_line(Line2D([sx_out, sx], [y_fb, y_fb], color=ARROW_C, lw=1.35, zorder=2))
    arrow(ax, sx, y_fb, sx, sy - sr - 0.02)
    label(
        ax,
        5.4,
        y_fb + 0.08,
        r"$T_m$ [°C]  ·  $H_s(s)=1$",
        size=8.0,
        color=MUTED,
        va="bottom",
    )

    # Footer
    ax.text(
        5.6,
        0.28,
        r"Modelo en variables incrementales alrededor de "
        r"$T_{z0}=180\,^\circ\mathrm{C}$, $u_0=0{,}70$ y $Q_{L0}=40\,\mathrm{kW}$.",
        ha="center",
        va="center",
        fontsize=8.5,
        color=FOOT_C,
    )

    OUT.parent.mkdir(parents=True, exist_ok=True)
    fig.savefig(OUT, dpi=180, bbox_inches="tight", pad_inches=0.12, facecolor="white")
    plt.close(fig)
    print(OUT)


if __name__ == "__main__":
    main()
