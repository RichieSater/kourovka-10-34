#!/usr/bin/env python3
"""Validate the two-host clean-room receipt bundle without soft passes.

The clean-room run is deliberately a two-phase attestation. Both machines run
the same clean candidate commit and therefore must report the same commit,
input manifests, and byte-for-byte full-suite log. The resulting receipts are
then added to the attestation commit with ``--add``.
"""
from __future__ import annotations

import argparse
import datetime
import hashlib
import json
import os
import re
import shutil
import sys
from pathlib import Path

ROOT = Path(os.environ.get(
    "KOUROVKA_SUPPORTING_ROOT", Path(__file__).resolve().parents[1]
)).resolve()
PATH = ROOT / "audit/CLEANROOM-RECEIPTS.json"
HEX64 = re.compile(r"^[0-9a-f]{64}$")
HEX40 = re.compile(r"^[0-9a-f]{40}$")
UTCSTAMP = re.compile(r"^\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}(?:\.\d+)?Z$")
FIELDS = {
    "receipt_id", "machine_fingerprint_sha256", "architecture", "os",
    "git_commit", "container_image_id", "evidence_manifest_sha256",
    "certificate_manifest_sha256", "full_log_sha256", "fresh_clone",
    "full_suite_result", "generated_utc",
}
LOG_DIR = ROOT / "audit/cleanroom-logs"


def die(msg: str) -> None:
    raise SystemExit("HARD-FAIL: " + msg)


def canonical_receipt_id(receipt: dict) -> str:
    payload = {key: value for key, value in receipt.items() if key != "receipt_id"}
    raw = json.dumps(payload, sort_keys=True, separators=(",", ":")).encode()
    return hashlib.sha256(raw).hexdigest()


def validate_receipt(raw: object, index: int) -> dict:
    if not isinstance(raw, dict) or set(raw) != FIELDS:
        die(f"receipt {index}: field drift")
    receipt = raw
    for key in [
        "receipt_id", "machine_fingerprint_sha256", "evidence_manifest_sha256",
        "certificate_manifest_sha256", "full_log_sha256",
    ]:
        if not isinstance(receipt[key], str) or not HEX64.fullmatch(receipt[key]):
            die(f"receipt {index}: {key} is not lowercase SHA-256")
    if receipt["receipt_id"] != canonical_receipt_id(receipt):
        die(f"receipt {index}: receipt ID does not bind its canonical payload")
    if not isinstance(receipt["git_commit"], str) or not HEX40.fullmatch(receipt["git_commit"]):
        die(f"receipt {index}: invalid git commit")
    image = receipt["container_image_id"]
    if (not isinstance(image, str) or not image.startswith("sha256:")
            or not HEX64.fullmatch(image[7:])):
        die(f"receipt {index}: invalid container image ID")
    for key in ["architecture", "os", "generated_utc"]:
        if not isinstance(receipt[key], str) or not receipt[key]:
            die(f"receipt {index}: empty {key}")
    timestamp = receipt["generated_utc"]
    if not UTCSTAMP.fullmatch(timestamp):
        die(f"receipt {index}: timestamp is not UTC RFC 3339")
    try:
        datetime.datetime.fromisoformat(timestamp[:-1] + "+00:00")
    except ValueError:
        die(f"receipt {index}: invalid timestamp")
    if receipt["fresh_clone"] is not True or receipt["full_suite_result"] != "PASS":
        die(f"receipt {index}: not a passing fresh-clone full run")
    return receipt


def validate_bundle(
    bundle: object, require_complete: bool = False, check_log: bool = True
) -> dict:
    if not isinstance(bundle, dict):
        die("clean-room bundle is not an object")
    if set(bundle) != {"schema_version", "required_distinct_machines", "receipts"}:
        die("clean-room top-level schema drift")
    if bundle["schema_version"] != 1 or bundle["required_distinct_machines"] != 2:
        die("clean-room policy drift")
    rows = bundle["receipts"]
    if not isinstance(rows, list):
        die("receipts is not a list")

    ids: list[str] = []
    machines: list[str] = []
    commits: list[str] = []
    evidence: list[str] = []
    certificates: list[str] = []
    full_logs: list[str] = []
    for index, raw in enumerate(rows):
        receipt = validate_receipt(raw, index)
        ids.append(receipt["receipt_id"])
        machines.append(receipt["machine_fingerprint_sha256"])
        commits.append(receipt["git_commit"])
        evidence.append(receipt["evidence_manifest_sha256"])
        certificates.append(receipt["certificate_manifest_sha256"])
        full_logs.append(receipt["full_log_sha256"])

    if len(ids) != len(set(ids)):
        die("duplicate receipt ID")
    if len(machines) != len(set(machines)):
        die("receipts do not identify distinct machines")
    for label, values in [
        ("candidate commits", commits),
        ("evidence manifests", evidence),
        ("certificate manifests", certificates),
        ("full-suite logs", full_logs),
    ]:
        if len(set(values)) > 1:
            die(f"clean-room {label} differ")

    if full_logs and check_log:
        log_path = LOG_DIR / f"{full_logs[0]}.log"
        if not log_path.is_file():
            die(f"clean-room full log missing: {log_path.relative_to(ROOT)}")
        actual = hashlib.sha256(log_path.read_bytes()).hexdigest()
        if actual != full_logs[0]:
            die("clean-room full log hash mismatch")

    distinct = len(set(machines))
    complete = len(rows) >= 2 and distinct >= 2
    if require_complete and not complete:
        die(f"clean-room incomplete: passing distinct machines={distinct}/2")
    return {"receipts": len(rows), "distinct_machines": distinct, "complete": complete}


def validate(require_complete: bool = False) -> dict:
    return validate_bundle(json.loads(PATH.read_text()), require_complete)


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("--require-complete", action="store_true")
    parser.add_argument("--add", type=Path, metavar="RECEIPT_JSON")
    parser.add_argument("--log", type=Path, metavar="FULL_LOG")
    args = parser.parse_args()

    if (args.add is None) != (args.log is None):
        die("--add and --log must be supplied together")

    if args.add is not None:
        incoming = json.loads(args.add.read_text())
        validate_receipt(incoming, -1)
        if not args.log.is_file():
            die(f"full log is not a file: {args.log}")
        log_bytes = args.log.read_bytes()
        if hashlib.sha256(log_bytes).hexdigest() != incoming["full_log_sha256"]:
            die("supplied full log does not match receipt")
        bundle = json.loads(PATH.read_text())
        validate_bundle(bundle)
        if incoming in bundle.get("receipts", []):
            die("receipt already present")
        candidate = json.loads(json.dumps(bundle))
        candidate["receipts"].append(incoming)
        validate_bundle(candidate, args.require_complete, check_log=False)
        # Make the content-addressed log visible while validating the
        # prospective bundle. If it already exists it must have the same bytes.
        LOG_DIR.mkdir(parents=True, exist_ok=True)
        stored_log = LOG_DIR / f"{incoming['full_log_sha256']}.log"
        if stored_log.exists() and stored_log.read_bytes() != log_bytes:
            die("stored clean-room log has colliding name but different bytes")
        if not stored_log.exists():
            shutil.copyfile(args.log, stored_log)
        validate_bundle(candidate, args.require_complete)
        PATH.write_text(json.dumps(candidate, indent=2, sort_keys=False) + "\n")

    info = validate(args.require_complete)
    print(
        "CLEANROOM RECEIPTS|PASS|"
        f"receipts={info['receipts']}|"
        f"distinct_machines={info['distinct_machines']}|"
        f"complete={str(info['complete']).lower()}"
    )
    return 0


if __name__ == "__main__":
    try:
        sys.exit(main())
    except (OSError, UnicodeError, json.JSONDecodeError, TypeError) as exc:
        die(str(exc))
