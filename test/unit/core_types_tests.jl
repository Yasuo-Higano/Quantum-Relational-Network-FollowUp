using Test
using QRNReplication.CoreTypes

@testset "semantic core types" begin
    @test DecayRate(0.0).value == 0.0
    @test LengthScale(2.5).value == 2.5
    @test InteractionWeight(3 // 2).value == 3 // 2
    @test_throws ArgumentError DecayRate(-1.0)
    @test_throws ArgumentError LengthScale(0.0)
    @test_throws ArgumentError InteractionWeight(-eps())

    contract = ObservationContract(
        :initial_covariance,
        :block_population,
        :raw_projector,
    )
    @test contract.noise_model == :none
    @test_throws ArgumentError ObservationContract(:unknown, :block_population, :raw_projector)

    budget = NumericalBudget(1e-6, 2e-6, 3e-6, 4e-6, 5e-6)
    @test sum(budget) ≈ 15e-6 atol = eps(15e-6)

    certificate = TopologyCertificate((1, 2, 0, 0), [0, 1, 2], :F2, true)
    @test certificate.betti == (1, 2, 0, 0)
    @test certificate.chain_condition
end
