module FreezeProtocol

using Dates
using LinearAlgebra
using Random
using SHA
using TOML
using ..CanonicalJSON: write_json_file

export sha256_file,
       freeze_target_paths,
       prepare_secret_commitment,
       write_environment_report,
       write_freeze_manifest,
       verify_freeze_manifest

"""Streaming SHA-256 of one file, returned as lowercase hexadecimal."""
function sha256_file(path::AbstractString)
    isfile(path) || throw(ArgumentError("not a file: $path"))
    return open(path, "r") do io
        bytes2hex(sha256(io))
    end
end

function _files_under(root::AbstractString, relative_directory::AbstractString)
    directory = joinpath(root, relative_directory)
    isdir(directory) || return String[]
    paths = String[]
    for (current, directories, files) in walkdir(directory)
        filter!(name -> name != ".git" && name != ".secrets", directories)
        for file in files
            push!(paths, relpath(joinpath(current, file), root))
        end
    end
    return paths
end

"""Explicit reproducibility target set frozen before holdout generation."""
function freeze_target_paths(root::AbstractString)
    paths = String[]
    for file in (".gitignore", "Project.toml", "Manifest.toml", "README.md")
        isfile(joinpath(root, file)) && push!(paths, file)
    end
    append!(paths, _files_under(root, "src"))
    append!(paths, _files_under(root, "test"))
    append!(paths, _files_under(root, "docs"))
    append!(paths, _files_under(root, "experiments/train"))
    append!(paths, _files_under(root, "experiments/validation"))
    for file in (
        "experiments/run_train.jl",
        "experiments/run_validation.jl",
        "experiments/run_holdout.jl",
        "experiments/prepare_freeze.jl",
        "experiments/create_freeze_manifest.jl",
        "experiments/verify_freeze.jl",
        "reports/environment.json",
        "reports/frozen_rules.toml",
        "reports/holdout_secret_commitment.json",
        "reports/holdout_secret_commitment.txt",
    )
        isfile(joinpath(root, file)) && push!(paths, file)
    end
    return sort!(unique!(paths))
end

"""Create an agent-opaque local secret and publish only its SHA-256 commitment."""
function prepare_secret_commitment(root::AbstractString)
    secret_directory = joinpath(root, ".secrets")
    secret_path = joinpath(secret_directory, "phase7_holdout_secret.txt")
    commitment_text_path = joinpath(root, "reports", "holdout_secret_commitment.txt")
    commitment_json_path = joinpath(root, "reports", "holdout_secret_commitment.json")
    any(ispath, (secret_path, commitment_text_path, commitment_json_path)) &&
        throw(ArgumentError("secret or commitment already exists"))
    mkpath(secret_directory)
    secret = bytes2hex(rand(RandomDevice(), UInt8, 32))
    open(secret_path, "w") do io
        println(io, secret)
    end
    chmod(secret_path, 0o600)
    commitment = bytes2hex(sha256(secret))
    mkpath(joinpath(root, "reports"))
    open(commitment_text_path, "w") do io
        println(io, commitment)
    end
    write_json_file(commitment_json_path, Dict(
        "algorithm" => "SHA-256",
        "commitment" => commitment,
        "created_at_utc" => Dates.format(now(UTC), dateformat"yyyy-mm-ddTHH:MM:SS.sssZ"),
        "secret_bits" => 256,
        "secret_source" => "Julia RandomDevice; value withheld from implementation model before freeze",
    ))
    return commitment
end

"""Record the numerical execution environment without external dependencies."""
function write_environment_report(root::AbstractString)
    cpu = first(Sys.cpu_info())
    report = Dict(
        "recorded_at_utc" => Dates.format(now(UTC), dateformat"yyyy-mm-ddTHH:MM:SS.sssZ"),
        "julia_version" => string(VERSION),
        "julia_commit" => string(Base.GIT_VERSION_INFO.commit),
        "llvm_version" => string(Base.libllvm_version),
        "kernel" => string(Sys.KERNEL),
        "architecture" => string(Sys.ARCH),
        "word_size" => Sys.WORD_SIZE,
        "cpu_model" => cpu.model,
        "cpu_threads" => Sys.CPU_THREADS,
        "total_memory_bytes" => Sys.total_memory(),
        "julia_threads" => Threads.nthreads(),
        "gc_threads" => Threads.ngcthreads(),
        "blas_threads" => BLAS.get_num_threads(),
        "blas_configuration" => sprint(show, BLAS.get_config()),
        "language" => "Julia",
        "original_source_access" => false,
        "original_results_access_during_implementation" => false,
    )
    return write_json_file(joinpath(root, "reports", "environment.json"), report)
end

function _manifest_payload(freeze_commit::AbstractString, entries)
    lines = ["freeze_commit\t$(freeze_commit)"]
    append!(lines, ["$(entry["path"])\t$(entry["sha256"])" for entry in entries])
    return join(lines, "\n") * "\n"
end

"""Write TOML and JSON views of a self-unambiguous hash manifest."""
function write_freeze_manifest(root::AbstractString, freeze_commit::AbstractString)
    isempty(freeze_commit) && throw(ArgumentError("freeze_commit must not be empty"))
    paths = freeze_target_paths(root)
    isempty(paths) && throw(ArgumentError("freeze target set is empty"))
    entries = [Dict(
        "path" => path,
        "sha256" => sha256_file(joinpath(root, path)),
    ) for path in paths]
    payload_sha256 = bytes2hex(sha256(_manifest_payload(freeze_commit, entries)))
    manifest = Dict(
        "schema" => "phase6-freeze-v1",
        "freeze_commit" => String(freeze_commit),
        "manifest_payload_sha256" => payload_sha256,
        "file_count" => length(entries),
        "files" => entries,
    )
    toml_path = joinpath(root, "reports", "freeze_manifest.toml")
    json_path = joinpath(root, "reports", "freeze_manifest.json")
    any(ispath, (toml_path, json_path)) && throw(ArgumentError("freeze manifest exists"))
    open(toml_path, "w") do io
        TOML.print(io, manifest; sorted = true)
    end
    write_json_file(json_path, manifest)
    return manifest
end

"""Verify payload digest and every frozen path against the working tree."""
function verify_freeze_manifest(root::AbstractString)
    manifest_path = joinpath(root, "reports", "freeze_manifest.toml")
    isfile(manifest_path) || throw(ArgumentError("freeze manifest is absent"))
    manifest = TOML.parsefile(manifest_path)
    entries = manifest["files"]
    payload = _manifest_payload(manifest["freeze_commit"], entries)
    bytes2hex(sha256(payload)) == manifest["manifest_payload_sha256"] ||
        throw(ArgumentError("freeze manifest payload digest mismatch"))
    for entry in entries
        path = joinpath(root, entry["path"])
        isfile(path) || throw(ArgumentError("frozen file is missing: $(entry["path"])"))
        sha256_file(path) == entry["sha256"] ||
            throw(ArgumentError("frozen file changed: $(entry["path"])"))
    end
    return manifest
end

end
