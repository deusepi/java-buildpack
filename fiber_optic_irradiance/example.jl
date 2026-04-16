#!/usr/bin/env julia
#
# Example: compute and display the cross-sectional irradiance distribution
# at 5 cm from three fiber types.
#
# Usage:
#   julia example.jl            # prints radial profiles to stdout
#   julia example.jl --plot     # also saves PNG plots (requires Plots.jl)

using Printf
include("FiberIrradiance.jl")
using .FiberIrradiance

# ─── Physical parameters ───

const DISTANCE  = 0.05           # 5 cm in meters
const POWER     = 1e-3           # 1 mW
const LAMBDA    = 1310e-9        # 1310 nm
const NA        = 0.12           # typical single-mode NA
const CORE_SM   = 4.1e-6         # SMF-28 core radius (8.2 µm diameter)
const MFR       = 4.6e-6         # mode field radius ≈ MFD/2

const NA_MM     = 0.22           # typical multimode NA
const CORE_MM   = 31.25e-6       # 62.5 µm diameter core

# ─── Build fiber configurations ───

fiber_sm  = FiberParams(NA,    CORE_SM, LAMBDA, POWER)
fiber_si  = FiberParams(NA_MM, CORE_MM, LAMBDA, POWER)
fiber_gi  = FiberParams(NA_MM, CORE_MM, LAMBDA, POWER)

sm  = SingleMode(MFR)
si  = StepIndexMultimode()
gi  = GradedIndexMultimode()

# ─── Radial sample points (0 to 20 mm) ───

r = collect(range(0.0, stop=0.020, length=500))  # meters

I_sm = irradiance_radial(fiber_sm, sm, DISTANCE, r)
I_si = irradiance_radial(fiber_si, si, DISTANCE, r)
I_gi = irradiance_radial(fiber_gi, gi, DISTANCE, r)

# ─── Print summary ───

function print_profile(name, r, I)
    peak = maximum(I)
    # Find 1/e^2 radius (where I drops to peak * exp(-2))
    threshold = peak * exp(-2)
    idx = findfirst(i -> I[i] <= threshold, eachindex(I))
    r_e2 = idx !== nothing ? r[idx] : r[end]
    @printf("  %-30s  peak = %10.2f W/m²   1/e² radius = %6.2f mm\n",
            name, peak, r_e2 * 1e3)
end

println("Fiber Optic Irradiance Model — Cross-sectional profiles at z = $(DISTANCE*100) cm")
println("=" ^ 78)
println()
@printf("  %-30s  λ = %g nm,  P = %g mW\n\n", "Common parameters", LAMBDA*1e9, POWER*1e3)

print_profile("Single-mode (Gaussian)",       r, I_sm)
print_profile("Step-index multimode (top-hat)", r, I_si)
print_profile("Graded-index multimode",        r, I_gi)
println()

# ─── Print a sampled radial table ───

println("Radial irradiance samples (W/m²):")
println("-" ^ 78)
@printf("  %8s   %14s   %14s   %14s\n", "r (mm)", "Single-mode", "Step-index MM", "Graded-index MM")
println("-" ^ 78)

sample_indices = 1:25:length(r)
for i in sample_indices
    @printf("  %8.2f   %14.4f   %14.4f   %14.4f\n",
            r[i]*1e3, I_sm[i], I_si[i], I_gi[i])
end

# ─── Optional plotting ───

if "--plot" in ARGS
    try
        using Plots
        println("\nGenerating plots...")

        # 1D radial profiles
        r_mm = r .* 1e3
        p1 = plot(r_mm, I_sm, label="Single-mode (Gaussian)", lw=2)
        plot!(p1, r_mm, I_si, label="Step-index MM (top-hat)", lw=2)
        plot!(p1, r_mm, I_gi, label="Graded-index MM", lw=2, ls=:dash)
        xlabel!(p1, "Radial distance (mm)")
        ylabel!(p1, "Irradiance (W/m²)")
        title!(p1, "Irradiance at z = $(DISTANCE*100) cm from fiber tip")
        savefig(p1, "irradiance_radial.png")
        println("  Saved irradiance_radial.png")

        # 2D map for single-mode
        xy = collect(range(-0.015, stop=0.015, length=200))
        I2d = irradiance_2d(fiber_sm, sm, DISTANCE, xy, xy)
        p2 = heatmap(xy .* 1e3, xy .* 1e3, I2d,
                     color=:inferno, aspect_ratio=:equal,
                     xlabel="x (mm)", ylabel="y (mm)",
                     title="Single-mode 2D irradiance at z = $(DISTANCE*100) cm")
        savefig(p2, "irradiance_2d_singlemode.png")
        println("  Saved irradiance_2d_singlemode.png")

        # 2D map for step-index multimode
        xy_mm = collect(range(-0.020, stop=0.020, length=200))
        I2d_si = irradiance_2d(fiber_si, si, DISTANCE, xy_mm, xy_mm)
        p3 = heatmap(xy_mm .* 1e3, xy_mm .* 1e3, I2d_si,
                     color=:inferno, aspect_ratio=:equal,
                     xlabel="x (mm)", ylabel="y (mm)",
                     title="Step-index MM 2D irradiance at z = $(DISTANCE*100) cm")
        savefig(p3, "irradiance_2d_stepindex.png")
        println("  Saved irradiance_2d_stepindex.png")

    catch e
        println("\nPlotting requires the Plots.jl package.")
        println("Install with:  using Pkg; Pkg.add(\"Plots\")")
        println("Error: ", e)
    end
end
