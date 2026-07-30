# Kourovka 10.34 — supporting materials

**[Download the current paper PDF](../kourovka1034.pdf)**
LaTeX source: [`paper/kourovka1034.tex`](paper/kourovka1034.tex)

## Result

**Claim.** Every finite group that coincides with the product of any two of
its non-conjugate maximal subgroups is soluble. This answers Problem 10.34
of the Kourovka Notebook (V. S. Monakhov, 1986) in the negative.

This directory contains the paper source, every GAP script and log
certificate backing its machine-verified claims, the arithmetic receipts
for the uniform family proofs, and the project's working notes. Every
machine claim in the paper cites a committed log file, and every log line
is independently re-checkable.

## Repository layout

The repository root is intentionally kept upload-friendly. The hidden
`.zenodo.json` file must remain at the root so Zenodo can read the release
metadata:

```text
.zenodo.json                  Zenodo release metadata
kourovka1034.pdf             Current compiled paper
supporting-materials/
├── README.md                This guide
├── LICENSE                  License for the code
├── paper/
│   ├── kourovka1034.tex     LaTeX source
│   └── submission/          Abstract and audit materials
├── notes/
│   ├── THEOREM.md           Machinery and exclusion criterion
│   ├── FAMILY-PROOFS.md     Uniform family proofs
│   ├── STATUS.md            Certificate ledger
│   └── HITLIST.md           Work log
└── computations/
│   ├── gap/                 GAP scripts and shared libraries
│   ├── python/              Coverage and arithmetic checks
│   ├── certificates/        Committed machine-generated logs
│   └── data/                Canonical simple-group lists
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

- **Tectonic** or a standard **LaTeX** installation to build the paper.
- **GAP 4.16.0** with the standard package distribution, including
  `ctbllib` and the `AtlasRep`/perfect-groups data. The sweeps were run
  with `gap -q -b -o 8g -T <script>.g`.
- **Python 3.9+** using only the standard library for the receipt scripts.

## Quick verification

These checks take seconds and do not require GAP:

```sh
python3 computations/python/verify_coverage.py
python3 computations/python/verify_coverage_big.py
python3 computations/python/sweepN_item5_arith.py
```

They respectively verify:

- all 47 non-abelian simple groups with `|S| < 500000`;
- all 51 simple groups with `500000 ≤ |S| ≤ 1.05×10^7`; and
- 7,892 family-proof instances, including the documented Zsigmondy
  exceptions.

Expected final lines are `COVERAGE COMPLETE: ...`,
`COVERAGE (big range) OK.`, and `SWEEP N DONE.`

## Full GAP reproduction

Run GAP scripts from their directory so their relative `Read(...)` calls
resolve correctly:

```sh
cd computations/gap
gap -q -b -o 8g -T sanity.g
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
| Base maximal pairs, `5e5..1.05e7` (§5, item 1) | `sweepJ3_bigrange.g`, `sweepJ5_smallAn.g`, `sweepJ6_L52_M23.g` | matching `sweepJ3/J5/J6*.log` | hours |
| Novelty pairs and saturation (§5, item 2) | `sweepK_novelty.g`, `sweepK2_saturation.g`, `sweepK3_bigsurvivors.g`, `sweepK4_L52.g` | matching `sweepK*.log` | minutes |
| Sporadics and the Tits group (§5, Prop. 5.2) | `sweepM_sporadic.g` | `sweepM_sporadic.log` | minutes |
| Coverage cross-checks (§5) | `gen_biglist.g`, `verify_coverage*.py` | `verify_coverage*.log` | seconds |
| Exhaustive consistency tests (§5, item 3) | `sweepA_smallgroups.g`, `sweepB_perfect.g`, `sweepB2_perfect.g`, `sweepC_socle.g`, `sweepF_survivors.g`, `sweepG_k3.g`, `sweepI_k4.g`, `sweepD_almostsimple.g` | matching logs | hours–days |
| Family-proof receipts (§6) | `sweepL_psl2_arith.g`, `sweepL2_an_arith.g`, `sweepN_item5_arith.py` | matching logs | seconds–minutes |

Scripts are in [`computations/gap/`](computations/gap/) and
[`computations/python/`](computations/python/); committed outputs are in
[`computations/certificates/`](computations/certificates/).

Certificate blocks from sweeps J/J3 list `|S|`, `|Out|`, maximal-class
orders, and an obstruction tuple `(|U|,|V|,p,d)`. Exploratory scripts
(`probe*.g`, `sweepE*`, and `sweepH*`) are retained for provenance but are
not required by the paper. `sweepG_k3.log` includes a still-running
redundant consistency case for `U3(5)^3`; no paper claim depends on it.

## License

Code (`*.g`, `*.py`) is released under the MIT License in
[`LICENSE`](LICENSE). The paper and notes are © Richie Sater; all rights
reserved pending journal submission.
