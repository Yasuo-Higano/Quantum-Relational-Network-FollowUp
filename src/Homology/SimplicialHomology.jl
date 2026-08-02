module SimplicialHomology

using LinearAlgebra
using ..CoreTypes: TopologyCertificate

export SimplicialComplex,
       clique_complex,
       vietoris_rips_complex,
       filled_simplex_complex,
       simplex_boundary_complex,
       complex_from_facets,
       triangulated_grid_surface,
       connected_sum_surfaces,
       triangulated_three_torus,
       codimension_one_status,
       boundary_matrix_f2,
       rank_f2,
       chain_condition_holds,
       betti_numbers,
       topology_certificate

struct SimplicialComplex
    simplices::Vector{Vector{Tuple}}
    function SimplicialComplex(raw_simplices::AbstractVector)
        isempty(raw_simplices) && throw(ArgumentError("complex must include a vertex level"))
        canonical = Vector{Vector{Tuple}}(undef, length(raw_simplices))
        for (dimension_index, level) in enumerate(raw_simplices)
            expected_size = dimension_index
            normalized = Tuple[]
            for simplex_raw in level
                simplex = Tuple(sort!(unique!(collect(Int, simplex_raw))))
                length(simplex) == expected_size ||
                    throw(ArgumentError("simplex has the wrong dimension or repeated vertices"))
                push!(normalized, simplex)
            end
            canonical[dimension_index] = sort!(unique!(normalized))
        end
        isempty(canonical[1]) && throw(ArgumentError("complex must contain vertices"))

        for dimension_index in 2:length(canonical)
            previous_faces = Set(canonical[dimension_index - 1])
            for simplex in canonical[dimension_index]
                for omitted in eachindex(simplex)
                    face = Tuple(simplex[index] for index in eachindex(simplex) if index != omitted)
                    face in previous_faces ||
                        throw(ArgumentError("complex is not closed under faces: missing $face"))
                end
            end
        end
        new(canonical)
    end
end

"""Construct the face closure of a finite list of maximal simplices."""
function complex_from_facets(raw_facets::AbstractVector)
    isempty(raw_facets) && throw(ArgumentError("at least one facet is required"))
    facets = Tuple[]
    for raw_facet in raw_facets
        facet = Tuple(sort!(unique!(collect(Int, raw_facet))))
        isempty(facet) && throw(ArgumentError("facets must contain vertices"))
        length(facet) == length(raw_facet) ||
            throw(ArgumentError("a facet contains a repeated vertex"))
        push!(facets, facet)
    end
    maximum_size = maximum(length, facets)
    levels = [Set{Tuple}() for _ in 1:maximum_size]
    for facet in facets
        for face_size in 1:length(facet)
            for positions in _combinations(length(facet), face_size)
                push!(levels[face_size], Tuple(facet[position] for position in positions))
            end
        end
    end
    return SimplicialComplex([collect(level) for level in levels])
end

"""The filled simplex of the requested topological dimension (a ball)."""
function filled_simplex_complex(dimension::Int)
    dimension >= 0 || throw(ArgumentError("dimension must be nonnegative"))
    vertex_count = dimension + 1
    levels = Vector{Vector{Tuple}}(undef, dimension + 1)
    for simplex_dimension in 0:dimension
        levels[simplex_dimension + 1] = _combinations(vertex_count, simplex_dimension + 1)
    end
    return SimplicialComplex(levels)
end

"""Boundary of a simplex; a `simplex_dimension-1` sphere."""
function simplex_boundary_complex(simplex_dimension::Int)
    simplex_dimension >= 1 || throw(ArgumentError("simplex_dimension must be at least one"))
    vertex_count = simplex_dimension + 1
    levels = Vector{Vector{Tuple}}(undef, simplex_dimension)
    for face_dimension in 0:(simplex_dimension - 1)
        levels[face_dimension + 1] = _combinations(vertex_count, face_dimension + 1)
    end
    return SimplicialComplex(levels)
end

"""Triangulate a rectangular surface, optionally identifying either axis."""
function triangulated_grid_surface(
    vertex_count_x::Int,
    vertex_count_y::Int;
    periodic_x::Bool = false,
    periodic_y::Bool = false,
    removed_cells = Set{Tuple{Int,Int}}(),
)
    vertex_count_x >= 3 || throw(ArgumentError("at least three x vertices are required"))
    vertex_count_y >= 3 || throw(ArgumentError("at least three y vertices are required"))
    cell_count_x = periodic_x ? vertex_count_x : vertex_count_x - 1
    cell_count_y = periodic_y ? vertex_count_y : vertex_count_y - 1
    vertex(x, y) = 1 + mod(x, vertex_count_x) + vertex_count_x * mod(y, vertex_count_y)
    triangles = Tuple[]
    for y in 0:(cell_count_y - 1), x in 0:(cell_count_x - 1)
        (x + 1, y + 1) in removed_cells && continue
        lower_left = vertex(x, y)
        lower_right = vertex(x + 1, y)
        upper_left = vertex(x, y + 1)
        upper_right = vertex(x + 1, y + 1)
        push!(triangles, (lower_left, lower_right, upper_right))
        push!(triangles, (lower_left, upper_right, upper_left))
    end
    return complex_from_facets(triangles)
end

"""Form a simplicial connected sum of two closed triangulated surfaces."""
function connected_sum_surfaces(
    first::SimplicialComplex,
    second::SimplicialComplex;
    first_facet::Tuple = first.simplices[3][1],
    second_facet::Tuple = second.simplices[3][1],
)
    length(first.simplices) == 3 == length(second.simplices) ||
        throw(ArgumentError("connected sum requires two-dimensional complexes"))
    first_facet in first.simplices[3] || throw(ArgumentError("first_facet is absent"))
    second_facet in second.simplices[3] || throw(ArgumentError("second_facet is absent"))
    maximum_first_vertex = maximum(only, first.simplices[1])
    glued = Dict(second_facet[index] => first_facet[index] for index in 1:3)
    next_vertex = maximum_first_vertex + 1
    for vertex_tuple in second.simplices[1]
        vertex = only(vertex_tuple)
        if !haskey(glued, vertex)
            glued[vertex] = next_vertex
            next_vertex += 1
        end
    end
    triangles = Tuple[facet for facet in first.simplices[3] if facet != first_facet]
    for facet in second.simplices[3]
        facet == second_facet && continue
        mapped = Tuple(glued[vertex] for vertex in facet)
        push!(triangles, mapped)
    end
    return complex_from_facets(triangles)
end

"""Freudenthal triangulation of a periodic cubic grid representing a 3-torus."""
function triangulated_three_torus(period::Int)
    period >= 3 || throw(ArgumentError("period must be at least three"))
    vertex(x, y, z) =
        1 + mod(x, period) + period * mod(y, period) + period^2 * mod(z, period)
    axis_permutations = (
        (1, 2, 3), (1, 3, 2), (2, 1, 3),
        (2, 3, 1), (3, 1, 2), (3, 2, 1),
    )
    tetrahedra = Tuple[]
    for z in 0:(period - 1), y in 0:(period - 1), x in 0:(period - 1)
        for permutation in axis_permutations
            coordinates = [x, y, z]
            vertices = Int[vertex(coordinates...)]
            for axis in permutation
                coordinates[axis] += 1
                push!(vertices, vertex(coordinates...))
            end
            push!(tetrahedra, Tuple(vertices))
        end
    end
    return complex_from_facets(tetrahedra)
end

"""Qualify only codimension-one incidence, without claiming full manifoldness."""
function codimension_one_status(complex::SimplicialComplex, dimension::Int)
    dimension >= 1 || throw(ArgumentError("dimension must be positive"))
    dimension + 1 <= length(complex.simplices) ||
        throw(ArgumentError("complex has no simplices in the requested dimension"))
    faces = Dict(face => 0 for face in complex.simplices[dimension])
    for simplex in complex.simplices[dimension + 1]
        for omitted in eachindex(simplex)
            face = Tuple(simplex[index] for index in eachindex(simplex) if index != omitted)
            faces[face] = get(faces, face, 0) + 1
        end
    end
    incidences = collect(values(faces))
    all(==(2), incidences) && return :closed_pseudomanifold
    all(value -> value in (1, 2), incidences) && return :pseudomanifold_with_boundary
    return :nonmanifold
end

function _combinations(number_of_vertices::Int, size_of_subset::Int)
    size_of_subset < 0 && throw(ArgumentError("combination size must be nonnegative"))
    size_of_subset == 0 && return [()]
    size_of_subset > number_of_vertices && return Tuple[]
    combinations = Tuple[]
    function extend!(prefix::Vector{Int}, next_vertex::Int)
        if length(prefix) == size_of_subset
            push!(combinations, Tuple(prefix))
            return
        end
        remaining_needed = size_of_subset - length(prefix)
        maximum_start = number_of_vertices - remaining_needed + 1
        for vertex in next_vertex:maximum_start
            push!(prefix, vertex)
            extend!(prefix, vertex + 1)
            pop!(prefix)
        end
    end
    extend!(Int[], 1)
    return combinations
end

function _validate_adjacency(adjacency::AbstractMatrix)
    size(adjacency, 1) == size(adjacency, 2) ||
        throw(DimensionMismatch("adjacency matrix must be square"))
    adjacency == adjacency' || throw(ArgumentError("adjacency matrix must be symmetric"))
    return nothing
end

"""Build the clique complex through `max_dimension` from a symmetric adjacency matrix."""
function clique_complex(adjacency::AbstractMatrix; max_dimension::Int = 4)
    _validate_adjacency(adjacency)
    max_dimension >= 0 || throw(ArgumentError("max_dimension must be nonnegative"))
    vertex_count = size(adjacency, 1)
    levels = Vector{Vector{Tuple}}(undef, max_dimension + 1)
    levels[1] = [(vertex,) for vertex in 1:vertex_count]
    for dimension in 1:max_dimension
        simplices = Tuple[]
        for candidate in _combinations(vertex_count, dimension + 1)
            is_clique = all(adjacency[candidate[left], candidate[right]] != 0
                            for left in 1:length(candidate)
                            for right in (left + 1):length(candidate))
            is_clique && push!(simplices, candidate)
        end
        levels[dimension + 1] = simplices
    end
    return SimplicialComplex(levels)
end

"""Build a Vietoris--Rips complex from a finite distance matrix."""
function vietoris_rips_complex(
    distances::AbstractMatrix,
    threshold::Real;
    max_dimension::Int = 4,
)
    _validate_adjacency(distances)
    threshold >= zero(threshold) || throw(ArgumentError("threshold must be nonnegative"))
    all(isfinite, distances) || throw(ArgumentError("distance matrix contains non-finite values"))
    all(distances .>= 0) || throw(ArgumentError("distances must be nonnegative"))
    all(iszero, diag(distances)) || throw(ArgumentError("distance diagonal must be zero"))
    adjacency = (distances .<= threshold) .& .!Matrix{Bool}(I, size(distances)...)
    return clique_complex(adjacency; max_dimension = max_dimension)
end

"""Return the `F2` boundary matrix from k-simplices to (k-1)-simplices."""
function boundary_matrix_f2(complex::SimplicialComplex, dimension::Int)
    dimension >= 0 || throw(ArgumentError("boundary dimension must be nonnegative"))
    dimension == 0 && return zeros(UInt8, 0, length(complex.simplices[1]))
    dimension + 1 <= length(complex.simplices) ||
        return zeros(UInt8, length(complex.simplices[end]), 0)
    faces = complex.simplices[dimension]
    simplices = complex.simplices[dimension + 1]
    face_rows = Dict(face => row for (row, face) in enumerate(faces))
    boundary = zeros(UInt8, length(faces), length(simplices))
    for (column, simplex) in enumerate(simplices)
        for omitted in eachindex(simplex)
            face = Tuple(simplex[index] for index in eachindex(simplex) if index != omitted)
            row = get(face_rows, face, 0)
            row != 0 || throw(ArgumentError("complex is missing face $face"))
            boundary[row, column] = xor(boundary[row, column], 0x01)
        end
    end
    return boundary
end

"""Exact Gaussian-elimination rank over `F2`."""
function rank_f2(matrix::AbstractMatrix{<:Integer})
    reduced = UInt8.(mod.(matrix, 2))
    row_count, column_count = size(reduced)
    pivot_row = 1
    rank_value = 0
    for column in 1:column_count
        candidate = findfirst(row -> reduced[row, column] == 0x01, pivot_row:row_count)
        isnothing(candidate) && continue
        selected_row = pivot_row + candidate - 1
        if selected_row != pivot_row
            reduced[pivot_row, :], reduced[selected_row, :] =
                copy(reduced[selected_row, :]), copy(reduced[pivot_row, :])
        end
        for row in 1:row_count
            row == pivot_row && continue
            if reduced[row, column] == 0x01
                reduced[row, :] .= xor.(reduced[row, :], reduced[pivot_row, :])
            end
        end
        rank_value += 1
        pivot_row += 1
        pivot_row > row_count && break
    end
    return rank_value
end

"""Check every available composition `partial_(k-1) partial_k = 0` over `F2`."""
function chain_condition_holds(complex::SimplicialComplex)
    for dimension in 2:(length(complex.simplices) - 1)
        lower = boundary_matrix_f2(complex, dimension - 1)
        upper = boundary_matrix_f2(complex, dimension)
        product = mod.(Int.(lower) * Int.(upper), 2)
        all(iszero, product) || return false
    end
    return true
end

"""Compute `beta_0` through `beta_maximum` exactly over `F2`."""
function betti_numbers(complex::SimplicialComplex; beta_maximum::Int = 3)
    beta_maximum >= 0 || throw(ArgumentError("beta_maximum must be nonnegative"))
    ranks = Int[]
    for dimension in 0:(beta_maximum + 1)
        push!(ranks, rank_f2(boundary_matrix_f2(complex, dimension)))
    end
    betti = ntuple(beta_maximum + 1) do offset
        dimension = offset - 1
        simplex_count = dimension + 1 <= length(complex.simplices) ?
            length(complex.simplices[dimension + 1]) : 0
        simplex_count - ranks[dimension + 1] - ranks[dimension + 2]
    end
    all(value -> value >= 0, betti) ||
        throw(ArgumentError("negative Betti number indicates an invalid chain complex"))
    return betti, ranks
end

"""Return a typed certificate for `beta_0` through `beta_3` over `F2`."""
function topology_certificate(complex::SimplicialComplex)
    betti, ranks = betti_numbers(complex; beta_maximum = 3)
    return TopologyCertificate(betti, ranks, :F2, chain_condition_holds(complex))
end

end
