# QRNReplication

This repository is a Julia clean-room implementation for independently testing
the supplied Quantum Relational Network paper claims. It does not port or
consult the original implementation or its results.

Current status: Phase 5 (train and one-use validation) is complete. Freeze,
fresh holdout, and the final replication verdict have not been run.

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

The scientific scope, independent derivations, ambiguities, and numerical
checks are documented in:

- `docs/claim_inventory.md`
- `docs/ambiguities.md`
- `docs/replication_plan.md`
- `docs/derivations.md`
- `docs/numerical_methods.md`
- `docs/phase4_adversarial_design.md`
- `docs/phase5_train_validation.md`

Do not generate a holdout before the Phase 6 freeze procedure in the
replication plan. The future holdout runner must fail closed unless the freeze
manifest and secret commitment are valid.
