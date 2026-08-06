# Kourovka 10.34: supporting materials

**[Download the current paper PDF](../kourovka1034.pdf)**
LaTeX source: [`paper/kourovka1034.tex`](paper/kourovka1034.tex)

## Result

**Claim.** Every finite group that is the product of every pair of its
non-conjugate maximal subgroups is soluble. This answers Problem 10.34 of the
Kourovka Notebook (V. S. Monakhov, 1986) in the negative.

This directory contains the paper source, every GAP script and log
certificate backing its machine-verified claims, the arithmetic receipts for the uniform family proofs, pinned Lean and Rocq/MathComp projects,
and machine-readable family, exception, and source manifests. Every proof-essential finite record now carries
an exact subgroup-class identity rather than an order-only label.

## Repository layout

The repository root is intentionally kept upload-friendly. The hidden
`.zenodo.json` file must remain at the root so Zenodo can read the release
metadata:

```text
.zenodo.json                  Zenodo release metadata
CITATION.cff                 Citation metadata for the release
kourovka1034.pdf             Current compiled paper
supporting-materials/
├── README.md                This guide
├── LICENSE                  License for the code
├── verify-quick.sh          One-command quick verification suite
├── verify-full.sh           Full (expensive) GAP reproduction
├── paper/
│   ├── kourovka1034.tex     LaTeX source
│   └── submission/          Abstract
├── audit/
│   ├── ASSUMPTIONS.md       Explicit external trust boundary
│   ├── CLASSIFICATION-MANIFEST.json
│   ├── EXCEPTION-MANIFEST.json
│   ├── FAMILY-ARITHMETIC-MANIFEST.json Exact 34-branch arithmetic specification
│   ├── ARITHMETIC-EXCEPTIONS.generated.json Generated exhaustive exception view
│   ├── LIE-SOURCE-MAP.csv Exact high-risk Lie-type source obligations
│   ├── MAXIMALITY-SOURCE-MAP.csv Exact family maximality pinpoints
│   ├── ORDER-FORMULA-SOURCE-MAP.csv Exact group, subgroup, and Levi formulas
│   ├── ZSIGMONDY-INVOCATIONS.csv One row for every primitive-prime invocation
│   ├── BOUNDARY-SOURCE-MAP.csv Exact simplicity/isomorphism boundary sources
│   ├── SPORADIC-SOURCE-MAP.csv Exact selected-class source map
│   ├── PRIORITY-SEARCH.md  Reproducible prior-proof search and limits
│   ├── SOURCE-LEDGER.md     Pinpoint citations
│   └── EVIDENCE.sha256      Cryptographic closure of proof evidence
├── formal/                  Lean project + coverage/formal-interface manifests
│   └── Kourovka1034/        Includes reindexing and ambient-wreath proofs
├── formal-rocq/             Rocq internal/external direct-power theorems + pins
└── computations/
    ├── gap/                 Fail-closed GAP proof programs
    ├── python/              Primary coverage/arithmetic checks
    ├── independent/         Independent parsers/checkers
    ├── environment/         Exact lock and container recipe
    ├── mutation-tests/      Deliberate fault-detection suite
    ├── certificates/        Committed logs and SHA-256 sums
    └── data/                Canonical finite inventories
```

All commands below assume the current directory is
`supporting-materials/`.

## Build the paper

### Tectonic

```sh
tectonic --outdir .. paper/kourovka1034.tex
```

This writes the upload-ready PDF to `../kourovka1034.pdf`.

### pdfLaTeX

```sh
cd paper
pdflatex kourovka1034.tex
pdflatex kourovka1034.tex
mv kourovka1034.pdf ../..
```

The generated auxiliary files remain ignored inside `paper/`.

## Requirements

- **GAP 4.16.0**, CTblLib 1.3.11, and AtlasRep 2.1.11, with
  `lib/csetgrp.gi` overlaid from GAP commit
  `b12f8342d641075d58fcbe62cc00dd433d7b8e18`. Vanilla GAP 4.16.0 is
  intentionally rejected because it predates the relevant regression fix.
  Run `computations/environment/apply-gap-containedconjugates-fix.sh` or use
  the pinned container recipe.
- **Python 3.9+**, standard library only for verification scripts.
- **Lean 4.32.2** and the locked mathlib commit for `formal/`.
- **Rocq 9.2** and **MathComp 2.6.0** for `formal-rocq/`; the verifier
  checks six exact upstream source SHA-256 pins used by the decomposition and
  explicit-coordinate bridge.
- **Tectonic** (or a standard LaTeX installation) to build the paper.

## Container reproduction

From the repository root, build the pinned environment and run the full
certificate reproduction with:

```sh
docker build -f supporting-materials/computations/environment/Dockerfile \
  -t kourovka1034:1.0.8 .
docker run --rm kourovka1034:1.0.8
```

The image build kernel-checks the Lean project, then removes disposable
mathlib build products so that they do not add roughly 19 GB to the runtime
image. The full run fetches the cache for the hash-locked mathlib revision
afresh before its independent Lean rebuild, so that command requires network
access.

To run only the quick suite inside the same image:

```sh
docker run --rm --entrypoint sh kourovka1034:1.0.8 \
  -c 'sh verify-quick.sh'
```

## Quick verification

One command runs the fast, no-GAP regression and integrity checks:

```sh
sh verify-quick.sh
```

It runs finite coverage, concrete regression arithmetic, the exact universal
34-branch arithmetic manifest, and a manifest-independent symbolic arithmetic
implementation,
family/exception topology, exact finite-witness parsing, fail-closed log scans,
the high-risk Lie-source/Levi, maximality, exact order-formula, Zsigmondy
invocation, and classification-boundary cross-checks, audit-schema checks,
the Rocq/MathComp characteristically-simple/direct-power theorem,
manuscript/manifest checks, and SHA-256 verification.

The finite inventories contain exactly 47 and 51 groups in the two
published ranges. The 7,892 concrete family instances are regression tests,
not proofs of universal family statements. The primary universal checker binds
all 34 branches to exact formula/source rows, proves the unbounded affine
inequalities, regenerates the complete exception view, and checks every finite
destination; the separately authored symbolic implementation does not read
that manifest. Lean kernel-checks the universal arithmetic deductions while
leaving the cited classification/order formulas as explicit external inputs.

Expected final lines are `COVERAGE COMPLETE: ...`,
`COVERAGE (big range) OK.`, `SWEEP N DONE.`, and
`QUICK VERIFICATION SUITE: ALL CHECKS PASSED.`

## Full GAP reproduction

The full suite (runtime depends strongly on GAP and hardware) regenerates every
proof-essential certificate, scans it for soft failures, byte-compares it to
the committed result, removes the temporary output, builds Lean and Rocq, and runs the
independent and mutation suites:

```sh
sh verify-full.sh
```

Alternatively, run GAP scripts individually from their directory so
their relative `Read(...)` calls resolve correctly:

```sh
cd computations/gap
gap -q -b -o 8g -T sweepJ_divisibility.g
```

To regenerate a committed certificate, direct output to the sibling
certificate directory, for example:

```sh
gap -q -b -o 8g -T sweepJ_divisibility.g \
  > ../certificates/sweepJ_divisibility.log
```

| Paper claim | GAP/Python scripts | Certificates | Typical runtime |
|---|---|---|---|
| Base maximal pairs, `|S| < 5e5` (§5, item 1) | `sweepJ_divisibility.g`, `sweepJ2_tail.g`, `sweepJ4_patch.g` | matching `sweepJ*.log` | minutes |
| Upper finite inventory, `5e5..1.05e7` (§5, item 1) | `sweepJ3_bigrange.g`, `sweepJ6_L52_M23.g`, `sweepL_psl2_arith.g` | J3/J6 certify the 13 non-`PSL(2,q)` rows; 38 `PSL(2,q)` rows route to the exact uniform theorem and sweep-L receipt | minutes–hours |
| Novelty pairs and saturation (§5, item 2) | `sweepK_novelty.g`, `sweepK2_saturation.g`, `sweepK3_bigsurvivors.g`, `sweepK4_L52.g` | matching `sweepK*.log` | minutes |
| Sporadics and the Tits group (§5, Prop. 5.2) | `sweepM_sporadic.g` | `sweepM_sporadic.log` | minutes |
| Coverage cross-checks (§5) | `gen_biglist.g`, `verify_coverage*.py` | `verify_coverage*.log` | seconds |
| Family-proof receipts (§6) | `sweepL_psl2_arith.g`, `sweepL2_an_arith.g`, `sweepN_item5_arith.py` | matching logs | seconds–minutes |

Scripts are in [`computations/gap/`](computations/gap/) and
[`computations/python/`](computations/python/); committed outputs are in
[`computations/certificates/`](computations/certificates/).

Certificate blocks from sweeps J/J3 include one exact action-fingerprinted
`XCASE` for every coordinate-closure class, plus `|S|`, `|Out|`,
maximal-class orders, and an obstruction tuple `(|U|,|V|,p,d)`. Exploratory scripts
and superseded consistency runs are retained under
[`computations/exploratory/`](computations/exploratory/) for provenance only.
They are not manuscript evidence and are deliberately excluded from the
certificate and evidence manifests.  This keeps every file in
`computations/certificates/` on a fail-closed release-gate path.


## Formal coverage

The current Lean coverage closes the exact quotient-inheritance theorem; the
minimal-order reduction through the unique minimal normal subgroup, its
nonsolubility, the soluble quotient, and trivial centralizer; the
exact coordinate-product construction, orbit-from-`X`-stability argument,
normalizer intersection/supplement/order conclusions; the finite
subgroup-product/lower-divisibility bridge; and the final universal-in-`k`
arithmetic contradiction, as well as non-conjugacy of the resulting ambient
normalizers. It also closes the 34-branch universal arithmetic deductions,
including exhaustive Zsigmondy exception routing, conditional on the exact
published formula and classification inputs recorded in the arithmetic
manifest. Constructing the normalized coordinate-action model in the
reduction is now kernel checked from an explicit equivalence
`N ≃* (Fin k → S)`: Lean constructs the faithful wreath map, proves factor
transitivity and the exact inner-base preimage, normalizes the coordinate
closure, and proves the quotient divisor. `RED-COORD` is now closed by the
strengthened Rocq theorem constructing an isomorphism to the explicit external
coordinate product over an explicitly nonabelian factor, the Lean theorem
reindexing any nonempty finite coordinate type to `Fin k` and constructing its
base coordinate, and the fail-closed producer/reindex/consumer signature and
definition-correspondence audit in
`formal/FORMAL-INTERFACE.json`. Conditional on the normalized model, Lean also checks the
full maximality lemma: supplement recovery of the coordinate-closure
generators, invariance and stable uniformity of the projections of `H \cap N`,
the saturation/Goursat product step, the finite-simple normalizer-tower/poset
dichotomy, the ambient intersection dichotomy, and the final coatom conclusion.

The root and nested `.gitignore` files deliberately ignore only caches,
compiled Lean/Rocq products, TeX auxiliaries, and scratch regeneration files.
Manifest CSV/JSON files, formal sources, certificate logs, and source maps
are proof evidence and must remain visible to Git.

## Citing this repository

Citation metadata lives in [`CITATION.cff`](../CITATION.cff) at the
repository root. Cite the versioned release (currently `v1.0.8`), not
the mutable default branch. The concept DOI covering all versions is
[10.5281/zenodo.21709124](https://doi.org/10.5281/zenodo.21709124).
Zenodo lists the immutable DOI for each archived release on that record's
version history.

## License

Code (`*.g`, `*.py`) is released under the MIT License in
[`LICENSE`](LICENSE). The paper is © Richie Sater; all rights
reserved pending journal submission.
