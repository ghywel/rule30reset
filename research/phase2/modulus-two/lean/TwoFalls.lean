import TwoCerts
import TwoCover

/-! Generated: the substrip classification of the modulus-two assignments, widths 3 to 27,
from the uncertified lists of the any-period census, with the fifteen certificates of `TwoCerts`. -/
namespace PhaseFalls.Moduli
set_option maxRecDepth 100000
set_option maxHeartbeats 0

private def two3 : List (List Nat) := [[0, 0, 0], [0, 0, 1], [0, 1, 0], [0, 1, 1]]
private theorem cover3 : ruledOut 2 (pairs 2) two3 = [] := by rw [← ruledOutFast_eq]; decide +kernel
private theorem cls3 : ClassifiesAny 3 2 two3 :=
  classify_stepAny (w := 2) (by decide) (by decide) (pairs_classifyAny 2) (by simp) cover3

private def two4 : List (List Nat) := [[0, 0, 0, 0], [0, 0, 0, 1], [0, 0, 1, 0], [0, 1, 0, 0], [0, 1, 0, 1], [0, 1, 1, 1]]
private theorem cover4 : ruledOut 2 (two3) two4 = [[0, 0, 1, 1], [0, 1, 1, 0]] := by rw [← ruledOutFast_eq]; decide +kernel
private theorem cls4 : ClassifiesAny 4 2 two4 :=
  classify_stepAny (w := 3) (by decide) (by decide) cls3 (by intro l hl; simp only [List.mem_cons, List.not_mem_nil, or_false] at hl; rcases hl with rfl | rfl <;> first | exact good_0011 | exact good_0110) cover4

private def two5 : List (List Nat) := [[0, 0, 0, 0, 0], [0, 0, 0, 0, 1], [0, 0, 0, 1, 0], [0, 0, 1, 0, 0], [0, 0, 1, 0, 1], [0, 1, 0, 0, 0], [0, 1, 1, 1, 0], [0, 1, 1, 1, 1]]
private theorem cover5 : ruledOut 2 (two4) two5 = [[0, 1, 0, 1, 0], [0, 1, 0, 1, 1]] := by rw [← ruledOutFast_eq]; decide +kernel
private theorem cls5 : ClassifiesAny 5 2 two5 :=
  classify_stepAny (w := 4) (by decide) (by decide) cls4 (by intro l hl; simp only [List.mem_cons, List.not_mem_nil, or_false] at hl; rcases hl with rfl | rfl <;> first | exact good_01010 | exact good_01011) cover5

private def two6 : List (List Nat) := [[0, 0, 0, 0, 0, 0], [0, 0, 0, 0, 0, 1], [0, 0, 0, 0, 1, 0], [0, 0, 0, 1, 0, 0], [0, 0, 0, 1, 0, 1], [0, 0, 1, 0, 0, 0], [0, 1, 0, 0, 0, 0], [0, 1, 0, 0, 0, 1], [0, 1, 1, 1, 1, 0], [0, 1, 1, 1, 1, 1]]
private theorem cover6 : ruledOut 2 (two5) two6 = [[0, 1, 1, 1, 0, 1]] := by rw [← ruledOutFast_eq]; decide +kernel
private theorem cls6 : ClassifiesAny 6 2 two6 :=
  classify_stepAny (w := 5) (by decide) (by decide) cls5 (by intro l hl; simp only [List.mem_cons, List.not_mem_nil, or_false] at hl; rcases hl with rfl <;> first | exact good_011101) cover6

private def two7 : List (List Nat) := [[0, 0, 0, 0, 0, 0, 0], [0, 0, 0, 0, 0, 0, 1], [0, 0, 0, 0, 0, 1, 0], [0, 0, 0, 0, 1, 0, 0], [0, 0, 0, 0, 1, 0, 1], [0, 0, 0, 1, 0, 0, 0], [0, 0, 1, 0, 0, 0, 0], [0, 0, 1, 0, 0, 0, 1], [0, 1, 0, 0, 0, 0, 0], [0, 1, 0, 0, 0, 0, 1], [0, 1, 1, 1, 1, 1, 0], [0, 1, 1, 1, 1, 1, 1]]
private theorem cover7 : ruledOut 2 (two6) two7 = [[0, 1, 1, 1, 1, 0, 1]] := by rw [← ruledOutFast_eq]; decide +kernel
private theorem cls7 : ClassifiesAny 7 2 two7 :=
  classify_stepAny (w := 6) (by decide) (by decide) cls6 (by intro l hl; simp only [List.mem_cons, List.not_mem_nil, or_false] at hl; rcases hl with rfl <;> first | exact good_0111101) cover7

private def two8 : List (List Nat) := [[0, 0, 0, 0, 0, 0, 0, 0], [0, 0, 0, 0, 0, 0, 0, 1], [0, 0, 0, 0, 0, 0, 1, 0], [0, 0, 0, 0, 0, 1, 0, 0], [0, 0, 0, 0, 0, 1, 0, 1], [0, 0, 0, 0, 1, 0, 0, 0], [0, 0, 0, 1, 0, 0, 0, 0], [0, 0, 0, 1, 0, 0, 0, 1], [0, 0, 1, 0, 0, 0, 0, 0], [0, 0, 1, 0, 0, 0, 0, 1], [0, 1, 0, 0, 0, 0, 0, 0], [0, 1, 0, 0, 0, 0, 0, 1], [0, 1, 1, 1, 1, 1, 1, 0], [0, 1, 1, 1, 1, 1, 1, 1]]
private theorem cover8 : ruledOut 2 (two7) two8 = [[0, 1, 1, 1, 1, 1, 0, 1]] := by rw [← ruledOutFast_eq]; decide +kernel
private theorem cls8 : ClassifiesAny 8 2 two8 :=
  classify_stepAny (w := 7) (by decide) (by decide) cls7 (by intro l hl; simp only [List.mem_cons, List.not_mem_nil, or_false] at hl; rcases hl with rfl <;> first | exact good_01111101) cover8

private def two9 : List (List Nat) := [[0, 0, 0, 0, 0, 0, 0, 0, 0], [0, 0, 0, 0, 0, 0, 0, 0, 1], [0, 0, 0, 0, 0, 0, 0, 1, 0], [0, 0, 0, 0, 0, 0, 1, 0, 0], [0, 0, 0, 0, 0, 0, 1, 0, 1], [0, 0, 0, 0, 0, 1, 0, 0, 0], [0, 0, 0, 0, 1, 0, 0, 0, 0], [0, 0, 0, 0, 1, 0, 0, 0, 1], [0, 0, 0, 1, 0, 0, 0, 0, 0], [0, 0, 0, 1, 0, 0, 0, 0, 1], [0, 0, 1, 0, 0, 0, 0, 0, 0], [0, 0, 1, 0, 0, 0, 0, 0, 1], [0, 1, 0, 0, 0, 0, 0, 0, 0], [0, 1, 0, 0, 0, 0, 0, 0, 1], [0, 1, 1, 1, 1, 1, 1, 1, 0], [0, 1, 1, 1, 1, 1, 1, 1, 1]]
private theorem cover9 : ruledOut 2 (two8) two9 = [[0, 1, 1, 1, 1, 1, 1, 0, 1]] := by rw [← ruledOutFast_eq]; decide +kernel
private theorem cls9 : ClassifiesAny 9 2 two9 :=
  classify_stepAny (w := 8) (by decide) (by decide) cls8 (by intro l hl; simp only [List.mem_cons, List.not_mem_nil, or_false] at hl; rcases hl with rfl <;> first | exact good_011111101) cover9

private def two10 : List (List Nat) := [[0, 0, 0, 0, 0, 0, 0, 0, 0, 0], [0, 0, 0, 0, 0, 0, 0, 0, 0, 1], [0, 0, 0, 0, 0, 0, 0, 1, 0, 0], [0, 0, 0, 0, 0, 0, 0, 1, 0, 1], [0, 0, 0, 0, 0, 0, 1, 0, 0, 0], [0, 0, 0, 0, 0, 1, 0, 0, 0, 0], [0, 0, 0, 0, 0, 1, 0, 0, 0, 1], [0, 0, 0, 0, 1, 0, 0, 0, 0, 0], [0, 0, 0, 0, 1, 0, 0, 0, 0, 1], [0, 0, 0, 1, 0, 0, 0, 0, 0, 0], [0, 0, 0, 1, 0, 0, 0, 0, 0, 1], [0, 0, 1, 0, 0, 0, 0, 0, 0, 0], [0, 0, 1, 0, 0, 0, 0, 0, 0, 1], [0, 1, 0, 0, 0, 0, 0, 0, 0, 0], [0, 1, 0, 0, 0, 0, 0, 0, 0, 1], [0, 1, 1, 1, 1, 1, 1, 1, 0, 1], [0, 1, 1, 1, 1, 1, 1, 1, 1, 0], [0, 1, 1, 1, 1, 1, 1, 1, 1, 1]]
private theorem cover10 : ruledOut 2 (two9) two10 = [[0, 0, 0, 0, 0, 0, 0, 0, 1, 0]] := by rw [← ruledOutFast_eq]; decide +kernel
private theorem cls10 : ClassifiesAny 10 2 two10 :=
  classify_stepAny (w := 9) (by decide) (by decide) cls9 (by intro l hl; simp only [List.mem_cons, List.not_mem_nil, or_false] at hl; rcases hl with rfl <;> first | exact good_0000000010) cover10

private def two11 : List (List Nat) := [[0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0], [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1], [0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0], [0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0], [0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 1], [0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0], [0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 1], [0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0], [0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 1], [0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0], [0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 1], [0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0], [0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 1], [0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0], [0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 1], [0, 1, 0, 0, 0, 0, 0, 0, 0, 1, 0], [0, 1, 1, 1, 1, 1, 1, 1, 0, 1, 0], [0, 1, 1, 1, 1, 1, 1, 1, 0, 1, 1], [0, 1, 1, 1, 1, 1, 1, 1, 1, 1, 0], [0, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1]]
private theorem cover11 : ruledOut 2 (two10) two11 = [] := by rw [← ruledOutFast_eq]; decide +kernel
private theorem cls11 : ClassifiesAny 11 2 two11 :=
  classify_stepAny (w := 10) (by decide) (by decide) cls10 (by simp) cover11

private def two12 : List (List Nat) := [[0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1], [0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0], [0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 1], [0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0], [0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 1], [0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0], [0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 1], [0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0], [0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 1], [0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0], [0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 1], [0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0], [0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 1], [0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 1, 0], [0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0], [0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1], [0, 1, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0], [0, 1, 0, 0, 0, 0, 0, 0, 0, 1, 0, 1], [0, 1, 1, 1, 1, 1, 1, 1, 0, 1, 1, 1], [0, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 0], [0, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1]]
private theorem cover12 : ruledOut 2 (two11) two12 = [[0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]] := by rw [← ruledOutFast_eq]; decide +kernel
private theorem cls12 : ClassifiesAny 12 2 two12 :=
  classify_stepAny (w := 11) (by decide) (by decide) cls11 (by intro l hl; simp only [List.mem_cons, List.not_mem_nil, or_false] at hl; rcases hl with rfl <;> first | exact good_000000000000) cover12

private def two13 : List (List Nat) := [[0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0], [0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 1], [0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0], [0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 1], [0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0], [0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 1], [0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0], [0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 1], [0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0], [0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 1], [0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 1, 0], [0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0], [0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1], [0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0], [0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 1, 0, 1], [0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0], [0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1], [0, 1, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0], [0, 1, 1, 1, 1, 1, 1, 1, 0, 1, 1, 1, 0], [0, 1, 1, 1, 1, 1, 1, 1, 0, 1, 1, 1, 1], [0, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 0]]
private theorem cover13 : ruledOut 2 (two12) two13 = [] := by rw [← ruledOutFast_eq]; decide +kernel
private theorem cls13 : ClassifiesAny 13 2 two13 :=
  classify_stepAny (w := 12) (by decide) (by decide) cls12 (by simp) cover13

private def two14 : List (List Nat) := [[0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0], [0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 1], [0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0], [0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 1], [0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0], [0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 1], [0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0], [0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 1], [0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 1, 0], [0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0], [0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1], [0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0], [0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 1, 0, 1], [0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0], [0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0], [0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1], [0, 1, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0], [0, 1, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 1], [0, 1, 1, 1, 1, 1, 1, 1, 0, 1, 1, 1, 1, 0], [0, 1, 1, 1, 1, 1, 1, 1, 0, 1, 1, 1, 1, 1]]
private theorem cover14 : ruledOut 2 (two13) two14 = [[0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1]] := by rw [← ruledOutFast_eq]; decide +kernel
private theorem cls14 : ClassifiesAny 14 2 two14 :=
  classify_stepAny (w := 13) (by decide) (by decide) cls13 (by intro l hl; simp only [List.mem_cons, List.not_mem_nil, or_false] at hl; rcases hl with rfl <;> first | exact good_00100000000001) cover14

private def two15 : List (List Nat) := [[0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0], [0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0], [0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 1], [0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0], [0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 1], [0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 1, 0], [0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0], [0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1], [0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0], [0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 1, 0, 1], [0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0], [0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0], [0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1], [0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0], [0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 1], [0, 1, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0], [0, 1, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 1], [0, 1, 1, 1, 1, 1, 1, 1, 0, 1, 1, 1, 1, 1, 0], [0, 1, 1, 1, 1, 1, 1, 1, 0, 1, 1, 1, 1, 1, 1]]
private theorem cover15 : ruledOut 2 (two14) two15 = [[0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 1]] := by rw [← ruledOutFast_eq]; decide +kernel
private theorem cls15 : ClassifiesAny 15 2 two15 :=
  classify_stepAny (w := 14) (by decide) (by decide) cls14 (by intro l hl; simp only [List.mem_cons, List.not_mem_nil, or_false] at hl; rcases hl with rfl <;> first | exact good_000000010000001) cover15

private def two16 : List (List Nat) := [[0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0], [0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 1], [0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0], [0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 1], [0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 1, 0], [0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0], [0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1], [0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0], [0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 1, 0, 1], [0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0], [0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0], [0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1], [0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0], [0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 1], [0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0], [0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 1], [0, 1, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0], [0, 1, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 1], [0, 1, 1, 1, 1, 1, 1, 1, 0, 1, 1, 1, 1, 1, 1, 1]]
private theorem cover16 : ruledOut 2 (two15) two16 = [] := by rw [← ruledOutFast_eq]; decide +kernel
private theorem cls16 : ClassifiesAny 16 2 two16 :=
  classify_stepAny (w := 15) (by decide) (by decide) cls15 (by simp) cover16

private def two17 : List (List Nat) := [[0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0], [0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 1], [0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0], [0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1], [0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0], [0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 1, 0, 1], [0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0], [0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0], [0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1], [0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0], [0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 1], [0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0], [0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 1], [0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0], [0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 1], [0, 1, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0], [0, 1, 1, 1, 1, 1, 1, 1, 0, 1, 1, 1, 1, 1, 1, 1, 0], [0, 1, 1, 1, 1, 1, 1, 1, 0, 1, 1, 1, 1, 1, 1, 1, 1]]
private theorem cover17 : ruledOut 2 (two16) two17 = [[0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 1, 0]] := by rw [← ruledOutFast_eq]; decide +kernel
private theorem cls17 : ClassifiesAny 17 2 two17 :=
  classify_stepAny (w := 16) (by decide) (by decide) cls16 (by intro l hl; simp only [List.mem_cons, List.not_mem_nil, or_false] at hl; rcases hl with rfl <;> first | exact good_00000001000000010) cover17

private def two18 : List (List Nat) := [[0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0], [0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0], [0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0], [0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1], [0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0], [0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 1], [0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0], [0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 1], [0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0], [0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 1], [0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0], [0, 1, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0], [0, 1, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 1], [0, 1, 1, 1, 1, 1, 1, 1, 0, 1, 1, 1, 1, 1, 1, 1, 1, 0], [0, 1, 1, 1, 1, 1, 1, 1, 0, 1, 1, 1, 1, 1, 1, 1, 1, 1]]
private theorem cover18 : ruledOut 2 (two17) two18 = [[0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1]] := by rw [← ruledOutFast_eq]; decide +kernel
private theorem cls18 : ClassifiesAny 18 2 two18 :=
  classify_stepAny (w := 17) (by decide) (by decide) cls17 (by intro l hl; simp only [List.mem_cons, List.not_mem_nil, or_false] at hl; rcases hl with rfl <;> first | exact good_000000010000000001) cover18

private def two19 : List (List Nat) := [[0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0], [0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1], [0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0], [0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 1], [0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0], [0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 1], [0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0], [0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 1], [0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0], [0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0], [0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 1], [0, 1, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0], [0, 1, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 1], [0, 1, 1, 1, 1, 1, 1, 1, 0, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1]]
private theorem cover19 : ruledOut 2 (two18) two19 = [] := by rw [← ruledOutFast_eq]; decide +kernel
private theorem cls19 : ClassifiesAny 19 2 two19 :=
  classify_stepAny (w := 18) (by decide) (by decide) cls18 (by simp) cover19

private def two20 : List (List Nat) := [[0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0], [0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 1], [0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0], [0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 1], [0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0], [0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0], [0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 1], [0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0], [0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 1], [0, 1, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0], [0, 1, 1, 1, 1, 1, 1, 1, 0, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1]]
private theorem cover20 : ruledOut 2 (two19) two20 = [[0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1]] := by rw [← ruledOutFast_eq]; decide +kernel
private theorem cls20 : ClassifiesAny 20 2 two20 :=
  classify_stepAny (w := 19) (by decide) (by decide) cls19 (by intro l hl; simp only [List.mem_cons, List.not_mem_nil, or_false] at hl; rcases hl with rfl <;> first | exact good_00000001000000000001) cover20

private def two21 : List (List Nat) := [[0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0], [0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 1], [0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0], [0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0], [0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 1], [0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0], [0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 1], [0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0], [0, 1, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]]
private theorem cover21 : ruledOut 2 (two20) two21 = [] := by rw [← ruledOutFast_eq]; decide +kernel
private theorem cls21 : ClassifiesAny 21 2 two21 :=
  classify_stepAny (w := 20) (by decide) (by decide) cls20 (by simp) cover21

private def two22 : List (List Nat) := [[0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0], [0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0], [0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 1], [0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0], [0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 1], [0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0], [0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]]
private theorem cover22 : ruledOut 2 (two21) two22 = [] := by rw [← ruledOutFast_eq]; decide +kernel
private theorem cls22 : ClassifiesAny 22 2 two22 :=
  classify_stepAny (w := 21) (by decide) (by decide) cls21 (by simp) cover22

private def two23 : List (List Nat) := [[0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0], [0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 1], [0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0], [0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 1], [0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0], [0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]]
private theorem cover23 : ruledOut 2 (two22) two23 = [] := by rw [← ruledOutFast_eq]; decide +kernel
private theorem cls23 : ClassifiesAny 23 2 two23 :=
  classify_stepAny (w := 22) (by decide) (by decide) cls22 (by simp) cover23

private def two24 : List (List Nat) := [[0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0], [0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 1], [0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0], [0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]]
private theorem cover24 : ruledOut 2 (two23) two24 = [] := by rw [← ruledOutFast_eq]; decide +kernel
private theorem cls24 : ClassifiesAny 24 2 two24 :=
  classify_stepAny (w := 23) (by decide) (by decide) cls23 (by simp) cover24

private def two25 : List (List Nat) := [[0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0], [0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]]
private theorem cover25 : ruledOut 2 (two24) two25 = [] := by rw [← ruledOutFast_eq]; decide +kernel
private theorem cls25 : ClassifiesAny 25 2 two25 :=
  classify_stepAny (w := 24) (by decide) (by decide) cls24 (by simp) cover25

private def two26 : List (List Nat) := [[0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]]
private theorem cover26 : ruledOut 2 (two25) two26 = [] := by rw [← ruledOutFast_eq]; decide +kernel
private theorem cls26 : ClassifiesAny 26 2 two26 :=
  classify_stepAny (w := 25) (by decide) (by decide) cls25 (by simp) cover26

private def two27 : List (List Nat) := []
private theorem cover27 : ruledOut 2 (two26) two27 = [] := by rw [← ruledOutFast_eq]; decide +kernel
private theorem cls27 : ClassifiesAny 27 2 two27 :=
  classify_stepAny (w := 26) (by decide) (by decide) cls26 (by simp) cover27

/-- Every phase assignment of a 27-cell strip, falls on one parity per cell, forces a repeating adjacent pair. -/
theorem goodAny27 (a : Nat → Nat) (ha : ∀ j, j < 27 → a j < 2) : GoodAny 27 2 a :=
  of_emptyAny (by decide) cls27 ha

/-- **Modulus two.** Every 27 adjacent singleton Rule 30 columns contain a column whose black-to-white falls
start on even ticks and on odd ticks, each after every cutoff. -/
theorem two_parities_every_27 (i : Int) :
    ∃ (j : Fin 27) (r q : Fin 2), r ≠ q ∧ Cofinal (i+j.val) r ∧ Cofinal (i+j.val) q :=
  two_cofinal_from_goodAny (by decide) (by decide) i goodAny27

end PhaseFalls.Moduli
