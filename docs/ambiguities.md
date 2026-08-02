# Ambiguities and specification gaps

Status: prereplication audit, 2026-08-02
Rule: no ambiguity may be resolved by consulting the original implementation,
its results, repository history, issues, prompts, or intermediate data.

Each entry records reasonable interpretations to be kept separate. Selecting an
interpretation for train does not retroactively make it the paper's intended
one. Where a choice changes the scientific claim, all feasible interpretations
receive distinct experiment IDs and the final report labels the result
`specification-limited`.

## A. Corpus and provenance gaps

### AMB-SRC-001 — Missing QRN core paper for the mandated A–E claims

- **Gap:** The supplied papers concern anomaly searches, magnetized-torus
  flavor, modular/BW normalization, and a gravitational-response
  preregistration. They do not contain a core paper specifying local response,
  operation-network factorization, interaction hypergraphs, or topology
  readout.
- **Interpretations:**
  1. Treat A–E solely as new conjectures mandated by `AGENTS.md`.
  2. Suspend attribution to QRN while still testing mathematically natural
     versions of A–E.
- **Decision:** Use both descriptions: implement the mandated tests, but never
  call them a paper replication until an allowed paper/specification is added.
- **Impact:** Central; final verdict on the missing QRN core claims may be
  `Inconclusive` even when the independently formulated tests are informative.

### AMB-SRC-002 — No `specs/` directory

- **Gap:** The allowed source location exists only as a rule, not on disk.
- **Decision:** Record the absence. Do not infer missing specifications from
  names or references in the papers.
- **Impact:** Prevents exact reconstruction of observation contracts and domain
  schemas.

### AMB-SRC-003 — Papers delegate primary definitions to forbidden or absent artifacts

- **Gap:** The papers cite `results/`, `certificates/`, `claims.yml`,
  `predictions.yml`, `measures.yml`, `proofs/`, and original Git history.
- **Interpretations:**
  1. Reproduce only what is closed under the prose and equations supplied here.
  2. Independently define a nearby experiment and label it as such.
- **Decision:** Both are allowed; neither may be silently compared as an exact
  replay.
- **Impact:** Exact anomaly domains, flavor priors/configurations, and
  prequential chronology cannot presently be independently reconstructed.

### AMB-SRC-004 — Result numbers were unavoidably seen during the required full-paper audit

- **Gap:** The instructions require reading every paper before implementation,
  while also forbidding tuning to the papers' result numbers.
- **Decision:** Place all quoted outputs in a conceptual `POST` quarantine.
  Algorithms, tolerances, thresholds, generator ranges, and stopping rules must
  be justified from derivations, numerical analysis, or train data without
  testing against those outputs. Numerical paper comparison occurs only after
  freeze and holdout.
- **Impact:** Avoids operational tuning, although human/model memory cannot be
  literally erased.

### AMB-SRC-005 — Markdown, TeX, and PDF variants

- **Gap:** Five papers occur in three formats; outlines and full drafts can also
  differ chronologically.
- **Decision:** Treat the latest full Markdown text as the semantic source,
  TeX/PDF as publication renderings, and outlines as historical scope. Later
  explicit addenda supersede earlier conclusions but do not erase them.
- **Impact:** In particular, the later measure paper supersedes the earlier
  “surviving measure correction” conclusion for the expanded geometry family.

## B. Local-response ambiguities

### AMB-RESP-001 — Meaning of the signed perturbation

- **Gap:** “Add positive/negative small perturbation to subsystem `i`” could
  mean a changed initial density matrix, an added Hamiltonian term, a particle
  injection/removal, or a local potential quench.
- **Variants:**
  1. Initial-state population perturbation `rho_plus/minus = rho0 +/- epsilon Delta_i`.
  2. Hamiltonian perturbation `H_plus/minus = H0 +/- epsilon P_i` with common state.
  3. Normalized particle/hole conditional preparation.
  4. Gaussian covariance perturbation constrained to remain physical.
- **Plan:** Derive and test every mathematically valid variant. Nonpositive
  density matrices are rejected, not silently renormalized.

### AMB-RESP-002 — Meaning and normalization of `P_i`

- **Gap:** `P_i` could be a rank-one site projector, a block projector, a
  many-body number operator, or a normalized subsystem embedding.
- **Variants:** raw projector; projector divided by rank; local traceless probe;
  Nambu-space projector.
- **Impact:** Frobenius weights acquire dimension factors and can change the
  factor of four.

### AMB-RESP-003 — Which density curvature is measured

- **Gap:** The paper does not state whether `n_j` is single-particle
  occupation, many-body number, density per internal degree, or connected
  density response.
- **Plan:** Give each observable a distinct `ObservationContract`; never mix
  units in a raw `Float64`.

### AMB-RESP-004 — Sign and factor conventions

- **Gap:** The displayed formula in `AGENTS.md` contains a Markdown divider in
  place of an ordinary equality, and the factors depend on whether the
  plus/minus state difference is `2epsilon` or `4epsilon` in occupation.
- **Plan:** The nested-commutator derivation, not the displayed coefficient,
  fixes each implementation. The paper-form expression is then classified as
  exact, rescaled, sign-reversed, or false under that contract.

### AMB-RESP-005 — Interacting extension

- **Gap:** It is not specified why density-density interactions should cancel,
  which fillings/states are allowed, or whether Wick/Gaussian closure is used.
- **Variants:** number eigenstates, thermal states, general diagonal mixtures,
  Slater determinants, and interacting ground states.
- **Plan:** Separate exact operator identities from state-specific
  cancellations and from Gaussian approximations.

### AMB-RESP-006 — Noise and finite-difference model

- **Gap:** Additive versus shot noise, correlations between plus/minus runs,
  sample counts, timestamp jitter, and missing observations are undefined.
- **Plan:** Train uses several preregistered synthetic models; holdout cells
  declare their noise contract in metadata. Unsupported noise models return
  `OutOfDomain`.

## C. Factorization and algebra ambiguities

### AMB-FAC-001 — What constitutes a primitive operation

- **Gap:** Matrices, black-box channels, Lie generators, projective
  measurements, and abstract commutation graphs carry different information.
- **Variants:** full matrices; exact multiplication table; binary commutation
  graph; noisy commutator norms.
- **Plan:** These are distinct observation contracts with strictly decreasing
  information. Results may only claim what their contract supports.

### AMB-FAC-002 — Closure operation

- **Gap:** Recovery might use linear span, associative star-algebra closure,
  Lie closure, or von Neumann bicommutant.
- **Plan:** Implement finite-dimensional associative star closure and Lie
  closure separately. The commutation-graph-only variant cannot manufacture
  products that were not observed.

### AMB-FAC-003 — Approximate commutation and numerical rank

- **Gap:** No scale-aware tolerance is given.
- **Plan:** Exact rational/symbolic cases determine correctness. Floating cases
  use singular-value gaps with confidence intervals; unresolved gaps yield
  `Abstain`, never an arbitrary cutoff-based factorization.

### AMB-FAC-004 — Equivalence of factorizations

- **Gap:** Local unitaries and node permutations are specified, but repeated
  equal-dimensional factors, antiunitaries, algebra automorphisms, and sector
  permutations are not.
- **Variants:** unitary-only; unitary plus antiunitary; center-preserving sector
  permutations.
- **Plan:** Primary equivalence is local unitary plus node permutation. Broader
  quotients are reported as separate equivalence relations.

### AMB-FAC-005 — Nontrivial center and superselection

- **Gap:** A direct-sum algebra does not canonically imply a tensor product on
  the entire Hilbert space.
- **Plan:** Return central projectors first, then factorization candidates
  within sectors. A global tensor product is forbidden unless compatible
  sector multiplicities are proved.

### AMB-FAC-006 — Fermionic locality

- **Gap:** Ordinary tensor commutation conflicts with CAR locality for odd
  operators.
- **Variants:** CAR algebra with graded commutator; parity-even observable
  algebra with ordinary commutator; Jordan-Wigner tensor representation with
  ordering data.
- **Plan:** Require an explicit grading in the contract. Missing parity data is
  `InsufficientObservation`.

## D. Hypergraph ambiguities

### AMB-HYP-001 — Definition of the support component `H_S`

- **Gap:** A term decomposition is nonunique without an orthogonality/gauge
  convention.
- **Variants:** normalized Hilbert-Schmidt identity/traceless decomposition;
  inclusion-exclusion of partial traces; a user-supplied operator dictionary.
- **Decision:** The first two are implemented and must agree; dictionary
  decompositions are descriptive and cannot define invariant weights by
  themselves.

### AMB-HYP-002 — Frobenius normalization

- **Gap:** Raw `Tr(H_S^dagger H_S)` scales with spectator dimensions, while a
  normalized trace does not.
- **Variants:** raw Frobenius norm; globally normalized Hilbert-Schmidt norm;
  support-normalized norm.
- **Plan:** Carry the norm convention in `ObservationContract`; compare all
  three only where dimensional conversion is explicit.

### AMB-HYP-003 — Null higher-body term

- **Gap:** “null three-body” may refer to zero coefficient, an algebraically
  reducible term, cancellation after summation, or an observationally invisible
  term.
- **Plan:** Use four distinct labels and tests. Observational nullity does not
  imply `H_S=0`.

### AMB-HYP-004 — Conditional and coherent probes

- **Gap:** Neither preparation nor accessible phase reference is defined.
- **Variants:** classical conditioning on local occupation; coherent
  superposition with a calibrated phase; ancilla-assisted process probe.
- **Plan:** Implement only contracts with explicit state and POVM formulas.

### AMB-HYP-005 — Factorization transformation under a nonlocal unitary

- **Gap:** A nonlocal basis change can mean changing `H` while holding the
  factorization fixed, or transporting both together.
- **Plan:** Test both. Only the former changes physical support relative to a
  fixed operational factorization.

## E. Geometry and homology ambiguities

### AMB-TOP-001 — Weight-to-length map

- **Gap:** Candidate maps include `1/w`, `1/sqrt(w)`, `-log(w/w0)`, and fitted
  decay length. They differ at weak or zero edges.
- **Plan:** Treat maps as separate preregistered models. No map is selected by
  matching a known topology.

### AMB-TOP-002 — Edge selection

- **Gap:** Hard threshold, multiple-testing confidence bounds, `k`-nearest
  neighbors, or full weighted filtrations give different complexes.
- **Plan:** Prefer a filtration when possible. A point graph is returned only
  when its edge/nonedge confidence intervals are separated; otherwise return a
  family or abstain.

### AMB-TOP-003 — Clique versus Vietoris-Rips

- **Gap:** A clique complex of a threshold graph equals a VR complex only for
  a compatible thresholded metric graph.
- **Plan:** Build independently and state the exact input to each. Agreement is
  tested, not assumed.

### AMB-TOP-004 — Homology coefficient domain

- **Gap:** Betti numbers over `F2` and `Q` can differ in the presence of torsion
  effects through universal-coefficient contributions.
- **Plan:** Primary computation uses `F2` for robust exact bit arithmetic;
  small complexes are cross-checked over `Q`. Suspected torsion requires Smith
  normal form and is explicitly qualified.

### AMB-TOP-005 — Triangulations of named spaces

- **Gap:** The papers provide no meshes for torus, genus-2 surface, 3-torus,
  3-sphere, or 3-ball.
- **Plan:** Create independent combinatorial generators and validate Euler
  characteristic, links, orientability where applicable, and known Betti
  numbers before they enter train.

### AMB-TOP-006 — Manifold and dimension inference

- **Gap:** Betti numbers do not determine manifoldness or dimension.
- **Plan:** Use vertex-link certificates and local dimension consistency.
  Random regular/Petersen/branched cases are negative controls, not forced into
  a manifold label.

## F. Identifiability ambiguities

### AMB-ID-001 — Status precedence

- **Gap:** `OutOfDomain`, `InsufficientObservation`, and `Abstain` can all apply.
- **Decision:** Frozen precedence will be:
  1. malformed input -> validation error, not a scientific status;
  2. model-contract violation -> `OutOfDomain`;
  3. provably information-incomplete -> `InsufficientObservation`;
  4. multiple exactly equivalent answers -> `EquivalenceClassOnly`;
  5. numerical/statistical uncertainty -> `Abstain`;
  6. otherwise -> `Answer`.
- **Impact:** This order must be fixed before validation and encoded in scoring.

### AMB-ID-002 — Gaussianity test power

- **Gap:** Covariance data alone cannot distinguish every non-Gaussian state.
- **Decision:** If higher correlators are unavailable, return
  `InsufficientObservation`, not “Gaussian”. With sampled fourth moments, use a
  calibrated Wick-residual test; low power returns `Abstain`.

### AMB-ID-003 — Confidence level and multiplicity

- **Gap:** No confidence level is stated.
- **Plan:** Set it from a train-only familywise-error analysis and freeze the
  exact procedure before validation. The global holdout objective is zero
  selective risk, so uncertain cells must sacrifice recall rather than risk a
  false answer.

## G. Anomaly-search ambiguities

### AMB-ANOM-001 — Exact domains are absent

- **Gap:** The prose gives envelope bounds but delegates exact core/extension
  domains to a missing JSON certificate.
- **Plan:** Define independent named domains `J-D0`, `J-D1`, etc. from explicit
  prose only. Results are “nearby independent bounded classifications”, not
  exact reproduction of `D1/D2`, unless the paper text closes the definition.

### AMB-ANOM-002 — Representation-index normalization

- **Gap:** Dynkin and cubic index conventions are not written as formulas.
- **Plan:** Derive from weights/traces and use a primitive integer normalization.
  Because anomaly zero sets are scale invariant, raw scaling is harmless if
  consistently applied, but mixed conventions are fatal.

### AMB-ANOM-003 — Chirality and “completely real content”

- **Gap:** Pairwise absence of conjugates is clearer than excluding “completely
  real content”; pseudoreal weak representations and zero hypercharge require
  care.
- **Variants:** strict no conjugate pair; nonzero net chiral index; exclude
  spectra globally equivalent to their conjugate.
- **Plan:** Enumerate all variants and identify which supports each conclusion.

### AMB-ANOM-004 — All-factor charge

- **Gap:** It may mean every multiplet is charged under every factor, or the
  spectrum collectively has nontrivial charge under every factor.
- **Plan:** Test both. The paper wording “some color, some weak, some
  hypercharge” suggests the collective interpretation, but this is not assumed
  silently.

### AMB-ANOM-005 — Component count

- **Gap:** It appears to mean `sum dim(R_c) dim(R_w)` over Weyl multiplets, but
  sterile states and multiplicity conventions matter.
- **Plan:** Make the formula explicit in independent domain schemas.

### AMB-ANOM-006 — Charge-plane equivalence

- **Gap:** `GL(r,Z)` basis changes, rational row-space equality, primitive
  lattice saturation, overall normalization, and Plücker signs form different
  quotients.
- **Plan:** Primary output includes both rational plane and saturated integer
  lattice invariants so overcounting is visible.

### AMB-ANOM-007 — Exceptional-group scope

- **Gap:** Finite checks of listed low-dimensional representations do not prove
  universal self-conjugacy for all representations.
- **Plan:** Separate finite weight-multiset checks from textbook theorem use.
  No finite scan is reported as a universal theorem.

## H. Magnetized-torus and flavor ambiguities

### AMB-YUK-001 — Exact one-body lattice operator

- **Gap:** Gauge choice and flux density are stated, but boundary links,
  hopping signs, constant offsets, and whether the “Dirac” operator is a
  Hamiltonian or squared operator are incomplete.
- **Plan:** Implement at least two gauge-equivalent constructions and compare
  projectors after a gauge transform. Different physical spectra indicate a
  specification failure.

### AMB-YUK-002 — Meaning of exact degeneracy

- **Gap:** The papers call spreads near `1e-12` exact.
- **Plan:** Reserve “algebraically exact” for a proved symmetry. Numerical
  degeneracy requires a scale-aware cluster certificate and is reported as
  tolerance-bounded.

### AMB-YUK-003 — Position localization in a degenerate band

- **Gap:** The position operator phase, branch cut, snapping convention, and
  tie-breaking affect generation labels.
- **Variants:** projected unitary position operator; projected sine/cosine pair;
  maximum-localization functional.
- **Plan:** Compare basis-independent subspace observables first. Label-dependent
  results require a stable convention certificate.

### AMB-YUK-004 — Wilson line implementation

- **Gap:** The prose gives physical steps but not all link matrices or sector
  charges.
- **Plan:** Derive link twists from gauge covariance; compare gauge-invariant
  spectra and projectors across gauges. No paper result is used to select a
  step convention.

### AMB-YUK-005 — Higgs profile and overlap normalization

- **Gap:** “Periodic Gaussian of width sigma” does not fix image summation,
  normalization, dimensional units, complex phase, or product-torus profile.
- **Variants:** minimum-image Gaussian; theta-function periodic sum; normalized
  and unnormalized profiles.
- **Plan:** Keep variants separate and test continuum convergence.

### AMB-YUK-006 — Evidence model

- **Gap:** Although `sigma=ln 2` is stated, the full target table, prior mass,
  zero handling, configuration multiplicities, and normalization are absent.
- **Plan:** Reproduce qualitative structural claims first. Evidence values are
  conditional until a closed allowed specification exists.

### AMB-YUK-007 — “Out of sample” chronology conflict

- **Gap:** Companion prose calls some CKM quantities holdouts, while the later
  prequential ledger states they were seen in earlier versions.
- **Decision:** For program-level scoring use the conservative first-seen rule
  supplied by the ledger; retain within-stage holdout labels only as historical
  claims.

### AMB-YUK-008 — Prime-three flattening inference

- **Gap:** `f_+ f_-=3` over real numbers does not by itself force asymmetry;
  balanced `sqrt(3),sqrt(3)` is algebraically possible.
- **Plan:** Determine the actual constraints imposed by integral antisymmetric
  flux matrices, lattice compatibility, and exact degeneracy. If those do not
  imply the no-go, record a new counterexample or narrow the statement.

### AMB-CP-001 — Structural zero scope

- **Gap:** Real Wilson lines and factorization may not be sufficient if the
  Higgs or boundary conditions carry unremovable complex phases.
- **Plan:** State and prove the complete phase-factorization assumptions. Test
  complex Higgs, complex Wilson, shared versus unshared left address, and
  degenerate-basis changes as boundary cases.

### AMB-CP-002 — Shear implementation and range

- **Gap:** The boundary identification is stated, but gauge-compatible link
  phases and the domain of “every shear” are not.
- **Plan:** Derive two gauge-equivalent link implementations. Claims remain
  finite-domain statements over registered `N,Q,s` sets.

### AMB-MSR-001 — “Uniform measure is correct”

- **Gap:** The evidence only shows preference within a tested finite family;
  it cannot establish a uniquely correct measure.
- **Decision:** Translate to “uniform counting measure is preferred among the
  tested candidates at the tested geometry”. Broader wording is excluded.

### AMB-MSR-002 — Sequential tau scans and causal interpretation

- **Gap:** `tau_re` and `tau_im` were scanned sequentially rather than as a
  preregistered joint surface.
- **Plan:** A joint scan is train/validation work, not a fresh confirmation of
  the published point. Holdout must test a frozen neighborhood-level rule.

## I. Modular/BW ambiguities

### AMB-BW-001 — Brillouin-zone measure and taste multiplicity

- **Gap:** The prose refers to a halved BZ and two taste bands but writes
  normalized expectations without an explicit integration domain/measure.
- **Plan:** Derive both full-BZ and reduced-BZ formulas and prove their
  equivalence including multiplicities before evaluating moments.

### AMB-BW-002 — Entanglement-Hamiltonian convention

- **Gap:** `K=log((1-C)/C)` versus its negative, correlation-matrix orientation,
  and clamping conventions can flip signs without changing gradient magnitude.
- **Plan:** Fix the reduced-state convention from first principles and test a
  two-site analytic example. Report sign and magnitude separately.

### AMB-BW-003 — Direct 3D measurement details

- **Gap:** The supplied paper does not fully specify clamp calibration,
  double-double kernel, fit windows, or finite-volume sequence.
- **Plan:** The exact moment formula is the primary target. Direct 3D agreement
  is an independently designed convergence test, not a bitwise reproduction.

### AMB-BW-004 — Prior external theorem

- **Gap:** The chain formula is attributed to Eisler and is not a QRN-specific
  discovery.
- **Decision:** Verify the formula as a known-theorem oracle; claim independent
  work only for the normalization mapping, BZ reduction, and our computations.

## J. Gravitational-response ambiguities

### AMB-GRAV-001 — BOND-A is a scheme, not a unique metric coupling

- **Gap:** The document explicitly defines a bond-strain source but does not
  prove it is the lattice Hilbert/Belinfante stress tensor.
- **Decision:** Result types remain `StaticSpatialStressResponse` until source
  matching succeeds. Failure is scientific termination of the gravitational
  interpretation, not a reason to change scheme post hoc.

### AMB-GRAV-002 — Missing earlier vertex definitions

- **Gap:** Several formulas refer to v26.2–v26.5 conventions not included here.
- **Plan:** Derive vertices directly from the explicit `H[h]` wherever closed.
  Anything depending on absent definitions is `Conditional` and receives
  multiple reasonable implementations or no claim.

### AMB-GRAV-003 — Static versus dynamic Ward identities

- **Gap:** A static longitudinal spatial component alone cannot diagnose the
  full four-dimensional conservation law; the document later corrects its own
  earlier interpretation.
- **Decision:** Use the amended semantics. Full gravitational polarization is
  unavailable until temporal components and contacts close the 4D Ward system.

### AMB-GRAV-004 — Continuum oracle normalization

- **Gap:** Euclidean/Minkowski signs, `delta S=(1/2) int hT`, flavor/taste
  factors, Frobenius channel normalization, and effective-action factors of
  two are not fully derived in the supplied text.
- **Plan:** Two independent analytic derivations must agree before any lattice
  ratio is scored. Literature constants cannot be copied before mapping these
  conventions.

### AMB-GRAV-005 — Continuum trajectory

- **Gap:** Finite-volume `N` scaling at fixed lattice mass is not an `a->0`
  trajectory. The paper explicitly warns about this.
- **Decision:** Store `a`, physical `m,q,L`, taste count, and discretization in
  typed configurations. Runs lacking them cannot claim regulator universality.

### AMB-GRAV-006 — Extrapolation model

- **Gap:** The specification amends an earlier conventional fit with derived
  staggered `a^2 log(1/a)+a^2` and Wilson `a+a^2` forms.
- **Decision:** Use the latest preregistered forms for paper-comparison runs,
  but independently derive the asymptotic basis before implementation. Report
  both full and tail windows without selecting after seeing the limit.

### AMB-GRAV-007 — Pole semantics

- **Gap:** The original `DeltaE^2->0` condition was corrected to invariant mass
  `M^2=DeltaE^2-q^2->0` plus nonvanishing residue.
- **Decision:** Only the amended condition is valid. Older near-zero-denominator
  language is retained as a negative control.

### AMB-GRAV-008 — Dynamic metric fork

- **Gap:** Even a universal matter-loop form factor does not by itself define a
  dynamical metric, gauge fixing, universal coupling, or a composite graviton.
- **Decision:** Enforce the document's gate/type system. The default endpoint
  is an external-metric response unless all dynamic conditions are separately
  met.

## K. Reproducibility and holdout ambiguities

### AMB-REP-001 — Who holds the holdout secret

- **Gap:** The secret must be committed at freeze but not available to the
  implementation agent before freeze.
- **Decision:** The human operator supplies only `SHA256(secret)` before the
  freeze commit and supplies `secret` after freeze. If this separation is not
  available, the run is labeled deterministic post-freeze holdout rather than
  externally hidden holdout.

### AMB-REP-002 — Validation reuse after failure

- **Gap:** “Principally once” does not define recovery from an instrument bug.
- **Decision:** Any code or threshold change after viewing validation retires
  that validation ID permanently. A new committed validation seed/ID is needed;
  all prior outcomes remain in the report.

### AMB-REP-003 — Git commit during freeze

- **Gap:** A commit is required, but identity/signing and branch policy are not
  specified.
- **Decision:** Use the existing repository identity and a dedicated freeze
  commit without rewriting history. Record the exact hash; no tags/releases are
  needed for scientific freeze unless requested separately.

### AMB-REP-004 — Machine-dependent reproducibility

- **Gap:** Julia BLAS uses 10 threads by default while Julia itself starts with
  one compute thread; reduction order may vary.
- **Decision:** Experiments record both counts. Reference/freeze runs set thread
  counts explicitly; deterministic exact tests must be independent of thread
  scheduling.

## L. Resolution policy

An ambiguity is considered resolved only by one of:

1. an explicit equation or definition already present in the allowed corpus;
2. an independent mathematical derivation whose assumptions are stated;
3. multiple implementations showing the result is interpretation-invariant;
4. an explicit scope restriction and abstention.

“The original code probably did X”, matching a quoted result, or choosing the
variant with the best paper agreement are prohibited resolution methods.
