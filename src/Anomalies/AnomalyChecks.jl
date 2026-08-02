module AnomalyChecks

export GaugeMultiplet,
       AnomalyVector,
       anomaly_vector,
       is_anomaly_free,
       standard_model_generation

"""
A left-handed Weyl multiplet in primitive integer anomaly normalization.
`witten_parity` is the color-weighted contribution modulo two per copy.
"""
struct GaugeMultiplet{T<:Integer}
    color_dimension::Int
    weak_dimension::Int
    hypercharge::T
    color_quadratic_index::Int
    weak_quadratic_index::Int
    color_cubic_index::Int
    witten_parity::Int
    multiplicity::Int
    function GaugeMultiplet(
        color_dimension::Int,
        weak_dimension::Int,
        hypercharge::T,
        color_quadratic_index::Int,
        weak_quadratic_index::Int,
        color_cubic_index::Int,
        witten_parity::Int,
        multiplicity::Int = 1,
    ) where {T<:Integer}
        color_dimension > 0 || throw(ArgumentError("color dimension must be positive"))
        weak_dimension > 0 || throw(ArgumentError("weak dimension must be positive"))
        color_quadratic_index >= 0 || throw(ArgumentError("quadratic index must be nonnegative"))
        weak_quadratic_index >= 0 || throw(ArgumentError("quadratic index must be nonnegative"))
        witten_parity in (0, 1) || throw(ArgumentError("Witten parity must be zero or one"))
        multiplicity > 0 || throw(ArgumentError("multiplicity must be positive"))
        new{T}(
            color_dimension,
            weak_dimension,
            hypercharge,
            color_quadratic_index,
            weak_quadratic_index,
            color_cubic_index,
            witten_parity,
            multiplicity,
        )
    end
end

"""The five perturbative anomaly sums and the Witten parity."""
struct AnomalyVector{T<:Integer}
    color_color_hypercharge::T
    weak_weak_hypercharge::T
    gravitational_hypercharge::T
    cubic_hypercharge::T
    cubic_color::Int
    witten_parity::Int
end

"""Sum exact anomaly contributions for a finite spectrum."""
function anomaly_vector(spectrum::AbstractVector{<:GaugeMultiplet})
    isempty(spectrum) && throw(ArgumentError("spectrum must not be empty"))
    charge_type = promote_type(map(multiplet -> typeof(multiplet.hypercharge), spectrum)...)
    a33y = zero(charge_type)
    a22y = zero(charge_type)
    agravy = zero(charge_type)
    ayyy = zero(charge_type)
    a333 = 0
    witten = 0
    for multiplet in spectrum
        factor = multiplet.multiplicity
        charge = convert(charge_type, multiplet.hypercharge)
        a33y += factor * multiplet.weak_dimension * multiplet.color_quadratic_index * charge
        a22y += factor * multiplet.color_dimension * multiplet.weak_quadratic_index * charge
        agravy += factor * multiplet.color_dimension * multiplet.weak_dimension * charge
        ayyy += factor * multiplet.color_dimension * multiplet.weak_dimension * charge^3
        a333 += factor * multiplet.weak_dimension * multiplet.color_cubic_index
        witten = mod(witten + factor * multiplet.witten_parity, 2)
    end
    return AnomalyVector(a33y, a22y, agravy, ayyy, a333, witten)
end

"""True exactly when all perturbative sums vanish and Witten parity is even."""
function is_anomaly_free(anomalies::AnomalyVector)
    return iszero(anomalies.color_color_hypercharge) &&
           iszero(anomalies.weak_weak_hypercharge) &&
           iszero(anomalies.gravitational_hypercharge) &&
           iszero(anomalies.cubic_hypercharge) &&
           iszero(anomalies.cubic_color) &&
           iszero(anomalies.witten_parity)
end

"""The five multiplets stated in the supplied bounded-anomaly paper."""
function standard_model_generation()
    return GaugeMultiplet[
        GaugeMultiplet(1, 1, -6, 0, 0, 0, 0),
        GaugeMultiplet(1, 2, 3, 0, 1, 0, 1),
        GaugeMultiplet(3, 1, -2, 1, 0, 1, 0),
        GaugeMultiplet(3, 1, 4, 1, 0, 1, 0),
        GaugeMultiplet(3, 2, -1, 1, 1, -1, 1),
    ]
end

end
