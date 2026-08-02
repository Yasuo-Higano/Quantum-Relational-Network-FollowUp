using Test
using LinearAlgebra
using Random
using QRNReplication.CoreTypes: Answer, Abstain
using QRNReplication.GraphGeometry
using QRNReplication.SimplicialHomology

function petersen_adjacency()
    adjacency = falses(10, 10)
    edges = [
        (1, 2), (2, 3), (3, 4), (4, 5), (5, 1),
        (6, 8), (8, 10), (10, 7), (7, 9), (9, 6),
        (1, 6), (2, 7), (3, 8), (4, 9), (5, 10),
    ]
    for (left, right) in edges
        adjacency[left, right] = adjacency[right, left] = true
    end
    return adjacency
end

function random_regular_adjacency(
    vertex_count::Int,
    degree::Int,
    rng::AbstractRNG;
    attempts::Int = 10_000,
)
    stubs = reduce(vcat, [fill(vertex, degree) for vertex in 1:vertex_count])
    for _ in 1:attempts
        shuffled = shuffle(rng, stubs)
        adjacency = falses(vertex_count, vertex_count)
        valid = true
        for offset in 1:2:length(shuffled)
            left, right = shuffled[offset], shuffled[offset + 1]
            if left == right || adjacency[left, right]
                valid = false
                break
            end
            adjacency[left, right] = adjacency[right, left] = true
        end
        valid && all(sum(adjacency; dims = 2) .== degree) && return adjacency
    end
    error("regular graph rejection sampler exhausted")
end

@testset "surface and volume homology adversaries" begin
    disk = triangulated_grid_surface(5, 5)
    cylinder = triangulated_grid_surface(5, 5; periodic_x = true)
    torus = triangulated_grid_surface(4, 4; periodic_x = true, periodic_y = true)
    two_holes = triangulated_grid_surface(
        7,
        5;
        removed_cells = Set([(2, 2), (5, 2)]),
    )
    sphere = simplex_boundary_complex(3)
    genus_two = connected_sum_surfaces(torus, torus)
    three_torus = triangulated_three_torus(3)
    three_sphere = simplex_boundary_complex(4)
    three_ball = filled_simplex_complex(3)

    @test topology_certificate(disk).betti == (1, 0, 0, 0)
    @test topology_certificate(cylinder).betti == (1, 1, 0, 0)
    @test topology_certificate(torus).betti == (1, 2, 1, 0)
    @test topology_certificate(two_holes).betti == (1, 2, 0, 0)
    @test topology_certificate(sphere).betti == (1, 0, 1, 0)
    @test topology_certificate(genus_two).betti == (1, 4, 1, 0)
    @test topology_certificate(three_torus).betti == (1, 3, 3, 1)
    @test topology_certificate(three_sphere).betti == (1, 0, 0, 1)
    @test topology_certificate(three_ball).betti == (1, 0, 0, 0)

    @test codimension_one_status(disk, 2) == :pseudomanifold_with_boundary
    @test codimension_one_status(cylinder, 2) == :pseudomanifold_with_boundary
    @test codimension_one_status(torus, 2) == :closed_pseudomanifold
    @test codimension_one_status(genus_two, 2) == :closed_pseudomanifold
    @test codimension_one_status(three_torus, 3) == :closed_pseudomanifold
end

@testset "regular, Petersen, complete, and branched graphs" begin
    petersen = petersen_adjacency()
    @test all(sum(petersen; dims = 2) .== 3)
    @test topology_certificate(clique_complex(petersen; max_dimension = 3)).betti ==
          (1, 6, 0, 0)
    @test graph_one_manifold_status(petersen) == :nonmanifold

    random_regular = random_regular_adjacency(12, 3, Xoshiro(0x514e52))
    @test all(sum(random_regular; dims = 2) .== 3)
    @test graph_one_manifold_status(random_regular) == :nonmanifold

    complete = trues(6, 6) .& .!Matrix{Bool}(I, 6, 6)
    @test topology_certificate(clique_complex(complete; max_dimension = 4)).betti ==
          (1, 0, 0, 0)
    @test graph_one_manifold_status(complete) == :nonmanifold

    branched = complex_from_facets([(1, 2, 3), (1, 2, 4), (1, 2, 5)])
    @test codimension_one_status(branched, 2) == :nonmanifold
end

@testset "geometry recovery and threshold degeneracy" begin
    weights = [
        0.0 2.0 0.1 0.1
        2.0 0.0 2.0 0.1
        0.1 2.0 0.0 2.0
        0.1 0.1 2.0 0.0
    ]
    recovered = recover_threshold_geometry(weights, 1.0)
    @test recovered.status == Answer
    @test graph_one_manifold_status(recovered.adjacency) == :one_manifold_with_boundary
    @test recovered.distances[1, 4] ≈ 1.5

    uncertainty = zeros(4, 4)
    weights[1, 3] = weights[3, 1] = 1.0
    uncertainty[1, 3] = uncertainty[3, 1] = 0.2
    degenerate = recover_threshold_geometry(weights, 1.0; uncertainty = uncertainty)
    @test degenerate.status == Abstain
    @test (1, 3) in degenerate.ambiguous_edges
    @test isnothing(degenerate.adjacency)
end
