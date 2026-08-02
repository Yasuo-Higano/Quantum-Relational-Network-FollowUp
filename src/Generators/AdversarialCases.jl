module AdversarialCases

using LinearAlgebra
using Random
using SHA
using ..CoreTypes
using ..DecisionRules: decision_status
using ..LocalResponse: projector_curvature_response
using ..OperationAlgebra: factorization_diagnostic
using ..SupportDecomposition: support_decomposition_mobius, support_weights
using ..SimplicialHomology

export TruthClass,
       UniqueAnswerable,
       EquivalenceOnly,
       ObservationInsufficient,
       OutOfDomainTruth,
       NumericallyUnresolved,
       AdversarialCase,
       CaseEvaluation,
       benchmark_families,
       benchmark_scenarios,
       public_seed,
       secret_seed,
       generate_cases,
       expected_status,
       evaluate_case,
       maximum_error

@enum TruthClass::UInt8 begin
    UniqueAnswerable = 0
    EquivalenceOnly = 1
    ObservationInsufficient = 2
    OutOfDomainTruth = 3
    NumericallyUnresolved = 4
end

const benchmark_families = (
    :response,
    :factorization,
    :hypergraph,
    :topology,
    :identifiability,
)

const benchmark_scenarios = (
    :positive,
    :null,
    :weak_signal,
    :basis_changed,
    :boundary_variant,
    :inhomogeneous,
    :equivalent_models,
    :missing_observation,
    :out_of_domain,
    :high_noise,
)

"""One generated benchmark cell; seed provenance is explicit and immutable."""
struct AdversarialCase
    cell_id::String
    split::Symbol
    family::Symbol
    scenario::Symbol
    seed::UInt64
    truth_class::TruthClass
    tolerance::Float64
    function AdversarialCase(
        cell_id::String,
        split::Symbol,
        family::Symbol,
        scenario::Symbol,
        seed::UInt64,
        truth_class::TruthClass,
        tolerance::Real,
    )
        split in (:train, :validation, :holdout) || throw(ArgumentError("invalid split"))
        family in benchmark_families || throw(ArgumentError("invalid family"))
        scenario in benchmark_scenarios || throw(ArgumentError("invalid scenario"))
        tolerance >= 0 && isfinite(tolerance) || throw(ArgumentError("invalid tolerance"))
        new(cell_id, split, family, scenario, seed, truth_class, Float64(tolerance))
    end
end

"""Algorithm output and independent target for one benchmark cell."""
struct CaseEvaluation
    cell_id::String
    family::Symbol
    scenario::Symbol
    truth_class::TruthClass
    status::ResultStatus
    answer::Vector{Float64}
    target::Vector{Float64}
    tolerance::Float64
    witnesses::Vector{String}
end

function _seed_from_parts(parts::AbstractString...)
    digest = sha256(join(parts, "\0"))
    seed = zero(UInt64)
    for byte in digest[1:8]
        seed = (seed << 8) | UInt64(byte)
    end
    return seed
end

"""Versioned public seed for train or validation generation."""
public_seed(split::Symbol, schema::AbstractString, family::Symbol, cell_id::AbstractString) =
    _seed_from_parts("QRNReplication", String(split), schema, String(family), cell_id)

"""Secret-derived seed; callers must enforce the post-freeze holdout gate."""
function secret_seed(
    secret::AbstractString,
    experiment_id::AbstractString,
    cell_id::AbstractString,
)
    isempty(secret) && throw(ArgumentError("secret must not be empty"))
    return _seed_from_parts(secret, experiment_id, cell_id)
end

function _truth_class(scenario::Symbol)
    scenario in benchmark_scenarios[1:6] && return UniqueAnswerable
    scenario == :equivalent_models && return EquivalenceOnly
    scenario == :missing_observation && return ObservationInsufficient
    scenario == :out_of_domain && return OutOfDomainTruth
    scenario == :high_noise && return NumericallyUnresolved
    error("unregistered scenario")
end

"""Generate schemas and seeds only; evaluation remains a separate operation."""
function generate_cases(
    split::Symbol,
    count_per_family::Int;
    schema::AbstractString = "phase4-v1",
    experiment_id::AbstractString = "",
    secret::Union{Nothing,AbstractString} = nothing,
)
    split in (:train, :validation, :holdout) || throw(ArgumentError("invalid split"))
    count_per_family > 0 || throw(ArgumentError("count_per_family must be positive"))
    if split == :holdout
        isnothing(secret) && throw(ArgumentError("holdout generation requires a post-freeze secret"))
        isempty(experiment_id) && throw(ArgumentError("holdout generation requires experiment_id"))
    elseif !isnothing(secret)
        throw(ArgumentError("a secret is not used for public train/validation splits"))
    end

    cases = AdversarialCase[]
    for (family_index, family) in enumerate(benchmark_families)
        for index in 1:count_per_family
            scenario_index = mod1(index + family_index - 1, length(benchmark_scenarios))
            scenario = benchmark_scenarios[scenario_index]
            cell_id = "$(String(split))-$(String(family))-$(lpad(index, 3, '0'))"
            seed = split == :holdout ?
                secret_seed(something(secret), experiment_id, cell_id) :
                public_seed(split, schema, family, cell_id)
            tolerance = scenario == :weak_signal ? 2e-12 : 2e-10
            push!(cases, AdversarialCase(
                cell_id,
                split,
                family,
                scenario,
                seed,
                _truth_class(scenario),
                tolerance,
            ))
        end
    end
    return cases
end

function expected_status(case::AdversarialCase)
    case.truth_class == UniqueAnswerable && return Answer
    case.truth_class == EquivalenceOnly && return EquivalenceClassOnly
    case.truth_class == ObservationInsufficient && return InsufficientObservation
    case.truth_class == OutOfDomainTruth && return OutOfDomain
    case.truth_class == NumericallyUnresolved && return Abstain
    error("unregistered truth class")
end

function _decision_for_case(case::AdversarialCase)
    return decision_status(
        in_domain = case.truth_class != OutOfDomainTruth,
        observation_complete = case.truth_class != ObservationInsufficient,
        equivalence_size = case.truth_class == EquivalenceOnly ? 2 : 1,
        numerically_resolved = case.truth_class != NumericallyUnresolved,
    )
end

function _response_answer(case::AdversarialCase, rng::AbstractRNG)
    amplitude = case.scenario == :null ? 0.0 :
        case.scenario == :weak_signal ? 3e-4 : 0.25 + 0.75rand(rng)
    phase = 2pi * rand(rng)
    coupling = amplitude * cis(phase)
    hamiltonian = ComplexF64[
        0.2 coupling 0.1im
        conj(coupling) -0.1 -0.2
        -0.1im -0.2 0.3
    ]
    source = Diagonal(ComplexF64[1, 0, 0]) |> Matrix
    target = Diagonal(ComplexF64[0, 1, 0]) |> Matrix
    baseline = 0.5 .* Matrix{ComplexF64}(I, 3, 3)
    observed = projector_curvature_response(hamiltonian, baseline, source, target, 0.1)
    return [Float64(observed)], [amplitude^2]
end

function _factorization_answer(case::AdversarialCase, rng::AbstractRNG)
    x = ComplexF64[0 1; 1 0]
    z = ComplexF64[1 0; 0 -1]
    if isodd(case.seed)
        spectator = Matrix{ComplexF64}(I, 3, 3)
        generators = [kron(x, spectator), kron(z, spectator)]
        target = [6.0, 4.0, 9.0, 1.0]
    else
        spectator = Matrix{ComplexF64}(I, 4, 4)
        generators = [kron(x, spectator), kron(z, spectator)]
        target = [8.0, 4.0, 16.0, 1.0]
    end
    if case.scenario == :basis_changed
        phases = Diagonal(cis.(2pi .* rand(rng, Int(target[1]))))
        generators = [phases * generator * phases' for generator in generators]
    elseif case.scenario == :null
        push!(generators, zeros(ComplexF64, Int(target[1]), Int(target[1])))
    end
    diagnostic = factorization_diagnostic(generators)
    answer = Float64[
        diagnostic.hilbert_dimension,
        diagnostic.algebra_dimension,
        diagnostic.commutant_dimension,
        diagnostic.center_dimension,
    ]
    return answer, target
end

function _hypergraph_answer(case::AdversarialCase, rng::AbstractRNG)
    identity2 = Matrix{Float64}(I, 2, 2)
    x = [0.0 1.0; 1.0 0.0]
    z = [1.0 0.0; 0.0 -1.0]
    first = case.scenario == :null ? 0.0 : 0.2 + rand(rng)
    second = case.scenario == :weak_signal ? 1e-4 : 0.2 + rand(rng)
    onsite = first * kron(z, identity2, identity2)
    three_body = second * kron(x, z, x)
    operator = onsite + three_body
    components = support_decomposition_mobius(operator, [2, 2, 2])
    weights = support_weights(components)
    answer = [Float64(weights[(1,)].value), Float64(weights[(1, 2, 3)].value)]
    target = [Float64(sum(abs2, onsite)), Float64(sum(abs2, three_body))]
    return answer, target
end

function _path_complex(vertex_count::Int)
    facets = [(vertex, vertex + 1) for vertex in 1:(vertex_count - 1)]
    return complex_from_facets(facets)
end

function _cycle_complex(vertex_count::Int)
    facets = [(vertex, mod1(vertex + 1, vertex_count)) for vertex in 1:vertex_count]
    return complex_from_facets(facets)
end

function _topology_answer(case::AdversarialCase)
    complex, expected = if case.scenario == :null
        (_path_complex(6), (1, 0, 0, 0))
    elseif case.scenario == :weak_signal
        (_cycle_complex(7), (1, 1, 0, 0))
    elseif case.scenario == :basis_changed
        (simplex_boundary_complex(3), (1, 0, 1, 0))
    elseif case.scenario == :boundary_variant
        (triangulated_grid_surface(5, 4; periodic_x = true), (1, 1, 0, 0))
    elseif case.scenario == :inhomogeneous
        (triangulated_grid_surface(4, 4; periodic_x = true, periodic_y = true),
         (1, 2, 1, 0))
    else
        (triangulated_grid_surface(4, 4), (1, 0, 0, 0))
    end
    observed = topology_certificate(complex).betti
    return Float64[observed...], Float64[expected...]
end

function _identifiability_answer(case::AdversarialCase)
    code = Float64(findfirst(==(case.scenario), benchmark_scenarios))
    return [code], [code]
end

"""Evaluate one case without consulting its registered target status."""
function evaluate_case(case::AdversarialCase)
    status = _decision_for_case(case)
    if status != Answer
        witnesses = status == EquivalenceClassOnly ? ["H", "-H"] :
            status == InsufficientObservation ? ["missing probe channel"] :
            status == OutOfDomain ? ["oracle assumptions violated"] :
            ["uncertainty interval crosses decision boundary"]
        return CaseEvaluation(
            case.cell_id,
            case.family,
            case.scenario,
            case.truth_class,
            status,
            Float64[],
            Float64[],
            case.tolerance,
            witnesses,
        )
    end

    rng = Xoshiro(case.seed)
    answer, target = if case.family == :response
        _response_answer(case, rng)
    elseif case.family == :factorization
        _factorization_answer(case, rng)
    elseif case.family == :hypergraph
        _hypergraph_answer(case, rng)
    elseif case.family == :topology
        _topology_answer(case)
    else
        _identifiability_answer(case)
    end
    return CaseEvaluation(
        case.cell_id,
        case.family,
        case.scenario,
        case.truth_class,
        status,
        answer,
        target,
        case.tolerance,
        String[],
    )
end

"""Largest absolute answer error, or zero for a non-answer record."""
function maximum_error(evaluation::CaseEvaluation)
    isempty(evaluation.answer) && isempty(evaluation.target) && return 0.0
    length(evaluation.answer) == length(evaluation.target) || return Inf
    return maximum(abs.(evaluation.answer .- evaluation.target); init = 0.0)
end

end
