module GraphGeometry

using LinearAlgebra
using ..CoreTypes: ResultStatus, Answer, Abstain

export GeometryReadout,
       recover_threshold_geometry,
       shortest_path_distances,
       graph_one_manifold_status

"""Threshold-graph result carrying ambiguity evidence separately from distances."""
struct GeometryReadout
    status::ResultStatus
    adjacency::Union{Nothing,BitMatrix}
    distances::Union{Nothing,Matrix{Float64}}
    ambiguous_edges::Vector{Tuple{Int,Int}}
    function GeometryReadout(
        status::ResultStatus,
        adjacency::Union{Nothing,BitMatrix},
        distances::Union{Nothing,Matrix{Float64}},
        ambiguous_edges::Vector{Tuple{Int,Int}},
    )
        if status == Answer
            isnothing(adjacency) && throw(ArgumentError("Answer requires an adjacency matrix"))
            isnothing(distances) && throw(ArgumentError("Answer requires distances"))
            isempty(ambiguous_edges) || throw(ArgumentError("Answer cannot carry ambiguous edges"))
        elseif status == Abstain
            isnothing(adjacency) || throw(ArgumentError("Abstain cannot carry a chosen graph"))
            isempty(ambiguous_edges) && throw(ArgumentError("Abstain requires ambiguity evidence"))
        else
            throw(ArgumentError("geometry readout supports only Answer or Abstain"))
        end
        new(status, adjacency, distances, copy(ambiguous_edges))
    end
end

function _validate_symmetric_matrix(name::AbstractString, matrix::AbstractMatrix)
    size(matrix, 1) == size(matrix, 2) || throw(DimensionMismatch("$name must be square"))
    all(isfinite, matrix) || throw(ArgumentError("$name contains a non-finite value"))
    isapprox(matrix, matrix'; atol = 64eps(Float64), rtol = 64eps(Float64)) ||
        throw(ArgumentError("$name must be symmetric"))
    return nothing
end

"""All-pairs shortest paths for an undirected graph with positive edge lengths."""
function shortest_path_distances(
    adjacency::AbstractMatrix,
    edge_lengths::AbstractMatrix = ones(Float64, size(adjacency)),
)
    _validate_symmetric_matrix("adjacency", adjacency)
    _validate_symmetric_matrix("edge_lengths", edge_lengths)
    size(adjacency) == size(edge_lengths) || throw(DimensionMismatch("matrix sizes differ"))
    vertex_count = size(adjacency, 1)
    distances = fill(Inf, vertex_count, vertex_count)
    for vertex in 1:vertex_count
        distances[vertex, vertex] = 0.0
    end
    for left in 1:vertex_count, right in (left + 1):vertex_count
        if !iszero(adjacency[left, right])
            length_value = Float64(edge_lengths[left, right])
            length_value > 0 || throw(ArgumentError("present edges need positive lengths"))
            distances[left, right] = length_value
            distances[right, left] = length_value
        end
    end
    for intermediate in 1:vertex_count, left in 1:vertex_count, right in 1:vertex_count
        candidate = distances[left, intermediate] + distances[intermediate, right]
        candidate < distances[left, right] && (distances[left, right] = candidate)
    end
    return distances
end

"""Recover a graph only when every edge confidence interval avoids the threshold."""
function recover_threshold_geometry(
    weights::AbstractMatrix,
    threshold::Real;
    uncertainty::AbstractMatrix = zeros(Float64, size(weights)),
)
    _validate_symmetric_matrix("weights", weights)
    _validate_symmetric_matrix("uncertainty", uncertainty)
    size(weights) == size(uncertainty) || throw(DimensionMismatch("matrix sizes differ"))
    threshold >= 0 || throw(ArgumentError("threshold must be nonnegative"))
    all(weights .>= 0) || throw(ArgumentError("weights must be nonnegative"))
    all(uncertainty .>= 0) || throw(ArgumentError("uncertainty must be nonnegative"))
    vertex_count = size(weights, 1)
    ambiguous = Tuple{Int,Int}[]
    adjacency = falses(vertex_count, vertex_count)
    edge_lengths = ones(Float64, vertex_count, vertex_count)
    for left in 1:vertex_count, right in (left + 1):vertex_count
        lower = weights[left, right] - uncertainty[left, right]
        upper = weights[left, right] + uncertainty[left, right]
        if lower <= threshold <= upper
            push!(ambiguous, (left, right))
        elseif lower > threshold
            adjacency[left, right] = adjacency[right, left] = true
            edge_lengths[left, right] = edge_lengths[right, left] =
                1 / Float64(weights[left, right])
        end
    end
    isempty(ambiguous) || return GeometryReadout(Abstain, nothing, nothing, ambiguous)
    return GeometryReadout(
        Answer,
        adjacency,
        shortest_path_distances(adjacency, edge_lengths),
        ambiguous,
    )
end

"""Necessary graph-level qualification for a one-dimensional manifold."""
function graph_one_manifold_status(adjacency::AbstractMatrix)
    _validate_symmetric_matrix("adjacency", adjacency)
    degrees = [count(!iszero, adjacency[vertex, :]) for vertex in axes(adjacency, 1)]
    all(==(2), degrees) && return :closed_one_manifold
    all(degree -> degree in (1, 2), degrees) && return :one_manifold_with_boundary
    return :nonmanifold
end

end
