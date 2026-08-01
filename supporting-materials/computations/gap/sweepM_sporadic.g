# Sweep M v2: exact CTblLib class records for the remaining sporadic groups
# and the Tits group.  No subgroup is identified by order alone.
#
# For |Out(S)|=2 we use only a Maxes-list position whose order occurs exactly
# once in the complete pinned list.  Since automorphisms preserve subgroup
# order, that exact S-class is Aut(S)-stable.  The certificate records the
# position, CTblLib identifier, order, uniqueness count, package version, and
# valuation tuple.  The manuscript describes this same argument; stored class
# fusions are not claimed or used here.

Read("proof_common.g");

Vp := function(n,p)
  local v; v:=0; while n mod p=0 do n:=n/p; v:=v+1; od; return v;
end;

CheckSporadic := function(name,out)
  local ct,S,ids,tables,orders,usable,candidates,i,j,p,d,best,ui,vi,
        ureason,vreason;
  AssertProof(out=1 or out=2,Concatenation(name,": invalid outer order"));
  ct:=CharacterTable(name);
  AssertProof(ct<>fail,Concatenation(name,": missing character table"));
  AssertProof(HasMaxes(ct),Concatenation(name,": missing CTblLib Maxes record"));
  S:=Size(ct); ids:=Maxes(ct);
  tables:=List(ids,CharacterTable);
  AssertProof(ForAll(tables,t->t<>fail),
              Concatenation(name,": a Maxes character table is missing"));
  orders:=List(tables,Size);
  AssertProof(Length(ids)=Length(orders) and Length(ids)>=2,
              Concatenation(name,": invalid Maxes list"));
  if out=1 then
    usable:=[1..Length(ids)];
  else
    usable:=Filtered([1..Length(ids)],i->Number(orders,o->o=orders[i])=1);
  fi;
  candidates:=[];
  for i in [1..Length(usable)] do
    for j in [i+1..Length(usable)] do
      for p in PrimeDivisors(S) do
        d:=Vp(S,p)-Vp(orders[usable[i]],p)-Vp(orders[usable[j]],p);
        if d>Vp(out,p) then
          Add(candidates,[p,d,usable[i],usable[j],
                          orders[usable[i]],orders[usable[j]]]);
        fi;
      od;
    od;
  od;
  AssertProof(Length(candidates)>0,
              Concatenation(name,": no stable CTblLib pair excludes the group"));
  # Deterministic declared policy: prefer the lexicographically greatest
  # (class-position pair, then prime) after re-keying.  This keeps witnesses
  # near the tail of CTblLib's order-descending Maxes list (small, readily
  # identifiable subgroups such as 59:29 and 41:40 in the Monster).
  candidates:=List(candidates,c->[c[3],c[4],c[1],c[2],c[5],c[6]]);
  Sort(candidates); best:=candidates[Length(candidates)];
  best:=[best[3],best[4],best[1],best[2],best[5],best[6]];
  p:=best[1]; d:=best[2]; ui:=best[3]; vi:=best[4];
  ureason:="Out=1"; vreason:="Out=1";
  if out=2 then
    AssertProof(Number(orders,o->o=orders[ui])=1 and
                Number(orders,o->o=orders[vi])=1,
                Concatenation(name,": selected order is not unique"));
    ureason:="unique-order-in-complete-Maxes";
    vreason:="unique-order-in-complete-Maxes";
  fi;
  Print("SPORADIC|group=",name,"|table=",Identifier(ct),"|s=",S,
        "|out=",out,"|maxes=",Length(ids),
        "|maxes_sha256=",HexSHA256(String(ids)),
        "|selection=max-class-positions-then-prime\n");
  Print("MAXCLASS|group=",name,"|position=",ui,"|identifier=",ids[ui],
        "|order=",orders[ui],"|multiplicity=",
        Number(orders,o->o=orders[ui]),"|stability=",ureason,"\n");
  Print("MAXCLASS|group=",name,"|position=",vi,"|identifier=",ids[vi],
        "|order=",orders[vi],"|multiplicity=",
        Number(orders,o->o=orders[vi]),"|stability=",vreason,"\n");
  Print(name," (|S| = ",S,", out = ",out,
        "): ALL k >= 1 EXCLUDED, ALL X, via (|U|,|V|,p,d) = ",
        [orders[ui],orders[vi],p,d],"\n");
  Print("CERT|kind=sporadic|group=",name,"|s=",S,"|out=",out,
        "|x=",out,"|uclass=",ui,"|uid=",ids[ui],"|u=",orders[ui],
        "|ustability=",ureason,"|vclass=",vi,"|vid=",ids[vi],
        "|v=",orders[vi],"|vstability=",vreason,
        "|p=",p,"|d=",d,"|vpx=",Vp(out,p),"|result=PASS\n");
end;

CheckSporadic("M24",     1);
CheckSporadic("J3",      2);
CheckSporadic("J4",      1);
CheckSporadic("HS",      2);
CheckSporadic("McL",     2);
CheckSporadic("Co1",     1);
CheckSporadic("Co2",     1);
CheckSporadic("Co3",     1);
CheckSporadic("Suz",     2);
CheckSporadic("He",      2);
CheckSporadic("Ru",      1);
CheckSporadic("ON",      2);
CheckSporadic("Fi22",    2);
CheckSporadic("Fi23",    1);
CheckSporadic("Fi24'",   2);
CheckSporadic("HN",      2);
CheckSporadic("Ly",      1);
CheckSporadic("Th",      1);
CheckSporadic("B",       1);
CheckSporadic("M",       1);
CheckSporadic("2F4(2)'", 2);
Print("SWEEP M DONE.|PASS\n");
QUIT_GAP(0);
