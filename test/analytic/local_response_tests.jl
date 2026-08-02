using Test
using LinearAlgebra
using QRNReplication.LocalResponse

@testset "signed local curvature identity" begin
    hamiltonian = ComplexF64[
        0.2       0.1im      1.0 + 0.3im
       -0.1im    -0.4       -0.7 + 0.2im
        1.0 - 0.3im -0.7 - 0.2im 0.6
    ]
    source = Diagonal(ComplexF64[1, 1, 0]) |> Matrix
    target = Diagonal(ComplexF64[0, 0, 1]) |> Matrix
    baseline = 0.5 .* Matrix{ComplexF64}(I, 3, 3)
    epsilon = 0.1

    exact_weight = coupling_weight(hamiltonian, source, target).value
    raw_response = projector_curvature_response(
        hamiltonian,
        baseline,
        source,
        target,
        epsilon,
    )
    normalized_response = projector_curvature_response(
        hamiltonian,
        baseline,
        source,
        target,
        epsilon;
        normalization = :per_internal_state,
    )

    @test raw_response ≈ exact_weight atol = 2e-14 rtol = 2e-14
    @test normalized_response ≈ exact_weight / 2 atol = 2e-14 rtol = 2e-14
    @test coupling_weight(-hamiltonian, source, target).value ≈ exact_weight

    gamma_plus = baseline + epsilon .* source
    analytic_curvature = population_curvature(hamiltonian, gamma_plus, target)
    steps = [0.08, 0.04, 0.02]
    errors = [abs(finite_difference_curvature(hamiltonian, gamma_plus, target, step) -
                  analytic_curvature) for step in steps]
    @test errors[2] < errors[1]
    @test errors[3] < errors[2]
    @test errors[1] / errors[2] ≈ 4 rtol = 0.08
    @test errors[2] / errors[3] ≈ 4 rtol = 0.08

    for time in (-0.31, 0.0, 0.27)
        @test dense_population(hamiltonian, gamma_plus, target, time) ≈
              spectral_population(hamiltonian, gamma_plus, target, time) atol = 3e-15
    end
end

@testset "BigFloat response oracle" begin
    setprecision(256) do
        hamiltonian = BigFloat[0 3 // 7; 3 // 7 1 // 5]
        source = BigFloat[1 0; 0 0]
        target = BigFloat[0 0; 0 1]
        baseline = BigFloat[1 // 2 0; 0 1 // 2]
        epsilon = BigFloat(1) / 10
        response = projector_curvature_response(
            hamiltonian,
            baseline,
            source,
            target,
            epsilon;
            check_physical = false,
        )
        exact = BigFloat(9) / 49
        @test abs(response - exact) <= eps(BigFloat) * 16
        @test abs(coupling_weight(hamiltonian, source, target).value - exact) <=
              eps(BigFloat) * 16
    end
end

@testset "Hamiltonian quench is not the projector-weight contract" begin
    hamiltonian = ComplexF64[0 1; 1 0]
    source = ComplexF64[1 0; 0 0]
    target = ComplexF64[0 0; 0 1]
    covariance = copy(source)
    epsilon = 0.2
    plus_curvature = population_curvature(hamiltonian + epsilon .* source, covariance, target)
    minus_curvature = population_curvature(hamiltonian - epsilon .* source, covariance, target)
    quench_response = (plus_curvature - minus_curvature) / (4 * epsilon)
    @test quench_response == 0.0
    @test coupling_weight(hamiltonian, source, target).value == 1.0
end

@testset "input guards" begin
    nonhermitian = ComplexF64[0 1; 0 0]
    projector = ComplexF64[1 0; 0 0]
    @test_throws ArgumentError double_commutator(nonhermitian, projector)
    @test_throws ArgumentError coupling_weight(Matrix{ComplexF64}(I, 2, 2), projector, projector)
end
