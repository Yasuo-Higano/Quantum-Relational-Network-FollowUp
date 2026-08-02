using Test
using LinearAlgebra
using QRNReplication.CoreTypes
using QRNReplication.DecisionRules
using QRNReplication.FermionFock
using QRNReplication.LocalResponse
using QRNReplication.ManyBodyResponse
using QRNReplication.OperationAlgebra

@testset "saturation and Gaussian covariance insufficiency" begin
    hopping = ComplexF64[0 1; 1 0]
    source = ComplexF64[1 0; 0 0]
    target = ComplexF64[0 0; 0 1]
    projector_state = copy(source)
    @test_throws ArgumentError projector_curvature_response(
        hopping,
        projector_state,
        source,
        target,
        0.01,
    )

    correlated = Diagonal(ComplexF64[0.5, 0.0, 0.0, 0.5]) |> Matrix
    anticorrelated = Diagonal(ComplexF64[0.0, 0.5, 0.5, 0.0]) |> Matrix
    first_number = fock_number_operator(1, 2)
    second_number = fock_number_operator(2, 2)
    @test tr(correlated * first_number) == tr(anticorrelated * first_number) == 0.5
    @test tr(correlated * second_number) == tr(anticorrelated * second_number) == 0.5
    @test tr(correlated * first_number * second_number) == 0.5
    @test tr(anticorrelated * first_number * second_number) == 0.0
    @test decision_status(
        in_domain = false,
        observation_complete = true,
        equivalence_size = 1,
        numerically_resolved = true,
    ) == OutOfDomain
end

@testset "second-order responses identify equivalence classes only" begin
    hamiltonian = ComplexF64[
        0.1 0.7 + 0.2im 0
        0.7 - 0.2im -0.3 0.4
        0 0.4 0.2
    ]
    covariance = Diagonal(ComplexF64[0.3, 0.5, 0.7]) |> Matrix
    observable = Diagonal(ComplexF64[0, 1, 0]) |> Matrix
    @test population_curvature(hamiltonian, covariance, observable) ≈
          population_curvature(-hamiltonian, covariance, observable) atol = 2e-15
    @test decision_status(
        in_domain = true,
        observation_complete = true,
        equivalence_size = 2,
        numerically_resolved = true,
    ) == EquivalenceClassOnly
end

@testset "primitive global algebra does not choose a tensor product" begin
    shift = ComplexF64[
        0 1 0 0
        0 0 1 0
        0 0 0 1
        1 0 0 0
    ]
    clock = Diagonal(cis.(2pi .* (0:3) ./ 4)) |> Matrix
    diagnostic = factorization_diagnostic([shift, clock])
    @test diagnostic.algebra_dimension == 16
    @test diagnostic.commutant_dimension == 1
    @test diagnostic.center_dimension == 1
    @test diagnostic.status == EquivalenceClassOnly
end

@testset "uncertainty boundary forces abstention" begin
    @test decision_status(
        in_domain = true,
        observation_complete = true,
        equivalence_size = 1,
        numerically_resolved = false,
    ) == Abstain
end
