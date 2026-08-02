module FluxDiagnostics

using LinearAlgebra

export pfaffian4,
       skew_singular_values,
       balanced_prime_flux_counterexample

function _validate_antisymmetric4(matrix::AbstractMatrix)
    size(matrix) == (4, 4) || throw(DimensionMismatch("flux matrix must be 4 by 4"))
    matrix == -matrix' || throw(ArgumentError("flux matrix must be antisymmetric"))
    all(isfinite, matrix) || throw(ArgumentError("flux matrix contains a non-finite value"))
    return nothing
end

"""Exact Pfaffian of a 4 by 4 antisymmetric matrix."""
function pfaffian4(matrix::AbstractMatrix)
    _validate_antisymmetric4(matrix)
    return matrix[1, 2] * matrix[3, 4] -
           matrix[1, 3] * matrix[2, 4] +
           matrix[1, 4] * matrix[2, 3]
end

"""Return the two distinct nonnegative skew singular values in descending order."""
function skew_singular_values(matrix::AbstractMatrix)
    _validate_antisymmetric4(matrix)
    values = svdvals(float.(matrix))
    return (values[1], values[3])
end

"""
Return an integer antisymmetric matrix with Pfaffian three and equal skew
singular values `sqrt(3)`. It is an algebraic counterexample to the claim that
prime Pfaffian alone forces unequal magnetic planes.
"""
balanced_prime_flux_counterexample() = [
     0  1  1  1
    -1  0  1 -1
    -1 -1  0  1
    -1  1 -1  0
]

end
