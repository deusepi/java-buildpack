module FiberIrradiance

export FiberParams, SingleMode, StepIndexMultimode, GradedIndexMultimode,
       irradiance_radial, irradiance_2d, beam_radius_at

"""
    FiberParams

Common physical parameters shared by all fiber types.

# Fields
- `na::Float64`: Numerical aperture
- `core_radius::Float64`: Core radius in meters
- `wavelength::Float64`: Operating wavelength in meters
- `power::Float64`: Total output power in watts
"""
struct FiberParams
    na::Float64
    core_radius::Float64
    wavelength::Float64
    power::Float64
end

# ─── Fiber type tags ───

"""Single-mode fiber — output modeled as a Gaussian beam."""
struct SingleMode
    mode_field_radius::Float64  # meters (MFD / 2)
end

"""Multimode step-index fiber — far-field modeled as a uniform top-hat."""
struct StepIndexMultimode end

"""Multimode graded-index fiber — far-field modeled as a Gaussian-like profile."""
struct GradedIndexMultimode end

# ─── Gaussian beam helpers ───

"""Rayleigh range z_R = pi * w0^2 / lambda."""
rayleigh_range(w0::Float64, lambda::Float64) = pi * w0^2 / lambda

"""Beam 1/e^2 radius at distance z from the waist."""
function beam_radius_at(w0::Float64, lambda::Float64, z::Float64)
    zr = rayleigh_range(w0, lambda)
    return w0 * sqrt(1.0 + (z / zr)^2)
end

# ─── Single-mode (Gaussian beam) ───

"""
    irradiance_radial(fiber, sm, z, r)

Compute irradiance I(r) at axial distance `z` and radial positions `r`
for a single-mode fiber (Gaussian beam model).

Returns a vector of irradiance values in W/m^2.
"""
function irradiance_radial(fiber::FiberParams, sm::SingleMode, z::Float64, r::AbstractVector{Float64})
    w0 = sm.mode_field_radius
    wz = beam_radius_at(w0, fiber.wavelength, z)
    I0 = 2.0 * fiber.power / (pi * wz^2)  # peak irradiance from power normalization
    return I0 .* exp.(-2.0 .* r.^2 ./ wz^2)
end

"""
    irradiance_2d(fiber, sm, z, x, y)

Compute the 2D irradiance map I(x, y) at axial distance `z`
for a single-mode fiber (Gaussian beam model).

Returns a matrix of size (length(y), length(x)) in W/m^2.
"""
function irradiance_2d(fiber::FiberParams, sm::SingleMode, z::Float64,
                       x::AbstractVector{Float64}, y::AbstractVector{Float64})
    w0 = sm.mode_field_radius
    wz = beam_radius_at(w0, fiber.wavelength, z)
    I0 = 2.0 * fiber.power / (pi * wz^2)
    return [I0 * exp(-2.0 * (xi^2 + yj^2) / wz^2) for yj in y, xi in x]
end

# ─── Multimode step-index (top-hat) ───

"""
    irradiance_radial(fiber, ::StepIndexMultimode, z, r)

Far-field top-hat model.  Uniform irradiance inside the NA cone,
zero outside. The illuminated spot radius is `z * tan(asin(NA)) + r_core`.
"""
function irradiance_radial(fiber::FiberParams, ::StepIndexMultimode, z::Float64, r::AbstractVector{Float64})
    theta_max = asin(fiber.na)
    spot_radius = z * tan(theta_max) + fiber.core_radius
    area = pi * spot_radius^2
    I_uniform = fiber.power / area
    return [ri <= spot_radius ? I_uniform : 0.0 for ri in r]
end

function irradiance_2d(fiber::FiberParams, si::StepIndexMultimode, z::Float64,
                       x::AbstractVector{Float64}, y::AbstractVector{Float64})
    theta_max = asin(fiber.na)
    spot_radius = z * tan(theta_max) + fiber.core_radius
    area = pi * spot_radius^2
    I_uniform = fiber.power / area
    return [sqrt(xi^2 + yj^2) <= spot_radius ? I_uniform : 0.0 for yj in y, xi in x]
end

# ─── Multimode graded-index (Gaussian-like) ───

"""
    irradiance_radial(fiber, ::GradedIndexMultimode, z, r)

Graded-index multimode far-field approximated as a Gaussian whose
1/e^2 radius is derived from the NA divergence angle:
`w(z) = z * tan(asin(NA)) + r_core`.
"""
function irradiance_radial(fiber::FiberParams, ::GradedIndexMultimode, z::Float64, r::AbstractVector{Float64})
    theta_max = asin(fiber.na)
    wz = z * tan(theta_max) + fiber.core_radius
    I0 = 2.0 * fiber.power / (pi * wz^2)
    return I0 .* exp.(-2.0 .* r.^2 ./ wz^2)
end

function irradiance_2d(fiber::FiberParams, ::GradedIndexMultimode, z::Float64,
                       x::AbstractVector{Float64}, y::AbstractVector{Float64})
    theta_max = asin(fiber.na)
    wz = z * tan(theta_max) + fiber.core_radius
    I0 = 2.0 * fiber.power / (pi * wz^2)
    return [I0 * exp(-2.0 * (xi^2 + yj^2) / wz^2) for yj in y, xi in x]
end

end # module
