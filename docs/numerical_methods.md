# Phase 3 numerical methods and analytic checks

Status: Phase 3 completion record, 2026-08-02
Scope: small analytic systems only; no train, validation, or holdout data

## 1. Numerical independence

The Phase 3 implementation uses only Julia's `LinearAlgebra` standard library.
No original QRN source, result, test, history, or intermediate data was used.
Algorithms and test instances were constructed from the supplied paper prose,
the independent derivations in `docs/derivations.md`, and standard finite
dimensional linear algebra.

Small systems are deliberately evaluated by structurally different routes:

| Quantity | Primary route | Independent route or oracle |
|---|---|---|
| One-particle population | dense matrix exponential | Hermitian eigendecomposition |
| Initial curvature | exact nested commutator | symmetric time finite difference |
| Coupling weight | projected Frobenius norm | signed state-response curvature |
| Many-body curvature | Fock-space nested commutator | dense density-matrix evolution |
| Support components | subset Mobius inversion | product of local trace projections |
| Homology | custom Gaussian elimination over `F2` | known balls, spheres, paths, and cycles |
| BW prefactor | arithmetic-geometric mean | composite Simpson quadrature |
| Anomalies | exact integer sums | known one-generation cancellation and mutation |

## 2. Local response

For Hermitian one-particle `h`, covariance `Gamma`, and target projector `P_j`,
the implementation evaluates

```text
n_j''(0) = -Tr(Gamma [h,[h,P_j]]).
```

The signed initial-state probe `Gamma_0 +/- epsilon P_i` reproduces
`||P_j h P_i||_F^2` on the analytic two- and three-mode cases. A 256-bit
`BigFloat` two-mode example checks the rational value `9/49` to a small
multiple of machine epsilon at that precision. A central time stencil shows
the expected second-order error reduction before roundoff, while dense
exponential and spectral evolution agree directly.

A Hamiltonian quench by `+/- epsilon P_i` is retained as a null
counterexample: under the tested contract its signed curvature is zero while
the projected coupling weight is one. The observation contract therefore
cannot leave the perturbed object unspecified.

## 3. Interacting many-body response

Spinless fermion operators are built independently with Jordan--Wigner strings
and checked against the canonical anticommutation relations on three modes.
For a two-site hopping Hamiltonian, physical product density matrices differing
by a signed occupation probe give unit response. Adding a diagonal
density-density term preserves this value in the registered product-state
case. The exact many-body commutator curvature is independently reproduced by
dense real-time density-matrix evolution with second-order stencil scaling.

A number-nonconserving pairing term changes the signed response to
`1 - Delta^2` in the registered two-site example. This is a scoped
counterexample to extending the number-conserving projector law to arbitrary
interactions without changing assumptions or observables.

## 4. Factorization and identifiability

Finite-dimensional unital star-algebras are closed by rank-revealing linear
independence tests. Their commutants and centers are computed from linear
commutator constraints. Hand-built qubit-qutrit and three-qubit tensor actions
check algebra and commutant dimensions. A two-sector direct sum checks that a
nontrivial center is reported as insufficient for a unique factorization.
Node permutation preserves the diagnostic dimensions.

Ordinary and graded commutators are tested separately for odd fermionic
operators. The decision layer enforces the registered status precedence and
does not emit `Answer` for missing observations, non-Gaussian input to a
Gaussian oracle, equivalent `H`/`-H` models, threshold-crossing uncertainty,
or multiple equally admissible factorizations.

These diagnostics characterize finite algebraic evidence; they do not yet
constitute a complete factorization-recovery search over arbitrary generator
sets.

## 5. Interaction supports

Hamiltonians are decomposed into exact Hilbert--Schmidt support components by
partial-trace Mobius inversion. A second implementation composes local
identity and traceless projections. Exact rational two-factor examples agree
component by component, reconstruct the input exactly, and are mutually
orthogonal. A three-factor example separates a genuine three-body term from a
two-body term. Local unitary changes preserve all support weights within the
declared floating budget.

The current stage assumes a supplied tensor factorization. Conditional and
coherent probe recovery, phase identifiability, and hidden high-body generator
families belong to Phase 4.

## 6. Geometry and homology

Clique and Vietoris--Rips complexes are constructed independently from
adjacency and distance matrices. Boundary matrices and ranks are computed
exactly over `F2`. Tests cover paths, cycles, complete graphs, a filled
tetrahedron, and boundaries of tetrahedra and 4-simplices, giving the expected
`beta_0` through `beta_3` for 3-balls, 2-spheres, and 3-spheres. The chain
condition is checked explicitly.

This validates the small-complex homology core. Surface triangulation
generators, inferred weighted geometry, manifold diagnostics, and adversarial
regular graphs remain Phase 4 work.

## 7. Exact paper-adjacent checks and counterexample

One Standard Model generation is represented by exact integer multiplicities
and integer-scaled hypercharges. All registered gauge, mixed, gravitational,
and Witten anomaly checks cancel exactly; a one-charge mutation is rejected.

For the lattice-flux claim, an explicit integral antisymmetric `4 x 4` matrix
has prime Pfaffian three while both skew singular values equal `sqrt(3)`. This
refutes the bare algebraic implication that prime Pfaffian alone forces unequal
magnetic planes. It does not refute a stronger finite-lattice statement with
additional compatibility hypotheses that are absent from the supplied prose.

For the one-dimensional BW chain, the arithmetic-geometric-mean formula and
direct Simpson quadrature agree, including a 256-bit convergence check.
Independent midpoint Brillouin-zone moments reproduce the claimed anisotropy
sign without using quarantined paper target numbers as tuning inputs.

## 8. Test and precision policy

The Phase 3 suite contains 153 assertions. Exact domains use integers,
rationals, or `F2` arithmetic. Floating comparisons use analytic-scale
tolerances or observed convergence ratios rather than a project-wide constant.
The suite is run with:

```bash
julia --project=. test/runtests.jl
julia --project=. -e 'using Pkg; Pkg.test()'
```

Phase 3 does not claim size convergence, noise calibration, sparse-solver
agreement, or holdout performance. Those are explicit gates for later phases.
