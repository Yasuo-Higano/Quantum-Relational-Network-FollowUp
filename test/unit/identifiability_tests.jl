using Test
using QRNReplication.CoreTypes
using QRNReplication.DecisionRules

@testset "fail-closed identifiability precedence" begin
    @test decision_status(
        in_domain = false,
        observation_complete = false,
        equivalence_size = 3,
        numerically_resolved = false,
    ) == OutOfDomain
    @test decision_status(
        in_domain = true,
        observation_complete = false,
        equivalence_size = 3,
        numerically_resolved = false,
    ) == InsufficientObservation
    @test decision_status(
        in_domain = true,
        observation_complete = true,
        equivalence_size = 3,
        numerically_resolved = false,
    ) == EquivalenceClassOnly
    @test decision_status(
        in_domain = true,
        observation_complete = true,
        equivalence_size = 1,
        numerically_resolved = false,
    ) == Abstain
    @test decision_status(
        in_domain = true,
        observation_complete = true,
        equivalence_size = 1,
        numerically_resolved = true,
    ) == Answer

    answer = unique_answer_result("factor class A")
    @test answer.status == Answer
    @test answer.answer == "factor class A"
    class_only = equivalence_class_result(
        "local-unitary orbit";
        witnesses = ["basis-1", "basis-2"],
    )
    @test class_only.status == EquivalenceClassOnly
    @test class_only.reason == MultipleEquivalentModels
    refused = nonanswer_result(
        InsufficientObservation,
        MissingObservation;
        witnesses = ["model-1", "model-2"],
    )
    @test refused.status == InsufficientObservation
    @test length(refused.witnesses) == 2
end
