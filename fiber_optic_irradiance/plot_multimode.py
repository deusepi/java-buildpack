#!/usr/bin/env python3
"""
Plot the cross-sectional irradiance distribution for both multimode fiber types
(step-index top-hat and graded-index Gaussian-like) at 5 cm from the fiber tip.

x-axis: radial distance centered on the fiber axis (negative = left, positive = right)
y-axis: irradiance (W/m^2)
"""

import numpy as np
import matplotlib
matplotlib.use("Agg")
import matplotlib.pyplot as plt

# ─── Fiber parameters ───
POWER      = 1e-3          # 1 mW
NA         = 0.22          # typical multimode NA
CORE_R     = 31.25e-6      # 62.5 µm diameter core → 31.25 µm radius
DISTANCE   = 0.05          # 5 cm

# ─── Step-index multimode (top-hat) ───
theta_max    = np.arcsin(NA)
spot_radius  = DISTANCE * np.tan(theta_max) + CORE_R   # ~11.3 mm
area_si      = np.pi * spot_radius**2
I_uniform    = POWER / area_si

# ─── Graded-index multimode (Gaussian-like) ───
wz        = DISTANCE * np.tan(theta_max) + CORE_R      # 1/e^2 radius same geometry
I0_gi     = 2.0 * POWER / (np.pi * wz**2)

# ─── Radial sample points (symmetric about axis) ───
r = np.linspace(-0.020, 0.020, 2000)   # ±20 mm in meters
r_mm = r * 1e3                          # for display

I_si = np.where(np.abs(r) <= spot_radius, I_uniform, 0.0)
I_gi = I0_gi * np.exp(-2.0 * r**2 / wz**2)

# ─── Plot ───
fig, ax = plt.subplots(figsize=(10, 6))

ax.plot(r_mm, I_si, color="#e74c3c", linewidth=2.2, label="Step-index multimode (top-hat)")
ax.plot(r_mm, I_gi, color="#2980b9", linewidth=2.2, label="Graded-index multimode (Gaussian-like)", linestyle="--")

ax.axvline(0, color="gray", linewidth=0.8, linestyle=":")
ax.set_xlabel("Distance from fiber axis (mm)", fontsize=13)
ax.set_ylabel("Irradiance (W/m²)", fontsize=13)
ax.set_title(
    f"Multimode Fiber Irradiance at z = {DISTANCE*100:.0f} cm\n"
    f"NA = {NA},  core ∅ = {CORE_R*2e6:.1f} µm,  P = {POWER*1e3:.0f} mW",
    fontsize=14,
)
ax.legend(fontsize=12)
ax.set_xlim(-20, 20)
ax.set_ylim(bottom=0)
ax.grid(True, alpha=0.3)

spot_mm = spot_radius * 1e3
ax.annotate(
    f"spot radius = {spot_mm:.2f} mm",
    xy=(spot_mm, I_uniform), xytext=(spot_mm + 2, I_uniform * 0.8),
    arrowprops=dict(arrowstyle="->", color="#e74c3c"),
    fontsize=10, color="#e74c3c",
)

fig.tight_layout()
out = "multimode_irradiance.png"
fig.savefig(out, dpi=150)
print(f"Saved {out}")
