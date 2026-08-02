using Test
using QRNReplication.CoreTypes
using QRNReplication.AdversarialCases

@testset "independent adversarial generator coverage" begin
    cases = generate_cases(:train, 10)
    @test length(cases) == 50
    @test length(unique(case.cell_id for case in cases)) == length(cases)
    @test generate_cases(:train, 10) == cases
    @test_throws ArgumentError generate_cases(:holdout, 10)

    for family in benchmark_families
        family_cases = filter(case -> case.family == family, cases)
        @test Set(case.scenario for case in family_cases) == Set(benchmark_scenarios)
        @test Set(case.truth_class for case in family_cases) == Set(instances(TruthClass))
    end

    evaluations = evaluate_case.(cases)
    @test all(evaluation.status == expected_status(case)
              for (case, evaluation) in zip(cases, evaluations))
    @test all(
        evaluation.status != Answer || maximum_error(evaluation) <= evaluation.tolerance
        for evaluation in evaluations
    )
    @test all(
        evaluation.status == Answer || !isempty(evaluation.witnesses)
        for evaluation in evaluations
    )
end
