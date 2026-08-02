using QRNReplication.FreezeProtocol

const PROJECT_ROOT = normpath(joinpath(@__DIR__, ".."))
manifest = verify_freeze_manifest(PROJECT_ROOT)
println("verified freeze commit ", manifest["freeze_commit"])
println("verified ", manifest["file_count"], " files")
println("manifest_payload_sha256=", manifest["manifest_payload_sha256"])
