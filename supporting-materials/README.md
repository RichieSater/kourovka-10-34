# Kourovka 10.34 — supporting materials

**[Download the current paper PDF](../kourovka1034.pdf)**
LaTeX source: [`paper/kourovka1034.tex`](paper/kourovka1034.tex)

## Result

**Claim.** Every finite group that coincides with the product of any two of
its non-conjugate maximal subgroups is soluble. This answers Problem 10.34
of the Kourovka Notebook (V. S. Monakhov, 1986) in the negative.

This directory contains the paper source, every GAP script and log
certificate backing its machine-verified claims, the arithmetic receipts for the uniform family proofs, a pinned Lean project,
and a binary obligation ledger. Every proof-essential finite record now carries
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
│   └── submission/          Abstract and audit materials
├── audit/
│   ├── WRITER-GATE-README.md Writer workflow for both binary gates
│   ├── BURDEN-OF-PROOF-MATRIX.csv Every granular submission/99% requirement
│   ├── BURDEN-POLICY.json   Pinned profile and requirement inventory
│   ├── OBLIGATIONS.csv      One binary row per proof obligation
│   ├── DEPENDENCY-DAG.json  Main-theorem dependency graph
│   ├── ASSUMPTIONS.md       Explicit external trust boundary
│   ├── CLASSIFICATION-MANIFEST.json
│   ├── EXCEPTION-MANIFEST.json
│   ├── LIE-SOURCE-MAP.csv Exact high-risk Lie-type source obligations
│   ├── MAXIMALITY-SOURCE-MAP.csv Exact family maximality pinpoints
│   ├── SPORADIC-SOURCE-MAP.csv Exact selected-class source map
│   ├── PRIORITY-SEARCH.md  Reproducible prior-proof search and limits
│   ├── SOURCE-LEDGER.md     Pinpoint citations and open actions
│   ├── RED-TEAM-REPORT.md   Reproduced defects and adversarial tests
│   ├── STOP-SHIP.md         Remaining binary blockers
│   ├── SUBMISSION-REPORT.md Machine-generated-gate outcome summary
│   └── EVIDENCE.sha256      Cryptographic closure of proof evidence
├── formal/                  Lean project + exact coverage manifest
├── notes/                   Non-normative historical working notes
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
- **Tectonic** (or a standard LaTeX installation) to build the paper.

## Quick verification

One command runs the fast, no-GAP regression and integrity checks:

```sh
sh verify-quick.sh
```

It runs finite coverage, concrete and symbolic family arithmetic,
family/exception topology, exact finite-witness parsing, fail-closed log scans,
the high-risk Lie-source/Levi and maximality-source cross-checks, audit-schema checks,
manuscript/manifest checks, and SHA-256 verification.

The finite inventories contain exactly 47 and 51 groups in the two
published ranges. The 7,892 concrete family instances are regression tests,
not proofs of universal family statements; the independent symbolic checker
separately verifies the encoded affine exponent inequalities and substitute
prime valuations.

Expected final lines are `COVERAGE COMPLETE: ...`,
`COVERAGE (big range) OK.`, `SWEEP N DONE.`, and
`QUICK VERIFICATION SUITE: ALL CHECKS PASSED.`

## Full GAP reproduction

The full suite (runtime depends strongly on GAP and hardware) regenerates every
proof-essential certificate, scans it for soft failures, byte-compares it to
the committed result, removes the temporary output, builds Lean, and runs the
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


## Binary release gates

Writers and reviewing agents must first read
[`audit/WRITER-GATE-README.md`](audit/WRITER-GATE-README.md). The complete
dual-profile checklist is
[`audit/BURDEN-OF-PROOF-MATRIX.csv`](audit/BURDEN-OF-PROOF-MATRIX.csv); it is
gate-validated rather than maintained as advisory prose.

```sh
sh submission-gate.sh submission
sh submission-gate.sh confidence99
```

A gate prints `PASS` only if every obligation required by that profile is
closed. It is not a weighted score. The current checkout deliberately retains
unresolved source, full-core formalization, literature-database, and two-host
clean-room obligations, so the 99% gate must report `FAIL`; see
[`audit/STOP-SHIP.md`](audit/STOP-SHIP.md). A passing test suite is evidence
that the implemented checks work, not permission to relabel open mathematics
as closed.

### Two-machine clean-room receipts

After committing a clean release candidate, run the following from two
independent machines (the receipt path must be outside the clone):

```sh
computations/environment/run-cleanroom.sh /tmp/kourovka-cleanroom.json
```

Each run first makes an enforced non-hardlinked fresh clone, then builds the
pinned container without cache, runs `verify-full.sh`, and writes both the JSON
receipt and a `.full.log` companion. The receipt records the candidate commit
plus hashes of the evidence manifest, certificate manifest, and complete log.
Add each receipt/log pair to the later attestation commit with:

```sh
python3 audit/check_cleanroom.py \
  --add /tmp/kourovka-cleanroom.json \
  --log /tmp/kourovka-cleanroom.json.full.log
python3 audit/check_cleanroom.py --require-complete
```

The second command hard-fails unless at least two distinct machines report the
same candidate commit and manifests and byte-identical full-suite output. The
current empty receipt bundle is intentionally valid only for linting; it cannot
close `CLEANROOM` or pass the 99%-confidence gate.

The current Lean coverage closes the exact quotient-inheritance theorem; the
minimal-order reduction through the unique minimal normal subgroup, its
nonsolubility, the soluble quotient, and trivial centralizer; the
exact coordinate-product construction, orbit-from-`X`-stability argument,
normalizer intersection/supplement/order conclusions; the finite
subgroup-product/lower-divisibility bridge; and the final universal-in-`k`
arithmetic contradiction, as well as non-conjugacy of the resulting ambient
normalizers. Constructing the normalized coordinate-action model in the
reduction remains open. Conditional on that exact model, Lean also checks the
full maximality lemma: supplement recovery of the coordinate-closure
generators, invariance and stable uniformity of the projections of `H \cap N`,
the saturation/Goursat product step, the finite-simple normalizer-tower/poset
dichotomy, the ambient intersection dichotomy, and the final coatom conclusion.

## Citing this repository

Citation metadata lives in [`CITATION.cff`](../CITATION.cff) at the
repository root. Cite the versioned release (currently `v1.0.4`), not
the mutable default branch; a versioned Zenodo DOI will be added to
`CITATION.cff` and the paper once the release is archived.

## License

Code (`*.g`, `*.py`) is released under the MIT License in
[`LICENSE`](LICENSE). The paper and notes are © Richie Sater; all rights
reserved pending journal submission.
