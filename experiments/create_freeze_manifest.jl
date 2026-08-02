using QRNReplication.FreezeProtocol

length(ARGS) == 1 || error("usage: create_freeze_manifest.jl FREEZE_COMMIT")
const PROJECT_ROOT = normpath(joinpath(@__DIR__, ".."))
manifest = write_freeze_manifest(PROJECT_ROOT, only(ARGS))
println("freeze_commit=", manifest["freeze_commit"])
println("file_count=", manifest["file_count"])
println("manifest_payload_sha256=", manifest["manifest_payload_sha256"])
