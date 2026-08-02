using QRNReplication.ExperimentIO

const PROJECT_ROOT = normpath(joinpath(@__DIR__, ".."))
const SOURCE_COMMIT = readchomp(`git -C $PROJECT_ROOT rev-parse HEAD`)

summary, paths = execute_public_experiment(
    :train,
    20,
    "phase5-train-v1",
    joinpath(@__DIR__, "train");
    schema = "phase4-v1",
    source_commit = SOURCE_COMMIT,
)

println("train summary: ", last(paths))
println("selective_risk=", summary.selective_risk)
println("answerable_recall=", summary.answerable_recall)
println("impossibility_recall=", summary.impossibility_recall)
