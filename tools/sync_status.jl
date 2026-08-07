#!/usr/bin/env julia
# Status display generator (governance tooling — no scientific content).
#
# FINAL_STATUS.json is the single machine-readable source of truth for the
# repository status. This script regenerates the marked status blocks in
#   README.md, docs/replication_plan.md, reports/final_report.md
# from that file. The preregistered plan body and the scientific content of
# the final report are never touched — only the blocks between the markers.
#
# Usage:
#   julia tools/sync_status.jl           # rewrite generated blocks in place
#   julia tools/sync_status.jl --check   # verify blocks match; exit 1 on drift
#
# Standard library only (consistent with the clean-room toolchain policy).

const ROOT = normpath(joinpath(@__DIR__, ".."))
const STATUS_FILE = joinpath(ROOT, "FINAL_STATUS.json")
const MARK_BEGIN = "<!-- STATUS:BEGIN (generated from FINAL_STATUS.json; edit that file and run tools/sync_status.jl) -->"
const MARK_END = "<!-- STATUS:END -->"

# --- minimal flat JSON field reader (FINAL_STATUS.json is flat and controlled) ---
function jfield(text::String, key::String)
    m = match(Regex("\"" * key * "\"\\s*:\\s*\"([^\"]*)\""), text)
    m !== nothing && return String(m.captures[1])
    m = match(Regex("\"" * key * "\"\\s*:\\s*(-?[0-9.eE+]+|true|false)"), text)
    m !== nothing && return String(m.captures[1])
    error("FINAL_STATUS.json: key not found: " * key)
end

function build_blocks()
    t = read(STATUS_FILE, String)
    verdict = jfield(t, "final_verdict")
    date = jfield(t, "completion_date")
    freeze = jfield(t, "freeze_commit")
    freeze_short = freeze[1:7]
    hid = jfield(t, "holdout_experiment_id")
    cells = jfield(t, "holdout_cells")
    va = jfield(t, "verdict_answer")
    ve = jfield(t, "verdict_equivalence_class_only")
    vi = jfield(t, "verdict_insufficient_observation")
    vo = jfield(t, "verdict_out_of_domain")
    vb = jfield(t, "verdict_abstain")
    sr = jfield(t, "selective_risk")
    ar = jfield(t, "answerable_recall")
    ir = jfield(t, "impossibility_recall")

    readme_block = """
Current status: **Complete.** The frozen fresh holdout (`$hid`,
$cells cells) was generated and opened exactly once on $date under the
Phase 6 freeze (commit `$freeze_short`), with all registered safety targets met
(selective risk $sr, answerable recall $ar, impossibility recall $ir; cell verdicts:
$va Answer / $ve EquivalenceClassOnly / $vi InsufficientObservation /
$vo OutOfDomain / $vb Abstain). The final verdict on the supplied paper set is
**$verdict** — see `reports/final_report.md` (summary),
`reports/machine_report.json` (machine-readable), and `docs/derivations.md`
(independent derivations, including the exact integer counterexample to the
bare prime-Pfaffian inference, YUK-005). This is a cross-model clean-room
replication with a shared human operator; it is not an organizationally
external replication. The holdout is consumed: the one-use runner must not be
re-run against a new target without a new preregistered freeze."""

    plan_block = """
Status: all phases complete — Phase 7 holdout opened once (consumed) and the
Phase 8 final report published on $date; final verdict: **$verdict**.
This header is generated from `FINAL_STATUS.json`. The plan body below is the
preregistered working plan and is preserved unmodified (its own phase-local
wording reflects the time of preregistration)."""

    report_block = """
Final verdict: **$verdict**
Completion date: $date
Freeze commit: `$freeze`
Fresh holdout: `$hid`, opened once"""

    return [
        (joinpath(ROOT, "README.md"), readme_block),
        (joinpath(ROOT, "docs", "replication_plan.md"), plan_block),
        (joinpath(ROOT, "reports", "final_report.md"), report_block),
    ]
end

function sync(path::String, block::String; check::Bool)
    text = read(path, String)
    i = findfirst(MARK_BEGIN, text)
    j = findfirst(MARK_END, text)
    (i === nothing || j === nothing) && error(path * ": status markers not found")
    current = text[first(i):last(j)]
    wanted = MARK_BEGIN * "\n" * block * "\n" * MARK_END
    if current == wanted
        println(basename(path) * ": up to date")
        return true
    elseif check
        println(stderr, basename(path) * ": status block OUT OF SYNC with FINAL_STATUS.json")
        return false
    else
        write(path, replace(text, current => wanted))
        println(basename(path) * ": updated")
        return true
    end
end

function main()
    check = "--check" in ARGS
    ok = true
    for (path, block) in build_blocks()
        ok &= sync(path, block; check = check)
    end
    if check && !ok
        exit(1)
    end
end

main()
