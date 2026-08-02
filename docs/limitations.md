# Limitations

The final verdict is `Partially Replicated`. The main limitations are:

- The supplied papers do not contain a complete core QRN specification for
  local-response, operation-network factorization, interaction-hypergraph, and
  geometry recovery.
- The response law is contract-dependent: it holds for the registered signed
  covariance probe, not for an arbitrary Hamiltonian quench or arbitrary
  interaction.
- Factorization code recovers finite algebra/commutant/center signatures and
  safe equivalence statuses, not all tensor-factor representatives.
- Hypergraph decomposition starts from a known factorization and Hamiltonian;
  it is not complete tomography from limited probes.
- Geometry/homology tests start from generated weights, graphs, or complexes.
  They do not identify a unique physical metric from correlations.
- The manifold qualification is a necessary low-dimensional incidence test,
  not a complete manifold-recognition algorithm.
- The frozen solver suite is dense and small-scale. Krylov, Arpack, interval,
  and broad size-convergence comparisons remain future work.
- The holdout secret was hidden from the implementation model but locally
  generated, not held by an external human or organization.
- Exact bounded anomaly domains, lattice link matrices, flavor configuration
  tables, measure candidates, and gravity source conventions are incomplete or
  absent from the supplied standalone corpus.
- No natural-world observation was predicted by the frozen QRN core. Nothing
  here establishes emergent spacetime, gravity, Einstein equations, or a
  unified theory.

See `reports/final_report.md` for claim-level classifications and recommended
experiments.
