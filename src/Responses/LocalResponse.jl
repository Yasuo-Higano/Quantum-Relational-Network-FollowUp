module LocalResponse

using LinearAlgebra
using ..CoreTypes: InteractionWeight, ObservationContract

export double_commutator,
       population_curvature,
       coupling_weight,
       signed_curvature_response,
       projector_curvature_response,
       dense_population,
       spectral_population,
       finite_difference_curvature

function _check_square(name::AbstractString, matrix::AbstractMatrix)
    size(matrix, 1) == size(matrix, 2) ||
        throw(DimensionMismatch("$name must be square"))
    all(isfinite, matrix) || throw(ArgumentError("$name contains a non-finite value"))
    return nothing
end

"""Compute the same block population using an explicit Hermitian eigendecomposition."""
function spectral_population(
    hamiltonian::AbstractMatrix,
    covariance::AbstractMatrix,
    projector::AbstractMatrix,
    time::Real,
)
    _check_hermitian("hamiltonian", hamiltonian)
    _check_hermitian("covariance", covariance)
    _check_projector("projector", projector)
    size(hamiltonian) == size(covariance) == size(projector) ||
        throw(DimensionMismatch("hamiltonian, covariance, and projector dimensions differ"))
    decomposition = eigen(Hermitian(hamiltonian))
    phases = exp.(-im * time .* decomposition.values)
    propagator = decomposition.vectors * Diagonal(phases) * decomposition.vectors'
    evolved = propagator * covariance * propagator'
    return real(tr(projector * evolved))
end

function _default_atol(matrix::AbstractMatrix)
    scalar = float(real(zero(eltype(matrix))))
    unit_roundoff = eps(typeof(scalar))
    return 64 * unit_roundoff * max(one(unit_roundoff), opnorm(matrix, Inf))
end

function _check_hermitian(name::AbstractString, matrix::AbstractMatrix; atol = nothing)
    _check_square(name, matrix)
    tolerance = isnothing(atol) ? _default_atol(matrix) : atol
    opnorm(matrix - matrix', Inf) <= tolerance ||
        throw(ArgumentError("$name must be Hermitian within the declared budget"))
    return nothing
end

function _check_projector(name::AbstractString, projector::AbstractMatrix; atol = nothing)
    _check_hermitian(name, projector; atol = atol)
    tolerance = isnothing(atol) ? _default_atol(projector) : atol
    opnorm(projector * projector - projector, Inf) <= tolerance ||
        throw(ArgumentError("$name must be idempotent within the declared budget"))
    return nothing
end

"""Return `[H,[H,A]]` after dimension and Hermiticity validation of `H`."""
function double_commutator(hamiltonian::AbstractMatrix, observable::AbstractMatrix)
    _check_hermitian("hamiltonian", hamiltonian)
    _check_square("observable", observable)
    size(hamiltonian) == size(observable) ||
        throw(DimensionMismatch("hamiltonian and observable dimensions differ"))
    first_commutator = hamiltonian * observable - observable * hamiltonian
    return hamiltonian * first_commutator - first_commutator * hamiltonian
end

"""Compute `-Tr(Gamma[H,[H,N]])`, the exact initial population curvature."""
function population_curvature(
    hamiltonian::AbstractMatrix,
    covariance::AbstractMatrix,
    observable::AbstractMatrix,
)
    _check_hermitian("covariance", covariance)
    _check_hermitian("observable", observable)
    size(hamiltonian) == size(covariance) == size(observable) ||
        throw(DimensionMismatch("hamiltonian, covariance, and observable dimensions differ"))
    return -real(tr(covariance * double_commutator(hamiltonian, observable)))
end

"""Compute the nonnegative block coupling `||P_j H P_i||_F^2`."""
function coupling_weight(
    hamiltonian::AbstractMatrix,
    source_projector::AbstractMatrix,
    target_projector::AbstractMatrix,
)
    _check_hermitian("hamiltonian", hamiltonian)
    _check_projector("source_projector", source_projector)
    _check_projector("target_projector", target_projector)
    size(hamiltonian) == size(source_projector) == size(target_projector) ||
        throw(DimensionMismatch("hamiltonian and projectors have different dimensions"))
    tolerance = max(_default_atol(source_projector), _default_atol(target_projector))
    opnorm(source_projector * target_projector, Inf) <= tolerance ||
        throw(ArgumentError("source and target projectors must be orthogonal"))
    block = target_projector * hamiltonian * source_projector
    return InteractionWeight(real(sum(abs2, block)))
end

function _check_covariance(covariance::AbstractMatrix)
    _check_hermitian("covariance", covariance)
    values = eigvals(Hermitian(covariance))
    tolerance = _default_atol(covariance)
    minimum(values) >= -tolerance ||
        throw(ArgumentError("covariance is not positive semidefinite"))
    maximum(values) <= one(eltype(values)) + tolerance ||
        throw(ArgumentError("fermionic covariance has an eigenvalue above one"))
    return nothing
end

"""
    signed_curvature_response(H, Gamma0, Delta, Pj, epsilon; check_physical=true)

Compute the signed initial-state response for
`Gamma_plus/minus = Gamma0 plus/minus epsilon*Delta`.
"""
function signed_curvature_response(
    hamiltonian::AbstractMatrix,
    baseline_covariance::AbstractMatrix,
    signed_probe::AbstractMatrix,
    target_projector::AbstractMatrix,
    epsilon::Real;
    check_physical::Bool = true,
)
    epsilon > zero(epsilon) || throw(ArgumentError("epsilon must be positive"))
    _check_hermitian("signed_probe", signed_probe)
    gamma_plus = baseline_covariance + epsilon * signed_probe
    gamma_minus = baseline_covariance - epsilon * signed_probe
    if check_physical
        _check_covariance(gamma_plus)
        _check_covariance(gamma_minus)
    end
    curvature_plus = population_curvature(hamiltonian, gamma_plus, target_projector)
    curvature_minus = population_curvature(hamiltonian, gamma_minus, target_projector)
    return (curvature_plus - curvature_minus) / (4 * epsilon)
end

"""
    projector_curvature_response(H, Gamma0, Pi, Pj, epsilon; normalization=:raw_projector)

Evaluate the response contract derived in `docs/derivations.md`. With a raw
projector probe it equals `||P_j H P_i||_F^2`; per-internal-state normalization
divides that value by `rank(P_i)`.
"""
function projector_curvature_response(
    hamiltonian::AbstractMatrix,
    baseline_covariance::AbstractMatrix,
    source_projector::AbstractMatrix,
    target_projector::AbstractMatrix,
    epsilon::Real;
    normalization::Symbol = :raw_projector,
    check_physical::Bool = true,
)
    _check_projector("source_projector", source_projector)
    contract = ObservationContract(
        :initial_covariance,
        :block_population,
        normalization,
    )
    probe = if contract.normalization == :raw_projector
        source_projector
    elseif contract.normalization == :per_internal_state
        projector_rank = round(Int, real(tr(source_projector)))
        projector_rank > 0 || throw(ArgumentError("source projector has zero rank"))
        source_projector / projector_rank
    else
        throw(ArgumentError("trace-preserving response requires an explicit reference block"))
    end
    return signed_curvature_response(
        hamiltonian,
        baseline_covariance,
        probe,
        target_projector,
        epsilon;
        check_physical = check_physical,
    )
end

"""Compute a block population by dense matrix-exponential evolution."""
function dense_population(
    hamiltonian::AbstractMatrix,
    covariance::AbstractMatrix,
    projector::AbstractMatrix,
    time::Real,
)
    _check_hermitian("hamiltonian", hamiltonian)
    _check_hermitian("covariance", covariance)
    _check_projector("projector", projector)
    size(hamiltonian) == size(covariance) == size(projector) ||
        throw(DimensionMismatch("hamiltonian, covariance, and projector dimensions differ"))
    propagator = exp(-im * time * hamiltonian)
    evolved = propagator * covariance * propagator'
    return real(tr(projector * evolved))
end

"""Three-point central estimate of the initial curvature."""
function finite_difference_curvature(
    hamiltonian::AbstractMatrix,
    covariance::AbstractMatrix,
    projector::AbstractMatrix,
    time_step::Real,
)
    time_step > zero(time_step) || throw(ArgumentError("time_step must be positive"))
    plus = dense_population(hamiltonian, covariance, projector, time_step)
    zero_time = dense_population(hamiltonian, covariance, projector, zero(time_step))
    minus = dense_population(hamiltonian, covariance, projector, -time_step)
    return (plus - 2 * zero_time + minus) / time_step^2
end

end
