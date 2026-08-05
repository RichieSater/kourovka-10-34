# Kourovka Notebook Problem 10.34

> **Main theorem.** Every finite group that is the product of every pair of
> its non-conjugate maximal subgroups is soluble.

This repository contains the preprint and reproducibility materials for a
negative answer to Problem 10.34 of the Kourovka Notebook, posed by
V. S. Monakhov in 1986.

**[Read the paper](https://arxiv.org/abs/2608.02970)** ·
**[Review the verification guide](supporting-materials/README.md)** ·
**[Reproduce release v1.0.7](#reproduction)**

> **Status — public preprint.** The manuscript is permanently available as
> [arXiv:2608.02970](https://arxiv.org/abs/2608.02970). It has not been
> accepted through journal peer review, and the complete informal argument
> has not been independently certified.

## Result

Let \(G\) be a finite group. Suppose that \(G=AB\) whenever \(A\) and \(B\)
are maximal subgroups of \(G\) that are not conjugate in \(G\). The paper
proves that \(G\) is soluble.

The almost-simple case was proved by Tikhonenko and Tyutyanov in 2010. The
new part treats the remaining minimal-counterexample case with socle
\(S^k\), \(k\ge 2\), using an all-\(k\) divisibility obstruction. Uniform
arguments cover the infinite families of finite simple groups; GAP
certificates cover the designated finite cases and exceptions.

A 1997 conference abstract announced a negative answer. Because no published
full proof was located in the literature search recorded with this release,
the manuscript claims a proof of the theorem, not absolute priority for its
conclusion. See
[`PRIORITY-SEARCH.md`](supporting-materials/audit/PRIORITY-SEARCH.md).

## Verification scope

The evidence is deliberately divided into separate layers:

| Layer | Verified scope |
|---|---|
| **Manuscript** | The complete informal mathematical argument and its cited external inputs |
| **GAP 4.16.0** | Named finite simple-group cases, subgroup-class records, obstruction primes and valuations, and designated saturation computations |
| **Python** | Certificate parsing, independent arithmetic, coverage bookkeeping, manifests, source maps, hashes, and mutation tests |
| **Lean 4.32.2** | The named structural and arithmetic results in [`FORMAL-COVERAGE.json`](supporting-materials/formal/FORMAL-COVERAGE.json) |
| **Rocq 9.2 / MathComp 2.6.0** | The two direct-power results in [`formal-rocq/FORMAL-COVERAGE.json`](supporting-materials/formal-rocq/FORMAL-COVERAGE.json) |

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

The immutable research artifact is
[`v1.0.7`](https://github.com/RichieSater/kourovka-10-34/releases/tag/v1.0.7).
Clone that tag rather than the moving default branch.

### Quick verification

Requires Python 3.9+, Rocq 9.2, and MathComp 2.6.0:

```sh
git clone --branch v1.0.7 --depth 1 \
  https://github.com/RichieSater/kourovka-10-34.git
cd kourovka-10-34
sh supporting-materials/verify-quick.sh
```

This validates the committed receipts, manifests, Rocq theorems, source maps,
and hashes. It does **not** rerun the expensive GAP computations.

### Full certificate regeneration

The pinned container rebuilds every proof-essential GAP certificate, checks
for soft failures, byte-compares the regenerated output with the committed
logs, builds Lean and Rocq, and runs the independent and mutation suites:

```sh
git clone --branch v1.0.7 --depth 1 \
  https://github.com/RichieSater/kourovka-10-34.git
cd kourovka-10-34
docker build -f supporting-materials/computations/environment/Dockerfile \
  -t kourovka1034:1.0.7 .
docker run --rm kourovka1034:1.0.7
```

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
├── formal-rocq/                    Rocq/MathComp project and manifest
├── verify-quick.sh                 fast validation of committed evidence
└── verify-full.sh                  full certificate regeneration
```

## Review boundary

The overall informal proof, the interpretation and priority implications of
the literature, the use of external classification results, the completeness
of the computational data, and the interfaces among prose, certificates,
Lean, and Rocq remain open to expert scrutiny. Author review and agreement
among AI systems are not substitutes for independent mathematical review.

## AI disclosure

Anthropic Claude and OpenAI Codex were used for mathematical exploration,
generation and criticism of candidate arguments, formal-proof development,
GAP and Python code, literature-search assistance, verification workflows,
and manuscript editing. The author directed the work, reviewed the argument
and stated interfaces, checked references, reran scripts or checked their
outputs against committed logs, edited the manuscript, and accepts
responsibility for the article. The complete declaration appears in the
paper.

## Citation and license

Cite the article as:

> Richie Sater, “Finite groups that are the product of every pair of
> non-conjugate maximal subgroups are soluble,” arXiv:2608.02970 (2026).

Machine-readable metadata and the archival DOI are in [`CITATION.cff`](CITATION.cff)
and [Zenodo](https://doi.org/10.5281/zenodo.21709124). Code (`*.g`, `*.py`) is
MIT-licensed under [`supporting-materials/LICENSE`](supporting-materials/LICENSE).
The paper is © Richie Sater; all rights reserved pending journal submission.
