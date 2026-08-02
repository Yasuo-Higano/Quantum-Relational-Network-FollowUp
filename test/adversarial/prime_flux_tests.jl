using Test
using LinearAlgebra
using QRNReplication.FluxDiagnostics

@testset "prime Pfaffian does not force skew-plane imbalance" begin
    flux = balanced_prime_flux_counterexample()
    @test flux == -flux'
    @test pfaffian4(flux) == 3
    @test det(flux) == 9
    @test flux' * flux == 3 * Matrix{Int}(I, 4, 4)
    first_value, second_value = skew_singular_values(flux)
    @test first_value ≈ sqrt(3) atol = 4eps(Float64)
    @test second_value ≈ sqrt(3) atol = 4eps(Float64)
end
