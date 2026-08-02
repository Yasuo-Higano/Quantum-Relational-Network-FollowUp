# Phase 6 freeze record

Status: completed 2026-08-02; authoritative commit and digest are stored in the
machine-readable freeze manifest.

## 1. Frozen experiment

```text
experiment_id: phase7-holdout-v1
generator_schema: phase4-v1
scorer_schema: phase5-selective-v1
holdout cells: 24 per family, 120 total
default numeric tolerance: 2e-10
weak-signal tolerance: 2e-12
selective risk target: 0
answerable recall target: >= 0.9
impossibility recall target: 1
```

The fail-closed precedence is `OutOfDomain`, `InsufficientObservation`,
`EquivalenceClassOnly`, `Abstain`, then `Answer`. Local-unitary and node
permutation invariant finite signatures define the scored equivalence contract.

## 2. Environment verification

The complete suite passed 253 of 253 assertions under Julia 1.12.6. It was then
instantiated and tested successfully using a newly created empty Julia depot,
without relying on packages cached by the development depot. The dependency
manifest contains standard-library and Julia-distributed binary dependencies
only.

The machine report fixes macOS/Darwin aarch64, Apple M4 Pro, 64 GiB memory,
Julia compute thread count one, GC thread count one, and ILP64 OpenBLAS with ten
BLAS threads. Exact values and Julia/LLVM commits are in
`reports/environment.json`.

## 3. Secret commitment

A 256-bit secret was drawn from Julia `RandomDevice`. Before the freeze, the
secret value was withheld from the implementation model and stored only in an
ignored mode-`0600` local file. The published commitment is:

```text
SHA256(secret) = 53527a3c56e9fcf1b4c1c2df2e6d7cffd6a34e6748b5b50aaa3a07796dcf57a1
```

This is agent-opaque local generation, not a human-supplied external secret.
The final independence statement must preserve that distinction. The secret is
revealed into the opening log only after manifest verification in Phase 7.

## 4. Manifest construction

The first Phase 6 commit freezes source, tests, generator/scorer, runners,
Project/Manifest, registered documentation, train/validation outputs,
environment, commitment, and rules. A second report-only commit stores JSON and
TOML views of a sorted path-to-SHA-256 mapping tied to that freeze commit.

The canonical payload consists of the freeze commit line followed by sorted
`path<TAB>sha256` lines. Its SHA-256 is stored as
`manifest_payload_sha256`. The manifest files are excluded from their own
target set, removing self-reference ambiguity.

## 5. Holdout gate

Before deriving any holdout seed, the runner:

1. verifies the canonical manifest payload;
2. verifies every frozen target file hash;
3. hashes the locally stored secret and compares the published commitment;
4. refuses to overwrite any existing holdout opening log or result;
5. derives each seed from secret, experiment ID, and cell ID;
6. records the revealed secret, commitment check, freeze commit, manifest
   digest, every cell seed, timestamp, raw output path, and score.

Any code defect discovered after opening is preserved as a failure for this
experiment ID. A correction requires a new freeze and fresh secret.
