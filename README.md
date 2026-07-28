# Kourovka 10.34 — a negative solution

**Claim.** Every finite group that coincides with the product of any two of
its non-conjugate maximal subgroups is soluble. This answers Problem 10.34
of the Kourovka Notebook (V. S. Monakhov, 1986) in the negative.

This repository contains the paper, every GAP script and log certificate
backing its machine-verified claims, and arithmetic receipts for the
uniform family proofs. Every machine claim in the paper cites a specific
log file committed here; every log line is independently re-checkable.

- **Paper:** [`paper/kourovka1034.tex`](paper/kourovka1034.tex)
  (compile with `tectonic kourovka1034.tex` or `pdflatex`)
- **Working notes:** `THEOREM.md` (machinery and criterion),
  `FAMILY-PROOFS.md` (family theorems), `STATUS.md` (certificate ledger),
  `HITLIST.md` (work log)

## Requirements

- **GAP 4.16.0** with the standard package distribution, including
  `ctbllib` (character table library) and the `AtlasRep`/perfect-groups
  data. All sweeps were run with:
  `gap -q -b -o 8g -T <script>.g`
- **Python 3.9+** (standard library only) for the receipt scripts.

## Quick verification (seconds, no GAP needed)

The three receipt scripts re-check the coverage bookkeeping and the
arithmetic of the family proofs from the committed logs:

```sh
python3 verify_coverage.py       # 47 simple groups |S| < 5e5 all certified
python3 verify_coverage_big.py   # 51 simple groups 5e5..1.05e7 all certified
python3 sweepN_item5_arith.py    # 7892 family-proof instances, 0 failures
```

Expected final lines: `COVERAGE OK.` / `COVERAGE (big range) OK.` /
`SWEEP N DONE.`  The last script verifies, for Theorems 6.4–6.6 of the
paper across ranks up to 25 and fields up to 3000: the Zsigmondy prime
exists, divides `|S|`, divides neither exhibited subgroup order nor
`|X/Inn(S)|`, and that the set of Zsigmondy exceptions encountered is
exactly the seven documented in the proofs.

## Full reproduction (GAP sweeps)

Each `sweep*.g` script regenerates the corresponding `sweep*.log`.
Shared definitions live in `_common.g` and `property.g` (the single
definition of property P used everywhere); `sanity.g` checks known
positives/negatives (S4 has P; A5, S5, SL(2,5), A5 wr C2 do not).

| Paper claim (section) | Scripts | Logs | Runtime (M-series Mac) |
|---|---|---|---|
| Base, maximal pairs, `\|S\| < 5e5` (§5, item 1) | `sweepJ_divisibility.g`, `sweepJ2_tail.g`, `sweepJ4_patch.g` | `sweepJ*.log` | minutes |
| Base, maximal pairs, `5e5..1.05e7` (§5, item 1) | `sweepJ3_bigrange.g`, `sweepJ5_smallAn.g`, `sweepJ6_L52_M23.g` | `sweepJ3/J5/J6*.log` | ~hours |
| Novelty pairs + saturation (§5, item 2) | `sweepK_novelty.g`, `sweepK2_saturation.g`, `sweepK3_bigsurvivors.g`, `sweepK4_L52.g` | `sweepK*.log` | minutes |
| Sporadics + Tits (§5, Prop. 5.2) | `sweepM_sporadic.g` (ctbllib) | `sweepM_sporadic.log` | minutes |
| Coverage cross-checks (§5) | `gen_biglist.g` then the two `verify_coverage*.py` | `verify_coverage*.log` | seconds |
| Consistency: exhaustive P-tests (§5, item 3) | `sweepA_smallgroups.g`, `sweepB_perfect.g`, `sweepB2_perfect.g`, `sweepC_socle.g`, `sweepF_survivors.g`, `sweepG_k3.g`, `sweepI_k4.g`, `sweepD_almostsimple.g` | matching `.log` | hours–days |
| Family-proof receipts (§6) | `sweepL_psl2_arith.g`, `sweepL2_an_arith.g`, `sweepN_item5_arith.py` | matching `.log` | seconds–minutes |

Certificate format (sweeps J/J3): one block per group, listing `|S|`,
`|Out|`, the maximal class orders, and per `X` a line
`ALL k >= 2 EXCLUDED via (|U|,|V|,p,d) = [...]` naming the two subgroup
orders, the obstruction prime and the valuation margin — exactly the data
needed to re-check Theorem 4.1 of the paper by hand.

Exploratory scripts (`probe*.g`, `sweepE*`, `sweepH*`) are retained for
provenance; the paper does not depend on them. `sweepG_k3.log` includes a
still-running redundant consistency case (U3(5)^3); no paper claim
depends on it.

## Layout

```
paper/                  LaTeX source of the paper
*.g                     GAP scripts (sweeps, receipts, helpers)
*.log                   committed certificates, one per script
verify_coverage*.py     coverage cross-checks against GAP's canonical
                        simple-group lists (committed as *.txt)
sweepN_item5_arith.py   arithmetic receipts for the family proofs
THEOREM.md, FAMILY-PROOFS.md, STATUS.md, HITLIST.md   working notes
```

## License

Code (`*.g`, `*.py`) is released under the MIT License (see `LICENSE`).
The paper and notes are © Richie Sater; all rights reserved pending
journal submission.
