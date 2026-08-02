module SimplicialHomology

using LinearAlgebra
using ..CoreTypes: TopologyCertificate

export SimplicialComplex,
       clique_complex,
       vietoris_rips_complex,
       filled_simplex_complex,
       simplex_boundary_complex,
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
