# Kourovka 10.34 revision baseline

**Frozen:** 2026-08-20
**Revision branch:** `revision/architecture-2026-08-20`

This record fixes the source from which the mathematical-architecture revision
began. It is a provenance record, not a release designation.

## Canonical baseline

| Item | Frozen value |
|---|---|
| Repository | `https://github.com/RichieSater/kourovka-10-34` |
| Source commit | `35942dc7cf00cd145434661167de9f2224241717` |
| Commit date | 2026-08-05T20:50:32-04:00 |
| Commit subject | `Release v1.0.8: English revision and repository README` |
| Canonical source | `supporting-materials/paper/kourovka1034.tex` |
| Canonical PDF | `kourovka1034.pdf` |
| Baseline PDF SHA-256 | `cb840b6c726dcc5315f0520ede25880e27f7284298bf68d165c8786658a96cd7` |
| Public preprint | arXiv:2608.02970 |
| Archived release | `v1.0.8` |
| Submission state | Public preprint; no journal acceptance is recorded in this repository |

The branches `release-v1.0.6`, `release-v1.0.7-prep`,
`draft-v1.0.8-english-audit`, and `ai-substitute-closure` are historical or
special-purpose branches, not separate papers. The source and PDF paths above
are the sole canonical manuscript paths in this repository.

## Baseline evidence hashes

| Evidence object | SHA-256 |
|---|---|
| `formal/FORMAL-COVERAGE.json` | `ce4caf5aaba05efa0b91752bce30ffd5c9adc4ec52b78d6a6ba9e9a56925e01e` |
| `formal/FORMAL-INTERFACE.json` | `4655c7541812e887458fde64cd03f9928b76ea6317829db63b4ac957ef5c191a` |
| `audit/CLASSIFICATION-MANIFEST.json` | `e841bffe7b15a65624f7ef82e5ab9f9e79de704df3a08ad5aba249e7b93c22ad` |
| `audit/FAMILY-ARITHMETIC-MANIFEST.json` | `48e90876a3c8aff84936955e3121f4c0a30dd805eac430f77c6e6795c8de4409` |

## Baseline theorem numbering

| Number | Label | Description |
|---|---|---|
| 1.1 | `thm:main` | Main theorem |
| 2.1 | `lem:conj` | Conjugation lemma |
| 2.2 | `lem:quot` | Quotient inheritance |
| 2.3 | `prop:min` | Minimal-counterexample structure |
| 3.3 | `lem:A` | Product-supplement existence and order |
| 3.4 | `lem:B` | Product-normalizer maximality |
| 3.5 | `lem:C` | Nonconjugacy |
| 3.6 | `lem:P` | Parabolic novelties |
| 4.1 | `thm:D` | Divisibility criterion |
| 4.3 | `thm:Dprime` | Almost-simple counterpart |
| 5.1 | `prop:base` | Finite machine base |
| 5.2 | `prop:sporadic` | Sporadic and Tits certificates |
| 6.1--6.6 | `thm:psl2`--`thm:graph` | Infinite-family coverage |
| 7.1 | `prop:coverage` | CFSG coverage |

Labels, rather than numbers, remain the stable internal identifiers during
the reorganization.
