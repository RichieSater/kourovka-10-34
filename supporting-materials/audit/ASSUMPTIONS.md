# External assumptions and assurance boundary

The verification boundary is **conditional**, not foundational.  The proof
package does not re-prove:

1. the classification of finite simple groups (CFSG);
2. the cited classifications of maximal subgroups and automorphisms of finite
   simple/almost simple groups;
3. the mathematical correctness of the pinned Atlas/CTblLib input data;
4. standard finite-group, BN-pair, and number-theoretic results explicitly
   cited in the source ledger; or
5. the correctness of the Lean and Rocq kernels, the pinned compiled MathComp
   library, compilers, GAP runtime, operating system, or hardware.

The package must make every use of those assumptions exact: each use is
pinned by the source maps, manifests, certificate logs, and formal coverage
files in this directory tree, and the verification suites fail closed on any
drift between the manuscript and that recorded evidence.

Formal evidence is also interface-sensitive. The strengthened Rocq/MathComp
theorem proves both the exact internal direct product, explicit
nonabelianness, and an isomorphism to the explicit external coordinate product
over the same positive finite factor index. Lean kernel-checks reindexing that
nonempty finite coordinate type to `Fin k` and constructs the base coordinate
consumed with that `MulEquiv` by the ambient-wreath theorem. The locked
`formal/FORMAL-INTERFACE.json` record and its fail-closed checker bind the
producer, reindex, and consumer signatures. This closes the named Lean and
Rocq endpoints recorded under `RED-COORD` without pretending that one proof
kernel verifies the other: both kernels, their pinned libraries, and the
mathematical identification across libraries remain declared trusted
components. The checker pins the enumerated correspondence rows and the
relevant MathComp `isogP`, `setXn`, and pointwise-product source statements;
it detects drift in those tokens but does not establish arbitrary semantic
equivalence between the two libraries.

Machine receipts below finite thresholds are redundant regression evidence for
uniform family theorems; the thresholds are not logical hypotheses of the main
theorem.  AI-model agreement is not treated as independent evidence.
