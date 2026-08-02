module ExperimentIO

using Dates
using TOML
using ..AdversarialCases
using ..SelectiveScoring

export execute_public_experiment,
       write_experiment_artifacts

function _metric_value(value::Union{Nothing,Float64})
    return isnothing(value) ? "null" : value
end

function _summary_dictionary(
    experiment_id::AbstractString,
    split::Symbol,
    schema::AbstractString,
    source_commit::AbstractString,
    summary::ScoreSummary,
)
    return Dict(
        "experiment_id" => String(experiment_id),
        "split" => String(split),
        "schema" => String(schema),
        "source_commit" => String(source_commit),
        "executed_at_utc" => Dates.format(now(UTC), dateformat"yyyy-mm-ddTHH:MM:SS.sssZ"),
        "cell_count" => summary.cell_count,
        "answer_outputs" => summary.answer_outputs,
        "incorrect_answer_outputs" => summary.incorrect_answer_outputs,
        "unique_answerable_cells" => summary.unique_answerable_cells,
        "correct_unique_answers" => summary.correct_unique_answers,
        "impossibility_cells" => summary.impossibility_cells,
        "safe_impossibility_outputs" => summary.safe_impossibility_outputs,
        "exact_status_matches" => summary.exact_status_matches,
        "selective_risk" => _metric_value(summary.selective_risk),
        "answerable_recall" => _metric_value(summary.answerable_recall),
        "impossibility_recall" => _metric_value(summary.impossibility_recall),
        "exact_status_accuracy" => _metric_value(summary.exact_status_accuracy),
        "passes_primary_targets" => passes_primary_targets(summary),
    )
end

"""Write raw tabular records and a TOML summary; existing outputs are never overwritten."""
function write_experiment_artifacts(
    output_directory::AbstractString,
    experiment_id::AbstractString,
    split::Symbol,
    schema::AbstractString,
    source_commit::AbstractString,
    cases::AbstractVector{AdversarialCase},
    evaluations::AbstractVector{CaseEvaluation},
    summary::ScoreSummary,
)
    mkpath(output_directory)
    raw_path = joinpath(output_directory, "$(experiment_id)_cells.tsv")
    summary_path = joinpath(output_directory, "$(experiment_id)_summary.toml")
    (ispath(raw_path) || ispath(summary_path)) &&
        throw(ArgumentError("experiment output already exists"))
    open(raw_path, "w") do io
        println(io, join((
            "cell_id", "family", "scenario", "seed", "truth_class",
            "output_status", "max_error", "tolerance", "correct",
        ), '\t'))
        for (case, evaluation) in zip(cases, evaluations)
            println(io, join((
                case.cell_id,
                String(case.family),
                String(case.scenario),
                string(case.seed),
                string(case.truth_class),
                string(evaluation.status),
                string(maximum_error(evaluation)),
                string(case.tolerance),
                string(evaluation_is_correct(case, evaluation)),
            ), '\t'))
        end
    end
    open(summary_path, "w") do io
        TOML.print(io, _summary_dictionary(
            experiment_id,
            split,
            schema,
            source_commit,
            summary,
        ); sorted = true)
    end
    return raw_path, summary_path
end

"""Generate, evaluate, score, and persist a public train or validation split."""
function execute_public_experiment(
    split::Symbol,
    count_per_family::Int,
    experiment_id::AbstractString,
    output_directory::AbstractString;
    schema::AbstractString = "phase4-v1",
    source_commit::AbstractString,
)
    split in (:train, :validation) ||
        throw(ArgumentError("public experiment supports only train or validation"))
    cases = generate_cases(split, count_per_family; schema = schema)
    evaluations = evaluate_case.(cases)
    summary = score_evaluations(cases, evaluations)
    paths = write_experiment_artifacts(
        output_directory,
        experiment_id,
        split,
        schema,
        source_commit,
        cases,
        evaluations,
        summary,
    )
    return summary, paths
end

end
