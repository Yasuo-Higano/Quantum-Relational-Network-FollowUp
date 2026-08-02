using QRNReplication.FreezeProtocol

const PROJECT_ROOT = normpath(joinpath(@__DIR__, ".."))

environment_path = write_environment_report(PROJECT_ROOT)
commitment = prepare_secret_commitment(PROJECT_ROOT)
println("environment report: ", environment_path)
println("holdout secret commitment: ", commitment)
println("secret value withheld in ignored local storage")
