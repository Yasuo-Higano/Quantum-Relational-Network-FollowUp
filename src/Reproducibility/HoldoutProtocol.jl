module HoldoutProtocol

using Dates
using SHA
using ..AdversarialCases
using ..CanonicalJSON: write_json_file
using ..ExperimentIO: write_experiment_artifacts
using ..FreezeProtocol: sha256_file, verify_freeze_manifest
using ..SelectiveScoring: score_evaluations, passes_primary_targets

export execute_fresh_holdout

function _score_dictionary(summary)
    return Dict(
        "cell_count" => summary.cell_count,
        "selective_risk" => summary.selective_risk,
        "answerable_recall" => summary.answerable_recall,
        "impossibility_recall" => summary.impossibility_recall,
        "exact_status_accuracy" => summary.exact_status_accuracy,
        "passes_primary_targets" => passes_primary_targets(summary),
    )
end

"""Verify freeze and commitment, then generate and score the holdout exactly once."""
function execute_fresh_holdout(
    root::AbstractString;
    experiment_id::AbstractString = "phase7-holdout-v1",
    count_per_family::Int = 24,
    secret_path::AbstractString = joinpath(root, ".secrets", "phase7_holdout_secret.txt"),
)
    output_directory = joinpath(root, "experiments", "holdout")
    opening_log_path = joinpath(output_directory, "$(experiment_id)_opening_log.json")
    ispath(opening_log_path) && throw(ArgumentError("holdout was already opened"))
    manifest = verify_freeze_manifest(root)
    isfile(secret_path) || throw(ArgumentError("holdout secret is absent"))
    secret = strip(read(secret_path, String))
    commitment_path = joinpath(root, "reports", "holdout_secret_commitment.txt")
    commitment = strip(read(commitment_path, String))
    observed_commitment = bytes2hex(sha256(secret))
    observed_commitment == commitment || throw(ArgumentError("secret commitment mismatch"))

    cases = generate_cases(
        :holdout,
        count_per_family;
        experiment_id = experiment_id,
        secret = secret,
    )
    evaluations = evaluate_case.(cases)
    summary = score_evaluations(cases, evaluations)
    paths = write_experiment_artifacts(
        output_directory,
        experiment_id,
        :holdout,
        "phase4-v1",
        manifest["freeze_commit"],
        cases,
        evaluations,
        summary,
    )

    opening_log = Dict(
        "experiment_id" => String(experiment_id),
        "opened_at_utc" => Dates.format(now(UTC), dateformat"yyyy-mm-ddTHH:MM:SS.sssZ"),
        "secret" => secret,
        "secret_commitment" => commitment,
        "commitment_verified" => true,
        "freeze_commit" => manifest["freeze_commit"],
        "manifest_payload_sha256" => manifest["manifest_payload_sha256"],
        "freeze_manifest_file_sha256" => sha256_file(
            joinpath(root, "reports", "freeze_manifest.json"),
        ),
        "raw_output_path" => relpath(first(paths), root),
        "summary_path" => relpath(last(paths), root),
        "cell_seeds" => [Dict("cell_id" => case.cell_id, "seed" => string(case.seed))
                         for case in cases],
        "score" => _score_dictionary(summary),
    )
    write_json_file(opening_log_path, opening_log)
    return summary, paths, opening_log_path
end

end
