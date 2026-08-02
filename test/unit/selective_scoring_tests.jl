using Test
using QRNReplication.CoreTypes
using QRNReplication.AdversarialCases
using QRNReplication.SelectiveScoring

@testset "selective scoring and deliberate corruptions" begin
    cases = generate_cases(:train, 10)
    evaluations = evaluate_case.(cases)
    perfect = score_evaluations(cases, evaluations)
    @test perfect.selective_risk == 0.0
    @test perfect.answerable_recall == 1.0
    @test perfect.impossibility_recall == 1.0
    @test perfect.exact_status_accuracy == 1.0
    @test passes_primary_targets(perfect)

    unique_index = findfirst(case -> case.truth_class == UniqueAnswerable, cases)
    corrupted = copy(evaluations)
    original = corrupted[unique_index]
    corrupted[unique_index] = CaseEvaluation(
        original.cell_id,
        original.family,
        original.scenario,
        original.truth_class,
        original.status,
        original.answer .+ 1.0,
        original.target,
        original.tolerance,
        original.witnesses,
    )
    damaged = score_evaluations(cases, corrupted)
    @test damaged.selective_risk > 0
    @test damaged.answerable_recall < 1
    @test !passes_primary_targets(damaged)

    impossible_index = findfirst(case -> case.truth_class == EquivalenceOnly, cases)
    false_answer = copy(evaluations)
    original_impossible = false_answer[impossible_index]
    false_answer[impossible_index] = CaseEvaluation(
        original_impossible.cell_id,
        original_impossible.family,
        original_impossible.scenario,
        original_impossible.truth_class,
        Answer,
        [0.0],
        [0.0],
        original_impossible.tolerance,
        String[],
    )
    unsafe = score_evaluations(cases, false_answer)
    @test unsafe.selective_risk > 0
    @test unsafe.impossibility_recall < 1
end

@testset "empty denominators remain null" begin
    cases = [case for case in generate_cases(:train, 10)
             if case.truth_class == NumericallyUnresolved]
    evaluations = evaluate_case.(cases)
    summary = score_evaluations(cases, evaluations)
    @test isnothing(summary.selective_risk)
    @test isnothing(summary.answerable_recall)
    @test isnothing(summary.impossibility_recall)
    @test !passes_primary_targets(summary)
end
