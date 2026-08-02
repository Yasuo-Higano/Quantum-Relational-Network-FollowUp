# Phase 7 fresh holdout record

Status: completed once on 2026-08-02

## 1. Opening verification

The runner verified the 64-file freeze manifest tied to commit
`5557eb9cd35286ecb5cbb86db307068683966618`. The locally withheld secret hashed
to the preregistered commitment
`53527a3c56e9fcf1b4c1c2df2e6d7cffd6a34e6748b5b50aaa3a07796dcf57a1`.
Only after both checks did the runner derive seeds for
`phase7-holdout-v1`.

The opening log records the revealed secret, commitment verification, freeze
commit, canonical manifest digest, manifest-file hash, UTC time, all 120 cell
seeds, raw output path, summary path, and score. The secret was locally
agent-opaque before freeze, but was not supplied by an external human; this
qualification remains part of the final independence statement.

## 2. Results

The holdout contained 24 cells in each of five families:

| Output | Count |
|---|---:|
| `Answer` | 77 |
| `EquivalenceClassOnly` | 12 |
| `InsufficientObservation` | 11 |
| `OutOfDomain` | 10 |
| `Abstain` | 10 |
| Total | 120 |

Primary metrics:

| Metric | Target | Result |
|---|---:|---:|
| Selective risk | 0 | 0 |
| Answerable recall | at least 0.9 | 1 |
| Impossibility recall | 1 | 1 |
| Exact status accuracy | diagnostic | 1 |

All 77 uniquely answerable cells were answered correctly. All 33 equivalence,
missing-observation, and out-of-domain cells received a safe non-answer. Ten
uncertainty-boundary cells abstained. Maximum numeric answer error was about
`2.78e-16`, below the frozen weak-signal tolerance `2e-12`.

## 3. Artifact integrity

```text
cells.tsv SHA-256:
82348cdeb6cf1daf9982b9d4b40fb59743dec0d09de6c1b131394ae454773c09

summary.toml SHA-256:
ccf93bff90616c827de5cc8acddea83234cc3c1176cd4eacd8005c5a1ba56efd

opening_log.json SHA-256:
e46cf3577f31645f3560ee5635adceae002c470bed71d421ae202156fb228d9c
```

The outputs are under `experiments/holdout/`. A second call to the frozen
runner was attempted and rejected because the opening log already existed.

## 4. Interpretation

The holdout establishes reliable execution for the frozen synthetic contracts.
It does not turn specification-limited paper claims into successful
replications. The final report separately evaluates analytic identities,
counterexamples, finite-contract recovery, and claims that cannot be uniquely
implemented from the supplied papers.
