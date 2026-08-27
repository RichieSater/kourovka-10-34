#!/usr/bin/env python3
"""Prove that public internal-evaluation wording is rejected fail closed."""
from __future__ import annotations

import os
import shutil
import subprocess
import sys
import tempfile
from pathlib import Path

REPO = Path(__file__).resolve().parents[3]


def require(condition: bool, message: str) -> None:
    if not condition:
        raise SystemExit("HARD-FAIL: " + message)


def exercise(fragments: tuple[str, ...]) -> None:
    with tempfile.TemporaryDirectory(prefix="kourovka-public-corpus-") as tmp:
        clone = Path(tmp) / "repo"
        shutil.copytree(
            REPO,
            clone,
            ignore=shutil.ignore_patterns(
                ".git", ".lake", "__pycache__", "*.pyc", "*.pdf", "CODEX-*.md"
            ),
        )
        readme = clone / "README.md"
        readme.write_text(readme.read_text() + "\n" + "".join(fragments) + "\n")
        env = os.environ.copy()
        env["KOUROVKA_REPO_ROOT"] = str(clone)
        env["KOUROVKA_SUPPORTING_ROOT"] = str(clone / "supporting-materials")
        result = subprocess.run(
            [
                sys.executable,
                str(
                    clone
                    / "supporting-materials/computations/independent/verify_manuscript.py"
                ),
            ],
            env=env,
            text=True,
            stdout=subprocess.PIPE,
            stderr=subprocess.STDOUT,
        )
        require(result.returncode != 0, "prohibited public wording escaped detection")
        require(
            "prohibited internal process-status artifact" in result.stdout,
            "public-corpus failure was not attributed to the intended gate",
        )


def main() -> int:
    exercise(
        (
            "Approval by a ",
            "special",
            "ist re",
            "view",
            "er is required before submission.",
        )
    )
    exercise(("This manuscript has not undergone ", "pe", "er re", "view."))
    exercise(("External approval required before ", "sub", "mission."))
    print("PUBLIC CORPUS POLICY SELF-TEST|PASS|mutations=3/3")
    return 0


if __name__ == "__main__":
    try:
        raise SystemExit(main())
    except (OSError, UnicodeError, subprocess.SubprocessError) as exc:
        raise SystemExit("HARD-FAIL: " + str(exc))
