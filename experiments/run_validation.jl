using TOML
using QRNReplication.ExperimentIO

const PROJECT_ROOT = normpath(joinpath(@__DIR__, ".."))
const REGISTRATION_PATH = joinpath(@__DIR__, "validation", "registration.toml")
const REGISTRATION = TOML.parsefile(REGISTRATION_PATH)
const SOURCE_COMMIT = readchomp(`git -C $PROJECT_ROOT rev-parse HEAD`)

summary, paths = execute_public_experiment(
    :validation,
    REGISTRATION["count_per_family"],
    REGISTRATION["experiment_id"],
    joinpath(@__DIR__, "validation");
    schema = REGISTRATION["schema"],
    source_commit = SOURCE_COMMIT,
)

println("validation summary: ", last(paths))
println("selective_risk=", summary.selective_risk)
println("answerable_recall=", summary.answerable_recall)
println("impossibility_recall=", summary.impossibility_recall)
summary.selective_risk == REGISTRATION["targets"]["selective_risk"] || exit(2)
summary.answerable_recall >= REGISTRATION["targets"]["minimum_answerable_recall"] || exit(2)
summary.impossibility_recall == REGISTRATION["targets"]["impossibility_recall"] || exit(2)
