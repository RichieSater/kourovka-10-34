#!/usr/bin/env python3
# sweepN: numeric receipts for FAMILY-PROOFS.md Theorems 4, 5, 6 (HITLIST item 5).
#
# For each family instance we form:
#   S  = a multiple of |S| whose extra factors are powers of 2 / divisors of
#        torus numbers p^j-1 (j a proper divisor of e) -- harmless, see below;
#   Vs = "supersets": for each class of the exhibited pair, an integer that
#        the p'-part of the subgroup order divides (full Levi/overgroup orders);
#   x  = a multiple of |X/Inn| for every admissible X;
#   e  = the claimed order of p modulo the obstruction prime.
# T := primitive part of p^e - 1 (strip gcd with p^j - 1 over all proper j | e).
# Every prime r | T has ord_r(p) = e.  The theorems' claims reduce to:
#   T > 1 (Zsygmondy prime exists), gcd(T, S) > 1 (r | |S| for some such r),
#   gcd(T, Vi) = 1 for each superset, gcd(T, x) = 1.
# Then d = v_r(|S|) - 0 - 0 >= 1 > 0 = v_r(x): Theorem D/D' fires.
# T == 1 must occur exactly at the Zsygmondy exceptions listed in the proofs.
from math import gcd, isqrt

def primes(bound):
    sieve = bytearray([1]) * (bound + 1)
    sieve[0:2] = b"\x00\x00"
    for i in range(2, isqrt(bound) + 1):
        if sieve[i]:
            sieve[i*i::i] = bytearray(len(sieve[i*i::i]))
    return [i for i in range(bound + 1) if sieve[i]]

def prime_powers(bound, pbase=None):
    out = []
    for p in primes(bound):
        if pbase and p != pbase:
            continue
        f, q = 1, p
        while q <= bound:
            out.append((q, p, f))
            q *= p
            f += 1
    return sorted(out)

def prod(it):
    r = 1
    for v in it:
        r *= v
    return r

def glo(m, Q):  return Q**(m*(m-1)//2) * prod(Q**i - 1 for i in range(1, m+1)) if m > 0 else 1
def guo(m, q):  return q**(m*(m-1)//2) * prod(q**i - (-1)**i for i in range(1, m+1)) if m > 0 else 1
def slo(m, q):  return glo(m, q) // (q - 1)
def spo(dim, q):
    m = dim // 2
    return q**(m*m) * prod(q**(2*i) - 1 for i in range(1, m+1))
def gop(m, q):  return 2 * q**(m*(m-1)) * (q**m - 1) * prod(q**(2*i) - 1 for i in range(1, m)) if m > 1 else 2*(q-1)
def gom(m, q):  return 2 * q**(m*(m-1)) * (q**m + 1) * prod(q**(2*i) - 1 for i in range(1, m)) if m > 1 else 2*(q+1)
def szo(q):     return q**2 * (q**2 + 1) * (q - 1)
def reeo(q):    return q**3 * (q**3 + 1) * (q - 1)
def g2o(q):     return q**6 * (q**6 - 1) * (q**2 - 1)

def divisors(n):
    ds = set()
    for i in range(1, isqrt(n) + 1):
        if n % i == 0:
            ds.add(i); ds.add(n // i)
    return sorted(ds)

def primitive_part(p, e):
    T = p**e - 1
    for j in divisors(e):
        if j == e:
            continue
        g = gcd(T, p**j - 1)
        while g > 1:
            T //= g
            g = gcd(T, p**j - 1)
    return T

def vp(n, r):
    v = 0
    while n % r == 0:
        n //= r; v += 1
    return v

fails, checked, exceptions = [], 0, []
expected_A = {"2A:PSU(4,2)"}  # Theorem 4's sole Zsygmondy exception (machine base)

def check(tag, p, f, e, S, subs, x):
    global checked
    checked += 1
    T = primitive_part(p, e)
    if T == 1:
        exceptions.append(tag)
        return
    ok = gcd(T, S) > 1 and all(gcd(T, V) == 1 for V in subs) and gcd(T, x) == 1
    if not ok:
        fails.append(tag)

def check_direct(tag, r, S, subs, x, need_d_gt):
    # explicit substitute prime: verify v_r(S) - sum v_r(subs) > need floor
    global checked
    checked += 1
    d = vp(S, r) - sum(vp(V, r) for V in subs)
    if not d > vp(x, r) and d >= 1:
        fails.append(tag)
    if d <= vp(x, r):
        fails.append(tag)

QB = 200      # generic prime-power bound
NB = 26       # generic rank bound

# ---- Theorem 4: twisted, twisted rank >= 2 ----
for q, p, f in prime_powers(QB):
    for n in range(4, NB):
        e = 2*n*f if n % 2 else 2*(n-1)*f
        V = glo(1, q*q) * guo(n-2, q) * (q*q - 1)
        W = glo(2, q*q) * guo(n-4, q)
        check(f"2A:PSU({n},{q})", p, f, e, guo(n, q), [V, W], 2*f*gcd(n, q+1))
    for n in range(4, NB):
        V = (q - 1) * gom(n-1, q)
        W = glo(2, q) * gom(n-2, q)
        check(f"2D:O-({2*n},{q})", p, f, 2*n*f, gom(n, q), [V, W], 8*f)
    S3d4 = q**12 * (q**8 + q**4 + 1) * (q**6 - 1) * (q**2 - 1)
    check(f"3D4({q})", p, f, 12*f, S3d4,
          [slo(2, q**3) * (q - 1), slo(2, q) * (q**3 - 1)], 3*f)
    S2e6 = q**36*(q**12-1)*(q**9+1)*(q**8-1)*(q**6-1)*(q**5+1)*(q**2-1)
    check(f"2E6({q})", p, f, 18*f, S2e6,
          [guo(6, q), slo(2, q)*slo(3, q*q), gom(4, q)*(q-1), slo(3, q)*slo(2, q*q)],
          6*f)
for f in range(3, 22, 2):  # 2F4(2^f), f odd
    q = 2**f
    S = q**12 * (q**6 + 1) * (q**4 - 1) * (q**3 + 1) * (q - 1)
    check(f"2F4(2^{f})", 2, f, 12*f, S, [szo(q)*(q-1), slo(2, q)*(q-1)], f)

# ---- Theorem 5: twisted rank one ----
for q, p, f in prime_powers(3000):
    if q >= 8:
        S = q**3 * (q**3 + 1) * (q**2 - 1)
        check(f"U3({q})", p, f, 6*f, S,
              [q**3 * (q**2 - 1), q * (q - 1) * (q + 1)**2], 6*f)
for f in range(3, 26, 2):
    q = 2**f
    check(f"Sz(2^{f})", 2, f, 4*f, szo(q), [q*q*(q-1), 2*(q-1)], f)
for f in range(3, 16, 2):
    q = 3**f
    check(f"2G2(3^{f})", 3, f, 6*f, reeo(q), [q**3*(q-1), q*(q*q-1)], f)

# ---- Theorem 6 Case A: untwisted, trivial graph part ----
for q, p, f in prime_powers(QB):
    for n in range(3, NB):  # PSL(n,q)
        tag = f"A:L{n}({q})"
        if (n, f, p) in ((3, 2, 2), (6, 1, 2)):
            expected_A.add(tag)
        check(tag, p, f, n*f, glo(n, q),
              [glo(n-1, q)*(q-1), glo(2, q)*glo(n-2, q)], 2*f*gcd(n, q-1))
    for n in range(4, NB):  # D_n(q)
        tag = f"A:D{n}({q})"
        if (n, f, p) == (4, 1, 2):
            expected_A.add(tag)
        check(tag, p, f, 2*(n-1)*f, gop(n, q),
              [(q-1)*gop(n-1, q), glo(2, q)*gop(n-2, q)], 24*f)
    Se6 = q**36*(q**12-1)*(q**9-1)*(q**8-1)*(q**6-1)*(q**5-1)*(q**2-1)
    check(f"E6({q})", p, f, 12*f, Se6,
          [slo(6, q)*(q-1), glo(3, q)**2 * glo(2, q)], 12*f)
    if p == 2 and f >= 2:  # Sp(4,2^f) case A
        check(f"A:S4({q})", p, f, 4*f, spo(4, q), [slo(2, q)*(q-1), glo(2, q)], 2*f)
    if p == 2:  # F4(2^f) case A
        Sf4 = q**24*(q**12-1)*(q**8-1)*(q**6-1)*(q**2-1)
        check(f"A:F4({q})", p, f, 12*f, Sf4,
              [spo(6, q)*(q-1), glo(3, q)*glo(2, q)], 2*f)
    if p == 3:  # G2(3^f) case A
        check(f"A:G2({q})", p, f, 6*f, g2o(q), [slo(2, q)*(q-1)]*2, 2*f)

# ---- Theorem 6 Case B: graph part present ----
for q, p, f in prime_powers(3000):
    if q >= 5:  # B1: L3(q), (Borel, (q-1)^2:S3)
        tag = f"B:L3({q})"
        if (f, p) == (2, 2):
            expected_A.add(tag)  # L3(4): machine
        check(tag, p, f, 3*f, glo(3, q), [q**3*(q-1)**2, 6*(q-1)**2], 6*f)
for q, p, f in prime_powers(QB):
    check(f"B:L4({q})", p, f, 4*f, glo(4, q),
          [glo(2, q)**2, (q-1)**2 * glo(2, q)], 2*f*gcd(4, q-1))
    for n in range(5, NB):
        tag = f"B:L{n}({q})"
        if (n, f, p) == (6, 1, 2):
            expected_A.add(tag)
        check(tag, p, f, n*f, glo(n, q),
              [(q-1)**2 * glo(n-2, q), glo(2, q)**2 * glo(n-4, q)], 2*n*f)
    tag = f"B:D4tri({q})"  # D4 triality pair (P2, Q_{2})
    if (f, p) == (1, 2):
        expected_A.add(tag)
    check(tag, p, f, 6*f, gop(4, q), [glo(2, q)**3, glo(2, q)*(q-1)**3], 24*f)
    if p == 2 and f >= 3 and f % 2 == 1:  # B5, f odd: (Borel, Sz(q)), r | q+1
        tag = f"B:S4({q})odd"
        if f == 3:
            expected_A.add(tag)  # q=8: substitute r=3 below
        check(tag, p, f, 2*f, spo(4, q), [q**4*(q-1)**2, szo(q)], 2*f)
    if p == 2 and f >= 2 and f % 2 == 0:  # B5, f even: (Borel, Sp(4,sqrt q))
        q0 = 2**(f//2)
        check(f"B:S4({q})even", p, f, 4*f, spo(4, q),
              [q**4*(q-1)**2, spo(4, q0)], 2*f)
    if p == 2:  # B6: F4, novelty pair (Q_{23}, Q_{14})
        Sf4 = q**24*(q**12-1)*(q**8-1)*(q**6-1)*(q**2-1)
        check(f"B:F4({q})", p, f, 12*f, Sf4,
              [spo(4, q)*(q-1)**2, glo(2, q)**2*(q-1)**2], 2*f)
    if p == 3 and f % 2 == 1:  # B7 f odd: (Borel, 2G2(q)), r | q^2+q+1
        check(f"B:G2({q})odd", p, f, 3*f, g2o(q), [q**6*(q-1)**2, reeo(q)], 2*f)
    if p == 3 and f % 2 == 0:  # B7 f even: (Borel, G2(sqrt q))
        q0 = 3**(f//2)
        check(f"B:G2({q})even", p, f, 6*f, g2o(q), [q**6*(q-1)**2, g2o(q0)], 2*f)

# ---- explicit substitute primes at the Zsygmondy exceptions ----
# PSL(6,2), r = 31: case A pair (P2,P3) and case B pair (Q_{J1},Q_{J2})
q = 2
check_direct("X:L6(2)A", 31, glo(6, 2), [glo(2,2)*glo(4,2), glo(3,2)**2], 2, 0)
check_direct("X:L6(2)B", 31, glo(6, 2), [(q-1)**2*glo(4,2), glo(2,2)**2*glo(2,2)], 2, 0)
# Omega+(8,2), r = 5: triality pair and (P1,P2) pair
check_direct("X:O8+(2)tri", 5, gop(4, 2), [glo(2,2)**3, glo(2,2)], 24, 0)
check_direct("X:O8+(2)P1P2", 5, gop(4, 2), [(q-1)*gop(3,2), glo(2,2)*gop(2,2)], 24, 0)
# Sp(4,8), r = 3: (Borel, Sz(8))
check_direct("X:S4(8)", 3, spo(4, 8), [8**4*49, szo(8)], 6, 1)

print(f"instances checked: {checked}")
print(f"FAILURES: {len(fails)}")
for t in fails:
    print("  FAIL", t)
unexpected = [t for t in exceptions if t not in expected_A]
print(f"Zsygmondy exceptions hit: {len(exceptions)}; unexpected: {len(unexpected)}")
for t in unexpected:
    print("  UNEXPECTED EXCEPTION", t)
print("expected-exception tags encountered:", sorted(t for t in exceptions if t in expected_A))
print("SWEEP N DONE." if not fails and not unexpected else "SWEEP N HAS PROBLEMS.")
