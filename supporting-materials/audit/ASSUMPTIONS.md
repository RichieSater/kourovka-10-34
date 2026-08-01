# External assumptions and assurance boundary

The claimed confidence target is **conditional**, not foundational.  The proof
package does not re-prove:

1. the classification of finite simple groups (CFSG);
2. the cited classifications of maximal subgroups and automorphisms of finite
   simple/almost simple groups;
3. the mathematical correctness of the pinned Atlas/CTblLib input data;
4. standard finite-group, BN-pair, and number-theoretic results explicitly
   cited in the source ledger; or
5. the correctness of the Lean kernel, compiler, GAP runtime, operating system,
   or hardware.

The package must make every use of those assumptions exact.  A claim counts as
closed only when `audit/OBLIGATIONS.csv` gives it `FORMAL-PASS`, `CITED-PASS`,
`COMPUTED-PASS`, or `REDUNDANT`.  At present, unresolved rows are deliberately
retained, so the 99%-confidence gate must fail.

Machine receipts below finite thresholds are redundant regression evidence for
uniform family theorems; the thresholds are not logical hypotheses of the main
theorem.  AI-model agreement is not treated as independent evidence.
