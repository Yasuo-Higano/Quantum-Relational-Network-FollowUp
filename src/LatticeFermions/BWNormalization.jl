module BWNormalization

export arithmetic_geometric_mean,
       bw_prefactor_agm,
       bw_prefactor_simpson,
       bw_moments_midpoint

"""Compute the positive arithmetic--geometric mean with a scale-aware stop."""
function arithmetic_geometric_mean(
    first_value::T,
    second_value::T;
    max_iterations::Int = 10_000,
) where {T<:AbstractFloat}
    isfinite(first_value) && isfinite(second_value) ||
        throw(ArgumentError("AGM inputs must be finite"))
    first_value > zero(T) && second_value > zero(T) ||
        throw(ArgumentError("AGM inputs must be positive"))
    max_iterations > 0 || throw(ArgumentError("max_iterations must be positive"))
    arithmetic = first_value
    geometric = second_value
    for _ in 1:max_iterations
        next_arithmetic = (arithmetic + geometric) / 2
        next_geometric = sqrt(arithmetic * geometric)
        if abs(next_arithmetic - next_geometric) <=
           8 * eps(T) * max(abs(next_arithmetic), abs(next_geometric))
            return (next_arithmetic + next_geometric) / 2
        end
        arithmetic = next_arithmetic
        geometric = next_geometric
    end
    throw(ErrorException("AGM iteration did not converge"))
end

"""Evaluate `g(mu)=1/AGM(1,sqrt(1+mu^2))`."""
function bw_prefactor_agm(mass::T) where {T<:AbstractFloat}
    isfinite(mass) || throw(ArgumentError("mass must be finite"))
    mass >= zero(T) || throw(ArgumentError("mass must be nonnegative"))
    return inv(arithmetic_geometric_mean(one(T), sqrt(one(T) + mass^2)))
end

bw_prefactor_agm(mass::Real) = bw_prefactor_agm(float(mass))

"""
Evaluate the independent integral representation of `g(mu)` by composite
Simpson quadrature. `panels` must be a positive even integer.
"""
function bw_prefactor_simpson(mass::T; panels::Int = 4096) where {T<:AbstractFloat}
    isfinite(mass) || throw(ArgumentError("mass must be finite"))
    mass >= zero(T) || throw(ArgumentError("mass must be nonnegative"))
    panels > 0 && iseven(panels) || throw(ArgumentError("panels must be positive and even"))
    lower = zero(T)
    upper = T(pi) / 2
    step = (upper - lower) / panels
    integrand(angle) = inv(sqrt(one(T) + mass^2 * cos(angle)^2))
    accumulator = integrand(lower) + integrand(upper)
    for index in 1:(panels - 1)
        coefficient = isodd(index) ? 4 : 2
        accumulator += coefficient * integrand(lower + index * step)
    end
    integral = step * accumulator / 3
    return 2 * integral / T(pi)
end

bw_prefactor_simpson(mass::Real; panels::Int = 4096) =
    bw_prefactor_simpson(float(mass); panels = panels)

"""
Compute midpoint Brillouin-zone estimates of `(r_x,r_perp,lambda_x,lambda_perp)`
on the full square BZ. No paper-reported target value enters the quadrature.
"""
function bw_moments_midpoint(grid_size::Int)
    grid_size > 0 || throw(ArgumentError("grid_size must be positive"))
    inverse_count = inv(float(grid_size)^2)
    sum_x = 0.0
    sum_perpendicular = 0.0
    for y_index in 0:(grid_size - 1)
        momentum_y = 2pi * (y_index + 0.5) / grid_size
        cosine_y_squared = cos(momentum_y)^2
        for z_index in 0:(grid_size - 1)
            momentum_z = 2pi * (z_index + 0.5) / grid_size
            mass = sqrt(cosine_y_squared + cos(momentum_z)^2)
            prefactor = bw_prefactor_agm(mass)
            sum_x += prefactor
            sum_perpendicular += 2 * cosine_y_squared * prefactor
        end
    end
    inverse_lambda_x = sum_x * inverse_count
    inverse_lambda_perpendicular = sum_perpendicular * inverse_count
    return (
        inverse_lambda_x = inverse_lambda_x,
        inverse_lambda_perpendicular = inverse_lambda_perpendicular,
        lambda_x = inv(inverse_lambda_x),
        lambda_perpendicular = inv(inverse_lambda_perpendicular),
    )
end

end
