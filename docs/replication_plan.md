# Clean-room replication plan

Status: preregistered working plan; Phase 6 completed, 2026-08-02
Baseline commit inspected: `974a7c35ebaa855862ad98e535331ab2a520d15b`
Language: Julia 1.12.6, official aarch64 Apple build
Current phase: Phase 6 freeze complete; Phase 7 holdout has not been opened or
generated.

## 1. Objective and decision discipline

The objective is to test, not confirm, the supplied claims. The implementation
will distinguish:

1. mathematical identity;
2. algorithmic correctness;
3. numerical stability;
4. identifiability under a declared observation contract;
5. agreement with a supplied paper;
6. interpretation about physics or nature.

Passing a lower layer never automatically promotes a result to a higher layer.
In particular, a finite-system fit is not evidence for emergent spacetime or
gravity, and a matter response is not a graviton propagator.

The final verdict is exactly one of `Replicated`, `Partially Replicated`,
`Not Replicated`, or `Inconclusive`, using the definitions in `AGENTS.md`.
Specification gaps are not repaired by looking at original code or outputs.

## 2. Clean-room controls

### 2.1 Allowed inputs

- Files committed under this repository's `papers/` or a future `specs/`.
- Official Julia and selected numerical-package documentation.
- Established textbook mathematics and physics.

### 2.2 Prohibited inputs

- The original Quantum-Relational-Network source, tests, results, certificates,
  repository history, issues, discussions, prompts, or intermediate data.
- Search-engine, filesystem, Git, or API attempts to locate those artifacts.
- Paper-result-driven choice of tolerances, scan ranges, algorithms, or priors.

### 2.3 Operational independence

- Source provenance is recorded per derived specification.
- Original variable/function names and algorithm organization are not copied.
- Problem generators, canonical forms, state models, dynamics, topology, and
  scoring are independently designed in Julia.
- Quoted paper numbers are labeled `POST` in `claim_inventory.md` and remain
  excluded from development gates.
- Small cases use at least two independent algorithms where feasible.
- Every negative/null/abstention case stays in reports and scoring.

## 3. Phase order and exit gates

### Phase 0 — Environment and repository audit

Completed read-only checks:

- Repository contains only `AGENTS.md` and `papers/` at the initial commit;
  there is no prior implementation, `results/`, or `specs/`.
- Worktree was clean at start.
- No prohibited original repository or artifact was accessed or searched.
- Julia is now executable at `/Users/yasuo/.juliaup/bin/julia`.

Recorded environment:

- Julia 1.12.6, commit `15346901f00`, LLVM 18.1.7.
- macOS arm64, Apple M4 Pro, 14 CPU cores, 64 GiB RAM.
- Julia compute threads: 1 at inspection; GC threads: 1.
- BLAS: ILP64 OpenBLAS via libblastrampoline, 10 threads at inspection.

Exit gate: a minimal Julia `Project.toml` exists, Julia starts with the project,
and environment facts can be emitted without depending on untracked software.

### Phase 1 — Literature audit

Artifacts:

- `docs/claim_inventory.md`
- `docs/ambiguities.md`
- `docs/replication_plan.md`

Exit gate: every major supplied-paper claim and every mandatory A–E family has
an ID, assumptions, input/output, verification, falsifier, tolerance policy,
provenance, inclusion status, and known gap. No scientific implementation may
begin before all three files pass this audit.

### Phase 2 — Independent derivations

Artifact: `docs/derivations.md`.

Derivation order:

1. Heisenberg nested-commutator formula and every signed-perturbation contract.
2. Hilbert-Schmidt support projections via partial traces and Möbius inversion.
3. Finite-dimensional star-algebra closure, commutants, centers, sectors, and
   ordinary versus graded commutators.
4. Simplicial boundary maps and Betti-number identities.
5. Exact anomaly coefficients and canonical equivalences.
6. BW chain prefactor, BZ measure, moment formulas, and covariance inequality.
7. Only then, lattice-torus and stress-response formulas that are closed by the
   supplied prose.

For each derivation, record assumptions, dimensional units, signs,
normalizations, counterexamples, and which numerical implementation it tests.

Exit gate: the response coefficient is derived rather than copied; the
hypergraph projection is unique under a stated inner product; topology and
anomaly conventions are fixed; ambiguous alternatives have distinct IDs.

### Phase 3 — Minimal analytic implementation

Implement only small systems first:

- two- and three-mode single-particle response;
- two-site interacting many-body response;
- two qubits, three qubits, and qubit-qutrit operator algebras;
- two- and three-factor Hilbert-Schmidt support decompositions;
- hand-built graph/complex examples through dimension four;
- exact rational anomaly checks in small domains;
- 1D BW chain and direct quadrature oracle.

Exit gate: unit and analytic tests pass under `Float64` and small `BigFloat`
checks; deliberate mutations are detected; no recovery algorithm produces a
unique result on registered non-identifiable examples.

Completion record, 2026-08-02:

- The clean-room Julia package contains typed result and observation objects,
  one-particle and many-body response calculations, operator-algebra
  diagnostics, exact support decomposition, custom `F2` homology, exact
  anomaly checks, a lattice-flux counterexample, and two independent BW
  normalization evaluations.
- Analytic response curvature is checked against dense real-time central
  differences. Dense matrix exponential evolution is independently checked
  against Hermitian spectral evolution in the one-particle case.
- Exact rational support decompositions, exact integer anomaly sums, and exact
  finite-field boundary ranks avoid floating thresholds on their small oracles.
- `BigFloat` checks cover the projector-response identity and BW quadrature.
- Registered non-identifiable cases return `EquivalenceClassOnly`,
  `InsufficientObservation`, `Abstain`, or `OutOfDomain` rather than a unique
  answer.
- The minimal suite passes 153 of 153 assertions under Julia 1.12.6. Detailed
  method and scope notes are in `docs/numerical_methods.md`.

This is a development milestone, not the Phase 6 freeze. Train, validation,
fresh holdout, paper-number comparison, and a final replication verdict remain
unperformed.

### Phase 4 — Independent generators and adversarial tests

Create generator families without copying paper examples beyond named topology
classes. Each generated instance stores:

- schema version and claim ID;
- `experiment_id` and `cell_id`;
- seed derivation label, never global mutable RNG state;
- model parameters and observation contract;
- ground-truth class and equivalence relation;
- expected output status, but not paper-result numbers;
- condition estimates and numerical budget;
- raw observations and missingness/noise metadata.

Adversarial families include weak hierarchical edges, long-range confounders,
symmetry degeneracy, nonlocal unitaries, incomplete operations, hidden
higher-body terms, boundary reflections, nonuniform noise, finite-difference
roundoff, and pairs of latent Hamiltonians with identical observations.

Exit gate: every recovery family has positive, null, counterexample,
non-identifiable, out-of-domain, and high-noise cells.

Completion record, 2026-08-02:

- A versioned SHA-derived generator now covers response, factorization,
  hypergraph, topology, and cross-cutting identifiability families. Each family
  contains positive, null, weak-signal, basis-change, boundary, inhomogeneous,
  equivalent-model, missing-observation, out-of-domain, and high-noise cases.
- Public train/validation seeds are deterministic. The holdout API refuses to
  generate cells without both a post-freeze secret and an experiment ID; no
  holdout cell or seed was generated during this phase.
- Response adversaries cover open/periodic boundaries, disorder, probe-size
  scaling, noise amplification, internal basis covariance, saturation,
  non-Gaussian covariance insufficiency, and `H`/`-H` equivalence.
- Hypergraph adversaries cover on-site, hopping, density-density, correlated
  hopping, pair hopping, true/null three-body, four-body, local/nonlocal basis
  changes, conditional projections, and sign/phase erasure by squared weights.
- Geometry/homology adversaries include path, cycle, disk, cylinder, two-hole
  disk, sphere, torus, genus-2, 3-ball, 3-sphere, 3-torus, Petersen, random
  regular, complete, branched, and threshold-degenerate examples.
- The full suite passes 234 of 234 assertions under Julia 1.12.6. The exact
  generator contract is recorded in `docs/phase4_adversarial_design.md`.

This completion establishes generator and adversarial coverage, not calibrated
thresholds or holdout performance. Those remain gated by Phases 5--7.

### Phase 5 — Train and validation

Train is reusable and may drive bug fixes and threshold development. Validation
is a one-use audit of frozen candidate rules. The exact partition rules are in
Section 8.

Exit gate:

- all unit, analytic, adversarial, integration, and train tests pass;
- validation has been run once under a recorded implementation hash;
- any post-validation change has retired that validation ID and been followed
  by a newly committed validation ID;
- thresholds, confidence levels, equivalence metrics, and abstention ordering
  are final.

Completion record, 2026-08-02:

- Scoring code, cell-local numeric tolerances, status precedence, validation
  count, and primary targets were committed and pushed in `4f9fab6` before any
  validation seed was derived.
- Train `phase5-train-v1` evaluated 100 cells: selective risk `0`, answerable
  recall `1`, impossibility recall `1`, and exact status accuracy `1`.
- Validation `phase5-validation-v1` was evaluated once on 50 cells under source
  commit `4f9fab6`: the same four metrics were all `0` or `1` at their ideal
  values, and all preregistered targets passed.
- Maximum numeric answer error in both splits was approximately `3.34e-16`,
  below the preregistered weak-signal tolerance `2e-12`. No threshold, scorer,
  generator, or algorithm was changed after observing validation.
- Raw cell outputs and summaries are preserved under `experiments/train/` and
  `experiments/validation/`; details are in `docs/phase5_train_validation.md`.

These metrics describe the registered synthetic finite contracts. They do not
resolve paper claims whose defining data or observation contract is missing.

### Phase 6 — Freeze

Execute the freeze checklist in Section 10. Freeze is a Git commit and a
machine-readable manifest. No holdout instance or seed is generated before the
freeze commit.

### Phase 7 — Fresh holdout

After verifying the human-held secret against its pre-freeze commitment,
generate and score the holdout exactly once. Preserve raw output, errors,
timeouts, and all failed cells. No code, threshold, generator family, or scorer
change is permitted under the same experiment ID.

### Phase 8 — Final comparison and report

Only now compare quarantined paper numbers with frozen outputs. Distinguish
qualitative replication, quantitative replication, tolerance agreement,
partial replication, failure, specification insufficiency, mathematically
valid alternatives, narrowed scope, and new counterexamples.

## 4. Proposed package architecture

```text
Project.toml
Manifest.toml
README.md

src/
  QRNReplication.jl
  CoreTypes.jl
  Algebra/
  States/
  Dynamics/
  Responses/
  Factorization/
  Hypergraphs/
  Geometry/
  Homology/
  Identifiability/
  Anomalies/
  LatticeFermions/
  VacuumPolarization/
  BayesAudit/
  Scoring/
  Generators/
  Reproducibility/

test/
  runtests.jl
  unit/
  analytic/
  adversarial/
  integration/
  holdout/

experiments/
  train/
  validation/
  holdout/
  run_train.jl
  run_validation.jl
  run_holdout.jl

docs/
reports/
```

Modules expose typed scientific objects, not unlabelled tuples. Planned types
include:

- `DecayRate{T}`, `LengthScale{T}`, `InteractionWeight{T}`;
- `ObservationContract`, carrying probe, observable, normalization, noise, and
  factorization conventions;
- `FactorizationResult` and an explicit equivalence certificate;
- `IdentifiabilityResult` with a closed status enumeration;
- `TopologyCertificate`, carrying coefficient field, filtration, boundary
  ranks, Betti numbers, and manifold qualifications;
- `AbstentionReason`, with machine-readable evidence;
- `NumericalBudget`, carrying condition estimate, truncation, rounding, and
  statistical uncertainty separately.

All public functions require argument validation and docstrings. Hermitian,
density-matrix, dimension, positivity, normalization, and finite-value checks
fail closed.

## 5. Planned Julia dependencies

Standard libraries:

- `LinearAlgebra`, `SparseArrays`: dense/sparse linear algebra and matrix
  functions.
- `Random`, `SHA`, `Dates`, `TOML`: deterministic generation, commitments,
  timestamps, and configuration.
- `Statistics`, `Printf`, `Test`: summaries, stable output, and tests.

External packages, to be fixed only after official-document compatibility
checks:

- `KrylovKit.jl`: Krylov eigensolvers and exponential action.
- `Arpack.jl`: a second sparse eigensolver implementation.
- `GenericLinearAlgebra.jl`: generic/BigFloat dense decompositions.
- `QuadGK.jl`: adaptive quadrature as a BZ/integral cross-check.
- `IntervalArithmetic.jl`: certified enclosures for small analytic targets.
- `StableRNGs.jl`: version-stable non-cryptographic generator streams.
- `JSON3.jl`, `StructTypes.jl`: typed machine reports.
- `Graphs.jl`: secondary graph-operation checks only.

Core graph recovery, response, factorization, support decomposition, homology,
decision rules, and scoring will not be delegated to a single external black
box. Dependency versions are not selected to reproduce paper numbers.

## 6. Independent numerical methods

| Quantity | Primary method | Independent check | Small-case oracle |
|---|---|---|---|
| Spectrum | dense `eigen(Hermitian(H))` | KrylovKit / Arpack | analytic 2x2 blocks, BigFloat |
| Time evolution | dense spectral or `exp(-im*t*H)` | Krylov exponential action | Taylor/nested commutators |
| Initial curvature | nested commutator | symmetric finite differences | exact two-mode formula |
| Hypergraph support | partial-trace Möbius projection | tensor operator basis | rational Pauli/Gell-Mann examples |
| Algebra factors | commutants/centers | representation multiplicities and double commutant | hand-built tensor/direct sums |
| Homology | custom `F2` bit elimination | rational boundary rank | known Betti/Euler values |
| Anomalies | exact integer branch-and-bound | meet-in-the-middle/elimination | textbook SM cancellation |
| BZ moments | tensor/adaptive quadrature | AGM plus interval Riemann bounds | series and symmetry values |
| Evidence | exact discrete log-sum-exp | partitioned/certified remainder sum | tiny exhaustive spaces |
| Continuum fit | derived asymptotic basis | tail/full-window and discretization comparison | analytic oracle |

Condition numbers, residuals, spectral gaps, iteration counts, tolerances,
precision, thread counts, and failure statuses are part of raw output.

## 7. Numerical error policy

### 7.1 Exact domains

Anomaly sums, canonical combinatorial objects, finite-field homology, seed
derivations, manifest hashes, and result-status transitions must agree exactly.

### 7.2 Floating-point domains

No universal `1e-8`-style threshold is allowed. Each comparison has:

```text
total_budget = analytic_truncation
             + discretization_estimate
             + conditioning_amplification
             + floating_roundoff
             + statistical_interval
```

The terms are stored separately. A result passes only if the discrepancy is
inside the frozen total budget and the expected convergence behavior is
observed. If the budget straddles a classification threshold, the result is
`Abstain`.

### 7.3 Precision ladder

Small cases run at `Float64`, at least one higher hardware-independent precision
(`BigFloat`, initially 256 bits), and where meaningful exact rational/integer
arithmetic. Precision is increased to diagnose instability, not to force a
paper match.

### 7.4 Finite differences

Use a registered symmetric stencil and a step ladder. Require the theoretical
truncation slope before the roundoff floor, explicitly locate the turnover, and
compare the extrapolation against nested commutators. A single best-looking
step is never selected after viewing the target.

## 8. Train, validation, and holdout partition

### 8.1 Train

- Public deterministic seeds derived from
  `SHA256("train" || schema_version || claim_id || cell_id)`.
- Contains analytic hand cases and random/adversarial cases.
- May be regenerated during development, but generator version changes are
  committed and old results retained.
- May be used for thresholds, confidence calibration, and performance work.

### 8.2 Validation

- A manifest of claim families, sizes, and generator versions is committed
  before seed derivation.
- A validation secret is revealed once for a named validation ID.
- Used only to confirm scorer and thresholds, not to hunt for better algorithms.
- If any observed validation result leads to code, threshold, or rule changes,
  that validation ID is permanently retired and reported. A new validation ID
  with a new commitment is required.

### 8.3 Holdout composition

The intended core holdout has 120 independently seeded small/medium cells:

- 24 response cells;
- 24 factorization/algebra cells;
- 24 interaction-hypergraph cells;
- 24 geometry/homology cells;
- 24 cross-cutting identifiability cells.

Within each family, the frozen generator targets approximately 60% uniquely
answerable cases and 40% equivalence-only, insufficient, noisy-boundary, or
out-of-domain cases. The precise counts and resource caps are frozen before the
secret is revealed. Paper-specific anomaly, BW, flavor, and gravity cells are
scored separately so a missing paper specification cannot be disguised as an
algorithmic failure.

The holdout includes both expected successes and mandatory abstentions. Family
labels and counts are public before freeze; parameters and seeds are not.

### 8.4 Hidden seed protocol

Before freeze, the human operator supplies:

```text
secret_commitment = SHA256(secret)
```

The implementation records only that commitment. After the freeze commit and
manifest are fixed, the human supplies `secret`. The runner verifies the
commitment and derives:

```text
seed_cell = SHA256(secret || experiment_id || cell_id)
```

The log records secret, commitment verification, freeze commit, manifest hash,
cell seeds, UTC and local timestamps, raw output, status, and score. If the
secret was available to the implementation agent before freeze, the final
report must downgrade `hidden_holdout` accordingly.

## 9. Scoring and acceptance rules

### 9.1 Ground-truth classes

- `UniqueAnswerable`: exactly one answer modulo the frozen equivalence.
- `EquivalenceOnly`: multiple latent representatives but one reportable
  equivalence class.
- `ObservationInsufficient`: at least two nonequivalent truths yield the same
  allowed observation.
- `OutOfDomainTruth`: the oracle assumptions are false.
- `NumericallyUnresolved`: the frozen uncertainty budget crosses a decision
  boundary.

### 9.2 Allowed outputs

The output statuses follow the frozen precedence in `ambiguities.md`:
`OutOfDomain`, `InsufficientObservation`, `EquivalenceClassOnly`, `Abstain`,
then `Answer`.

### 9.3 Primary metrics

```text
selective_risk = incorrect Answer outputs / all Answer outputs

answerable_recall = correct Answer outputs on UniqueAnswerable cells
                    / all UniqueAnswerable cells

impossibility_recall = safely non-unique/non-answer outputs on
                       EquivalenceOnly + ObservationInsufficient
                       + OutOfDomainTruth cells
                       / all such cells
```

An empty denominator is reported as `null`, never as a perfect score. In
addition, exact-reason accuracy distinguishes the non-answer statuses; a safe
but wrong reason can satisfy safety recall but fails reason accuracy.

Primary holdout targets, unchanged from `AGENTS.md`:

- `selective_risk = 0`;
- `answerable_recall >= 0.9`;
- `impossibility_recall = 1.0`.

No post-holdout confidence-interval relaxation or exception reclassification is
permitted. Per-claim analytic gates may be stricter and are frozen before
validation.

## 10. Freeze checklist

1. Run all unit, analytic, adversarial, integration, train, and current valid
   validation tests.
2. Instantiate dependencies from scratch in a clean temporary depot check.
3. Fix `Project.toml` and `Manifest.toml`.
4. Record Julia version/commit, OS/build, CPU, memory, LLVM, BLAS vendor and
   integer mode, Julia/BLAS/GC thread counts, locale, and relevant numeric
   environment settings.
5. Freeze all generator schemas, claim scopes, scorers, thresholds, confidence
   levels, equivalence relations, timeouts, and resource limits.
6. Record the human-provided holdout secret commitment, not the secret.
7. Ensure no holdout instances, seeds, or outputs exist.
8. Commit all target files in a dedicated freeze commit.
9. Generate a sorted SHA-256 manifest over every target file, including the Git
   commit hash and dependency manifest.
10. Store it in `reports/freeze_manifest.json` and record its own canonical
    digest without self-reference ambiguity.
11. Verify a clean worktree and rerun a lightweight manifest verifier.
12. Stop code and rule changes for that experiment ID.

If a post-freeze bug is found, preserve the original failure. A fix requires a
new experiment ID, new freeze commit, new secret commitment, and fresh holdout.

Completion record, 2026-08-02:

- All 253 assertions passed under the normal depot and a newly created empty
  depot instantiated from `Project.toml` and `Manifest.toml`.
- Julia, OS, CPU, memory, LLVM, BLAS, and thread facts are fixed in
  `reports/environment.json`; scoring and threshold rules are fixed in
  `reports/frozen_rules.toml`.
- A 256-bit secret was generated through Julia `RandomDevice` into ignored,
  mode-`0600` local storage. The implementation model was shown only the
  SHA-256 commitment
  `53527a3c56e9fcf1b4c1c2df2e6d7cffd6a34e6748b5b50aaa3a07796dcf57a1`
  before freeze.
- The dedicated freeze commit and canonical SHA-256 payload digest are recorded
  in `reports/freeze_manifest.json` and its TOML verification companion. The
  manifest excludes itself to avoid self-reference and hashes every declared
  code, test, experiment, specification, environment, and frozen-rule target.
- The Phase 7 runner refuses repeated opening, verifies every frozen file and
  the secret commitment, and only then derives cell seeds. No holdout cell or
  seed was generated in Phase 6.

No implementation, generator, scorer, tolerance, or decision-rule change is
permitted for experiment `phase7-holdout-v1` after this gate.

## 11. Reporting plan

### 11.1 Machine outputs

`reports/machine_report.json` will contain the required provenance fields plus:

- corpus hashes and allowed-source list;
- environment and thread configuration;
- experiment/freeze/secret commitment metadata;
- per-claim verdicts and ambiguity IDs;
- raw confusion counts behind selective metrics;
- failures separated into implementation, specification, numerical,
  identifiability, and claim-level categories.

### 11.2 Human report

`reports/final_report.md` follows the 16-section structure in `AGENTS.md`.
Every conclusion cites claim IDs and distinguishes:

- analytic proof or counterexample;
- numerical evidence and convergence;
- train/validation/holdout provenance;
- paper comparison performed only after holdout;
- unresolved specification;
- maximum justified physical scope.

### 11.3 Reproduction interface

The final `README.md` will provide commands equivalent to:

```bash
julia --project=. -e 'using Pkg; Pkg.instantiate()'
julia --project=. test/runtests.jl
julia --project=. experiments/run_train.jl
julia --project=. experiments/run_validation.jl
julia --project=. experiments/run_holdout.jl
```

The holdout command will fail closed unless a valid freeze manifest and secret
commitment are present.

## 12. Stop conditions

Work pauses rather than improvises if:

- a required interpretation would materially change the claimed problem and
  cannot be represented as parallel variants;
- a requested action would require a prohibited original artifact;
- validation/holdout provenance is compromised;
- numerical conditioning prevents a frozen decision;
- a gravity gate fails and a higher semantic type is requested;
- available resources make the preregistered convergence test impossible.

In these cases the result is recorded as `Inconclusive`, `Abstain`,
`InsufficientObservation`, or `OutOfDomain` as appropriate. Scientific failure
is retained; it is not repaired by changing the question after seeing the
answer.
