module CanonicalJSON

export canonical_json,
       write_json_file

function _escape_json(value::AbstractString)
    return replace(
        String(value),
        '\\' => "\\\\",
        '"' => "\\\"",
        '\b' => "\\b",
        '\f' => "\\f",
        '\n' => "\\n",
        '\r' => "\\r",
        '\t' => "\\t",
    )
end

function canonical_json(value)
    value === nothing && return "null"
    value isa Bool && return value ? "true" : "false"
    value isa Integer && return string(value)
    value isa AbstractFloat && begin
        isfinite(value) || throw(ArgumentError("JSON numbers must be finite"))
        return string(value)
    end
    value isa AbstractString && return "\"$(_escape_json(value))\""
    value isa Symbol && return canonical_json(String(value))
    value isa AbstractVector && return "[" * join(canonical_json.(value), ",") * "]"
    value isa Tuple && return canonical_json(collect(value))
    if value isa AbstractDict
        keys_sorted = sort!(collect(keys(value)); by = string)
        entries = [canonical_json(string(key)) * ":" * canonical_json(value[key])
                   for key in keys_sorted]
        return "{" * join(entries, ",") * "}"
    end
    throw(ArgumentError("unsupported canonical JSON value of type $(typeof(value))"))
end

"""Write canonical compact JSON followed by one newline, refusing overwrite by default."""
function write_json_file(path::AbstractString, value; overwrite::Bool = false)
    !overwrite && ispath(path) && throw(ArgumentError("JSON output already exists: $path"))
    mkpath(dirname(path))
    open(path, "w") do io
        println(io, canonical_json(value))
    end
    return path
end

end
