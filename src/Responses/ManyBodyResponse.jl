module ManyBodyResponse

using LinearAlgebra

export manybody_curvature,
       signed_manybody_curvature_response,
       dense_manybody_expectation,
       finite_difference_manybody_curvature

function _validate_density_matrix(density::AbstractMatrix)
    size(density, 1) == size(density, 2) ||
        throw(DimensionMismatch("density matrix must be square"))
    ishermitian(density) || throw(ArgumentError("density matrix must be Hermitian"))
    all(isfinite, density) || throw(ArgumentError("density matrix is non-finite"))
    abs(real(tr(density)) - 1) <= 128eps(Float64) ||
        throw(ArgumentError("density matrix must have unit trace"))
    minimum(eigvals(Hermitian(ComplexF64.(density)))) >= -128eps(Float64) ||
        throw(ArgumentError("density matrix must be positive semidefinite"))
    return nothing
end

"""Exact many-body curvature `-Tr(rho[H,[H,N]])`."""
function manybody_curvature(
    hamiltonian::AbstractMatrix,
    density::AbstractMatrix,
    observable::AbstractMatrix,
)
    size(hamiltonian, 1) == size(hamiltonian, 2) ||
        throw(DimensionMismatch("Hamiltonian must be square"))
    size(hamiltonian) == size(density) == size(observable) ||
        throw(DimensionMismatch("many-body operators have inconsistent dimensions"))
    ishermitian(hamiltonian) || throw(ArgumentError("Hamiltonian must be Hermitian"))
    ishermitian(observable) || throw(ArgumentError("observable must be Hermitian"))
    _validate_density_matrix(density)
    first_commutator = hamiltonian * observable - observable * hamiltonian
    second_commutator = hamiltonian * first_commutator - first_commutator * hamiltonian
    return -real(tr(density * second_commutator))
end

"""Evolve a density matrix with a dense exponential and measure an observable."""
function dense_manybody_expectation(
    hamiltonian::AbstractMatrix,
    density::AbstractMatrix,
    observable::AbstractMatrix,
    time::Real,
)
    size(hamiltonian, 1) == size(hamiltonian, 2) ||
        throw(DimensionMismatch("Hamiltonian must be square"))
    size(hamiltonian) == size(density) == size(observable) ||
        throw(DimensionMismatch("many-body operators have inconsistent dimensions"))
    ishermitian(hamiltonian) || throw(ArgumentError("Hamiltonian must be Hermitian"))
    ishermitian(observable) || throw(ArgumentError("observable must be Hermitian"))
    _validate_density_matrix(density)
    propagator = exp(-im * time * hamiltonian)
    evolved = propagator * density * propagator'
    return real(tr(evolved * observable))
end

"""Three-point central estimate of a many-body expectation curvature."""
function finite_difference_manybody_curvature(
    hamiltonian::AbstractMatrix,
    density::AbstractMatrix,
    observable::AbstractMatrix,
    time_step::Real,
)
    time_step > 0 || throw(ArgumentError("time_step must be positive"))
    plus = dense_manybody_expectation(hamiltonian, density, observable, time_step)
    zero_time = dense_manybody_expectation(hamiltonian, density, observable, zero(time_step))
    minus = dense_manybody_expectation(hamiltonian, density, observable, -time_step)
    return (plus - 2 * zero_time + minus) / time_step^2
end

"""Signed response from two separately normalized physical density matrices."""
function signed_manybody_curvature_response(
    hamiltonian::AbstractMatrix,
    density_plus::AbstractMatrix,
    density_minus::AbstractMatrix,
    observable::AbstractMatrix,
    epsilon::Real,
)
    epsilon > 0 || throw(ArgumentError("epsilon must be positive"))
    plus = manybody_curvature(hamiltonian, density_plus, observable)
    minus = manybody_curvature(hamiltonian, density_minus, observable)
    return (plus - minus) / (4epsilon)
end

end
