# Common fail-closed helpers for proof-producing GAP programs.
#
# The proof suite intentionally does not use CALL_WITH_CATCH.  An exception,
# missing package, version drift, failed assertion, or ambiguous class identity
# must terminate GAP with a nonzero status.

PROOF_GAP_VERSION := "4.16.0";
PROOF_CTBLIB_VERSION := "1.3.11";
PROOF_ATLASREP_VERSION := "2.1.11";
PROOF_RNG_SEED := 1034;

# GAP library algorithms may make internal randomized choices even when the
# calling proof program does not invoke Random.  Reset both global sources at
# the start of every proof process to remove that avoidable source of drift.
# Proof programs must still canonicalize mathematical receipts: the seed is a
# reproducibility guard, not a substitute for representation-independent data.
Reset(GlobalMersenneTwister,PROOF_RNG_SEED);;
Reset(GlobalRandomSource,PROOF_RNG_SEED);;

# GAP 4.16.0 predates GAP commit b12f8342d641075d58fcbe62cc00dd433d7b8e18,
# which fixes and regression-tests ContainedConjugates.  The proof environment
# overlays lib/csetgrp.gi from that commit.  Pin its exact SHA-256 here.
PROOF_CSETGRP_SHA256 :=
  "3e7a00ef8730f6c058213db2f13c076565603ea2467e04aeea756e4afcb76b9f";

# Prevent terminal-width-dependent line wrapping in certificate logs.
SizeScreen([4096,100000]);

HardFail := function(msg)
  Print("HARD-FAIL: ", msg, "\n");
  QUIT_GAP(1);
end;

AssertProof := function(condition, msg)
  if not condition then HardFail(msg); fi;
end;

PackageVersionOrFail := function(name)
  local key, info;
  AssertProof(LoadPackage(name) = true,
              Concatenation("required package did not load: ", name));
  key := LowercaseString(name);
  AssertProof(IsBound(GAPInfo.PackagesInfo.(key)),
              Concatenation("missing package metadata: ", name));
  info := GAPInfo.PackagesInfo.(key);
  AssertProof(Length(info) = 1,
              Concatenation("ambiguous package metadata: ", name));
  return info[1].Version;
end;

ProofRootFile := function(relative)
  local root, path;
  for root in GAPInfo.RootPaths do
    path := Filename(Directory(root), relative);
    if path <> fail and IsExistingFile(path) then return path; fi;
  od;
  return fail;
end;

Sha256FileOrFail := function(path)
  local stream, digest;
  AssertProof(path <> fail and IsExistingFile(path), "hash input is missing");
  stream := InputTextFile(path);
  AssertProof(stream <> fail, Concatenation("cannot open hash input: ", path));
  digest := HexSHA256(stream);
  CloseStream(stream);
  return digest;
end;

CheckProofEnvironment := function()
  local csetgrp, ctblib, atlasrep;
  AssertProof(GAPInfo.Version = PROOF_GAP_VERSION,
    Concatenation("GAP version mismatch: got ", GAPInfo.Version,
                  ", require ", PROOF_GAP_VERSION));
  ctblib := PackageVersionOrFail("ctbllib");
  atlasrep := PackageVersionOrFail("atlasrep");
  AssertProof(ctblib = PROOF_CTBLIB_VERSION,
    Concatenation("CTblLib version mismatch: got ", ctblib,
                  ", require ", PROOF_CTBLIB_VERSION));
  AssertProof(atlasrep = PROOF_ATLASREP_VERSION,
    Concatenation("AtlasRep version mismatch: got ", atlasrep,
                  ", require ", PROOF_ATLASREP_VERSION));
  csetgrp := ProofRootFile("lib/csetgrp.gi");
  AssertProof(Sha256FileOrFail(csetgrp) = PROOF_CSETGRP_SHA256,
    "ContainedConjugates implementation is not the pinned fixed source");
  Print("ENV|gap=", GAPInfo.Version,
        "|ctbllib=", ctblib,
        "|atlasrep=", atlasrep,
        "|csetgrp_sha256=", PROOF_CSETGRP_SHA256,
        "|rng_seed=",PROOF_RNG_SEED,"\n");
end;

# A persistent class identifier independent of the particular permutation
# representation selected internally by GAP.  The pinned class position is the
# logical identifier.  The SHA-256 binds the canonical numeric tuple
# (class position, order, index, normalizer order).  In particular, never hash
# a chosen generating set: equivalent clean runs can choose different ones.
ClassFingerprintData := function(S,classpos,U)
  return [classpos,Size(U),Index(S,U),Size(Normalizer(S,U))];
end;

ClassFingerprintHash := function(S,classpos,U)
  return HexSHA256(String(ClassFingerprintData(S,classpos,U)));
end;

SubgroupFingerprint := function(S, classpos, U)
  local data;
  data := ClassFingerprintData(S,classpos,U);
  return Concatenation(
    "class=", String(data[1]),
    ",order=", String(data[2]),
    ",index=", String(data[3]),
    ",normalizer=", String(data[4]),
    ",class_sha256=", ClassFingerprintHash(S,classpos,U));
end;

GroupFingerprint := function(S)
  return Concatenation(
    "order=", String(Size(S)),
    "|order_factors_sha256=", HexSHA256(String(Collected(Factors(Size(S))))));
end;

# Canonicalize conjugacy classes of coordinate-closure subgroups.  GAP does
# not promise an order for ConjugacyClassesSubgroups, and even a pcgs for the
# same abstract quotient can vary after different preceding computations.
# A proof receipt must therefore use neither the raw class position nor pc
# generator words.
#
# Instead, bind X/Inn to its exact induced permutation action on the pinned
# list of S-subgroup classes.  The key records the complete permutation image
# for every conjugate of X, together with intrinsic group invariants for X and
# for its intersection with the action kernel.  The caller chooses the class
# list (maximal classes in sweep J, every subgroup class in sweep K).  A hard
# failure on a key collision prevents a merely order-level identifier from
# entering a proof certificate.
AbstractFiniteGroupKey := function(G)
  return [Size(G),StructureDescription(G),Collected(List(Elements(G),Order))];
end;

PermutationSubgroupKey := function(H,degree)
  return SortedList(List(Elements(H),p -> ListPerm(p,degree)));
end;

CanonicalQuotientClassActionRecords := function(Q0,classHom,degree,ambientHom)
  local classes, out, c, reps, pairs, key, i, kernel, collision, collisions,
        extensionKey;
  AssertProof(IsGroupHomomorphism(classHom),
              "coordinate-class action is not a group homomorphism");
  kernel := KernelOfMultiplicativeGeneralMapping(classHom);
  AssertProof(kernel<>fail,"coordinate-class action kernel is unavailable");
  classes := ConjugacyClassesSubgroups(Q0);
  out := [];
  for c in classes do
    reps := AsList(c);
    AssertProof(Length(reps)>0,"empty coordinate-quotient subgroup class");
    pairs := List(reps,XQ -> [
      [PermutationSubgroupKey(Image(classHom,XQ),degree),
       AbstractFiniteGroupKey(Intersection(XQ,kernel))],XQ]);
    Sort(pairs,function(a,b) return a[1] < b[1]; end);
    key := [AbstractFiniteGroupKey(pairs[1][2]),Length(pairs),
            List(pairs,p -> p[1])];
    Add(out,rec(
      key := key,
      hash := "",
      reps := List(pairs,p -> p[2])
    ));
  od;
  Sort(out,function(a,b) return a.key < b.key; end);
  # Usually the exact action key is already injective.  If two distinct
  # quotient classes induce exactly the same audited class action (the three
  # exceptional outer involutions of A6 are the motivating case), refine only
  # those colliding keys by the intrinsic structure of their almost-simple
  # preimages.  Avoiding StructureDescription on noncolliding large groups is
  # both faster and less dependent on heuristic recognition code.
  collisions := List([1..Length(out)],i ->
    (i>1 and out[i-1].key=out[i].key)
    or (i<Length(out) and out[i].key=out[i+1].key));
  for i in [1..Length(out)] do
    collision := collisions[i];
    if collision then
      AssertProof(ambientHom<>fail,
                  "quotient-class action keys collide without an extension resolver");
      extensionKey := StructureDescription(PreImage(ambientHom,out[i].reps[1]));
    else extensionKey := "";
    fi;
    out[i].key := [out[i].key,extensionKey];
  od;
  Sort(out,function(a,b) return a.key < b.key; end);
  for i in [2..Length(out)] do
    AssertProof(out[i-1].key <> out[i].key,
                "two quotient-subgroup classes have the same exact key");
  od;
  for i in [1..Length(out)] do
    out[i].hash := HexSHA256(String([Size(Q0),degree,out[i].key]));
  od;
  return out;
end;

ClassPositionOrFail := function(S, reps, U)
  local pos;
  pos := PositionProperty(reps, R -> Size(R) = Size(U)
                                     and IsConjugate(S, R, U));
  AssertProof(pos <> fail, "subgroup does not match a recorded S-class");
  return pos;
end;

# Independent implementation of the contained-conjugate orbit calculation.
# It deliberately does not call ContainedConjugates or DoConjugateInto.
# Double cosets N_S(V) \\ S / W parametrize W-conjugacy classes of
# S-conjugates of V lying in W.
DirectContainedConjugates := function(S, W, V)
  local N, dcs, gens, out, dc, E;
  if Size(W) mod Size(V) <> 0 then return []; fi;
  N := Normalizer(S,V);
  dcs := DoubleCosetRepsAndSizes(S,N,W);
  gens := GeneratorsOfGroup(V);
  out := [];
  for dc in dcs do
    if ForAll(gens, g -> g^dc[1] in W) then
      E := V^dc[1];
      Add(out,[E,dc[1]]);
    fi;
  od;
  AssertProof(ForAll(Combinations(out,2), pair ->
    not IsConjugate(W,pair[1][1],pair[2][1])),
    "direct double-coset method returned duplicate W-orbits");
  return out;
end;

CheckContainedConjugatesRegression := function()
  local S,H,F,cc;
  S := SymmetricGroup(10);
  H := Group([ (3,4), (3,4,5,6,7,8,9,10), (1,2) ]);
  F := Group([ (1,7)(2,8)(5,6), (1,8)(2,7)(3,9)(5,6) ]);
  cc := ContainedConjugates(S,H,F);
  AssertProof(Length(cc)=2 and ForAll(Combinations(cc,2), pair ->
    not IsConjugate(H,pair[1][1],pair[2][1])),
    "ContainedConjugates regression case 1 failed");

  S := SymmetricGroup(12);
  H := ClosureGroup(Group([ (1,3), (2,6)(5,7), (2,5)(6,7) ]),
                    SymmetricGroup([8..12]));
  F := ClosureGroup(Group([ (1,6)(2,7) ]),SymmetricGroup([8..12]));
  cc := ContainedConjugates(S,H,F);
  AssertProof(Length(cc)=3 and ForAll(Combinations(cc,2), pair ->
    not IsConjugate(H,pair[1][1],pair[2][1])),
    "ContainedConjugates regression case 2 failed");
  Print("REGRESSION|ContainedConjugates|PASS|cases=2\n");
end;

CheckProofEnvironment();
