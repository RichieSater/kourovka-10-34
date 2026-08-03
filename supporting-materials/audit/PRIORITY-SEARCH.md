# Priority and prior-proof search

Search date: **2026-08-01**.  This is an absence search, not a proof of
priority.  Its defensible conclusion is limited to: **no published full proof
was located in the sources searched below**.

## Material prior claim that must be disclosed

Tikhonenko--Tyutyanov (2010), Russian p. 212 / PDF p. 1, state that
V. I. Zenkov announced a negative answer to the full Problem 10.34 in:

> V. I. Zenkov, “Factorization of finite groups,” *Abstracts of the
> International Algebra Conference in Memory of D. K. Faddeev*,
> St. Petersburg, 1997, p. 202 (in Russian).

The same sentence says that a proof was unknown to the 2010 authors.  The
present manuscript therefore does **not** make an absolute first-solution or
priority claim.

## Ten-query broad search

The `/research-god` search was run with ten distinct queries (English exact
phrases, problem-number variants, DOI/title/citation variants, Russian exact
phrases, arXiv, zbMATH, and Google Scholar).  The only on-point mathematical
publication returned was Tikhonenko--Tyutyanov (2010); related factorization
papers did not claim the general theorem.  A Russian-language query surfaced
the Zenkov announcement quoted above.

## Database-specific checks

| Source | Exact check | Result on 2026-08-01 |
|---|---|---|
| Official Kourovka Notebook | 21st edition and July 2026 update, Problem 10.34 | Problem entry still records only the almost-simple 2010 result; no full-solution update. |
| MathSciNet | MR2654533 direct record / Relay Station | Bibliographic record confirmed.  Full citation-search functionality was unavailable without a subscription, so this remains an explicit access limitation. |
| zbMATH Open | exact-title API query | Exactly one title match: Zbl 1202.20017 (Tikhonenko--Tyutyanov).  Its reference list records the Zenkov 1997 abstract. |
| Crossref | DOI lookup and bibliographic-title query | Exact paper found; `is-referenced-by-count=0`; no competing exact result. |
| OpenAlex | DOI lookup and `Kourovka 10.34 Monakhov` query | DOI has `cited_by_count=0`; phrase query returned only the 2010 paper. |
| Google Scholar | exact title; `Question 10.34 Monakhov Kourovka`; English and Russian citing-article links | One result (the 2010 paper); both citing-article searches reported no citing articles. |
| arXiv/web index | exact theorem phrase, exact paper title, problem number, and Russian variants | No published full proof located.  The July 2026 paper *On two questions from the Kourovka Notebook concerning maximal subgroups* concerns different problems. |
| MathNet | smj2078 record, full Russian text and reference list | Confirms the 2010 theorem, MR/DOI metadata, and exact Zenkov 1997 citation. |

## Supplementary citation-chain sweep (2026-08-02)

A second, deeper pass of 33 logged queries was run on 2026-08-02 across
arXiv (listing, API full-text, and the complete Kourovka Notebook v45 PDF
downloaded and searched locally), the zbMATH Open API, OpenAlex, Semantic
Scholar, Crossref, Math-Net.Ru, the official Kourovka Notebook site, and
English- and Russian-language web search.  Key outcomes:

- The Kourovka Notebook v45 (July 3, 2026 — the latest edition) still lists
  Problem 10.34 verbatim as open, with only the Tikhonenko–Tyutyanov 2010
  almost-simple editorial comment; its author index credits 10.34 to no
  solver.
- TT2010 has zero forward citations on OpenAlex, Semantic Scholar, and
  Crossref, and no citing articles on Math-Net.Ru.
- Zenkov's 1997 announced negative answer remains an unpublished conference
  abstract: his complete indexed output (24 zbMATH documents) contains no
  matching paper; his sole factorization-adjacent paper (2004) addresses
  Problem 14.62.
- Candidates examined and dismissed: Lemeshev–Monakhov 2012 (full text
  searched — cofactors, not 10.34), Vasil'ev–Murashka–Furs 2022
  (formational maximal subgroups; metadata-level check only), Chunikhin
  1956 (predates the problem), arXiv:2607.17477 and arXiv:2607.06434
  (solve other Kourovka problems).

## Remaining limitation

A subscriber-level MathSciNet forward/backward citation search was not
available.  A direct MR2654533 request on 2026-08-01 was reproduced in the
dedicated browser and redirected to the AMS/LibLynx
institution-or-registered-user login; no authorized subscription credential
is configured, so the login was not bypassed.  MathSciNet-only review text
and print-only conference proceedings therefore remain outside the search's
reach, and the novelty statement in the manuscript is deliberately limited
to the named databases and dates.  Crossref, OpenAlex, Google Scholar,
zbMATH, Semantic Scholar, Math-Net.Ru, arXiv/web search, and the official
Notebook all independently yielded no later full proof.
