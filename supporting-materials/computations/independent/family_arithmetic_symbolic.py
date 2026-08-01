#!/usr/bin/env python3
"""Independent symbolic audit of primitive-exponent inequalities.

The primary sweep N evaluates thousands of concrete parameters.  This checker
instead encodes each unbounded rank branch as affine functions of the rank and
proves the strict exponent inequalities from the minimum permitted rank and
coefficient comparison.  It also recomputes all substitute-prime valuations
from independently stated order-factor formulas.

Published order formulas and Zsigmondy's theorem remain external assumptions;
this program checks the arithmetic layered on top of those inputs.
"""
from __future__ import annotations
from dataclasses import dataclass
from math import gcd
import sys

@dataclass(frozen=True)
class Affine:
    a: int
    b: int
    def at(self, n: int) -> int: return self.a*n + self.b

def strict_for_all(lhs: Affine, rhs: Affine, n0: int, label: str) -> None:
    # Difference is affine.  A nonnegative slope and positivity at the left
    # endpoint prove positivity for every integer n >= n0.
    diff = Affine(lhs.a-rhs.a, lhs.b-rhs.b)
    if diff.a < 0 or diff.at(n0) <= 0:
        raise AssertionError(f"{label}: cannot prove {lhs}>{rhs} for all n>={n0}")

UNBOUNDED = [
    ("C_n/B_n P1", Affine(2,0), Affine(2,-2), 2),
    ("C_n/B_n P2", Affine(2,0), Affine(2,-4), 3),
    ("PSL_n P1", Affine(1,0), Affine(1,-1), 3),
    ("PSL_n P2", Affine(1,0), Affine(1,-2), 4),
    ("PSL_n graph flag 1", Affine(1,0), Affine(1,-2), 5),
    ("PSL_n graph flag 2", Affine(1,0), Affine(1,-4), 5),
    ("D_n P1", Affine(2,-2), Affine(2,-4), 4),
    ("D_n P2", Affine(2,-2), Affine(2,-4), 4),
    ("PSU_n odd GU remainder", Affine(2,0), Affine(2,-4), 5),
    ("PSU_n even GU remainder", Affine(2,-2), Affine(2,-6), 4),
    ("PSU_n even linear remainder", Affine(2,-2), Affine(1,-2), 4),
    ("^2D_n", Affine(2,0), Affine(2,-2), 4),
]

FIXED = {
    "G2": (6, [2]),
    "F4": (12, [6,3,2]),
    "E7": (18, [12]),
    "E8": (30, [18]),
    "E6": (12, [6,3]),
    "^3D4": (12, [6,3,2]),
    "^2E6": (18, [10,8,6,4]),
    "^2F4": (12, [4,2,1]),
    "PSU3": (6, [2]),
    "Suzuki": (4, [2,1]),
    "small Ree": (6, [2,1]),
    "Sp4 graph-even": (4, [2]),
    "F4 graph": (12, [4,2]),
}

def vp(n: int, p: int) -> int:
    out = 0
    while n and n % p == 0:
        out += 1; n //= p
    return out

def prod(xs):
    z = 1
    for x in xs: z *= x
    return z

def sl_order(n: int, q: int) -> int:
    return q**(n*(n-1)//2) * prod(q**i-1 for i in range(2,n+1))

def gl_order(n: int, q: int) -> int:
    return q**(n*(n-1)//2) * prod(q**i-1 for i in range(1,n+1))

def omega_plus_cover(n: int, q: int) -> int:
    return q**(n*(n-1)) * (q**n-1) * prod(q**(2*i)-1 for i in range(1,n))

def sp_order(n: int, q: int) -> int:
    return q**(n*n) * prod(q**(2*i)-1 for i in range(1,n+1))

def explicit_substitutions() -> None:
    # PSL(6,2), r=31.  Central quotients have order prime to 31.
    s = sl_order(6,2)
    p2 = gl_order(2,2)*gl_order(4,2)
    p3 = gl_order(3,2)**2
    flag1 = gl_order(4,2)
    flag2 = gl_order(2,2)**3
    assert vp(s,31) == 1 and all(vp(v,31)==0 for v in [p2,p3,flag1,flag2])
    assert vp(2,31) == 0

    # Omega^+(8,2), r=5.  The cover/central quotient discrepancy is a
    # 2-power and therefore irrelevant to v_5.
    s = omega_plus_cover(4,2)
    trial1 = gl_order(2,2)**3
    trial2 = gl_order(2,2)
    p1 = omega_plus_cover(3,2)
    p2 = gl_order(2,2)*omega_plus_cover(2,2)
    assert vp(s,5) == 2
    assert vp(trial1,5)==vp(trial2,5)==0
    assert vp(s,5)-vp(p1,5)-vp(p2,5) == 1 > vp(24,5)

    # Sp(4,8), r=3: Borel and Suzuki subgroup omit the entire 3-part.
    q=8
    s=sp_order(2,q)
    borel=q**4*(q-1)**2
    suzuki=q**2*(q**2+1)*(q-1)
    assert vp(s,3)==4 and vp(borel,3)==vp(suzuki,3)==0
    assert 4 > vp(6,3)==1

def main() -> int:
    for label,lhs,rhs,n0 in UNBOUNDED:
        strict_for_all(lhs,rhs,n0,label)
    for label,(e,levi) in FIXED.items():
        if not all(j < e for j in levi):
            raise AssertionError(f"{label}: primitive exponent not above every Levi exponent")
    explicit_substitutions()
    print(f"unbounded affine branches proved: {len(UNBOUNDED)}")
    print(f"fixed-rank exponent branches checked: {len(FIXED)}")
    print("substitute-prime exact valuations: PSL(6,2), Omega+(8,2), Sp(4,8): PASS")
    print("INDEPENDENT SYMBOLIC FAMILY ARITHMETIC|PASS")
    return 0

if __name__ == "__main__":
    try:
        sys.exit(main())
    except (AssertionError, ArithmeticError) as exc:
        raise SystemExit("HARD-FAIL: " + str(exc))
