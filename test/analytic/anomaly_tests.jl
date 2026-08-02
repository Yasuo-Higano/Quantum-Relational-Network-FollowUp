using Test
using QRNReplication.AnomalyChecks

@testset "exact Standard Model anomaly cancellation" begin
    spectrum = standard_model_generation()
    anomalies = anomaly_vector(spectrum)
    @test anomalies.color_color_hypercharge == 0
    @test anomalies.weak_weak_hypercharge == 0
    @test anomalies.gravitational_hypercharge == 0
    @test anomalies.cubic_hypercharge == 0
    @test anomalies.cubic_color == 0
    @test anomalies.witten_parity == 0
    @test is_anomaly_free(anomalies)

    broken = copy(spectrum)
    broken[1] = GaugeMultiplet(1, 1, -5, 0, 0, 0, 0)
    @test !is_anomaly_free(anomaly_vector(broken))
end
