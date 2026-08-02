module FermionFock

using LinearAlgebra

export fermion_annihilation,
       fock_number_operator,
       quadratic_fock_hamiltonian,
       density_density_term,
       pairing_term,
       product_occupation_state

function _validate_site(site::Int, site_count::Int)
    site_count > 0 || throw(ArgumentError("site_count must be positive"))
    1 <= site <= site_count || throw(ArgumentError("site is outside the Fock system"))
    return nothing
end

"""Jordan--Wigner annihilation operator for a spinless fermionic site."""
function fermion_annihilation(site::Int, site_count::Int)
    _validate_site(site, site_count)
    identity2 = Matrix{ComplexF64}(I, 2, 2)
    parity = ComplexF64[1 0; 0 -1]
    lowering = ComplexF64[0 1; 0 0]
    factors = Matrix{ComplexF64}[
        position < site ? parity : position == site ? lowering : identity2
        for position in 1:site_count
    ]
    operator = factors[1]
    for factor in factors[2:end]
        operator = kron(operator, factor)
    end
    return operator
end

"""Local occupation operator `c_i^dagger c_i`."""
function fock_number_operator(site::Int, site_count::Int)
    annihilation = fermion_annihilation(site, site_count)
    return annihilation' * annihilation
end

"""Second-quantize a Hermitian one-particle Hamiltonian exactly."""
function quadratic_fock_hamiltonian(one_particle::AbstractMatrix)
    size(one_particle, 1) == size(one_particle, 2) ||
        throw(DimensionMismatch("one-particle Hamiltonian must be square"))
    ishermitian(one_particle) || throw(ArgumentError("one-particle Hamiltonian must be Hermitian"))
    all(isfinite, one_particle) ||
        throw(ArgumentError("one-particle Hamiltonian contains a non-finite value"))
    site_count = size(one_particle, 1)
    annihilations = [fermion_annihilation(site, site_count) for site in 1:site_count]
    fock_dimension = 2^site_count
    hamiltonian = zeros(ComplexF64, fock_dimension, fock_dimension)
    for source in 1:site_count, target in 1:site_count
        hamiltonian += one_particle[target, source] *
                       annihilations[target]' * annihilations[source]
    end
    return (hamiltonian + hamiltonian') / 2
end

"""Return `strength*n_i*n_j` for distinct spinless sites."""
function density_density_term(
    first_site::Int,
    second_site::Int,
    site_count::Int,
    strength::Real,
)
    _validate_site(first_site, site_count)
    _validate_site(second_site, site_count)
    first_site != second_site || throw(ArgumentError("density interaction needs distinct sites"))
    isfinite(strength) || throw(ArgumentError("interaction strength must be finite"))
    return strength .* fock_number_operator(first_site, site_count) *
           fock_number_operator(second_site, site_count)
end

"""Return the Hermitian number-nonconserving pairing term `Delta(c_i^dagger c_j^dagger+c_j c_i)`."""
function pairing_term(
    first_site::Int,
    second_site::Int,
    site_count::Int,
    strength::Real,
)
    _validate_site(first_site, site_count)
    _validate_site(second_site, site_count)
    first_site != second_site || throw(ArgumentError("pairing needs distinct sites"))
    isfinite(strength) || throw(ArgumentError("pairing strength must be finite"))
    first_annihilation = fermion_annihilation(first_site, site_count)
    second_annihilation = fermion_annihilation(second_site, site_count)
    creation_pair = first_annihilation' * second_annihilation'
    return strength .* (creation_pair + creation_pair')
end

"""Product mixed state with independently occupied spinless sites."""
function product_occupation_state(probabilities::AbstractVector{<:Real})
    isempty(probabilities) && throw(ArgumentError("at least one occupation probability is required"))
    all(probability -> isfinite(probability) && 0 <= probability <= 1, probabilities) ||
        throw(ArgumentError("occupation probabilities must lie in [0,1]"))
    factors = [ComplexF64[1 - probability 0; 0 probability] for probability in probabilities]
    density = factors[1]
    for factor in factors[2:end]
        density = kron(density, factor)
    end
    return density
end

end
