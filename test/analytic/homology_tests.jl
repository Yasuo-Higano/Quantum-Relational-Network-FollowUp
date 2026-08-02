using Test
using LinearAlgebra
using QRNReplication.SimplicialHomology

function cycle_adjacency(vertex_count::Int)
    adjacency = falses(vertex_count, vertex_count)
    for vertex in 1:vertex_count
        next_vertex = mod1(vertex + 1, vertex_count)
        adjacency[vertex, next_vertex] = true
        adjacency[next_vertex, vertex] = true
    end
    return adjacency
end

@testset "simplex balls and sphere boundaries through dimension three" begin
    sphere2 = topology_certificate(simplex_boundary_complex(3))
    sphere3 = topology_certificate(simplex_boundary_complex(4))
    ball3 = topology_certificate(filled_simplex_complex(3))
    @test sphere2.betti == (1, 0, 1, 0)
    @test sphere3.betti == (1, 0, 0, 1)
    @test ball3.betti == (1, 0, 0, 0)
    @test sphere2.chain_condition && sphere3.chain_condition && ball3.chain_condition
end

@testset "known graph clique complexes" begin
    path = falses(5, 5)
    for vertex in 1:4
        path[vertex, vertex + 1] = true
        path[vertex + 1, vertex] = true
    end
    path_certificate = topology_certificate(clique_complex(path; max_dimension = 4))
    @test path_certificate.betti == (1, 0, 0, 0)
    @test path_certificate.chain_condition

    cycle_certificate = topology_certificate(clique_complex(cycle_adjacency(6); max_dimension = 4))
    @test cycle_certificate.betti == (1, 1, 0, 0)
    @test cycle_certificate.chain_condition

    complete = trues(5, 5)
    for vertex in 1:5
        complete[vertex, vertex] = false
    end
    complete_certificate = topology_certificate(clique_complex(complete; max_dimension = 4))
    @test complete_certificate.betti == (1, 0, 0, 0)
    @test complete_certificate.chain_condition
end

@testset "Vietoris--Rips and clique construction agree on a threshold graph" begin
    distances = [
        0.0 1.0 2.0 1.0
        1.0 0.0 1.0 2.0
        2.0 1.0 0.0 1.0
        1.0 2.0 1.0 0.0
    ]
    rips = vietoris_rips_complex(distances, 1.1; max_dimension = 3)
    adjacency = (distances .<= 1.1) .& .!Matrix{Bool}(I, 4, 4)
    clique = clique_complex(adjacency; max_dimension = 3)
    @test rips.simplices == clique.simplices
    @test topology_certificate(rips).betti == (1, 1, 0, 0)
end

@testset "boundary composition mutation guard" begin
    cycle = clique_complex(cycle_adjacency(4); max_dimension = 2)
    @test chain_condition_holds(cycle)
    boundary1 = boundary_matrix_f2(cycle, 1)
    @test rank_f2(boundary1) == 3
end
