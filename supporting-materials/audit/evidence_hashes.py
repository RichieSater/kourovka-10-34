#!/usr/bin/env python3
"""Generate or verify the cryptographic closure of proof inputs/receipts.

EVIDENCE.sha256 is deliberately not self-hashed.  Paths are relative to the
supporting-materials directory and are sorted bytewise before hashing.
"""
from __future__ import annotations
import argparse, hashlib, os, sys
from pathlib import Path

ROOT=Path(os.environ.get('KOUROVKA_SUPPORTING_ROOT',Path(__file__).resolve().parents[1])).resolve()
REPO=Path(os.environ.get('KOUROVKA_REPO_ROOT',ROOT.parent)).resolve()
MANIFEST=ROOT/'audit/EVIDENCE.sha256'
BUILD_SUFFIXES={'.aux','.glob','.vo','.vos','.vok','.olean','.ilean'}

def selected() -> list[Path]:
    fixed=[ROOT/'README.md',ROOT/'verify-quick.sh',ROOT/'verify-full.sh',
           ROOT/'paper/kourovka1034.tex',
           REPO/'.gitignore',REPO/'.dockerignore']
    trees=['audit','formal','formal-rocq','paper/submission','computations/gap','computations/python',
           'computations/independent','computations/mutation-tests',
           'computations/environment','computations/data','computations/certificates']
    out=set(p for p in fixed if p.is_file())
    for tree in trees:
        for p in (ROOT/tree).rglob('*'):
            rel=p.relative_to(ROOT).as_posix()
            if (not p.is_file() or '/.lake/' in '/'+rel
                    or p.suffix in BUILD_SUFFIXES
                    or p.name.endswith('.olean.hash')
                    or p.name == '.lia.cache'
                    or rel.endswith(('.pyc','.regen','.new'))):
                continue
            if rel == 'audit/EVIDENCE.sha256':
                continue
            out.add(p)
    return sorted(out,key=lambda p:display_path(p).encode())

def display_path(p:Path)->str:
    # In mutation snapshots the operational repository root is deliberately a
    # child directory of the synthetic supporting root.  Preserve the release
    # manifest's canonical `../ROOT-FILE` spelling in both layouts.
    if p.parent == REPO:
        return '../'+p.name
    try: return p.relative_to(ROOT).as_posix()
    except ValueError: return '../'+p.relative_to(REPO).as_posix()

def digest(p:Path)->str:
    h=hashlib.sha256()
    with p.open('rb') as f:
        for b in iter(lambda:f.read(1024*1024),b''): h.update(b)
    return h.hexdigest()

def render()->str:
    return ''.join(f'{digest(p)}  {display_path(p)}\n' for p in selected())

def main()->int:
    ap=argparse.ArgumentParser()
    g=ap.add_mutually_exclusive_group(required=True)
    g.add_argument('--write',action='store_true')
    g.add_argument('--verify',action='store_true')
    a=ap.parse_args(); current=render()
    if a.write:
        MANIFEST.write_text(current)
        print(f'EVIDENCE HASH MANIFEST|WROTE|files={len(current.splitlines())}')
        return 0
    if not MANIFEST.exists(): raise SystemExit('HARD-FAIL: audit/EVIDENCE.sha256 missing')
    expected=MANIFEST.read_text()
    if expected!=current:
        old={x.split('  ',1)[1]:x.split('  ',1)[0] for x in expected.splitlines() if '  ' in x}
        new={x.split('  ',1)[1]:x.split('  ',1)[0] for x in current.splitlines() if '  ' in x}
        for p in sorted(set(old)|set(new)):
            if old.get(p)!=new.get(p): print(f'DRIFT|{p}|expected={old.get(p)}|actual={new.get(p)}')
        raise SystemExit('HARD-FAIL: evidence hash manifest differs')
    print(f'EVIDENCE HASH MANIFEST|PASS|files={len(current.splitlines())}')
    return 0
if __name__=='__main__':
    try: sys.exit(main())
    except (OSError,UnicodeError) as exc: raise SystemExit('HARD-FAIL: '+str(exc))
