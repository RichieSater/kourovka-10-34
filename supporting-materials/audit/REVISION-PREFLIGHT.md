# Working-revision verification preflight

**Checked:** 2026-08-27
**Branch:** `main`
**Frozen baseline:** `35942dc7cf00cd145434661167de9f2224241717`

This record identifies the verified revision by content hashes. The corrected
mathematical and computational tree was first archived as `v1.1.0` on
21 August 2026. Release `v1.1.1`, dated 27 August 2026, carries the same
mathematics with strengthened public-corpus safeguards and synchronized
archive references.

## Canonical working artifacts

| Artifact | Path | SHA-256 |
|---|---|---|
| Principal source | `supporting-materials/paper/kourovka1034.tex` | `34db127e953211e3f65b82e1d1179a343822371a3a4cff6750d53148b4c4386a` |
| Compiled manuscript | `kourovka1034.pdf` | `e625fb0a00394ea30970c37b5eef3daabd44c9912e849484296b990bc597a419` |
| Rebuilt nested copy | `supporting-materials/paper/kourovka1034.pdf` | `e625fb0a00394ea30970c37b5eef3daabd44c9912e849484296b990bc597a419` |

The PDF has 26 US-letter pages. The ignored nested build copy is byte-identical
to the canonical top-level PDF and is not designated as a second manuscript.

## Verification results

| Check | Result |
|---|---|
| Tectonic build, repeated after reference stabilization | PASS; no unresolved references or overfull boxes; four visually benign underfull warnings |
| Visual PDF inspection | PASS; all 26 rendered pages inspected in contact sheets, with corrected pages 4 and 7 and the graph-summary and trust tables additionally inspected at full rendered size |
| PDF text sentinel scan | PASS; no unresolved-reference, placeholder, tool-token, or failure marker found |
| Manuscript/manifest architecture and style checker | PASS; 21 families, 94 required tokens, 125 source rows, 20 exceptions, and repository-wide subgroup-index gate |
| Public release metadata gate | PASS; manuscript, both guides, CFF, Zenodo metadata, clone commands, and container tag consistently designate `v1.1.1`; CFF 1.2 validation passed |
| Proof-artifact manuscript-label gate | PASS; 130 stable-label references checked against the labels declared by the principal TeX; obsolete printed manuscript numbering rejected; explicitly marked frozen-baseline comparison records excluded |
| Ordinary/Lean normalization bridge | PASS; the TeX transporter $g_j^{-1}gg_i$, component $a_j^{-1}\circ c\circ a_i$, and conjugate $\delta^{-1}G\delta$ agree in orientation with the Lean term $\delta^{-1}\rho(g)\delta$ and its target-inverse/source transporter |
| Subsequent-work attribution audit | PASS; Li--Yang `arXiv:2608.19478v1` metadata, public chronology, theorem overlap, and distinct method are recorded without unsupported independence, correctness-certification, or official-closure language |
| Repository notation normalization | PASS; 3,784 legacy strings normalized in 11 tracked files; zero tracked square-delimited subgroup indexes remain |
| Working-tree whitespace gate | PASS; trailing spaces removed from the five regenerated legacy logs without changing their numerical content; `git diff --check` is clean |
| Lie, maximality, order-formula, Zsigmondy, and boundary source-map checks | PASS |
| Lean full build, axiom audit, and Comparator proposition check | PASS; 11 closed claims, one declared item outside Lean; `comparator=ELABORATED-PASS` |
| Rocq/MathComp producer build and source-pin audit | PASS |
| Quick verification suite | PASS; all 18 gates |
| Full certificate regeneration | PASS; every proof-essential GAP and Python receipt byte-identical and both formal builds passed |
| Optimized Python and mutation checks | PASS; proof-path `assert` count zero, symbolic arithmetic passed under `PYTHONOPTIMIZE=1`, and all 55 mutations were detected, including reversal of the coordinate transporter, stale public release metadata, stale manuscript numbering, removal of GAP user-root isolation, unsupported Li--Yang independence language, and prohibited public evaluation-process wording |
| Evidence closure | PASS; 128 files, including root README/CFF/Zenodo metadata and the public-corpus policy self-test, regenerated after all proof-evidence changes |

The documented full-reproduction script and its environment gate now disable
the user package root with `-r`, so GAP selects the bundled pinned CTblLib
1.3.11 and AtlasRep 2.1.11 copies without duplicate package metadata. The gate
then verified those versions, the patched `csetgrp.gi` hash, and both upstream
regression cases before running the certificates. The named runtime tools and
direct downloads are pinned. The Debian package snapshot and complete opam
solver closure remain unfrozen, so the container is not fully hermetic at
those package-manager layers. The unmodified documented command
`sh verify-full.sh` passed under this policy.

## Authorized release boundary

The corrected mathematical and computational tree passes its technical
preflight gates and is designated for public reproducibility release
`v1.1.1`. The release procedure is complete only when the ten architecture and
Comparator files are tracked in the exact tagged commit, GitHub publishes that
tag and the rebuilt PDF, Zenodo archives the same tag under concept DOI
`10.5281/zenodo.21709124`, and the public metadata agrees with the tag.
