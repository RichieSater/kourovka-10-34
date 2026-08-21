#!/usr/bin/env python3
"""Fail-closed manuscript, architecture, manifest, and style consistency checks."""
from __future__ import annotations

import csv
import json
import os
import re
import sys
from pathlib import Path

ROOT = Path(
    os.environ.get(
        "KOUROVKA_SUPPORTING_ROOT", Path(__file__).resolve().parents[2]
    )
).resolve()
REPO = Path(os.environ.get("KOUROVKA_REPO_ROOT", ROOT.parent)).resolve()
TEX_PATH = ROOT / "paper/kourovka1034.tex"
TEX = TEX_PATH.read_text()
CFSG = json.loads((ROOT / "audit/CLASSIFICATION-MANIFEST.json").read_text())
ROOT_README_PATH = REPO / "README.md"
CFF_PATH = REPO / "CITATION.cff"
ZENODO_PATH = REPO / ".zenodo.json"


def die(message: str) -> None:
    raise SystemExit("HARD-FAIL: " + message)


# Public release metadata is one atomic interface: manuscript, repository
# guides, CFF, Zenodo metadata, clone commands, and container tag must all name
# the same immutable release.
for path in [ROOT_README_PATH, CFF_PATH, ZENODO_PATH]:
    if not path.is_file():
        die(f"public release metadata file missing: {path}")
root_readme = ROOT_README_PATH.read_text()
cff = CFF_PATH.read_text()
zenodo_text = ZENODO_PATH.read_text()
zenodo = json.loads(zenodo_text)
if zenodo.get("version") != "1.1.0":
    die("Zenodo metadata version is not 1.1.0")
if zenodo.get("publication_date") != "2026-08-21":
    die("Zenodo publication date is not 2026-08-21")
for token in [
    "version: 1.1.0",
    "date-released: 2026-08-21",
    "doi: 10.5281/zenodo.21709124",
]:
    if token not in cff:
        die("CITATION.cff release metadata missing: " + token)
for token in [
    "reproducibility release v1.1.0",
    "/releases/tag/v1.1.0",
    "--branch v1.1.0",
    "kourovka1034:1.1.0",
]:
    if token not in root_readme:
        die("root README release metadata missing: " + token)
support_readme = (ROOT / "README.md").read_text()
for token in ["/releases/tag/v1.1.0", "Cite `v1.1.0`"]:
    if token not in support_readme:
        die("supporting guide release metadata missing: " + token)
for token in [
    "archived as release 1.1.0",
    "version 1.1.0, Zenodo, 2026",
    "/releases/tag/v1.1.0",
]:
    if token not in TEX:
        die("manuscript release metadata missing: " + token)
for stale in [
    "--branch v1.0.8",
    "kourovka1034:1.0.8",
    "corrected working revision not yet archived",
    "requires a new exact commit",
    "External circulation of this revision requires a new immutable archive",
]:
    for path, body in [
        (ROOT_README_PATH, root_readme),
        (ROOT / "README.md", support_readme),
        (TEX_PATH, TEX),
        (CFF_PATH, cff),
        (ZENODO_PATH, zenodo_text),
    ]:
        if stale in body:
            die(f"{path}: obsolete release metadata returned: {stale}")


# Editorial status language and operational implementation detail do not belong
# in the mathematical narrative.
for forbidden in [
    "TODO",
    "ContainedConjugates(S, W, V, true)",
    "checked against the stored class fusions",
    "Our argument is independent of \\cite{TT2010}",
    "four independent layers",
    "exhaustively tested candidate groups",
    "the first full proof",
    "the first solution",
    "CTblLib~1.3.11",
    "AtlasRep~2.1.11",
    "recorded seed $1034$",
    "no explicit random witness search",
]:
    if forbidden in TEX:
        die("forbidden/stale manuscript phrase: " + forbidden)

for pattern, description in [
    (r"\bsweep[J-N]\w*", "operational sweep label"),
    (r"\b[\w.-]+\.log\b", "certificate log filename"),
    (r"\b[0-9a-f]{40}\b", "source commit hash"),
]:
    if re.search(pattern, TEX):
        die(f"{description} remains in manuscript prose")

prose_paths = [
    REPO / "README.md",
    ROOT / "README.md",
    *sorted((ROOT / "audit").glob("*.md")),
    *sorted((ROOT / "formal/Comparator").glob("*.md")),
]
prose = {path: path.read_text() for path in prose_paths if path.is_file()}
for path, body in {TEX_PATH: TEX, **prose}.items():
    lowered = body.lower()
    for phrase in [
        "ai-assisted review",
        "needs human validation",
        "claimed complete solution",
    ]:
        if phrase in lowered:
            die(f"{path}: vague status phrase: {phrase}")
for path, body in [(CFF_PATH, cff), (ZENODO_PATH, zenodo_text)]:
    if re.search(
        r"generative[- ]AI|AI disclosure|OpenAI Codex|Anthropic Claude",
        body,
        flags=re.I,
    ):
        die(f"generative-AI disclosure duplicated in release metadata: {path}")

# The public dates establish arXiv chronology, not when either project began.
# Guard against upgrading the subsequently submitted Li--Yang v1 into an
# independence, peer-review, or official-closure claim.
for forbidden in [
    "li and yang independently proved",
    "independent solution by li and yang",
    "independent confirmation by li and yang",
    "confirms that problem 10.34 is closed",
    "officially closes problem 10.34",
]:
    for path, body in {TEX_PATH: TEX, **prose}.items():
        if forbidden in body.lower():
            die(f"{path}: unsupported subsequent-work status phrase: {forbidden}")

# Guard the two mathematical statement corrections identified in the
# independent accuracy audit. Summary prose may not collapse the supplement
# hypotheses back to stability alone, and the representative graph proposition
# must retain its proved fixed-X scope.
submission_abstract_path = ROOT / "paper/submission/abstract.txt"
submission_abstract = submission_abstract_path.read_text()
yield_path = ROOT / "audit/MATHEMATICAL-YIELD.md"
yield_text = yield_path.read_text()
summary_corpus = "\n".join((TEX, submission_abstract, yield_text))
for stale in [
    r"an\s+automorphism-stable\s+subgroup\s+class.*?produces\s+a\s+maximal\s+supplement",
    r"Two\s+distinct\s+stable\s+classes\s+produce\s+non-conjugate\s+maximal\s+supplements",
    r"From\s+one\s+stable\s+class",
    r"turns\s+one\s+local\s+stable\s+class.*?into\s+a\s+maximal\s+subgroup",
]:
    if re.search(stale, summary_corpus, flags=re.I | re.S):
        die("stability-only supplement summary returned: " + stale)
for path, body, token in [
    (
        submission_abstract_path,
        submission_abstract,
        "automorphism-stable coordinate\nsubgroup classes satisfying the supplement criterion",
    ),
    (
        yield_path,
        yield_text,
        "Exact intersection and order follow from those two hypotheses; maximality",
    ),
]:
    if token not in body:
        die(f"{path}: corrected supplement-hypothesis wording missing")
if "Either or both of the selected classes" not in TEX:
    die("flag-parabolic corollary does not cover either or both selected classes")
psl_flag = re.search(
    r"\\begin\{proposition\}\[Projective flag-parabolic application\]"
    r".*?\\end\{proposition\}",
    TEX,
    flags=re.S,
)
if not psl_flag:
    die("projective flag-parabolic proposition block missing")
if "Then $S$ is excluded" in psl_flag.group(0):
    die("projective flag-parabolic proposition regained a universal conclusion")
if "coordinate closure $X$ has property $\\mathrm{P}$" not in psl_flag.group(0):
    die("projective flag-parabolic proposition lost its fixed-X conclusion")

# Guard the three local corrections from the final adversarial manuscript pass.
for stale in [
    "$B_n/C_n$: Levi types\n$A_{i-1}\\times C_{n-i}$",
    "are novelties covered by",
    "Independent inventory generation checks",
]:
    if stale in TEX:
        die("final local manuscript correction regressed: " + stale)
for token in [
    "$A_{i-1}\\times B_{n-i}$ and $A_{i-1}\\times C_{n-i}$",
    "are flag-parabolic substitutes covered by",
    "An independent routing and coverage check verifies",
]:
    if token not in TEX:
        die("final local manuscript correction missing: " + token)

# Guard the final four exposition corrections.  The abstract must be readable
# without terminology introduced later, the criterion must bind its own
# variables, the normalization proof must state its local component rule, and
# the size-only remark must identify the actual divergent upper bound.
abstract_match = re.search(r"\\begin\{abstract\}(.*?)\\end\{abstract\}", TEX, re.S)
if not abstract_match:
    die("principal abstract block missing")
abstract_text = abstract_match.group(1)
abstract_flat = re.sub(r"\s+", " ", abstract_text)
submission_abstract_flat = re.sub(r"\s+", " ", submission_abstract)
for stale in [r"Property $\\mathrm{P}$", "wreath top", "Using CFSG"]:
    if stale in abstract_flat or stale in submission_abstract_flat:
        die("undefined abstract terminology returned: " + stale)
for token in [
    "The factorization hypothesis would then impose",
    "wreath-product quotient",
    "classification of finite simple groups (CFSG)",
]:
    if token not in abstract_flat or token not in submission_abstract_flat:
        die("abstract synchronization/correction missing: " + token)

criterion = re.search(
    r"\\begin\{theorem\}\[Uniform stable-class divisibility criterion\]"
    r".*?\\end\{theorem\}", TEX, re.S,
)
if not criterion:
    die("uniform criterion theorem block missing")
criterion_text = criterion.group(0)
if "as in Conventions" in criterion_text:
    die("uniform criterion regained convention-dependent quantifiers")
for token in [
    "Let $S$ be non-abelian simple",
    "$\\Inn(S)\\leq X\\leq\\Aut(S)$",
    "put $x:=|X/\\Inn(S)|$",
    "for every $k\\geq2$",
    "unique minimal normal\nsubgroup $N\\cong S^k$",
]:
    if token not in criterion_text:
        die("uniform criterion is not self-contained: " + token)

normalization = re.search(
    r"\\begin\{lemma\}\[Coordinate normalization\].*?"
    r"\\end\{proof\}", TEX, re.S,
)
if not normalization:
    die("coordinate-normalization proof block missing")
normalization_text = normalization.group(0)
for token in [
    "its $i\\!\\to\\!j$ component is the induced",
    "ordinary right-to-left order",
    "$c_g(z)=gzg^{-1}$",
    "$A^g=g^{-1}Ag$",
    "$g_j^{-1}\\,g\\,g_i$",
    "$a_j^{-1}\\circ c\\circ a_i$",
    "$a_j^{-1}ca_i$",
    "$G$ by $\\delta^{-1}G\\delta$",
    r"S_1\xrightarrow{\ c_{g_i}\ }S_i",
    r"\xrightarrow{\ c_g\ }S_j",
    r"\xrightarrow{\ c_{g_j^{-1}}\ }S_1",
]:
    if token not in normalization_text:
        die("coordinate-normalization formula/convention missing: " + token)
for stale in [
    "$g_i\\,g\\,g_j^{-1}$",
    "$a_i\\,c\\,a_j^{-1}$",
    "$\\delta G\\delta^{-1}$",
]:
    if stale in normalization_text:
        die("reversed coordinate-normalization formula returned: " + stale)

criterion_with_proof = re.search(
    r"\\begin\{theorem\}\[Uniform stable-class divisibility criterion\]"
    r".*?\\end\{theorem\}\s*\\begin\{proof\}(.*?)\\end\{proof\}",
    TEX,
    re.S,
)
if not criterion_with_proof:
    die("uniform criterion proof block missing")
criterion_proof_flat = re.sub(r"\s+", " ", criterion_with_proof.group(1))
for token in [
    r"Conjugate the wreath realization as in Lemma~\ref{lem:coordinate-normalization}",
    r"Conventions~\ref{conv:X}--\ref{conv:coord}",
    r"Lemmas~\ref{lem:A}--\ref{lem:C} apply",
]:
    if token not in criterion_proof_flat:
        die("uniform criterion lost its normalized-model bridge: " + token)

criterion_remark = re.search(
    r"\\begin\{remark\}\\label\{rem:crit\}(.*?)\\end\{remark\}", TEX, re.S,
)
if not criterion_remark:
    die("criterion remark block missing")
if "eventually exceeds the\nfixed ratio" in criterion_remark.group(1):
    die("misleading fixed-ratio explanation returned")
for token in [
    "using $t\\leq x^k k!$",
    "$|B_V||B_W|/|G|$",
    "$x|V||W|\\,(k!)^{1/k}/|S|$",
    "The valuation gap is\nessential",
]:
    if token not in criterion_remark.group(1):
        die("correct size-bound explanation missing: " + token)

# There is exactly one disclosure, and it lives only in the principal TeX file.
heading = r"\subsection*{Declaration of generative AI use}"
if TEX.count(heading) != 1:
    die("principal TeX file must contain exactly one generative-AI declaration")
if len(re.findall(r"Generative AI tools were used", TEX, flags=re.I)) != 1:
    die("principal TeX disclosure text must occur exactly once")
for path, body in prose.items():
    if re.search(
        r"generative[- ]AI|AI disclosure|OpenAI Codex|Anthropic Claude",
        body,
        flags=re.I,
    ):
        die(f"generative-AI disclosure duplicated outside principal TeX: {path}")

required = [
    # Architecture and conceptual hierarchy.
    r"\section{Introduction}\label{sec:intro}",
    r"\subsection*{Proof mechanism}",
    r"\subsection*{Contribution and dependence}",
    r"\section{Reduction to the monolithic coordinate case}",
    "Coordinate normalization",
    "Wreath-top quotient divisor",
    r"t\mid x^k k!",
    r"\section{Stable classes and maximal product supplements}",
    "Product-supplement construction",
    "Maximality of stable product normalizers",
    "Nonconjugacy of distinct stable classes",
    "Flag-parabolic stability under graph fusion",
    "Stable product-supplement engine",
    r"\section{The stable-class divisibility criterion}",
    "Uniform stable-class divisibility criterion",
    "The criterion for $A_5$",
    r"\section{Two representative applications}",
    "Ordinary stable maximal classes: alternating groups",
    "Graph fusion: flag parabolics in projective linear groups",
    "Projective flag-parabolic application",
    r"\section{Classification coverage and proof of the main theorem}",
    r"\section{Conclusion}\label{sec:conclusion}",
    r"\section{Supplementary and infinite-family proofs}\label{app:families}",
    r"\subsection*{Common inputs for the family analysis}\label{app:common-inputs}",
    r"\section{Finite and sporadic certificate claims}\label{app:finite}",
    r"\section{Verification and trust boundary}\label{app:trust}",
    "Main theorem end to end & Complete relative to cited external inputs & Not end-to-end formalized",
    "Graph-fusion flag-parabolic substitutes & Selected finite checks only",
    r"\texttt{PAR-NOVELTY}",
    # Mathematical content and verification claims.
    "The quotient argument and the monolithic reduction are standard",
    "coordinate outer automorphisms and $k!$",
    "rules out this branch for every",
    "classification of finite simple groups (CFSG)",
    "Uniform parabolic, torus, and primitive-prime-divisor arguments",
    "The mathematical yield is the passage from local stable-class data",
    "exact $34$-branch arithmetic manifest",
    "the $47$ non-abelian simple",
    "the $51$ groups",
    "the $38$",
    "remaining $13$",
    "$A_{11},A_{12},A_{13},A_{14}$",
    "$\\PSL(6,2)$, $\\Omega^+(8,2)$, and",
    "$\\Sp(4,8)$ are treated in Appendix",
    "Exactly two of those $13$ are not excluded by ordinary maximal-class pairs",
    "$X/\\Inn(S)\\in\\{2_2,2_3,2^2\\}$ for $A_6$",
    "A stable-poset substitute record for $\\PSL(3,2)$ with $x=2$",
    "three distinct overgroup and embedding-orbit",
    "share the same GAP runtime, group representations",
    "The resulting $42$ selected-class records",
    "positions $45,46$",
    "(59{:}29,41{:}40),\\quad r=71",
    "occurs in $12$ branches, representing seven",
    "$7892$ Lie-type parameter instances",
    "field sizes through $3000$",
    "These are regression checks",
    "not proofs of the universally quantified family statements",
    "not an end-to-end proof",
    "partial formal verification, certified finite computation",
    "No single kernel checks the translation",
    "constructs the faithful map",
    "$\\Aut(S^k)\\to\\Aut(S)\\wr S_k$",
    "The proof-essential scripts are deterministic and fail closed",
    "GAP certifies only the finite inventories",
    # Priority, related work, and narrow stable cross-reference.
    "Tikhonenko and Tyutyanov proved the",
    "Zenkov had announced a negative answer",
    r"\cite{Zenkov1997}",
    "does not claim priority for the conclusion",
    r"\cite{LiYang2026}",
    "After this paper's arXiv v1 and v2",
    "4 August 2026",
    "6 August 2026",
    "submitted a separately authored preprint dated",
    "19 August 2026 that states the same theorem",
    "uses product--socle lifting",
    "distinct proof architectures",
    "arXiv:2608.19478v1",
    r"\cite{LPS1990}",
    r"\cite[Thm.~1.1]{RoneyDougal2021}",
    r"\cite{CTblLib,ATLAS}",
    r"\cite{Sater1868}",
    "The wreath-top valuation budget is shared preliminary",
    "neither proof reduces to the other criterion",
    "DOI 10.5281/zenodo.21894829",
    # High-risk source anchors retained after the move.
    r"\cite[Lemma~2.10, pp.~173--174]{ZhangShi2009}",
    r"\cite[p.~432]{LucchiniMorini2002}",
    r"\cite[Ch.~1, Table~I, pp.~8--10]{GLS1}",
    r"\cite[Tables~5--6, p.~xvi]{ATLAS}",
    r"\cite[\S10, pp.~220--221, and summary table, p.~239]{Carter1965}",
    r"\cite[Thm.~4.5(i)--(ii), p.~166]{Wilson2009}",
    r"\cite[specialized theorem, p.~283]{Zsigmondy}",
    r"\cite[Thm.~2.2, p.~2]{Jones2007}",
    r"\cite[Thm.~2.2.7(a)]{GLS3}",
    r"\cite[Thm.~5.3, p.~61]{CameronNotes}",
    "this group, of order $25920$, is",
]
flat_tex = re.sub(r"\s+", " ", TEX)
for token in required:
    if token not in TEX and re.sub(r"\s+", " ", token) not in flat_tex:
        die("required manuscript token missing: " + token)

# The architecture pass must not orphan material that was deliberately removed
# from the body. Mathematical content is mapped to the body/appendices, while
# execution transcript detail is mapped to the repository supplement.
preservation_path = ROOT / "audit/CONTENT-PRESERVATION-MAP.md"
if not preservation_path.is_file():
    die("missing baseline-to-revision content-preservation map")
preservation = preservation_path.read_text()
for token in [
    "All **22 labeled mathematical environments**",
    "Every baseline proof obligation is now in the body, Appendix A, Appendix B,",
    "Finite and exceptional details explicitly restored in Appendix B",
    "Formal and computational details explicitly restored in Appendix C",
]:
    if token not in preservation:
        die("content-preservation map token missing: " + token)

supplement = (ROOT / "README.md").read_text()
for token in [
    "Operational details displaced from the manuscript",
    "b12f8342d641075d58fcbe62cc00dd433d7b8e18",
    "Both GAP global pseudorandom sources are reset to seed `1034`",
    "`verify_coverage.log`",
    "`verify_coverage_big.log`",
    "| J5 | `sweepJ5_smallAn.g` | `sweepJ5_smallAn.log` |",
    "| M | `sweepM_sporadic.g` | `sweepM_sporadic.log` |",
]:
    if token not in supplement:
        die("supplemental preservation token missing: " + token)

# Labels are the stable interface through the reorganization. Every reference
# and citation must resolve locally.
label_list = re.findall(r"\\label\{([^}]+)\}", TEX)
labels = set(label_list)
if len(labels) != len(label_list):
    die("duplicate LaTeX label")
for label in [
    "thm:main",
    "thm:D",
    "thm:psl2",
    "thm:an",
    "thm:nograph",
    "thm:twisted2",
    "thm:twisted1",
    "thm:graph",
    "def:X",
    "lem:coordinate-normalization",
    "lem:wreath-divisor",
    "cor:supplement-engine",
    "ex:a5",
    "prop:psl-flag",
    "prop:base",
    "prop:sporadic",
    "prop:coverage",
    "app:families",
    "app:almost-simple",
    "app:psl2",
    "app:nograph",
    "app:twisted2",
    "app:twisted1",
    "app:graph",
    "app:finite",
    "app:trust",
]:
    if label not in labels:
        die("missing manuscript label " + label)
references = set(re.findall(r"\\(?:ref|eqref|autoref)\{([^}]+)\}", TEX))
missing_references = sorted(references - labels)
if missing_references:
    die("unresolved manuscript references: " + ", ".join(missing_references))

bibkeys = set(re.findall(r"\\bibitem(?:\[[^\]]*\])?\{([^}]+)\}", TEX))
cited: set[str] = set()
for group in re.findall(r"\\cite(?:\[[^\]]*\])?\{([^}]+)\}", TEX):
    cited.update(key.strip() for key in group.split(","))
missing_citations = sorted(cited - bibkeys)
if missing_citations:
    die("unresolved manuscript citations: " + ", ".join(missing_citations))
if TEX.count(r"\cite{LiYang2026}") < 2:
    die("Li--Yang subsequent work must be cited in both literature context and conclusion")

# Group indexes must use |G:M| / \lvert G:M\rvert, never square delimiters.
# Stable conjugacy-class notation such as [V] is intentionally unaffected.
# This is a repository-wide gate, including retained exploratory sources and
# logs; it is not limited to manuscript prose.
index_re = re.compile(
    r"\[(?:\\?[A-Za-z][A-Za-z0-9_{}^()|\\]*)\s*:\s*"
    r"(?:\\?[A-Za-z][A-Za-z0-9_{}^()|\\]*)\]"
)
text_suffixes = {
    ".tex", ".md", ".txt", ".log", ".g", ".py", ".json", ".csv",
    ".lean", ".v", ".sh", ".toml", ".yml", ".yaml", ".cff", ".lock",
}
text_names = {".gitignore", ".dockerignore"}
skip_dirs = {".git", ".lake", "__pycache__", ".cache", "_build"}
skip_names = {"kourovka1034.log"}  # ignored TeX build transcript, not an artifact
index_scan_files = 0
seen_paths: set[Path] = set()
for scan_root in (REPO, ROOT):
    if not scan_root.is_dir():
        continue
    for path in scan_root.rglob("*"):
        if (
            not path.is_file()
            or path.name in skip_names
            or any(part in skip_dirs for part in path.parts)
        ):
            continue
        if path.name.startswith("CODEX-REVIEW-"):
            # User-supplied review records are preserved verbatim and are not
            # project artifacts. They are also untracked and evidence-excluded.
            continue
        if path.suffix.lower() not in text_suffixes and path.name not in text_names:
            continue
        resolved = path.resolve()
        if resolved in seen_paths:
            continue
        seen_paths.add(resolved)
        try:
            body = path.read_text()
        except UnicodeDecodeError:
            die(f"declared text artifact is not UTF-8: {path}")
        index_scan_files += 1
        match = index_re.search(body)
        if match:
            die(f"{path}: square-delimited group index {match.group(0)!r}")

# Ensure the hand-authored classification routes are represented by the exact
# family names in the coverage proposition/manuscript.
family_tokens = {
    "alternating": "$A_n$",
    "psl2": "$\\PSL(2,q)$",
    "psl_rank_ge3": "$\\PSL(n,q)$",
    "psu3": "$\\PSU(n,q)$",
    "psu_rank_ge4": "$\\PSU(n,q)$",
    "symplectic": "$\\PSp(2n,q)$",
    "odd_orthogonal": "$\\Omega(2n{+}1,q)$",
    "plus_orthogonal": "$D_n(q)$",
    "minus_orthogonal": "$" + "{}^2D_n(q)$",
    "suzuki": "$\\Sz(2^f)$",
    "small_ree": "$" + "{}^2G_2(3^f)$",
    "triality": "$" + "{}^3D_4(q)$",
    "g2": "$G_2(q)$",
    "f4": "$F_4(q)$",
    "e6": "$E_6(q)$",
    "twisted_e6": "$" + "{}^2E_6(q)$",
    "e7": "$E_7(q)$",
    "e8": "$E_8(q)$",
    "large_ree": "$" + "{}^2F_4(2^f)$",
    "tits": "$" + "{}^2F_4(2)'$",
    "sporadic": "Sporadic groups",
}
ids = {item["id"] for item in CFSG["families"]}
if ids != set(family_tokens):
    die("checker family token map drift")
for family_id, token in family_tokens.items():
    if token not in TEX:
        die(f"manuscript lacks family token for {family_id}: {token}")


def noncomment_lines(path: Path) -> list[str]:
    return [
        line
        for line in path.read_text().splitlines()
        if line.strip() and not line.lstrip().startswith(("#", "TOTAL"))
    ]


if len(noncomment_lines(ROOT / "computations/data/simple_groups_below_500000.txt")) != 47:
    die("small finite-inventory count drift")
if len(noncomment_lines(ROOT / "computations/data/simple_groups_5e5_to_1.05e7.txt")) != 51:
    die("big finite-inventory count drift")
arithmetic_receipt = (
    ROOT / "computations/certificates/sweepN_item5_arith.log"
).read_text()
if (
    "instances checked: 7892" not in arithmetic_receipt
    or "FAILURES: 0" not in arithmetic_receipt
):
    die("7892-instance receipt does not match manuscript")

source_maps = [
    ("LIE-SOURCE-MAP.csv", 7),
    ("MAXIMALITY-SOURCE-MAP.csv", 10),
    ("SPORADIC-SOURCE-MAP.csv", 42),
    ("ORDER-FORMULA-SOURCE-MAP.csv", 23),
    ("ZSIGMONDY-INVOCATIONS.csv", 31),
    ("BOUNDARY-SOURCE-MAP.csv", 12),
]
source_rows = 0
for name, count in source_maps:
    with (ROOT / "audit" / name).open(newline="") as source_file:
        actual = sum(1 for _ in csv.DictReader(source_file))
    if actual != count:
        die(f"{name}: row count drift: {actual} != {count}")
    source_rows += actual

exceptions = json.loads((ROOT / "audit/EXCEPTION-MANIFEST.json").read_text())[
    "exceptions"
]
if len(exceptions) != 20:
    die("exception-manifest count drift")
arithmetic_manifest = json.loads(
    (ROOT / "audit/FAMILY-ARITHMETIC-MANIFEST.json").read_text()
)
if (
    arithmetic_manifest.get("expected_branch_count") != 34
    or len(arithmetic_manifest.get("branches", [])) != 34
):
    die("family-arithmetic manifest branch count drift")
generated_arithmetic = json.loads(
    (ROOT / "audit/ARITHMETIC-EXCEPTIONS.generated.json").read_text()
)
if len(generated_arithmetic.get("exception_cases", [])) != 12:
    die("generated arithmetic exception-occurrence count drift")
if len(generated_arithmetic.get("zsigmondy_exception_ids", [])) != 7:
    die("generated arithmetic distinct Zsigmondy-exception count drift")

gap_essential = [
    "sweepJ_divisibility",
    "sweepJ2_tail",
    "sweepJ3_bigrange",
    "sweepJ4_patch",
    "sweepJ5_smallAn",
    "sweepJ6_L52_M23",
    "sweepK_novelty",
    "sweepK2_saturation",
    "sweepK3_bigsurvivors",
    "sweepK4_L52",
    "sweepM_sporadic",
    "sweepL_psl2_arith",
    "sweepL2_an_arith",
]
full = (ROOT / "verify-full.sh").read_text()
log_checker = (ROOT / "computations/independent/verify_logs.py").read_text()
static_checker = (ROOT / "audit/static_check.py").read_text()
for base in gap_essential:
    for path in [
        ROOT / f"computations/gap/{base}.g",
        ROOT / f"computations/certificates/{base}.log",
    ]:
        if not path.is_file():
            die(f"missing proof-essential artifact {path.relative_to(ROOT)}")
    if (
        base not in full
        or base not in log_checker
        or f"{base}.g" not in static_checker
    ):
        die(f"proof-essential sweep omitted from a gate: {base}")

python_checkers = [
    "computations/python/sweepN_item5_arith.py",
    "computations/python/verify_coverage.py",
    "computations/python/verify_coverage_big.py",
    "computations/independent/family_arithmetic_universal.py",
    "computations/independent/family_arithmetic_symbolic.py",
    "computations/independent/verify_family_manifest.py",
    "computations/independent/verify_finite_witnesses.py",
    "computations/independent/verify_lie_sources.py",
    "computations/independent/verify_maximality_sources.py",
    "computations/independent/verify_order_formula_sources.py",
    "computations/independent/verify_zsigmondy_sources.py",
    "computations/independent/verify_boundary_sources.py",
    "computations/independent/verify_logs.py",
    "computations/independent/verify_manuscript.py",
]
quick = (ROOT / "verify-quick.sh").read_text()
for script in python_checkers:
    if not (ROOT / script).is_file():
        die("missing proof checker " + script)
    if script not in full or script not in quick:
        die("checker omitted from quick/full gate: " + script)
for gate_text, gate_name in [(quick, "quick"), (full, "full")]:
    if "formal-rocq/verify.sh" not in gate_text:
        die(f"Rocq/MathComp build omitted from {gate_name} gate")

for required_file in [
    ROOT / "audit/REVISION-BASELINE.md",
    ROOT / "audit/CONTRIBUTION-MAP.md",
    ROOT / "audit/MATHEMATICAL-YIELD.md",
    ROOT / "audit/REVIEW-PROTOCOL.md",
    ROOT / "audit/REVISION-CHANGELOG.md",
    ROOT / "audit/REVISION-PREFLIGHT.md",
    ROOT / "formal/Comparator/Challenge.lean",
    ROOT / "formal/Comparator/Solution.lean",
    ROOT / "formal/Comparator/README.md",
]:
    if not required_file.is_file():
        die(f"architecture artifact missing: {required_file.relative_to(ROOT)}")

print(
    "MANUSCRIPT/MANIFEST CONSISTENCY|PASS|"
    f"families={len(ids)}|required_tokens={len(required)}|"
    f"source_rows={source_rows}|exceptions={len(exceptions)}|"
    f"gap_sweeps={len(gap_essential)}|checkers={len(python_checkers)}|"
    "repository_index_gate=PASS|public_metadata_gate=PASS"
)
