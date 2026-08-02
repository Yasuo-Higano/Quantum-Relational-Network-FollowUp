using Test
using LinearAlgebra
using Random
using QRNReplication.LocalResponse

function site_projector(site::Int, site_count::Int)
    projector = zeros(ComplexF64, site_count, site_count)
    projector[site, site] = 1
    return projector
end

@testset "boundary, disorder, probe strength, and internal basis response" begin
    rng = Xoshiro(0x525350)
    for periodic in (false, true)
        site_count = 5
        hamiltonian = zeros(ComplexF64, site_count, site_count)
        for site in 1:(site_count - 1)
            hopping = 0.2 + rand(rng) + 0.2im * randn(rng)
            hamiltonian[site, site + 1] = hopping
            hamiltonian[site + 1, site] = conj(hopping)
        end
        if periodic
            hopping = 0.4 - 0.3im
            hamiltonian[1, end] = hopping
            hamiltonian[end, 1] = conj(hopping)
        end
        hamiltonian += Diagonal(randn(rng, site_count))
        baseline = 0.5 .* Matrix{ComplexF64}(I, site_count, site_count)
        source = site_projector(1, site_count)
        target = site_projector(2, site_count)
        target_weight = coupling_weight(hamiltonian, source, target).value
        for epsilon in (1e-1, 1e-3, 1e-5)
            response = projector_curvature_response(
                hamiltonian,
                baseline,
                source,
                target,
                epsilon,
            )
            @test response ≈ target_weight atol = 5e-11
        end
    end

    block = randn(rng, ComplexF64, 2, 2)
    left_block = Hermitian(randn(rng, ComplexF64, 2, 2)) |> Matrix
    right_block = Hermitian(randn(rng, ComplexF64, 2, 2)) |> Matrix
    hamiltonian = [left_block block'; block right_block]
    source = Diagonal(ComplexF64[1, 1, 0, 0]) |> Matrix
    target = Diagonal(ComplexF64[0, 0, 1, 1]) |> Matrix
    qr_left = qr(randn(rng, ComplexF64, 2, 2)).Q |> Matrix
    qr_right = qr(randn(rng, ComplexF64, 2, 2)).Q |> Matrix
    internal_unitary = [qr_left zeros(ComplexF64, 2, 2);
                        zeros(ComplexF64, 2, 2) qr_right]
    transformed = internal_unitary * hamiltonian * internal_unitary'
    @test coupling_weight(hamiltonian, source, target).value ≈
          coupling_weight(transformed, source, target).value atol = 2e-13
end

@testset "noise amplification is explicit and inverse in probe size" begin
    sigma_large_probe = response_noise_standard_error(2e-5, 3e-5, 1e-2)
    sigma_small_probe = response_noise_standard_error(2e-5, 3e-5, 1e-4)
    @test sigma_small_probe / sigma_large_probe ≈ 100
    @test_throws ArgumentError response_noise_standard_error(-1.0, 1.0, 0.1)
    @test_throws ArgumentError response_noise_standard_error(1.0, 1.0, 0.0)
end
