using Test
using LinearAlgebra
using QRNReplication.FermionFock
using QRNReplication.SupportDecomposition

@testset "fermionic support orders and null high-body terms" begin
    annihilations = [fermion_annihilation(site, 4) for site in 1:4]
    numbers = [annihilation' * annihilation for annihilation in annihilations]
    onsite = 0.7 .* numbers[1]
    hopping = 0.4 .* (annihilations[1]' * annihilations[2] +
                     annihilations[2]' * annihilations[1])
    density_density = 0.3 .* numbers[1] * numbers[2]
    correlated_hopping = 0.2 .* numbers[1] *
        (annihilations[2]' * annihilations[3] + annihilations[3]' * annihilations[2])
    pair_hopping_seed = annihilations[1]' * annihilations[2]' *
        annihilations[3] * annihilations[4]
    pair_hopping = 0.15 .* (pair_hopping_seed + pair_hopping_seed')
    genuine_three_body = 0.11 .* (2numbers[1] - I) * (2numbers[2] - I) *
        (2numbers[3] - I)
    null_three_body = 0.0 .* genuine_three_body

    components = support_decomposition_mobius(
        onsite + hopping + density_density + correlated_hopping + pair_hopping +
        genuine_three_body + null_three_body,
        [2, 2, 2, 2],
    )
    weights = support_weights(components)
    @test weights[(1,)].value > 0
    @test weights[(1, 2)].value > 0
    @test weights[(1, 2, 3)].value > 0
    @test weights[(1, 2, 3, 4)].value > 0
    @test reconstruct_operator(components) ≈
          onsite + hopping + density_density + correlated_hopping + pair_hopping +
          genuine_three_body atol = 2e-14

    only_null = support_decomposition_mobius(null_three_body, [2, 2, 2, 2])
    @test iszero(support_weights(only_null)[(1, 2, 3)].value)
end

@testset "local versus nonlocal basis transformations" begin
    identity2 = Matrix{ComplexF64}(I, 2, 2)
    z = ComplexF64[1 0; 0 -1]
    local_operator = kron(identity2, z)
    hadamard = ComplexF64[1 1; 1 -1] / sqrt(2)
    local_unitary = kron(hadamard, hadamard)
    local_transformed = local_unitary * local_operator * local_unitary'
    original = support_weights(support_decomposition_mobius(local_operator, [2, 2]))
    local_weights = support_weights(support_decomposition_mobius(local_transformed, [2, 2]))
    @test original[(2,)].value ≈ local_weights[(2,)].value atol = 2e-14

    cnot = ComplexF64[
        1 0 0 0
        0 1 0 0
        0 0 0 1
        0 0 1 0
    ]
    nonlocal_transformed = cnot * local_operator * cnot'
    nonlocal_weights = support_weights(
        support_decomposition_mobius(nonlocal_transformed, [2, 2]),
    )
    @test original[(1, 2)].value == 0
    @test nonlocal_weights[(1, 2)].value > 0
    @test nonlocal_weights[(2,)].value == 0
end

@testset "support weights erase signs and coherent hopping phases" begin
    c1 = fermion_annihilation(1, 2)
    c2 = fermion_annihilation(2, 2)
    function phased_hopping(phase)
        seed = cis(phase) .* c1' * c2
        return seed + seed'
    end
    reference = support_weights(support_decomposition_mobius(phased_hopping(0.3), [2, 2]))
    reversed_flux = support_weights(
        support_decomposition_mobius(phased_hopping(-0.3), [2, 2]),
    )
    sign_reversed = support_weights(
        support_decomposition_mobius(-phased_hopping(0.3), [2, 2]),
    )
    @test reference[(1, 2)].value ≈ reversed_flux[(1, 2)].value atol = 2e-14
    @test reference[(1, 2)].value ≈ sign_reversed[(1, 2)].value atol = 2e-14

    projected_local = conditional_expectation(phased_hopping(0.3), [2, 2], (1,))
    @test iszero(norm(projected_local))
end
