using QRNReplication.HoldoutProtocol

const PROJECT_ROOT = normpath(joinpath(@__DIR__, ".."))
summary, paths, opening_log = execute_fresh_holdout(PROJECT_ROOT)
println("holdout summary: ", last(paths))
println("opening log: ", opening_log)
println("selective_risk=", summary.selective_risk)
println("answerable_recall=", summary.answerable_recall)
println("impossibility_recall=", summary.impossibility_recall)
