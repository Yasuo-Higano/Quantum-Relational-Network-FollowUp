# QRNReplication

This repository is a Julia clean-room implementation for independently testing
the supplied Quantum Relational Network paper claims. It does not port or
consult the original implementation or its results.

Current status: **Complete.** The frozen fresh holdout (`phase7-holdout-v1`,
120 cells) was generated and opened exactly once on 2026-08-02 under the
Phase 6 freeze (commit `5557eb9`), with all registered safety targets met
(selective risk 0, answerable recall 1, impossibility recall 1; cell verdicts:
77 Answer / 12 EquivalenceClassOnly / 11 InsufficientObservation /
10 OutOfDomain / 10 Abstain). The final verdict on the supplied paper set is
**Partially Replicated** — see `reports/final_report.md` (summary),
`reports/machine_report.json` (machine-readable), and `docs/derivations.md`
(independent derivations, including the exact integer counterexample to the
bare prime-Pfaffian inference, YUK-005). This is a cross-model clean-room
replication with a shared human operator; it is not an organizationally
external replication. The holdout is consumed: the one-use runner must not be
re-run against a new target without a new preregistered freeze.

## Requirements

- Julia 1.12 (the recorded Phase 3 environment used Julia 1.12.6 on macOS
  aarch64)
- No external Julia packages beyond standard-library dependencies at this stage

## Reproduce the current suite

```bash
julia --project=. -e 'using Pkg; Pkg.instantiate()'
julia --project=. test/runtests.jl
```

The package-manager test entry point is equivalent:

```bash
julia --project=. -e 'using Pkg; Pkg.test()'
```

After inspecting the freeze record, the one-use holdout entry point was
(already consumed on 2026-08-02 — the runner fails closed on the existing
output; kept for audit replay of the freeze verification only):

```bash
julia --project=. experiments/verify_freeze.jl
julia --project=. experiments/run_holdout.jl
```

The holdout command refuses to run if a frozen target changed, the secret does
not match its pre-freeze commitment, or the named output already exists.

The scientific scope, independent derivations, ambiguities, and numerical
checks are documented in:

- `docs/claim_inventory.md`
- `docs/ambiguities.md`
- `docs/replication_plan.md`
- `docs/derivations.md`
- `docs/numerical_methods.md`
- `docs/phase4_adversarial_design.md`
- `docs/phase5_train_validation.md`
- `docs/phase6_freeze.md`

Do not generate a holdout before the Phase 6 freeze procedure in the
replication plan. The future holdout runner must fail closed unless the freeze
manifest and secret commitment are valid.
