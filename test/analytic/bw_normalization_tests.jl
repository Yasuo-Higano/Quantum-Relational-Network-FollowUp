using Test
using QRNReplication.BWNormalization

@testset "BW prefactor independent representations" begin
    @test bw_prefactor_agm(0.0) == 1.0
    masses = [0.2, 0.5, 1.0, sqrt(2.0)]
    agm_values = [bw_prefactor_agm(mass) for mass in masses]
    simpson_values = [bw_prefactor_simpson(mass; panels = 4096) for mass in masses]
    @test all(isapprox(agm, integral; atol = 2e-14, rtol = 2e-14)
              for (agm, integral) in zip(agm_values, simpson_values))
    @test all(agm_values[index + 1] < agm_values[index] for index in 1:(length(agm_values) - 1))

    setprecision(256) do
        mass = BigFloat(1)
        exact_agm = bw_prefactor_agm(mass)
        errors = [abs(exact_agm - bw_prefactor_simpson(mass; panels = panels))
                  for panels in (4, 8, 16)]
        @test errors[2] < errors[1]
        @test errors[3] < errors[2]
        @test errors[3] < big"1e-12"
    end
end

@testset "BW anisotropy sign without paper target values" begin
    coarse = bw_moments_midpoint(32)
    fine = bw_moments_midpoint(64)
    @test coarse.inverse_lambda_perpendicular < coarse.inverse_lambda_x
    @test fine.inverse_lambda_perpendicular < fine.inverse_lambda_x
    @test coarse.lambda_perpendicular > coarse.lambda_x
    @test fine.lambda_perpendicular > fine.lambda_x
    @test abs(fine.lambda_x - coarse.lambda_x) < 2e-4
    @test abs(fine.lambda_perpendicular - coarse.lambda_perpendicular) < 2e-4
end
