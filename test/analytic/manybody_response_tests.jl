using Test
using QRNReplication.FermionFock
using QRNReplication.ManyBodyResponse

@testset "two-site many-body response and interaction boundary" begin
    one_particle = ComplexF64[0 1; 1 0]
    hopping = quadratic_fock_hamiltonian(one_particle)
    target_number = fock_number_operator(2, 2)
    epsilon = 0.1
    density_plus = product_occupation_state([0.5 + epsilon, 0.3])
    density_minus = product_occupation_state([0.5 - epsilon, 0.3])

    free_response = signed_manybody_curvature_response(
        hopping,
        density_plus,
        density_minus,
        target_number,
        epsilon,
    )
    @test free_response ≈ 1.0 atol = 2e-15

    for interaction_strength in (0.4, 1.7)
        interacting = hopping + density_density_term(1, 2, 2, interaction_strength)
        response = signed_manybody_curvature_response(
            interacting,
            density_plus,
            density_minus,
            target_number,
            epsilon,
        )
        @test response ≈ 1.0 atol = 2e-15

        exact_curvature = manybody_curvature(interacting, density_plus, target_number)
        steps = (0.08, 0.04, 0.02)
        errors = [
            abs(finite_difference_manybody_curvature(
                interacting,
                density_plus,
                target_number,
                step,
            ) - exact_curvature)
            for step in steps
        ]
        @test errors[2] < errors[1]
        @test errors[3] < errors[2]
        @test errors[1] / errors[2] ≈ 4 rtol = 0.08
        @test errors[2] / errors[3] ≈ 4 rtol = 0.08
    end

    pairing_strength = 0.7
    nonconserving = hopping + pairing_term(1, 2, 2, pairing_strength)
    pairing_response = signed_manybody_curvature_response(
        nonconserving,
        density_plus,
        density_minus,
        target_number,
        epsilon,
    )
    @test pairing_response ≈ 1 - pairing_strength^2 atol = 2e-15
    @test pairing_response != free_response
end

@testset "fermionic operator algebra guards" begin
    annihilations = [fermion_annihilation(site, 3) for site in 1:3]
    identity_fock = Matrix{ComplexF64}(I, 8, 8)
    for first_site in 1:3, second_site in 1:3
        anticommutator = annihilations[first_site] * annihilations[second_site]' +
                         annihilations[second_site]' * annihilations[first_site]
        expected = first_site == second_site ? identity_fock : zeros(ComplexF64, 8, 8)
        @test anticommutator == expected
    end
end
