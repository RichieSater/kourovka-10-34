# Kourovka Notebook Problem 10.34

> **Main theorem.** Every finite group that is the product of every pair of
> its non-conjugate maximal subgroups is soluble.

This repository contains the preprint and reproducibility materials for a
negative answer to Problem 10.34 of the Kourovka Notebook, posed by
V. S. Monakhov in 1986.

**[Read the paper](https://arxiv.org/abs/2608.02970)** ·
**[Verification guide](supporting-materials/README.md)** ·
**[Reproduce release v1.1.0](#reproduction)**

> **Status: proved public preprint; reproducibility release v1.1.0.** The
> theorem is proved in the manuscript by an ordinary mathematical argument,
> with partial formal verification and computationally certified finite
> components. The arXiv record is
> [arXiv:2608.02970](https://arxiv.org/abs/2608.02970); release v1.1.0 contains
> the corrected 26-page repository manuscript and its exact evidence tree. No
> journal acceptance is recorded in this repository.

## Result

Let \(G\) be a finite group. Suppose that \(G=AB\) whenever \(A\) and \(B\)
are maximal subgroups of \(G\) that are not conjugate in \(G\). The paper
proves that \(G\) is soluble.

The almost-simple case was proved by Tikhonenko and Tyutyanov in 2010. The
new part treats the remaining minimal-counterexample case with socle
\(S^k\), \(k\ge 2\), using an all-\(k\) divisibility obstruction. Uniform
arguments cover the infinite families of finite simple groups; GAP
certificates cover the designated finite cases and exceptions.

A 1997 conference abstract announced a negative answer. This paper does not
claim priority for the conclusion; the search record is in
[`PRIORITY-SEARCH.md`](supporting-materials/audit/PRIORITY-SEARCH.md). After
this paper's arXiv v1 and v2, dated 4 and 6 August 2026, respectively, Jinbao
Li and Yong Yang submitted
[arXiv:2608.19478v1](https://arxiv.org/abs/2608.19478), dated 19 August
2026, which states the same theorem and develops a different product--socle
lifting approach. These are distinct proof architectures.

## Verification scope

The evidence is deliberately divided into separate layers:

| Layer | Verified scope |
|---|---|
| **Manuscript** | The complete informal mathematical argument and its cited external inputs |
| **GAP 4.16.0** | Named finite simple-group cases, subgroup-class records, obstruction primes and valuations, and designated saturation computations |
| **Python** | Certificate parsing, independent arithmetic, coverage bookkeeping, manifests, source maps, hashes, and mutation tests |
| **Lean 4.32.2** | The named structural and arithmetic results in [`FORMAL-COVERAGE.json`](supporting-materials/formal/FORMAL-COVERAGE.json) |
| **Rocq 9.2 / MathComp 2.6.0** | The two direct-power results in [`formal-rocq/FORMAL-COVERAGE.json`](supporting-materials/formal-rocq/FORMAL-COVERAGE.json) |

The release's neutral-mathlib
[`Comparator/Challenge.lean`](supporting-materials/formal/Comparator/Challenge.lean)
states the exact conditional Lean spine, while
[`Comparator/Solution.lean`](supporting-materials/formal/Comparator/Solution.lean)
checks that the project theorem has the same elaborated proposition.

These layers reinforce one another, but they are not interchangeable:

- GAP does not verify the surrounding prose argument.
- Lean and Rocq provide partial formal coverage, not an end-to-end formal
  proof of the main theorem.
- No single kernel checks the Rocq-to-Lean translation. Its manifest is a
  stated trusted interface.
- Published classifications, order formulae, software libraries, kernels,
  compilers, and hardware remain trusted inputs.

The exact assumptions and exclusions are listed in
[`ASSUMPTIONS.md`](supporting-materials/audit/ASSUMPTIONS.md). Program-level
scope, theorem names, expected output, and certificate locations are in the
[`supporting-materials` guide](supporting-materials/README.md).

## Reproduction

The latest immutable public research artifact is
[`v1.1.0`](https://github.com/RichieSater/kourovka-10-34/releases/tag/v1.1.0),
archived by Zenodo under the concept DOI
[10.5281/zenodo.21709124](https://doi.org/10.5281/zenodo.21709124). It contains
the corrected manuscript, Comparator package, architecture records, formal
sources, checkers, certificates, and evidence hashes described here. The
frozen v1.0.8 comparison remains recorded in
[`REVISION-BASELINE.md`](supporting-materials/audit/REVISION-BASELINE.md).

### Quick verification

Requires Python 3.9+, Rocq 9.2, and MathComp 2.6.0:

```sh
git clone --branch v1.1.0 --depth 1 \
  https://github.com/RichieSater/kourovka-10-34.git
cd kourovka-10-34
sh supporting-materials/verify-quick.sh
```

This validates the committed receipts, manifests, Rocq theorems, source maps,
and hashes. It does **not** rerun the expensive GAP computations.

### Full certificate regeneration

The v1.1.0 container rebuilds every proof-essential GAP certificate, checks
for soft failures, byte-compares the regenerated output with the committed
logs, builds Lean and Rocq, and runs the independent and mutation suites:

```sh
git clone --branch v1.1.0 --depth 1 \
  https://github.com/RichieSater/kourovka-10-34.git
cd kourovka-10-34
docker build -f supporting-materials/computations/environment/Dockerfile \
  -t kourovka1034:1.1.0 .
docker run --rm kourovka1034:1.1.0
```

The named runtime tools and directly downloaded artifacts are version- or
hash-pinned. The Debian package snapshot and complete opam solver closure are
not frozen, so the environment is reproducible at the checked tool/artifact
boundary but is not fully hermetic at those package-manager layers.
The local `sh supporting-materials/verify-full.sh` command invokes GAP with
`-r`, isolating the pinned package copies from user GAP roots.

For individual GAP, Lean, Rocq, and Python commands, see
[`supporting-materials/README.md`](supporting-materials/README.md).

## Repository layout

```text
kourovka1034.pdf                    compiled manuscript
CITATION.cff                       citation metadata
supporting-materials/
├── paper/kourovka1034.tex         manuscript source
├── computations/gap/              proof-path GAP programs
├── computations/certificates/     committed logs and hashes
├── computations/independent/      independent Python checkers
├── computations/mutation-tests/   deliberate fault-detection suite
├── audit/                          assumptions, sources, and manifests
├── formal/                         Lean project and coverage manifest
│   └── Comparator/                 neutral challenge and exact solution check
├── formal-rocq/                    Rocq/MathComp project and manifest
├── verify-quick.sh                 fast validation of committed evidence
└── verify-full.sh                  full certificate regeneration
```

## Evidence boundary

The ordinary proof depends on CFSG, published maximal-subgroup and
automorphism classifications, group and Levi order formulas, parabolic theory,
and Zsigmondy's theorem. The finite certificates additionally assume the
completeness and correctness of the pinned GAP and character-table data. Lean
does not close the graph-fusion flag-parabolic claim `PAR-NOVELTY`, and neither
Lean nor Rocq proves the main theorem end to end. The exact allocation of
claims among prose, kernels, computation, and external sources appears in
Appendix C of the paper and in
[`ASSUMPTIONS.md`](supporting-materials/audit/ASSUMPTIONS.md).

## Citation and license

Cite the article as:

> Richie Sater, “Finite groups that are the product of every pair of
> non-conjugate maximal subgroups are soluble,” arXiv:2608.02970 (2026).

Machine-readable metadata and the archival DOI are in [`CITATION.cff`](CITATION.cff)
and [Zenodo](https://doi.org/10.5281/zenodo.21709124). Code (`*.g`, `*.py`) is
MIT-licensed under [`supporting-materials/LICENSE`](supporting-materials/LICENSE).
The paper is © Richie Sater; all rights reserved pending journal submission.
