using Test
using QRNReplication

@testset "QRNReplication clean-room minimal suite" begin
    include("unit/core_types_tests.jl")
    include("unit/operation_algebra_tests.jl")
    include("unit/identifiability_tests.jl")
    include("analytic/anomaly_tests.jl")
    include("analytic/bw_normalization_tests.jl")
    include("analytic/local_response_tests.jl")
    include("analytic/manybody_response_tests.jl")
    include("analytic/support_decomposition_tests.jl")
    include("analytic/homology_tests.jl")
    include("adversarial/prime_flux_tests.jl")
    include("adversarial/geometry_topology_tests.jl")
    include("adversarial/generated_case_tests.jl")
    include("adversarial/response_regime_tests.jl")
    include("adversarial/hypergraph_regime_tests.jl")
    include("adversarial/identifiability_regime_tests.jl")
end
