using Test
using LinearAlgebra
using QRNReplication.SupportDecomposition

@testset "orthogonal interaction support decomposition" begin
    identity2 = Rational{Int}.(Matrix(I, 2, 2))
    pauli_x = Rational{Int}[0 1; 1 0]
    pauli_z = Rational{Int}[1 0; 0 -1]

    operator = 2 * kron(identity2, identity2) +
               (3 // 5) * kron(pauli_z, identity2) +
               (7 // 11) * kron(identity2, pauli_x) +
               (13 // 17) * kron(pauli_x, pauli_z)

    mobius = support_decomposition_mobius(operator, [2, 2])
    product_projection = support_decomposition_product(operator, [2, 2])

    @test keys(mobius) == keys(product_projection)
    for support in keys(mobius)
        @test mobius[support] == product_projection[support]
    end
    @test reconstruct_operator(mobius) == operator
    @test mobius[()] == 2 * kron(identity2, identity2)
    @test mobius[(1,)] == (3 // 5) * kron(pauli_z, identity2)
    @test mobius[(2,)] == (7 // 11) * kron(identity2, pauli_x)
    @test mobius[(1, 2)] == (13 // 17) * kron(pauli_x, pauli_z)

    supports = collect(keys(mobius))
    for left in eachindex(supports), right in eachindex(supports)
        left == right && continue
        @test iszero(hilbert_schmidt_inner(mobius[supports[left]], mobius[supports[right]]))
    end

    weights = support_weights(mobius)
    @test weights[()].value == sum(abs2, mobius[()])
    @test all(weight.value >= 0 for weight in values(weights))
end

@testset "genuine three-factor support" begin
    identity2 = Rational{Int}.(Matrix(I, 2, 2))
    x = Rational{Int}[0 1; 1 0]
    z = Rational{Int}[1 0; 0 -1]
    three_body = (5 // 7) * kron(x, z, x)
    two_body = (2 // 3) * kron(identity2, x, z)
    components = support_decomposition_mobius(three_body + two_body, [2, 2, 2])
    @test components[(1, 2, 3)] == three_body
    @test components[(2, 3)] == two_body
    @test reconstruct_operator(components) == three_body + two_body
    @test count(!iszero, (sum(abs2, component) for component in values(components))) == 2
end

@testset "local basis changes preserve support weights" begin
    identity2 = Matrix{Float64}(I, 2, 2)
    x = [0.0 1.0; 1.0 0.0]
    z = [1.0 0.0; 0.0 -1.0]
    operator = 0.4 * kron(z, identity2) + 0.9 * kron(x, z)
    hadamard = [1.0 1.0; 1.0 -1.0] / sqrt(2)
    local_unitary = kron(hadamard, [0.0 1.0; 1.0 0.0])
    transformed = local_unitary * operator * local_unitary'

    original_weights = support_weights(support_decomposition_mobius(operator, [2, 2]))
    transformed_weights = support_weights(support_decomposition_mobius(transformed, [2, 2]))
    for support in keys(original_weights)
        @test original_weights[support].value ≈ transformed_weights[support].value atol = 2e-14
    end
end
