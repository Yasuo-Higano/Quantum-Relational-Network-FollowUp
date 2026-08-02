using Test
using LinearAlgebra
using QRNReplication.OperationAlgebra
using QRNReplication.CoreTypes: EquivalenceClassOnly, InsufficientObservation

@testset "operation algebra closure, commutant, and center" begin
    identity3 = Matrix{ComplexF64}(I, 3, 3)
    x = ComplexF64[0 1; 1 0]
    z = ComplexF64[1 0; 0 -1]

    local_generators = [kron(x, identity3), kron(z, identity3)]
    @test length(algebra_closure_basis(local_generators)) == 4
    @test length(commutant_basis(local_generators)) == 9
    @test length(center_basis(local_generators)) == 1
    diagnostic = factorization_diagnostic(local_generators)
    @test diagnostic.hilbert_dimension == 6
    @test diagnostic.status == EquivalenceClassOnly

    incomplete_generators = [kron(z, identity3)]
    @test length(algebra_closure_basis(incomplete_generators)) == 2
    @test length(commutant_basis(incomplete_generators)) == 18
    @test length(center_basis(incomplete_generators)) == 2
    @test factorization_diagnostic(incomplete_generators).status == InsufficientObservation
end

@testset "three-qubit covariance and superselection center" begin
    identity2 = Matrix{ComplexF64}(I, 2, 2)
    x = ComplexF64[0 1; 1 0]
    z = ComplexF64[1 0; 0 -1]
    three_qubit_local = [kron(x, identity2, identity2), kron(z, identity2, identity2)]
    diagnostic = factorization_diagnostic(three_qubit_local)
    @test diagnostic.algebra_dimension == 4
    @test diagnostic.commutant_dimension == 16
    @test diagnostic.center_dimension == 1

    zero2 = zeros(ComplexF64, 2, 2)
    first_block_x = [x zero2; zero2 zero2]
    first_block_z = [z zero2; zero2 zero2]
    second_block_x = [zero2 zero2; zero2 x]
    second_block_z = [zero2 zero2; zero2 z]
    sector_generators = [first_block_x, first_block_z, second_block_x, second_block_z]
    sector_diagnostic = factorization_diagnostic(sector_generators)
    @test sector_diagnostic.algebra_dimension == 8
    @test sector_diagnostic.commutant_dimension == 2
    @test sector_diagnostic.center_dimension == 2
    @test sector_diagnostic.status == InsufficientObservation

    swap_first_two = zeros(ComplexF64, 8, 8)
    for first in 0:1, second in 0:1, third in 0:1
        old_index = 1 + 4first + 2second + third
        new_index = 1 + 4second + 2first + third
        swap_first_two[new_index, old_index] = 1
    end
    permuted = [swap_first_two * generator * swap_first_two' for generator in three_qubit_local]
    permuted_diagnostic = factorization_diagnostic(permuted)
    @test permuted_diagnostic.algebra_dimension == diagnostic.algebra_dimension
    @test permuted_diagnostic.commutant_dimension == diagnostic.commutant_dimension
    @test permuted_diagnostic.center_dimension == diagnostic.center_dimension
end

@testset "ordinary and graded commutators differ for odd disjoint modes" begin
    raising = ComplexF64[0 1; 0 0]
    parity = ComplexF64[1 0; 0 -1]
    left_odd = kron(raising, Matrix{ComplexF64}(I, 2, 2))
    right_odd = kron(parity, raising)
    @test !iszero(norm(ordinary_commutator(left_odd, right_odd)))
    @test iszero(norm(graded_commutator(left_odd, right_odd, 1, 1)))
end
