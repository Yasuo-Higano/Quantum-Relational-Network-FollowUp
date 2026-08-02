# Independent derivations

Status: Phase 2 analytic baseline, 2026-08-02
Sources: supplied papers, `AGENTS.md`, and standard finite-dimensional
quantum mechanics, linear algebra, operator algebra, and algebraic topology.
No original implementation, result artifact, or original-repository history was
used.

## 1. Conventions

All Hilbert spaces in the initial implementation are finite-dimensional. The
inner product on operators is

```math
\langle A,B\rangle_{\mathrm{HS}}=\operatorname{Tr}(A^\dagger B),
\qquad
\|A\|_F^2=\operatorname{Tr}(A^\dagger A).
```

For a tensor product `H = tensor_i H_i`, `P_i` denotes an orthogonal projector
onto a block only in the direct-sum single-particle setting. It is not silently
identified with the many-body number operator `N_i`. Hermitian time evolution
uses `U(t)=exp(-iHt)` and units with `hbar=1`.

The normalized partial trace onto a subset `T` is the Hilbert-Schmidt
conditional expectation

```math
E_T(A)=\frac{\operatorname{Tr}_{V\setminus T}A}
              {\prod_{i\notin T}d_i}\otimes I_{V\setminus T}.
```

This normalization makes `E_T` an orthogonal projector in operator space.

## 2. Universal short-time curvature identity

Let a state `rho` evolve under a time-independent Hermitian `H`, and let `N_j`
be a Hermitian observable. In the Heisenberg picture,

```math
N_j(t)=e^{iHt}N_j e^{-iHt}.
```

Differentiation gives

```math
\dot N_j(t)=i[H,N_j(t)],
\qquad
\ddot N_j(t)=-[H,[H,N_j(t)]].
```

Therefore

```math
\boxed{
\ddot n_j(0)=-\operatorname{Tr}\!\left(\rho[H,[H,N_j]]\right),
\qquad n_j(t)=\operatorname{Tr}(\rho N_j(t)).
}
```

This identity is general. The stronger coupling-recovery identity below needs
additional assumptions.

## 3. Exact coupling recovery for a direct-sum single-particle system

### 3.1 Setup

Let the single-particle Hilbert space be an orthogonal direct sum

```math
\mathcal H=\bigoplus_{k=1}^m\mathcal H_k,
\qquad P_kP_l=\delta_{kl}P_k,
\qquad \sum_kP_k=I.
```

Let `h=h^dagger` be the one-particle Hamiltonian and `Gamma` a one-particle
density/covariance matrix. The population of block `j` is

```math
n_j(t)=\operatorname{Tr}\!\left(P_j e^{-iht}\Gamma e^{iht}\right).
```

Prepare two covariances

```math
\Gamma_\pm=\Gamma_0\pm\epsilon P_i.
```

They need not have equal trace: this contract represents a signed population
injection/removal. They are physical fermionic covariances only if
`0 <= Gamma_plus/minus <= I`; thus `Gamma_0` must have sufficient spectral
slack on block `i`.

### 3.2 Projector trace lemma

For `i != j`, expand the double commutator:

```math
[h,[h,P_j]]=h^2P_j-2hP_jh+P_jh^2.
```

Orthogonality and cyclicity give

```math
\operatorname{Tr}(P_i h^2P_j)=0,
\qquad
\operatorname{Tr}(P_iP_jh^2)=0.
```

Moreover,

```math
\operatorname{Tr}(P_i hP_jh)
=\operatorname{Tr}(P_i hP_jhP_i)
=\operatorname{Tr}\!\left[(P_jhP_i)^\dagger(P_jhP_i)\right]
=\|P_jhP_i\|_F^2.
```

Hence

```math
\boxed{
\operatorname{Tr}\!\left(P_i[h,[h,P_j]]\right)
=-2\|P_jhP_i\|_F^2,
\qquad i\ne j.
}
```

### 3.3 Signed-curvature theorem

Linearity in `Gamma` yields

```math
\begin{aligned}
\ddot n_j^+(0)-\ddot n_j^-(0)
&=-\operatorname{Tr}\!\left[(\Gamma_+-\Gamma_-)
 [h,[h,P_j]]\right]\\
&=-2\epsilon\operatorname{Tr}\!\left(P_i[h,[h,P_j]]\right)\\
&=4\epsilon\|P_jhP_i\|_F^2.
\end{aligned}
```

Therefore, under this precise contract,

```math
\boxed{
\frac{\ddot n_j^+(0)-\ddot n_j^-(0)}{4\epsilon}
=\|P_jhP_i\|_F^2,
\qquad i\ne j.
}
```

The result is exact for any `epsilon` for which both covariances are valid,
because the curvature is linear in the initial covariance. A small-`epsilon`
limit is needed for experimental preparation or nonlinear normalization rules,
not for this algebraic identity.

### 3.4 Dimension-normalized probes

If the perturbation is `P_i/d_i`, with `d_i=rank(P_i)`, then

```math
\frac{\ddot n_j^+(0)-\ddot n_j^-(0)}{4\epsilon}
=\frac{1}{d_i}\|P_jhP_i\|_F^2.
```

Thus the raw and per-internal-state conventions must be distinct typed
contracts.

### 3.5 Quadratic many-body realization

For fermionic operators

```math
\widehat H=\sum_{ab}h_{ab}c_a^\dagger c_b,
\qquad
\widehat N_j=\sum_{ab}(P_j)_{ab}c_a^\dagger c_b,
```

and one-particle covariance

```math
\Gamma_{ba}=\operatorname{Tr}(\rho c_a^\dagger c_b),
```

the covariance evolves as `Gamma(t)=e^{-iht} Gamma e^{iht}` and
`<N_j>=Tr(P_j Gamma)`. The theorem therefore applies to arbitrary Gaussian or
non-Gaussian many-body states whose signed preparation changes the covariance
by exactly `2 epsilon P_i`; higher correlations are irrelevant for quadratic
observables under quadratic dynamics.

### 3.6 Local basis invariance

Let `U=directsum_k U_k` be block-local. Then

```math
P_j(UhU^\dagger)P_i=U_j(P_jhP_i)U_i^\dagger.
```

Unitary invariance of the Frobenius norm proves

```math
\|P_j(UhU^\dagger)P_i\|_F=\|P_jhP_i\|_F.
```

The response matrix therefore identifies block magnitudes, not a preferred
internal basis.

## 4. Contracts for which the same response formula does not follow

### 4.1 Hamiltonian rather than state perturbation

Take `h_plus/minus=h_0 plus/minus epsilon P_i` and a common state `Gamma`.
For disjoint blocks, `[P_i,P_j]=0`, and expansion gives

```math
\ddot n_j^+(0)-\ddot n_j^-(0)
=-2\epsilon\operatorname{Tr}\!\left(
\Gamma[P_i,[h_0,P_j]]\right).
```

Consequently

```math
\frac{\ddot n_j^+(0)-\ddot n_j^-(0)}{4\epsilon}
=-\frac12\operatorname{Tr}\!\left(
\Gamma[P_i,[h_0,P_j]]\right),
```

which is state dependent and is not generally `||P_jhP_i||_F^2`. Thus the
paper-form formula cannot be applied to a local potential quench without a
different derivation.

### 4.2 Trace-preserving compensated preparation

If

```math
\Gamma_\pm=\Gamma_0\pm\epsilon(P_i-P_r),
```

then the response is the difference of two block weights:

```math
\frac{\ddot n_j^+-\ddot n_j^-}{4\epsilon}
=\|P_jhP_i\|_F^2-\|P_jhP_r\|_F^2
```

for distinct `i,r,j`. A reference block must therefore be known or separately
calibrated.

### 4.3 Interacting dynamics

Let `H=T+V`, where `V` is density diagonal, so `[V,N_j]=0`. Then

```math
[H,[H,N_j]]=[T,[T,N_j]]+[V,[T,N_j]].
```

The second term is generally nonzero. Its expectation under the signed
many-body state perturbation depends on correlations and occupations. A
density-density interaction therefore does not preserve the free response law
as an operator identity merely because it commutes with `N_j`. It may vanish in
special states or signed differences; those are scoped results requiring proof.

Pair hopping, correlated hopping, and interactions that do not commute with
`N_j` introduce still more terms. These are mandatory counterexample families.

### 4.4 Second-order non-identifiability

Replacing `h` by `-h` leaves `[h,[h,P_j]]` unchanged. The curvature contract
therefore cannot distinguish `h` from `-h`.

For rank-one blocks, the recovered value is `|h_ji|^2`, so link phase and sign
are absent. For higher-rank blocks it is the sum of squared singular values of
the coupling block. Density curvatures alone cannot recover its internal
unitary orientation.

## 5. Time-difference cross-check and error scaling

For a smooth scalar population,

```math
D_2(\delta t)=\frac{n(\delta t)-2n(0)+n(-\delta t)}{\delta t^2}
=\ddot n(0)+\frac{\delta t^2}{12}n^{(4)}(0)+O(\delta t^4).
```

Thus a three-point central curvature has second-order truncation error. If each
population measurement has independent variance `sigma_n^2`, the curvature
variance is

```math
\operatorname{Var}(D_2)=\frac{6\sigma_n^2}{\delta t^4}.
```

For paired/common-random-number measurements, covariance terms must be retained
and can reduce or increase this value. The `delta t^2` bias and `delta t^-4`
variance create an optimal region; decreasing the step indefinitely is not a
valid convergence strategy.

## 6. Orthogonal interaction-support decomposition

### 6.1 Operator-space tensor splitting

At site `i`, decompose

```math
\mathcal B(\mathcal H_i)
=\operatorname{span}\{I_i\}\oplus\mathcal T_i,
\qquad
\mathcal T_i=\{A:\operatorname{Tr}A=0\}.
```

The two subspaces are Hilbert-Schmidt orthogonal. Tensoring these choices gives
an orthogonal direct sum indexed by exact supports `S subseteq V`:

```math
\mathcal B\!\left(\bigotimes_i\mathcal H_i\right)
=\bigoplus_{S\subseteq V}
\left(\bigotimes_{i\in S}\mathcal T_i\right)
\otimes
\left(\bigotimes_{i\notin S}\operatorname{span}\{I_i\}\right).
```

Every Hamiltonian consequently has a unique orthogonal decomposition

```math
H=\sum_{S\subseteq V}H_S.
```

### 6.2 Conditional expectations and Möbius inversion

The normalized partial-trace map `E_T` keeps precisely those exact-support
components contained in `T`:

```math
E_T(H)=\sum_{S\subseteq T}H_S.
```

Möbius inversion on the subset lattice gives

```math
\boxed{
H_S=\sum_{T\subseteq S}(-1)^{|S|-|T|}E_T(H).
}
```

Therefore

```math
\langle H_S,H_R\rangle_{\mathrm{HS}}=0\quad(S\ne R),
\qquad
\|H\|_F^2=\sum_S\|H_S\|_F^2.
```

This is the primary definition of the interaction hypergraph weight
`w_S=||H_S||_F^2`. The global identity lies in `H_emptyset`; it must not be
misclassified as an on-site term.

### 6.3 Basis invariance and nonlocal changes

Local conjugation `U=tensor_i U_i` preserves the identity/traceless split at
each site, maps every exact-support subspace to itself, and preserves each
`w_S`. A genuinely entangling conjugation does not preserve this decomposition
relative to a fixed factorization and can redistribute support weights.

### 6.4 Normalization alternatives

Using normalized global trace changes all raw squared norms by a common factor
`1/prod_i d_i`. Support-normalized conventions introduce support-dependent
factors. They are convertible but not interchangeable; the norm convention is
part of the observation contract.

## 7. Finite-dimensional operator algebras and factorization

Every finite-dimensional unital star-algebra is unitarily equivalent to

```math
\mathcal A\cong\bigoplus_\alpha
\left(I_{m_\alpha}\otimes M_{n_\alpha}(\mathbb C)\right),
```

with commutant

```math
\mathcal A'\cong\bigoplus_\alpha
\left(M_{m_\alpha}(\mathbb C)\otimes I_{n_\alpha}\right).
```

The center is

```math
Z(\mathcal A)=\mathcal A\cap\mathcal A'
\cong\bigoplus_\alpha\mathbb C I_{m_\alpha n_\alpha}.
```

Thus central projectors must be recovered before tensor factors in the presence
of superselection. Within a single central block, a pair of commuting factors
`A_i,A_j` supports a tensor-factor interpretation only when, collectively,
they generate the full matrix algebra and their mutual commutants have the
required dimensions. Pairwise commutation alone is insufficient.

A binary commutation graph discards multiplication tables, representation
multiplicities, and centers. Distinct operator embeddings can therefore share
the same graph. This proves the need for `InsufficientObservation` whenever the
input is only an undercomplete graph.

For fermionic odd operators, locality is graded:

```math
[A,B]_g=AB-(-1)^{|A||B|}BA.
```

Odd operators on disjoint CAR regions anticommute, whereas parity-even
observables commute ordinarily. A factorization algorithm lacking parity labels
cannot decide which relation is intended.

## 8. Simplicial homology

For an oriented `k`-simplex `[v_0,...,v_k]`, define

```math
\partial_k[v_0,\ldots,v_k]
=\sum_{r=0}^k(-1)^r[v_0,\ldots,\widehat v_r,\ldots,v_k].
```

Each codimension-two face appears twice with opposite sign, so

```math
\partial_{k-1}\partial_k=0.
```

Over a field `F`, cycles and boundaries are

```math
Z_k=\ker\partial_k,
\qquad
B_k=\operatorname{im}\partial_{k+1},
```

and

```math
\boxed{
\beta_k=\dim Z_k-\dim B_k
=n_k-\operatorname{rank}\partial_k
-\operatorname{rank}\partial_{k+1}.
}
```

The Euler check is

```math
\sum_k(-1)^k n_k=\sum_k(-1)^k\beta_k.
```

Over `F2`, orientation signs disappear but ranks are exact bit operations. A
rational calculation provides an independent small-case rank check. Betti
numbers alone do not certify manifoldness; vertex links must separately have
the homology/combinatorics of spheres or half-spheres appropriate to the
claimed dimension and boundary.

## 9. Exact anomaly equations and the SM check

For a left-handed Weyl multiplet `(R_c,R_w)_y`, write `d_c,d_w` for dimensions,
`T_c,T_w` for quadratic indices, and `A_c` for the cubic color index. Up to
nonzero common normalization factors, the anomaly contributions are

```math
\begin{aligned}
\mathcal A_{33Y}&=d_wT_cy,\\
\mathcal A_{22Y}&=d_cT_wy,\\
\mathcal A_{\mathrm{grav}Y}&=d_cd_wy,\\
\mathcal A_{YYY}&=d_cd_wy^3,\\
\mathcal A_{333}&=d_wA_c.
\end{aligned}
```

Use the primitive convention `T(3)=T(3bar)=1`, `T(2)=1`,
`A(3)=1`, `A(3bar)=-1`. The paper's generation is

```math
(1,1)_{-6}\oplus(1,2)_3\oplus(3,1)_{-2}
\oplus(3,1)_4\oplus(\bar3,2)_{-1}.
```

The exact sums are

```math
\begin{array}{c|c}
\text{condition}&\text{sum}\\ \hline
[SU(3)]^2U(1)&(-2)+(4)+2(-1)=0\\
[SU(2)]^2U(1)&(3)+3(-1)=0\\
\mathrm{grav}^2U(1)&(-6)+2(3)+3(-2)+3(4)+6(-1)=0\\
[U(1)]^3&(-216)+2(27)+3(-8)+3(64)+6(-1)=0\\
[SU(3)]^3&1+1+2(-1)=0.
\end{array}
```

The weak doublet count weighted by color dimension is `1+3=4`, even, so the
restricted Witten condition also passes. This verifies anomaly freedom only;
minimality and uniqueness remain finite enumeration claims.

Canonical charge assignments must quotient permutation, global conjugation,
global sign, and gcd rescaling. For several `U(1)` charges, rational plane
equality and saturated integer-lattice equality are recorded separately.

## 10. CP structural-zero criterion

Suppose the up and down Yukawa matrices factor as

```math
Y^u=D_L\,R^u\,D_R^u,
\qquad
Y^d=D_L\,R^d\,D_R^d,
```

where `D_L,D_R^u,D_R^d` are diagonal unitary matrices and `R^u,R^d` are real.
The common `D_L` is essential because the same left-handed doublet participates
in both sectors. Weak-basis rephasings remove all three diagonal phase matrices,
leaving real Yukawa matrices.

Real singular-value decompositions use orthogonal left matrices `O_u,O_d`.
The CKM matrix is then

```math
V=O_u^T O_d,
```

which is real, so

```math
\boxed{J=\operatorname{Im}(V_{us}V_{cb}V_{ub}^*V_{cs}^*)=0.}
```

This proves a sufficient structural-zero theorem. The supplied documents do
not give enough overlap detail to prove that every rectangular real-Wilson
configuration has exactly this phase factorization. That geometric step remains
an implementation target. Complex Higgs phases, nonshared left rephasings, or
nonfactorizable phases can evade the sufficient conditions.

## 11. BW prefactor and Brillouin-zone moments

The supplied paper states the one-dimensional chain prefactor

```math
g(\mu)=\frac{2}{\pi}\kappa K(\kappa'),
\qquad
\kappa=\frac1{\sqrt{1+\mu^2}},
\qquad
\kappa'=\frac{|\mu|}{\sqrt{1+\mu^2}}.
```

The elliptic-integral AGM identity is

```math
K(k)=\frac{\pi}{2\operatorname{AGM}(1,\sqrt{1-k^2})}.
```

Because `sqrt(1-kappa'^2)=kappa`,

```math
g(\mu)=\frac{\kappa}{\operatorname{AGM}(1,\kappa)}.
```

Homogeneity of the AGM gives

```math
\operatorname{AGM}(1,\kappa)
=\kappa\operatorname{AGM}(1/\kappa,1),
```

and hence

```math
\boxed{
g(\mu)=\frac1{\operatorname{AGM}(1,\sqrt{1+\mu^2})}.
}
```

The integral representation follows as

```math
g(\mu)=\frac2\pi\int_0^{\pi/2}
\frac{d\theta}{\sqrt{1+\mu^2\cos^2\theta}}.
```

Differentiating under the integral for `mu>0`,

```math
g'(\mu)=-\frac2\pi\int_0^{\pi/2}
\frac{\mu\cos^2\theta\,d\theta}
{(1+\mu^2\cos^2\theta)^{3/2}}<0.
```

With independent uniform transverse momenta, set
`Y=cos^2(k_y)`, `Z=cos^2(k_z)`, `E[Y]=1/2`, and
`h(s)=g(sqrt(s))`, which is decreasing. The claimed inverse normalizations are

```math
r_x=E[h(Y+Z)],
\qquad
r_\perp=E[2Yh(Y+Z)].
```

Thus

```math
r_\perp-r_x=2\operatorname{Cov}(Y,h(Y+Z)).
```

Conditioning on `Z=z`, an increasing variable `Y` is paired with the strictly
decreasing function `h(Y+z)`, giving a strictly negative covariance unless the
distribution is degenerate. Therefore

```math
r_\perp<r_x,
\qquad
\boxed{\lambda_\perp>\lambda_x}.
```

This sign result is independent of the paper's quoted decimal values.

## 12. Counterexample to “prime Pfaffian forces unequal magnetic planes”

For a real `4x4` antisymmetric matrix, let the two positive skew singular
values be `f_+,f_-`. Then

```math
f_+^2+f_-^2=\sum_{i<j}F_{ij}^2,
\qquad
f_+f_-=|\operatorname{Pf}(F)|.
```

Consider the integer antisymmetric matrix

```math
F=\begin{pmatrix}
0&1&1&1\\
-1&0&1&-1\\
-1&-1&0&1\\
-1&1&-1&0
\end{pmatrix}.
```

Writing the independent upper-triangle entries as
`a=F12,b=F13,c=F14,d=F23,e=F24,f=F34`,

```math
\operatorname{Pf}(F)=af-be+cd=1-(-1)+1=3.
```

Also

```math
\sum_{i<j}F_{ij}^2=6.
```

The squared skew singular values are therefore the roots of

```math
x^2-6x+9=(x-3)^2,
```

so

```math
\boxed{f_+=f_-=\sqrt3.}
```

Direct Julia linear algebra independently confirmed four ordinary singular
values equal to `sqrt(3)` and `det(F)=9`.

This is an exact counterexample to the bare inference

```text
integer antisymmetric F + Pf(F)=3 + primality of 3
    => one magnetic eigenplane must flatten.
```

It is not yet a counterexample to the paper's full finite-lattice claim: the
matrix may fail additional flux-quantization, boundary-compatibility,
threefold-band, chirality, or model-specific conditions that are not stated in
the prose. The claim must therefore be narrowed to those additional conditions
or classified as specification-incomplete. This counterexample will remain in
the adversarial suite and may not be excluded after seeing its spectrum.

## 13. BOND-A variations and static kernel

For a diagonal bond strain, the defined factor is

```math
(1+h)^{-1/2}=1-\frac12h+\frac38h^2+O(h^3).
```

If `T_A` is the unscaled bond operator for mode `A`, then

```math
V_A=\frac{\partial H}{\partial\epsilon_A}\bigg|_0=-\frac12T_A.
```

For two modes on the same bond direction,

```math
S_{AB}=\frac{\partial^2H}
{\partial\epsilon_A\partial\epsilon_B}\bigg|_0
=\frac34\sum_{b\parallel A}c_A(u_b)c_B(u_b)t_bB_b,
```

and it vanishes for different directions in this scheme.

For a nondegenerate ground state, second-order perturbation theory gives

```math
\frac{d^2E_0}{d\epsilon_A d\epsilon_B}
=\langle S_{AB}\rangle
-2\operatorname{Re}\sum_{n>0}
\frac{\langle0|V_A|n\rangle\langle n|V_B|0\rangle}
{E_n-E_0}.
```

The factor `V=-T/2` produces the stated `-chi/4` response contribution when
`chi` is normalized with the paper's factor of two.

For a diagonal metric,

```math
\sqrt g=\prod_i(1+h_i)^{1/2}.
```

At zero background,

```math
\partial_i^2\sqrt g=-\frac14,
\qquad
\partial_i\partial_j\sqrt g=\frac14\quad(i\ne j).
```

Consequently the Hessian of `-Lambda sum_x sqrt(g)` is

```math
-\frac\Lambda4(J-2I),
```

matching the supplied static-kernel structure. This verifies the algebra of
the defined scheme, not its continuum gravitational interpretation.

## 14. Null-combination estimator for a nonlocal form factor

Suppose a channel kernel has the schematic small-momentum form

```math
K(q)=c_0+c_2q^2+c_4q^4+Aq^4\log q^2+R(q).
```

Choose at least four distinct momenta and weights satisfying

```math
\sum_iw_i=0,
\quad
\sum_iw_iq_i^2=0,
\quad
\sum_iw_iq_i^4=0,
\quad
\sum_iw_iq_i^4\log q_i^2=1.
```

Then

```math
\boxed{A_{\mathrm{null}}=\sum_iw_iK(q_i)=A+\sum_iw_iR(q_i).}
```

All local polynomial counterterms through fourth order and the change
`log(q^2/mu^2)=log q^2-2log mu` cancel algebraically. The estimator still needs
a conditioning analysis because clustered momenta can make the weights large
and amplify numerical error.

## 15. Pole-identifiability condition

At nonzero spatial momentum, a massless relativistic excitation lies near
`DeltaE^2=q^2`, not `DeltaE^2=0`. Define

```math
M_n^2=\Delta E_n^2-q^2.
```

A pole requires both an isolated cluster approaching `M^2=0` and a nonzero
volume-scaled residue after the thermodynamic limit:

```math
Z_{\mathrm{pole}}=
\lim_{\varepsilon\to0}\lim_{L\to\infty}
\sum_{0\le M_n^2<\varepsilon}\frac{Z_n^{(L)}}{V}>0.
```

If the lowest energies approach the light cone but their cluster residue tends
to zero while a continuum accumulates, the data do not support an isolated
particle pole. This is an identifiability condition, not merely a numerical
threshold.

## 16. Consequences for implementation order

The derivations establish the following pre-code gates:

1. `RESP-001` is exact only for the signed initial-covariance projector
   contract (or a precisely equivalent quadratic many-body preparation).
2. Hamiltonian perturbations, trace compensation, normalized probes, and
   interactions require separate formulas and result types.
3. Hypergraph components are defined by normalized conditional expectations
   and Möbius inversion; raw term dictionaries are not canonical.
4. Centers and parity grading precede factorization claims.
5. Homology is exact after the complex is fixed; geometry extraction before
   that remains statistical/ambiguous.
6. SM anomaly freedom is an exact unit oracle, while bounded uniqueness remains
   conditional on independently explicit domains.
7. The CP structural zero is proved under a common-left-phase real-factor
   condition; the geometric premise still needs testing.
8. BW moments and anisotropy provide strong analytic numerical oracles.
9. The prime-three flattening argument, as stated at the level of integral
   antisymmetric flux matrices, has an exact balanced counterexample.
10. BOND-A calculations remain stress/strain response until source matching and
    later gates succeed.
