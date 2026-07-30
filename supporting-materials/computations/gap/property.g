# Kourovka Notebook 10.34 (V.S. Monakhov, 1986)
# Does there exist a non-soluble finite group which coincides with the
# product of any two of its non-conjugate maximal subgroups?
#
# Property P(G): for all non-conjugate maximal subgroups A, B of G: G = AB.
# By the conjugation lemma (G=AB  =>  G=A^x B^y for all x,y), it suffices to
# check one representative pair per unordered pair of distinct conjugacy
# classes of maximal subgroups.

# Returns true if G has property P; otherwise returns a record describing
# the first failing pair.
KourovkaTest := function(G)
  local mx, n, i, j, A, B, p;
  mx := MaximalSubgroupClassReps(G);
  n := Size(G);
  for i in [1..Length(mx)] do
    for j in [i+1..Length(mx)] do
      A := mx[i]; B := mx[j];
      p := Size(A)*Size(B);
      # necessary integrality condition, avoids most intersections
      if p mod n <> 0 or p <> n*Size(Intersection(A,B)) then
        return rec(fails := true, i := i, j := j,
                   sizeA := Size(A), sizeB := Size(B),
                   nclasses := Length(mx));
      fi;
    od;
  od;
  return true;
end;

HasKourovkaProperty := G -> KourovkaTest(G) = true;
