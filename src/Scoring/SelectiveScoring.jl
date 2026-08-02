module SelectiveScoring

using ..CoreTypes
using ..AdversarialCases

export ScoreSummary,
       score_evaluations,
       passes_primary_targets,
       evaluation_is_correct

"""Selective-prediction counts and metrics without empty-denominator inflation."""
struct ScoreSummary
    cell_count::Int
    answer_outputs::Int
    incorrect_answer_outputs::Int
    unique_answerable_cells::Int
    correct_unique_answers::Int
    impossibility_cells::Int
    safe_impossibility_outputs::Int
    exact_status_matches::Int
    selective_risk::Union{Nothing,Float64}
    answerable_recall::Union{Nothing,Float64}
    impossibility_recall::Union{Nothing,Float64}
    exact_status_accuracy::Union{Nothing,Float64}
end

function _ratio(numerator::Int, denominator::Int)
    denominator == 0 && return nothing
    return numerator / denominator
end

"""Check both status and numeric answer under the case-local tolerance."""
function evaluation_is_correct(case::AdversarialCase, evaluation::CaseEvaluation)
    evaluation.cell_id == case.cell_id || return false
    evaluation.status == expected_status(case) || return false
    if case.truth_class == UniqueAnswerable
        return maximum_error(evaluation) <= case.tolerance
    end
    return evaluation.status != Answer
end

"""Compute preregistered selective-risk and recall metrics."""
function score_evaluations(
    cases::AbstractVector{AdversarialCase},
    evaluations::AbstractVector{CaseEvaluation},
)
    length(cases) == length(evaluations) || throw(DimensionMismatch("case/result counts differ"))
    cell_count = length(cases)
    answer_outputs = 0
    incorrect_answer_outputs = 0
    unique_answerable_cells = 0
    correct_unique_answers = 0
    impossibility_cells = 0
    safe_impossibility_outputs = 0
    exact_status_matches = 0

    for (case, evaluation) in zip(cases, evaluations)
        case.cell_id == evaluation.cell_id || throw(ArgumentError("case/result order mismatch"))
        is_unique = case.truth_class == UniqueAnswerable
        is_impossibility = case.truth_class in (
            EquivalenceOnly,
            ObservationInsufficient,
            OutOfDomainTruth,
        )
        evaluation.status == Answer && (answer_outputs += 1)
        if evaluation.status == Answer &&
           (!is_unique || maximum_error(evaluation) > case.tolerance)
            incorrect_answer_outputs += 1
        end
        if is_unique
            unique_answerable_cells += 1
            evaluation_is_correct(case, evaluation) && (correct_unique_answers += 1)
        end
        if is_impossibility
            impossibility_cells += 1
            evaluation.status != Answer && (safe_impossibility_outputs += 1)
        end
        evaluation.status == expected_status(case) && (exact_status_matches += 1)
    end

    return ScoreSummary(
        cell_count,
        answer_outputs,
        incorrect_answer_outputs,
        unique_answerable_cells,
        correct_unique_answers,
        impossibility_cells,
        safe_impossibility_outputs,
        exact_status_matches,
        _ratio(incorrect_answer_outputs, answer_outputs),
        _ratio(correct_unique_answers, unique_answerable_cells),
        _ratio(safe_impossibility_outputs, impossibility_cells),
        _ratio(exact_status_matches, cell_count),
    )
end

"""Primary gates registered in `docs/replication_plan.md`."""
function passes_primary_targets(summary::ScoreSummary)
    return !isnothing(summary.selective_risk) && summary.selective_risk == 0.0 &&
           !isnothing(summary.answerable_recall) && summary.answerable_recall >= 0.9 &&
           !isnothing(summary.impossibility_recall) && summary.impossibility_recall == 1.0
end

end
