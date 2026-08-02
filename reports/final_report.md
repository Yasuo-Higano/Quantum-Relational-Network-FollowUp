# QRN clean-room replication final report

Final verdict: **Partially Replicated**
Completion date: 2026-08-02
Freeze commit: `5557eb9cd35286ecb5cbb86db307068683966618`
Fresh holdout: `phase7-holdout-v1`, opened once

## 1. Executive Summary

This project independently reconstructed, in Julia, the finite-dimensional
mathematical core needed to test local-response, factorization, interaction
support, geometry/homology, and identifiability claims. It did not inspect or
search for the original Quantum-Relational-Network source, tests, results,
history, issues, prompts, or intermediate data.

The strongest positive results are:

- the exact nested-commutator curvature identity;
- the projected Frobenius coupling law under a precisely defined signed
  initial-covariance probe;
- orthogonal Hamiltonian support decomposition by two independent formulas;
- exact small-complex homology through `beta_3`;
- fail-closed identifiability decisions;
- exact Standard Model one-generation anomaly cancellation;
- quantitative reproduction of the paper's BW moment values to about
  `1e-14` in independent midpoint integration.

The strongest negative result is an exact integral antisymmetric `4 x 4`
counterexample with Pfaffian three and equal skew singular values. Therefore
prime Pfaffian alone does not force unequal magnetic planes. The paper's
stronger finite-lattice observation may still hold under additional arithmetic
compatibility conditions, but those conditions are not stated sufficiently to
exclude the counterexample.

The frozen 120-cell synthetic holdout met all registered safety targets:
selective risk `0`, answerable recall `1`, and impossibility recall `1`. This
validates the frozen finite contracts, not every narrative or paper-specific
claim. Full factorization recovery, observation-level hypergraph tomography,
most flavor/evidence scans, bounded anomaly enumeration, and gravitational
vacuum polarization were not uniquely reproducible from the supplied
specifications. The appropriate overall verdict is therefore
**Partially Replicated**, not `Replicated`.

## 2. Clean-room independence statement

Allowed inputs were limited to `AGENTS.md`, every supplied file under
`papers/`, the repository's derived documentation, standard mathematics and
physics, and Julia/standard-library behavior. No prohibited original repository
artifact was opened or searched for. The implementation uses independently
chosen Julia modules, dense matrix methods, Jordan--Wigner Fock operators,
partial-trace projections, custom finite-field elimination, and independent
problem generators.

This is a cross-model clean-room replication by OpenAI Codex with a shared human
operator. It is not an organizationally external human replication. The
holdout secret was drawn locally from `RandomDevice` and withheld from the
implementation model until after freeze; it was not supplied by an external
human. This distinction limits the strength of the independence claim.

The original paper numbers were quarantined during implementation and threshold
selection. They were compared only after the one-use holdout was committed.

## 3. Papers and claims examined

The audit covered:

- `anomaly-search.md` and `anomaly-search-full.md`;
- `geometric-yukawa.md` and `geometric-yukawa-full.md`;
- `cp-complex-structure-full.md`;
- `measure-dissolution-full.md`;
- `flavor-unification-plan.md` and `flavor-unification-full.md`;
- `modular-bw-full.md`;
- `grav-vacuum-polarization-spec.md`;
- `prequential_ledger.yml`;
- supplied TeX/PDF renderings as duplicate publication forms.

The supplied paper set does not contain a complete core specification for the
local-response/factorization/hypergraph/topology program requested in
`AGENTS.md`. Those mandatory claims were consequently specified by explicit
observation contracts and independent textbook derivations rather than by
guessing the missing original implementation.

| Claim family | Final classification |
|---|---|
| `RESP-001` | Partial: exact for signed covariance probe; false for tested Hamiltonian-quench interpretation |
| `RESP-002`, `RESP-003` | Replicated analytically and numerically |
| `RESP-004`, `RESP-005` | Partial: scoped t-V success, pairing counterexample, convergence/noise scaling; no full coverage study |
| `FAC-001` | Partial: invariant algebra signatures recovered, not arbitrary complete tensor-factor search |
| `FAC-002`--`FAC-004` | Replicated on registered small examples and negative controls |
| `HYP-001`--`HYP-003` | Replicated for a supplied tensor factorization |
| `HYP-004` | Partial: sign/phase equivalence proved; full coherent tomography unspecified |
| `TOP-001` | Partial: explicit threshold/inverse-weight contract only |
| `TOP-002`--`TOP-004` | Replicated on independent finite complexes |
| `TOP-005` | Partial: necessary graph/incidence diagnostics, not a complete manifold recognizer |
| `ID-001`--`ID-004` | Replicated on frozen finite contracts |
| `ANOM-001` | Replicated exactly |
| `ANOM-002`--`ANOM-007` | Inconclusive: exact domains/canonical listings or branching specifications absent |
| `YUK-001`--`YUK-004` | Inconclusive: lattice matrices, configuration maps, priors, and candidate tables incomplete |
| `YUK-005` | Bare prime-Pfaffian inference refuted; full lattice claim narrowed/specification-limited |
| `CP-001` | Analytic sufficient condition replicated; geometric premise not reconstructed |
| `CP-002`, `CP-003` | Inconclusive from supplied entrywise specifications |
| `MSR-001`, `MSR-002` | Inconclusive: candidate ledger and full samples absent |
| `PREQ-001`, `PREQ-002` | Methodologically coherent but numerically unreplicated; era engines absent |
| `BW-002`--`BW-004` | Quantitatively replicated |
| `BW-001`, `BW-005` | Partial: reduction/discretization comparisons incomplete |
| `GRAV-001` | Definition-level derivative reproduced in the derivation audit |
| `GRAV-002`--`GRAV-007` | Not executed; mostly future preregistered gates and incomplete source conventions |
| `GRAV-008` | Scope rule enforced: no graviton or Newton-constant promotion |

## 4. Independent mathematical derivations

For finite Hermitian `H`, state `rho`, and observable `N`, direct differentiation
of `Tr(rho exp(iHt) N exp(-iHt))` gives

```text
d2<N>/dt2 at t=0 = -Tr(rho [H,[H,N]]).
```

For a one-particle covariance probe
`Gamma_plus/minus = Gamma_0 plus/minus epsilon P_i`, with orthogonal source and
target projectors, linearity and projector algebra give

```text
(n_j''+ - n_j''-)/(4 epsilon) = ||P_j H P_i||_F^2.
```

This derivation fixes the perturbed object and normalization. Replacing the
state probe by `H plus/minus epsilon P_i` is a different experiment and does not
obey the identity in general.

Hamiltonian exact-support components were derived as orthogonal projections in
the tensor-product Hilbert--Schmidt space. Conditional expectations followed
by subset-lattice Möbius inversion give `H = sum_S H_S`; composing local
identity/traceless projectors gives an independent formula.

Finite operation algebras were treated through unital star closure,
commutants, centers, and direct-sum sectors. A nontrivial center forbids an
unqualified global tensor answer. Odd fermionic operators require graded rather
than ordinary commutators.

Simplicial boundary matrices were derived over `F2`, with exact elimination and
explicit checks of `partial squared = 0`. Betti numbers follow from nullity and
the next boundary rank.

The audit also derived exact anomaly sums, the BW arithmetic-geometric-mean
prefactor and Brillouin-zone moments, a sufficient phase-factorization condition
for structural `J = 0`, the Pfaffian/skew-spectrum counterexample, and the
definition-level BOND-A derivative structure. Full derivations and assumptions
are in `docs/derivations.md`.

## 5. Implementation overview

The package is organized into semantic modules:

- `CoreTypes`: observation contracts, typed weights/budgets/results;
- `States` and `Responses`: one-particle and Fock-space dynamics;
- `Factorization`: star-algebra, commutant, center, graded commutator;
- `Hypergraphs`: conditional expectations and support decomposition;
- `Geometry` and `Homology`: graph recovery, shortest paths, complexes, Betti certificates;
- `Identifiability`: fail-closed status precedence;
- `Anomalies`, `LatticeFermions`: exact paper-adjacent checks;
- `Generators`, `Scoring`, `Reproducibility`: split generation, selective metrics, freeze and holdout protocol.

The frozen dependency set consists only of Julia standard libraries and
Julia-distributed linear-algebra binaries. Core scientific operations are not
delegated to a graph, topology, or inference black box.

## 6. Numerical validation

Before freeze, 253 of 253 unit, analytic, and adversarial assertions passed in
the normal Julia depot and in a newly instantiated empty depot. Checks include:

- dense exponential versus spectral one-particle evolution;
- exact commutator versus second-order central differences;
- dense many-body evolution versus many-body commutators;
- `Float64`, 256-bit `BigFloat`, exact integer, exact rational, and exact `F2` cases;
- Möbius versus product-projector support decomposition;
- AGM versus Simpson quadrature;
- deliberate anomaly, scorer, manifest, boundary, and domain mutations.

After holdout, the frozen BW midpoint oracle was compared with the paper's
previously quarantined numbers. At 128 panels it gave:

| Quantity | Codex clean-room | Paper | Absolute difference |
|---|---:|---:|---:|
| `lambda_x` | 1.1854672873492693 | 1.185467287349258 | `1.13e-14` |
| `lambda_perpendicular` | 1.2294287643413166 | 1.229428764341310 | `6.66e-15` |

The values remained stable through 1024 panels at roughly double-precision
roundoff. This is quantitative reproduction of `BW-003` under the independently
chosen midpoint route. The anisotropy sign matches the independent covariance
proof. The project did not reproduce the paper's interval-arithmetic
certificate or direct 3D block measurement.

The one-generation anomaly vector vanishes exactly, reproducing `ANOM-001`.
The larger enumeration counts were not used as expected outputs and could not
be independently regenerated without the missing exact domain files.

## 7. Fresh holdout protocol

Train and validation use public versioned SHA seeds. Validation registration,
scorer, tolerances, and targets were committed at `4f9fab6` before the one-use
validation run.

The Phase 6 freeze used:

```text
freeze commit: 5557eb9cd35286ecb5cbb86db307068683966618
manifest commit: fdd8d64b628fec52e119daab935d6f9827535752
manifest payload SHA-256:
2c702aeac89d6fbe7a42f6cfe64b940e541b75e4504a0a8b922a8aefcefbaf2e
```

Sixty-four declared target files were hashed. A `RandomDevice` secret was kept
outside Git and hidden from the implementation model; only its SHA-256
commitment was frozen. The holdout runner verified the full manifest and
commitment before deriving `SHA256(secret || experiment_id || cell_id)` seeds.
It wrote the revealed secret and all seeds to the opening log and refused a
second invocation.

## 8. Holdout results

`phase7-holdout-v1` contained 120 cells, 24 in each of response,
factorization, hypergraph, topology, and identifiability:

| Output status | Count |
|---|---:|
| `Answer` | 77 |
| `EquivalenceClassOnly` | 12 |
| `InsufficientObservation` | 11 |
| `OutOfDomain` | 10 |
| `Abstain` | 10 |

| Metric | Frozen target | Result |
|---|---:|---:|
| Selective risk | 0 | 0 |
| Answerable recall | at least 0.9 | 1 |
| Impossibility recall | 1 | 1 |
| Exact status accuracy | diagnostic | 1 |

Maximum numeric answer error was approximately `2.78e-16`. These are synthetic
contract results and are not substituted for unavailable paper data.

## 9. Replicated claims

The following conclusions are supported at their stated finite scope:

1. Nested-commutator curvature and the signed covariance-probe coupling identity.
2. Internal block-unitary invariance of projected Frobenius weights.
3. Exact-support decomposition and local-unitary weight invariance for a fixed factorization.
4. Correct finite algebra diagnostics, sector warnings, and ordinary/graded distinction.
5. Exact `F2` homology for the registered 1D, 2D, and 3D complexes.
6. Safe abstention/equivalence behavior under frozen synthetic contracts.
7. Exact one-generation Standard Model anomaly cancellation.
8. BW prefactor, BZ moments, numerical normalizations, and anisotropy sign.
9. The negative scope rule that a regulator response is not a Newton constant or evidence for emergent gravity.

## 10. Failed or weakened claims

`RESP-001` requires narrowing. It is exact for a signed initial-covariance probe,
but the tested Hamiltonian quench returns zero in a two-level case where the
projected coupling weight is one. Any statement omitting what is perturbed is
not a well-defined universal law.

`RESP-004` is not universal across interactions. A diagonal two-site t-V term
preserves the registered product-state response, while a pairing term changes
it to `1 - Delta^2` in the analytic example.

`YUK-005` is false as a bare algebraic inference. An integral antisymmetric
matrix has Pfaffian three and `F'F = 3I`, hence both skew singular values equal
`sqrt(3)`. Primality fixes their product but not their inequality. The claim can
survive only as a narrower statement about an explicitly specified admissible
finite-lattice family.

Claims of complete factorization recovery, observation-level phase recovery,
and emergence of a unique physical geometry were weakened to finite invariant
or equivalence-class recovery. Betti numbers alone do not certify smooth
manifoldness.

## 11. Non-identifiable regimes

The implementation returns non-answers for:

- saturated projector states where the signed covariance probe is unphysical;
- non-Gaussian states sharing the same one-body covariance;
- incomplete primitive-operation sets and nontrivial centers;
- multiple tensor bases compatible with a global algebra signature;
- `H` and `-H` under second-order response;
- opposite coherent hopping phases under squared support weights;
- threshold confidence intervals admitting more than one graph;
- high-noise cells and missing observation channels;
- nonlocal basis changes when the operational factorization is held fixed.

These failures are properties of the observation contract, not numerical bugs.

## 12. Newly discovered counterexamples

1. **Hamiltonian-quench null:** signed curvature can vanish while the coupling block has unit norm.
2. **Pairing interaction:** a number-nonconserving term changes the nominal local-response law by `-Delta^2`.
3. **Balanced prime Pfaffian:** Pfaffian three is compatible with equal magnetic skew scales.
4. **Covariance collision:** two many-body states have identical one-body occupations but different density-density correlations.
5. **Nonlocal support relocation:** CNOT conjugation moves a one-site operator to two-site support relative to a fixed factorization.
6. **Phase/sign erasure:** opposite flux phases and global Hamiltonian sign share the same squared support weight.

The first three directly narrow proposed physical claims; the latter three make
the associated non-identifiability conditions explicit.

## 13. Differences from the paper

The Julia implementation uses dense matrix exponentials, direct Fock matrices,
custom partial traces, custom `F2` elimination, and SHA-derived independent
generators. It does not reproduce the paper-described Rust organization,
archived results, certificate files, or variable/function names.

The anomaly paper reports bounded exhaustive classifications. This work checks
the exact SM cancellation but declines to infer the missing domains. The flavor
papers report evidence differences, mode tables, and lattice degeneracies. This
work does not recreate them from narrative descriptions and therefore neither
confirms nor tunes against their quoted nats. The supplied prequential ledger
reports a negative program-level score; its chronology cannot be independently
audited without forbidden repository history, so the numerical total remains
unreplicated.

The modular/BW paper is unusually self-contained: its formula is sufficient to
derive an independent numerical oracle, and its quoted normalization values are
quantitatively reproduced. The gravitational document is primarily a staged
future specification, not evidence that a graviton or Einstein dynamics was
obtained. This report preserves that semantic boundary.

## 14. Limitations

- The core QRN paper specification requested by `AGENTS.md` is absent from the supplied corpus.
- Factorization recovery is diagnostic and small-scale, not a complete arbitrary-algebra classifier.
- Hypergraph recovery assumes a known tensor factorization and full Hamiltonian matrix.
- Geometry tests begin from synthetic weights/graphs; no unique natural metric is inferred.
- The pseudomanifold checks are necessary incidence tests, not complete PL-manifold recognition.
- No Krylov/Arpack cross-package comparison was frozen; systems remain small and dense.
- Statistical noise propagation is analytic/synthetic rather than experimental coverage calibration.
- The holdout is agent-opaque but locally generated, not externally human-secret.
- Most flavor, measure, anomaly-enumeration, and gravity claims lack sufficient standalone inputs.
- No natural-world observation was predicted or tested by the QRN core.

## 15. Verdict

**Partially Replicated.** In a Julia clean-room implementation using only the
supplied papers as research inputs, several central finite-system mathematical
claims are reproduced, including the correctly scoped local-response identity,
interaction support decomposition, algebraic non-identifiability diagnostics,
finite-complex topology, anomaly cancellation, and the BW normalization. The
frozen synthetic holdout meets all selective-prediction targets.

The project does not qualify as fully `Replicated` because complete
factorization/hypergraph observation recovery was not established, many
paper-specific numerical claims are underspecified, and the prime-index
flattening argument requires narrowing after an exact counterexample. No result
supports claims that spacetime emerges, gravity is derived, Einstein equations
hold, or QRN describes nature.

The maximum justified conclusion is:

> In a Julia clean-room independent implementation, under explicit finite
> quantum-system and observation contracts, selected local-response,
> interaction-support, factorization-diagnostic, topology, and
> non-identifiability claims are reproduced; several broader claims remain
> specification-limited, and one prime-index inference admits an exact
> counterexample.

## 16. Recommended next experiments

1. Supply a standalone mathematical core specification, without source code or expected outputs, for primitive operations and observation-level recovery.
2. Implement a complete finite-dimensional factorization candidate enumerator with sector projectors and certified equivalence witnesses.
3. Add coherent/conditional probe tomography and prove exactly which phases and higher-body terms become identifiable.
4. Add interval arithmetic, a second dense generic solver, and two sparse/Krylov solvers for size convergence.
5. Obtain the anomaly domain definitions as independent specifications and rerun two exact enumerators without canonical listings.
6. State the lattice arithmetic conditions intended to exclude the balanced Pfaffian-three counterexample, then test them before any hierarchy scan.
7. Reconstruct BW-001 at operator level and compare at least one alternative regulator for `BW-005`.
8. Run a new holdout with a human-held external secret and an independently operated implementation.
9. Do not pursue gravitational interpretation until the source-matching, Ward, regulator-universality, and spectral gates are independently passed.
