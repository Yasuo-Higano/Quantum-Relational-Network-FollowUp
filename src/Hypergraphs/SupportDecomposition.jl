module SupportDecomposition

using LinearAlgebra
using ..CoreTypes: InteractionWeight

export conditional_expectation,
       support_decomposition_mobius,
       support_decomposition_product,
       support_weights,
       reconstruct_operator,
       hilbert_schmidt_inner

function _validate_dimensions(operator::AbstractMatrix, dimensions::AbstractVector{<:Integer})
    isempty(dimensions) && throw(ArgumentError("at least one local dimension is required"))
    all(d -> d > 0, dimensions) || throw(ArgumentError("local dimensions must be positive"))
    total_dimension = prod(dimensions)
    size(operator) == (total_dimension, total_dimension) ||
        throw(DimensionMismatch("operator size does not match tensor dimensions"))
    all(isfinite, operator) || throw(ArgumentError("operator contains a non-finite value"))
    return nothing
end

function _canonical_subset(subset, number_of_sites::Int)
    canonical = sort!(unique!(collect(Int, subset)))
    all(site -> 1 <= site <= number_of_sites, canonical) ||
        throw(ArgumentError("support contains an invalid site"))
    return Tuple(canonical)
end

function _decode_index(index::Int, dimensions::AbstractVector{<:Integer})
    1 <= index <= prod(dimensions) || throw(BoundsError(dimensions, index))
    remainder = index - 1
    coordinates = Vector{Int}(undef, length(dimensions))
    for site in reverse(eachindex(dimensions))
        coordinates[site] = mod(remainder, dimensions[site]) + 1
        remainder = div(remainder, dimensions[site])
    end
    return coordinates
end

function _linear_index(coordinates::AbstractVector{<:Integer}, dimensions)
    length(coordinates) == length(dimensions) || throw(DimensionMismatch("coordinate rank mismatch"))
    index = 1
    stride = 1
    for site in reverse(eachindex(dimensions))
        1 <= coordinates[site] <= dimensions[site] ||
            throw(BoundsError(coordinates, site))
        index += (coordinates[site] - 1) * stride
        stride *= dimensions[site]
    end
    return index
end

function _coordinate_products(dimensions, sites::Vector{Int})
    products = [Int[]]
    for site in sites
        products = [vcat(prefix, value) for prefix in products for value in 1:dimensions[site]]
    end
    return products
end

function _subsets(sites::Tuple)
    count = length(sites)
    return [Tuple(sites[index] for index in 1:count if (mask >> (index - 1)) & 1 == 1)
            for mask in 0:(2^count - 1)]
end

"""
    conditional_expectation(A, dimensions, retained_sites)

Orthogonally project `A` onto operators supported within `retained_sites` using
a normalized partial trace over all other tensor factors. Tensor indices follow
Julia's `kron(A, B)` convention: the last factor is the fastest index.
"""
function conditional_expectation(
    operator::AbstractMatrix,
    dimensions::AbstractVector{<:Integer},
    retained_sites,
)
    _validate_dimensions(operator, dimensions)
    site_count = length(dimensions)
    retained = _canonical_subset(retained_sites, site_count)
    retained_set = Set(retained)
    traced_sites = [site for site in 1:site_count if !(site in retained_set)]
    traced_products = _coordinate_products(dimensions, traced_sites)
    traced_dimension = prod(dimensions[traced_sites]; init = 1)

    output_type = typeof(zero(eltype(operator)) / one(Int))
    total_dimension = prod(dimensions)
    output = zeros(output_type, total_dimension, total_dimension)

    decoded = [_decode_index(index, dimensions) for index in 1:total_dimension]
    for row in 1:total_dimension, column in 1:total_dimension
        row_coordinates = decoded[row]
        column_coordinates = decoded[column]
        all(row_coordinates[site] == column_coordinates[site] for site in traced_sites) ||
            continue

        accumulator = zero(output_type)
        for traced_values in traced_products
            source_row = copy(row_coordinates)
            source_column = copy(column_coordinates)
            for (offset, site) in enumerate(traced_sites)
                source_row[site] = traced_values[offset]
                source_column[site] = traced_values[offset]
            end
            accumulator += operator[
                _linear_index(source_row, dimensions),
                _linear_index(source_column, dimensions),
            ]
        end
        output[row, column] = accumulator / traced_dimension
    end
    return output
end

"""Compute exact-support components using subset-lattice Möbius inversion."""
function support_decomposition_mobius(
    operator::AbstractMatrix,
    dimensions::AbstractVector{<:Integer},
)
    _validate_dimensions(operator, dimensions)
    all_sites = Tuple(1:length(dimensions))
    supports = _subsets(all_sites)
    expectations = Dict(support => conditional_expectation(operator, dimensions, support)
                        for support in supports)
    matrix_type = typeof(first(values(expectations)))
    components = Dict{Tuple,matrix_type}()
    output_eltype = eltype(first(values(expectations)))
    for support in supports
        component = zeros(output_eltype, size(operator)...)
        for subset in _subsets(support)
            sign = iseven(length(support) - length(subset)) ? 1 : -1
            component .+= sign .* expectations[subset]
        end
        components[support] = component
    end
    return components
end

"""
Compute exact-support components by applying commuting local traceless
projections successively. This is an independent formula-level cross-check of
Möbius inversion.
"""
function support_decomposition_product(
    operator::AbstractMatrix,
    dimensions::AbstractVector{<:Integer},
)
    _validate_dimensions(operator, dimensions)
    all_sites = Tuple(1:length(dimensions))
    supports = _subsets(all_sites)
    seed = conditional_expectation(operator, dimensions, ())
    components = Dict{Tuple,typeof(seed)}()
    for support in supports
        component = conditional_expectation(operator, dimensions, support)
        for site in support
            sites_without = Tuple(filter(candidate -> candidate != site, support))
            component -= conditional_expectation(component, dimensions, sites_without)
        end
        components[support] = component
    end
    return components
end

"""Hilbert--Schmidt inner product."""
hilbert_schmidt_inner(left::AbstractMatrix, right::AbstractMatrix) =
    tr(left' * right)

"""Return typed nonnegative weights for every exact support."""
function support_weights(components::AbstractDict)
    weights = Dict{Tuple,InteractionWeight}()
    for (support, component) in components
        weights[support] = InteractionWeight(real(sum(abs2, component)))
    end
    return weights
end

"""Sum all support components and return the reconstructed operator."""
function reconstruct_operator(components::AbstractDict)
    isempty(components) && throw(ArgumentError("component dictionary is empty"))
    matrices = collect(values(components))
    reconstruction = zeros(eltype(first(matrices)), size(first(matrices))...)
    for component in matrices
        size(component) == size(reconstruction) ||
            throw(DimensionMismatch("support components have inconsistent sizes"))
        reconstruction .+= component
    end
    return reconstruction
end

end
