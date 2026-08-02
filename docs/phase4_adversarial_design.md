# Phase 4 independent generators and adversarial design

Status: completed 2026-08-02

## 1. Seed and split contract

Train and validation cell seeds are derived from SHA-256 over a domain label,
split, schema version, family, and cell ID. No mutable global random-number
state is used. Holdout derivation is a separate API requiring both a nonempty
post-freeze secret and experiment ID:

```text
seed = SHA256(secret || experiment_id || cell_id)
```

The Phase 4 tests call only public train generation. They verify that holdout
generation without a secret fails closed. No holdout instance, parameter, or
seed exists at this milestone.

## 2. Registered families and scenarios

The five core families are response, factorization, interaction hypergraph,
topology, and cross-cutting identifiability. Every family cycles through ten
scenarios:

1. positive;
2. null;
3. weak signal;
4. basis changed;
5. boundary variant;
6. inhomogeneous;
7. equivalent latent models;
8. missing observation;
9. out of domain;
10. high noise.

The first six are registered as uniquely answerable for the finite invariant
actually scored by the cell. The remaining four map respectively to
`EquivalenceClassOnly`, `InsufficientObservation`, `OutOfDomain`, and
`Abstain`. This registration predates validation and holdout observation.

## 3. Independent answer oracles

- Response cells compare signed covariance curvature with a directly generated
  projected hopping magnitude.
- Factorization cells compare computed algebra, commutant, and center
  dimensions with tensor-multiplicity formulas. They score only these finite
  invariants, not a preferred tensor basis.
- Hypergraph cells compare Mobius-extracted support weights with norms of
  independently assembled Pauli-product components.
- Topology cells compare custom `F2` boundary elimination with analytic Betti
  vectors of named small complexes.
- Identifiability cells test the fail-closed status ordering with explicit
  observation-contract evidence.

The target status is stored in the case schema, but the evaluator derives its
status from in-domain, observation-completeness, equivalence, and numerical
resolution predicates rather than reading that target status.

## 4. Dedicated adversarial checks

Response tests include open and periodic hopping, inhomogeneous Hermitian
couplings, perturbation-strength ladders, internal block-unitary transformations,
and explicit inverse-`epsilon` noise amplification. A saturated projector state
rejects an invalid signed covariance probe. Two many-body states with identical
one-body occupations but different density-density correlations demonstrate
why a Gaussian covariance oracle cannot identify general non-Gaussian states.

Interaction tests use Jordan--Wigner Fock operators for on-site, hopping,
density-density, correlated hopping, pair hopping, and genuine three- and
four-site support. A nonlocal CNOT changes support relative to a fixed tensor
factorization, while local unitaries preserve support weights. Hamiltonian sign
and opposite coherent hopping phases yield the same squared support weight.

Topology tests independently construct rectangular grid triangulations,
periodic surfaces, connected sums, simplex boundaries, and a Freudenthal
triangulation of the 3-torus. Betti vectors are checked for disk, cylinder,
two-hole disk, sphere, torus, genus-2, 3-ball, 3-sphere, and 3-torus. Petersen,
random regular, complete, and branched examples are not promoted to smooth
manifolds merely from homology. A separate codimension-one incidence check
detects the registered branching example.

## 5. Scientific boundaries

The factorization cells currently recover algebraic dimension signatures and
safe equivalence statuses, not every tensor-factor representative. Geometry
cells validate threshold graphs and exact small-complex topology; they do not
derive a unique physical metric from arbitrary correlations. Conditional and
coherent observations demonstrate visibility limits but do not provide full
experimental tomography.

Paper-specific flavor, CP shear, measure-selection, and gravity calculations
whose defining data are missing remain specification-limited. They are not
silently replaced by synthetic successes. Phase 5 will calibrate and score only
the explicitly registered finite contracts above.
