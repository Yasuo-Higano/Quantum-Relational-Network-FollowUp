using Test
using SHA
using TOML
using QRNReplication.CanonicalJSON
using QRNReplication.FreezeProtocol

@testset "canonical JSON and streaming hashes" begin
    @test canonical_json(Dict("b" => 2, "a" => [true, nothing, "x"])) ==
          "{\"a\":[true,null,\"x\"],\"b\":2}"
    mktempdir() do directory
        path = joinpath(directory, "sample.txt")
        open(path, "w") do io
            write(io, "clean-room")
        end
        @test sha256_file(path) == bytes2hex(sha256("clean-room"))
    end
end

@testset "freeze manifest detects mutation" begin
    mktempdir() do root
        mkpath(joinpath(root, "src"))
        mkpath(joinpath(root, "reports"))
        open(joinpath(root, "Project.toml"), "w") do io
            write(io, "name = \"Tiny\"\n")
        end
        open(joinpath(root, "src", "Tiny.jl"), "w") do io
            write(io, "module Tiny\nend\n")
        end
        manifest = write_freeze_manifest(root, "0123456789abcdef")
        @test manifest["file_count"] == 2
        @test verify_freeze_manifest(root)["manifest_payload_sha256"] ==
              manifest["manifest_payload_sha256"]
        open(joinpath(root, "src", "Tiny.jl"), "a") do io
            write(io, "# mutation\n")
        end
        @test_throws ArgumentError verify_freeze_manifest(root)
    end
end
