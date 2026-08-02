# Phase 5 train and validation record

Status: completed 2026-08-02

## 1. Registration

The scorer, generator schema, status precedence, cell counts, numeric
tolerances, and acceptance targets were committed and pushed before validation:

```text
registration commit: 4f9fab6e93aa6f02fb055c9d4c3ec327d3466396
generator schema: phase4-v1
validation ID: phase5-validation-v1
validation cells per family: 10
default numeric tolerance: 2e-10
weak-signal tolerance: 2e-12
```

The registered primary targets were selective risk `0`, answerable recall at
least `0.9`, and impossibility recall `1`. Empty metric denominators remain
`null` and cannot pass. Deliberate wrong-answer and false-answer mutations fail
the scorer tests.

## 2. Train result

`phase5-train-v1` used 20 cells in each of the five families, for 100 cells:

| Metric | Result |
|---|---:|
| Answer outputs | 60 |
| Incorrect answer outputs | 0 |
| Selective risk | 0 |
| Unique answerable cells | 60 |
| Correct unique answers | 60 |
| Answerable recall | 1 |
| Impossibility cells | 30 |
| Safe impossibility outputs | 30 |
| Impossibility recall | 1 |
| Exact status accuracy | 1 |

The remaining ten cells are numerical-boundary cases registered to `Abstain`.
The largest numeric answer error was approximately `3.34e-16`.

## 3. One-use validation result

After the train result required no rule change, `phase5-validation-v1` was run
once under the registration commit. It used 10 cells in each family, for 50
cells:

| Metric | Result |
|---|---:|
| Answer outputs | 30 |
| Incorrect answer outputs | 0 |
| Selective risk | 0 |
| Unique answerable cells | 30 |
| Correct unique answers | 30 |
| Answerable recall | 1 |
| Impossibility cells | 15 |
| Safe impossibility outputs | 15 |
| Impossibility recall | 1 |
| Exact status accuracy | 1 |

The remaining five cells are registered numerical abstentions. The largest
numeric answer error was again approximately `3.34e-16`. All primary targets
passed. No code, threshold, equivalence rule, generator, or scorer was modified
after the validation output was observed.

## 4. Interpretation boundary

The perfect scores are expected for these small, generated contracts with
analytic answer oracles. They establish internal correctness and fail-closed
status handling; they are not evidence that underspecified paper-specific
flavor, shear, measure, or gravitational calculations have been reproduced.
Those claims remain separately classified by analytic result, counterexample,
or specification insufficiency in the final report.
