# Priority and prior-proof search

Search dates: **2026-08-01, 2026-08-02, refresh on 2026-08-20, and
subsequent-work refresh on 2026-08-21**. This is a literature record, not a
proof of priority. No journal-published full proof was located in the named
sources. The arXiv record now contains two preprints stating the full theorem:
the present paper, whose v1 and v2 are dated 2026-08-04 and 2026-08-06, and
the later preprint of Jinbao Li and Yong Yang, first submitted on 2026-08-19.

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

On 2026-08-21 a new ten-query arXiv sweep used the exact problem number,
theorem language, nonconjugate-maximal-subgroup terminology, author variants,
Zenkov, and Tikhonenko--Tyutyanov. It identified Li--Yang
`arXiv:2608.19478v1`. The exact record and source archive were then inspected
directly rather than inferred from search snippets.

## Database-specific checks

| Source | Exact check | Recorded result, refreshed through 2026-08-20 |
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
- Zenkov's 1997 announced negative answer remains a conference-abstract
  announcement: his complete indexed output (24 zbMATH documents) contains no
  matching paper; his sole factorization-adjacent paper (2004) addresses
  Problem 14.62.
- Candidates examined and dismissed: Lemeshev–Monakhov 2012 (full text
  searched — cofactors, not 10.34), Vasil'ev–Murashka–Furs 2022
  (formational maximal subgroups; metadata-level check only), Chunikhin
  1956 (predates the problem), arXiv:2607.17477 and arXiv:2607.06434
  (solve other Kourovka problems).

## Refresh on 2026-08-20

The independent readiness audit refreshed the exact theorem phrase, problem
number, author/title, arXiv, MathNet, Crossref, and general web searches. The
official July 2026 Notebook PDF was rechecked directly: Problem 10.34 appears
on printed/PDF page 40 and still records only the almost-simple result. The
search located the present preprint and the Tikhonenko--Tyutyanov paper but no
competing published full proof. This refresh does not enlarge the conclusion
beyond the named databases or cure the access limitations below. Zenkov's
original 1997 conference item was still not inspected directly.

## Subsequent work located on 2026-08-21

The exact arXiv record is:

> Jinbao Li and Yong Yang, *Products of Nonconjugate Maximal Subgroups and
> Solvability*, arXiv:2608.19478v1 [math.GR], submitted 19 August 2026.

The arXiv metadata title is shortened to *Products of nonconjugate maximal
subgroups*, while the PDF and TeX source use the full title above. The abstract
and Theorem 1.2 state the same solubility theorem as the present manuscript.
Theorem 3.1 develops a different product--socle lifting construction for a
primitive group with unique socle $T^k$: it starts with nonfactorizing maximal
subgroups of the almost-simple coordinate group and lifts their intersections
to normalizers of product subgroups. It does not use the stable-class
valuation obstruction of the present paper.

The metadata records no journal reference and no journal DOI. The source does
not cite the present paper. Those facts do not establish when the two projects
began or that the mathematical development was independent; only the public
arXiv chronology is established. The
[AMS Ethical Guidelines](https://www.ams.org/about-us/governance/policy-statements/sec-ethics)
expressly warn that an independence claim cannot rest on ignorance of
disseminated work, so the manuscript calls Li--Yang a separately authored,
subsequently submitted preprint rather than an independent confirmation.

The downloaded v1 artifacts were pinned during this audit:

- PDF SHA-256: `1a565e17edda896343408b00efe09d6e136d452902bcaace0a5ac4aa3a35bc83`;
- arXiv source archive SHA-256:
  `d7423942204dc9f0745f926d9a6d259b9854ea182a55d7d7f26e86bcb7a4e96f`;
- principal TeX SHA-256:
  `e3d61a6711f5db8d58714b5f06177d68acb8ed4ef1ecba803aefa0e8c4f7370a`.

### Why the citation is not described as correctness certification

The v1 source was compared at theorem-and-proof-architecture level but is not
used as correctness certification for this manuscript. A direct spot check
also found unresolved family-coverage scope in Proposition 2.5 as written:

1. in the $L_n(q)$ branch, the even-rank paragraph excludes $q=2$ after
   disposing only of $L_4(2)$, while the odd-rank $q=2$ paragraph gives the
   $L_5(2)$-specific pair $L_4(2){.}C_2$ and $C_{31}{.}C_{10}$ without routing
   the remaining ranks; and
2. in the $\PSp_4(q)$ even-characteristic branch, the displayed choice
   $\operatorname{Sz}(q)$ is asserted for every even $q\geq8$, although a
   Suzuki group with parameter $q$ exists only for $q=2^{2m+1}$.

These are proof-coverage issues in the posted v1, not counterexamples to its
main theorem, and they may be repairable from the cited maximal-factorization
classification. Until they are resolved, the responsible claim is that a
second preprint states the same theorem and supplies a distinct proof
architecture whose coverage remains unresolved as written—not that it
independently certifies or officially closes the problem.

## Remaining limitation

A subscriber-level MathSciNet forward/backward citation search was not
available. A direct MR2654533 request on 2026-08-01 was reproduced in the
dedicated browser and redirected to the AMS/LibLynx
institution-or-registered-user login; no authorized subscription credential
is configured, so the login was not bypassed.  MathSciNet-only editorial text
and print-only conference proceedings therefore remain outside the search's
reach, and the novelty statement in the manuscript is deliberately limited
to the named databases and dates. Crossref, OpenAlex, Google Scholar, zbMATH,
Semantic Scholar, Math-Net.Ru, and the official Notebook yielded no
journal-published full proof in the recorded searches. The arXiv search now
records the Li--Yang v1 preprint described above.
