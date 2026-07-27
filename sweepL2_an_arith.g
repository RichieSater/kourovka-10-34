# Sweep L2: arithmetic receipts for the A_n case of the section-5 program,
# 12 <= n <= 10000: with p the largest prime <= n (so p > n/2 by Bertrand),
# count the X-stable maximal classes avoiding p:
#   intransitive (S_m x S_{n-m}) cap A_n  with  n-p < m <= floor((n-1)/2),
#   plus the imprimitive (S_{n/2} wr S_2) cap A_n when n is even and n/2 < p.
# The program needs >= 2 such classes.  Report all n where the count is < 2.
bad := [];
for n in [12..10000] do
  p := n; while not IsPrimeInt(p) do p := p-1; od;
  cnt := Maximum(0, Int((n-1)/2) - Maximum(1, n-p+1) + 1);
  if IsEvenInt(n) and n/2 < p then cnt := cnt + 1; fi;
  if cnt < 2 then Add(bad, [n, p, cnt]); fi;
od;
Print("failures: ", bad, "\n");
if bad = [] then Print("A_n ARITHMETIC RECEIPTS OK for 12 <= n <= 10000.\n"); fi;
QUIT;
