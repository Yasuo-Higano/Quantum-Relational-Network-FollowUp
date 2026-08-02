module CoreTypes

export DecayRate,
       LengthScale,
       InteractionWeight,
       ObservationContract,
       ResultStatus,
       Answer,
       EquivalenceClassOnly,
       InsufficientObservation,
       Abstain,
       OutOfDomain,
       AbstentionReason,
       NumericalUncertainty,
       MissingObservation,
       MultipleEquivalentModels,
       ContractViolation,
       FactorizationResult,
       IdentifiabilityResult,
       NumericalBudget,
       TopologyCertificate

"""A nonnegative decay rate with explicit scientific meaning."""
struct DecayRate{T<:Real}
    value::T
    function DecayRate(value::T) where {T<:Real}
        isfinite(value) || throw(ArgumentError("decay rate must be finite"))
        value >= zero(T) || throw(ArgumentError("decay rate must be nonnegative"))
        new{T}(value)
    end
end

"""A strictly positive finite length scale."""
struct LengthScale{T<:Real}
    value::T
    function LengthScale(value::T) where {T<:Real}
        isfinite(value) || throw(ArgumentError("length scale must be finite"))
        value > zero(T) || throw(ArgumentError("length scale must be positive"))
        new{T}(value)
    end
end

"""A nonnegative Hilbert--Schmidt interaction weight."""
struct InteractionWeight{T<:Real}
    value::T
    function InteractionWeight(value::T) where {T<:Real}
        isfinite(value) || throw(ArgumentError("interaction weight must be finite"))
        value >= zero(T) || throw(ArgumentError("interaction weight must be nonnegative"))
        new{T}(value)
    end
end

@enum ResultStatus::UInt8 begin
    Answer = 0
    EquivalenceClassOnly = 1
    InsufficientObservation = 2
    Abstain = 3
    OutOfDomain = 4
end

@enum AbstentionReason::UInt8 begin
    NumericalUncertainty = 0
    MissingObservation = 1
    MultipleEquivalentModels = 2
    ContractViolation = 3
end

"""A factorization diagnostic reported only up to its declared equivalence."""
struct FactorizationResult
    hilbert_dimension::Int
    algebra_dimension::Int
    commutant_dimension::Int
    center_dimension::Int
    status::ResultStatus
    function FactorizationResult(
        hilbert_dimension::Int,
        algebra_dimension::Int,
        commutant_dimension::Int,
        center_dimension::Int,
        status::ResultStatus,
    )
        hilbert_dimension > 0 || throw(ArgumentError("Hilbert dimension must be positive"))
        algebra_dimension > 0 || throw(ArgumentError("algebra dimension must be positive"))
        commutant_dimension > 0 || throw(ArgumentError("commutant dimension must be positive"))
        center_dimension > 0 || throw(ArgumentError("center dimension must be positive"))
        new(
            hilbert_dimension,
            algebra_dimension,
            commutant_dimension,
            center_dimension,
            status,
        )
    end
end

"""A typed inference outcome with optional answer, reason, and witness strings."""
struct IdentifiabilityResult{T}
    status::ResultStatus
    answer::Union{Nothing,T}
    reason::Union{Nothing,AbstentionReason}
    witnesses::Vector{String}
    function IdentifiabilityResult{T}(
        status::ResultStatus,
        answer::Union{Nothing,T},
        reason::Union{Nothing,AbstentionReason},
        witnesses::Vector{String} = String[],
    ) where {T}
        if status == Answer
            isnothing(answer) && throw(ArgumentError("Answer status requires an answer value"))
            isnothing(reason) || throw(ArgumentError("Answer status cannot carry an abstention reason"))
        elseif status == EquivalenceClassOnly
            isnothing(answer) &&
                throw(ArgumentError("EquivalenceClassOnly requires a class representative"))
            reason == MultipleEquivalentModels ||
                throw(ArgumentError("EquivalenceClassOnly requires the multiple-model reason"))
        elseif status in (InsufficientObservation, Abstain, OutOfDomain)
            isnothing(answer) || throw(ArgumentError("non-answer status cannot carry an answer value"))
            isnothing(reason) && throw(ArgumentError("non-answer status requires a reason"))
        end
        new{T}(status, answer, reason, copy(witnesses))
    end
end

IdentifiabilityResult(
    status::ResultStatus,
    answer::T,
    reason::Union{Nothing,AbstentionReason},
    witnesses::Vector{String} = String[],
) where {T} = IdentifiabilityResult{T}(status, answer, reason, witnesses)

IdentifiabilityResult(
    status::ResultStatus,
    ::Nothing,
    reason::Union{Nothing,AbstentionReason},
    witnesses::Vector{String} = String[],
) = IdentifiabilityResult{Nothing}(status, nothing, reason, witnesses)

"""
    ObservationContract

Declares what was perturbed and observed. These fields prevent state probes,
Hamiltonian quenches, and normalization conventions from sharing an unlabelled
numeric result.
"""
struct ObservationContract
    perturbation::Symbol
    observable::Symbol
    normalization::Symbol
    noise_model::Symbol
    function ObservationContract(
        perturbation::Symbol,
        observable::Symbol,
        normalization::Symbol;
        noise_model::Symbol = :none,
    )
        perturbation in (:initial_covariance, :hamiltonian, :conditional_state) ||
            throw(ArgumentError("unsupported perturbation contract: $perturbation"))
        observable in (:block_population, :many_body_number, :connected_density) ||
            throw(ArgumentError("unsupported observable contract: $observable"))
        normalization in (:raw_projector, :per_internal_state, :trace_preserving) ||
            throw(ArgumentError("unsupported normalization: $normalization"))
        noise_model in (:none, :gaussian, :shot, :heteroscedastic) ||
            throw(ArgumentError("unsupported noise model: $noise_model"))
        new(perturbation, observable, normalization, noise_model)
    end
end

"""Separated analytic, discretization, conditioning, roundoff, and statistical errors."""
struct NumericalBudget{T<:Real}
    analytic_truncation::T
    discretization::T
    conditioning::T
    roundoff::T
    statistical::T
    function NumericalBudget(
        analytic_truncation::T,
        discretization::T,
        conditioning::T,
        roundoff::T,
        statistical::T,
    ) where {T<:Real}
        values = (analytic_truncation, discretization, conditioning, roundoff, statistical)
        all(isfinite, values) || throw(ArgumentError("all numerical budgets must be finite"))
        all(x -> x >= zero(T), values) ||
            throw(ArgumentError("all numerical budgets must be nonnegative"))
        new{T}(values...)
    end
end

Base.sum(budget::NumericalBudget) =
    budget.analytic_truncation + budget.discretization + budget.conditioning +
    budget.roundoff + budget.statistical

"""Exact homology result plus the chain-complex qualification used to obtain it."""
struct TopologyCertificate
    betti::NTuple{4,Int}
    boundary_ranks::Vector{Int}
    coefficient_field::Symbol
    chain_condition::Bool
    function TopologyCertificate(
        betti::NTuple{4,Int},
        boundary_ranks::Vector{Int},
        coefficient_field::Symbol,
        chain_condition::Bool,
    )
        all(x -> x >= 0, betti) || throw(ArgumentError("Betti numbers must be nonnegative"))
        all(x -> x >= 0, boundary_ranks) ||
            throw(ArgumentError("boundary ranks must be nonnegative"))
        coefficient_field in (:F2, :Q) ||
            throw(ArgumentError("unsupported coefficient field: $coefficient_field"))
        new(betti, boundary_ranks, coefficient_field, chain_condition)
    end
end

end
