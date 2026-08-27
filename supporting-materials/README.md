# Kourovka 10.34: supporting materials

**[Download the current paper PDF](../kourovka1034.pdf)**
LaTeX source: [`paper/kourovka1034.tex`](paper/kourovka1034.tex)

> **Archive status.** Release
> [`v1.1.2`](https://github.com/RichieSater/kourovka-10-34/releases/tag/v1.1.2)
> contains this corrected manuscript, the Comparator package, the complete
> architecture/audit files, and the proof-evidence tree. Zenodo archives the
> exact release under concept DOI 10.5281/zenodo.21709124.

## Result

**Theorem.** Every finite group that is the product of every pair of its
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
│   ├── REVISION-BASELINE.md Canonical source, commit, PDF, and revision baseline
│   ├── CONTENT-PRESERVATION-MAP.md Baseline block-to-body/appendix/supplement audit
│   ├── CONTRIBUTION-MAP.md Mathematical thesis, novelty, yield, and boundary
│   ├── MATHEMATICAL-YIELD.md Three-paragraph explanation and seminar outline
│   ├── REVISION-CHANGELOG.md Claim changes separated from exposition moves
│   ├── REVISION-PREFLIGHT.md Verified hashes, builds, and release boundary
│   ├── SOURCE-LEDGER.md     Pinpoint citations
│   └── EVIDENCE.sha256      Cryptographic closure of proof evidence
├── formal/                  Lean project + coverage/formal-interface manifests
│   ├── Comparator/          Neutral challenge and exact solution comparison
│   └── Kourovka1034/        Includes reindexing and ambient-wreath proofs
├── formal-rocq/             Rocq internal/external direct-power theorems + pins
└── computations/
    ├── gap/                 Fail-closed GAP proof programs
    ├── python/              Primary coverage/arithmetic checks
    ├── independent/         Independent parsers/checkers
    ├── environment/         Tool/artifact pins and container recipe
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

The named runtime tools and directly downloaded artifacts are version- or
hash-pinned. The Debian package snapshot and complete opam solver closure are
not frozen, so the environment is not fully hermetic at those package-manager
layers.

## Container reproduction

From the repository root, build the versioned tool/artifact environment and
run the full certificate reproduction with:

```sh
docker build -f supporting-materials/computations/environment/Dockerfile \
  -t kourovka1034:working .
docker run --rm kourovka1034:working
```

The image build kernel-checks the Lean project, then removes disposable
mathlib build products so that they do not add roughly 19 GB to the runtime
image. The full run fetches the cache for the hash-locked mathlib revision
afresh before its independent Lean rebuild, so that command requires network
access.

To run only the quick suite inside the same image:

```sh
docker run --rm --entrypoint sh kourovka1034:working \
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
The static gate parses the labels declared by the principal TeX source and
requires every proof-facing audit, formal, Python, and GAP artifact to use
existing stable labels rather than obsolete printed theorem numbers.

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

The script invokes GAP with `-r`, suppressing user package roots so that local
or duplicate package metadata cannot shadow the pinned CTblLib and AtlasRep
copies. The environment gate runs under the same isolation policy.

Alternatively, run GAP scripts individually from their directory so
their relative `Read(...)` calls resolve correctly:

```sh
cd computations/gap
gap -r -q -b -o 8g -T sweepJ_divisibility.g
```

To regenerate a committed certificate, direct output to the sibling
certificate directory, for example:

```sh
gap -r -q -b -o 8g -T sweepJ_divisibility.g \
  > ../certificates/sweepJ_divisibility.log
```

| Paper claim | GAP/Python scripts | Certificates | Typical runtime |
|---|---|---|---|
| Finite-range coverage (Appendix B) | `sweepJ_divisibility.g`, `sweepJ2_tail.g`, `sweepJ4_patch.g` | matching `sweepJ*.log` | minutes |
| Upper finite inventory (Appendix B) | `sweepJ3_bigrange.g`, `sweepJ6_L52_M23.g`, `sweepL_psl2_arith.g` | J3/J6 certify the 13 non-`PSL(2,q)` rows; 38 `PSL(2,q)` rows route to the uniform theorem and arithmetic receipt | minutes–hours |
| Stable-poset substitutes and saturation (Appendix B) | `sweepK_novelty.g`, `sweepK2_saturation.g`, `sweepK3_bigsurvivors.g`, `sweepK4_L52.g` | matching `sweepK*.log`; historical filenames retain `novelty` | minutes |
| Sporadics and the Tits group (Appendix B) | `sweepM_sporadic.g` | `sweepM_sporadic.log` | minutes |
| Coverage cross-checks (Sections 6 and Appendix B) | `gen_biglist.g`, `verify_coverage*.py` | `verify_coverage*.log` | seconds |
| Family arithmetic (Appendix A) | `sweepL_psl2_arith.g`, `sweepL2_an_arith.g`, `sweepN_item5_arith.py` | matching logs | seconds–minutes |

Scripts are in [`computations/gap/`](computations/gap/) and
[`computations/python/`](computations/python/); committed outputs are in
[`computations/certificates/`](computations/certificates/).

### Operational details displaced from the manuscript

The architecture revision moved proof-operational detail out of the article,
not out of the repository. Appendix B retains the mathematical inventory,
certificate fields, representative witnesses, completeness assumptions, and
cross-checks; the exact reproduction information formerly stated in the body
is preserved here:

- The proof environment is GAP 4.16.0 with CTblLib 1.3.11 and AtlasRep
  2.1.11, overlaid with the `ContainedConjugates` correction from GAP commit
  `b12f8342d641075d58fcbe62cc00dd433d7b8e18`. The environment gate rejects
  an unpatched installation.
- Both GAP global pseudorandom sources are reset to seed `1034` at process
  start. The proof scripts perform no explicit random witness search.
- `verify_coverage_big.py`, with receipt `verify_coverage_big.log`, checks the
  upper inventory regenerated by `SimpleGroupsIterator`. The lower inventory
  is read from its frozen canonical data file and checked by
  `verify_coverage.py`, with receipt `verify_coverage.log`, against every
  certificate route; the committed replay does not independently regenerate
  that lower range.
- The former short sweep labels have the following exact source/receipt map:

| Label | Script | Committed receipt |
|---|---|---|
| J | `sweepJ_divisibility.g` | `sweepJ_divisibility.log` |
| J2 | `sweepJ2_tail.g` | `sweepJ2_tail.log` |
| J3 | `sweepJ3_bigrange.g` | `sweepJ3_bigrange.log` |
| J4 | `sweepJ4_patch.g` | `sweepJ4_patch.log` |
| J5 | `sweepJ5_smallAn.g` | `sweepJ5_smallAn.log` |
| J6 | `sweepJ6_L52_M23.g` | `sweepJ6_L52_M23.log` |
| K | `sweepK_novelty.g` | `sweepK_novelty.log` |
| K2 | `sweepK2_saturation.g` | `sweepK2_saturation.log` |
| K3 | `sweepK3_bigsurvivors.g` | `sweepK3_bigsurvivors.log` |
| K4 | `sweepK4_L52.g` | `sweepK4_L52.log` |
| L | `sweepL_psl2_arith.g` | `sweepL_psl2_arith.log` |
| L2 | `sweepL2_an_arith.g` | `sweepL2_an_arith.log` |
| M | `sweepM_sporadic.g` | `sweepM_sporadic.log` |
| N | `sweepN_item5_arith.py` | `sweepN_item5_arith.log` |

The exact `Sp43` finite record used for
`PSU(4,2) \cong PSp(4,3)` is in `sweepJ_divisibility.log`. Sporadic records
retain their pinned `Maxes` positions, identifiers, orders, and source-map
bindings. Certificate identity uses action and subgroup-class fingerprints,
not order alone. Superseded exploratory programs remain under
`computations/exploratory/` and are excluded from all proof-evidence manifests.

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
`formal/FORMAL-INTERFACE.json`. That checker guards the enumerated signatures,
correspondence rows, and definition-source tokens; it does not prove arbitrary
semantic equivalence across Rocq/MathComp and Lean/mathlib, so the mathematical
identification remains a trusted correspondence. Conditional on the normalized
model, Lean also checks the
full maximality lemma: supplement recovery of the coordinate-closure
generators, invariance and stable uniformity of the projections of `H \cap N`,
the saturation/Goursat product step, the finite-simple normalizer-tower/poset
dichotomy, the ambient intersection dichotomy, and the final coatom conclusion.

For a reader-facing statement of the strongest conditional spine, see
[`formal/Comparator/README.md`](formal/Comparator/README.md). From
`supporting-materials/formal/`, the exact proposition comparison is checked by:

```sh
lake build +Comparator.Challenge +Comparator.Solution
```

The challenge imports only mathlib and exposes every classification,
maximality, exact-order, wreath-top, and valuation input as a hypothesis. The
solution imports the project theorem and type-checks an equality between the
two theorem constants. This is a conditional formal result, not an end-to-end
formal proof; `PAR-NOVELTY` remains explicitly outside closed Lean coverage.

The root and nested `.gitignore` files deliberately ignore only caches,
compiled Lean/Rocq products, TeX auxiliaries, and scratch regeneration files.
Manifest CSV/JSON files, formal sources, certificate logs, and source maps
are proof evidence and must remain visible to Git.

## Citing this repository

Citation metadata lives in [`CITATION.cff`](../CITATION.cff) at the repository
root. Cite `v1.1.2` for the present corrected manuscript and evidence tree;
do not attribute the Comparator or architecture claims to the older v1.0.8
baseline. The concept DOI covering all versions is
[10.5281/zenodo.21709124](https://doi.org/10.5281/zenodo.21709124).
Zenodo lists the immutable DOI for each archived release on that record's
version history.

## License

Code (`*.g`, `*.py`) is released under the MIT License in
[`LICENSE`](LICENSE). The paper is © Richie Sater; all rights reserved.
