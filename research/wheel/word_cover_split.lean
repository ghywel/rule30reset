module
public import word_cover_fast
@[expose] public section
namespace Ruliology.CellularAutomata.WordCover
open PureThreeExit

private theorem forward_append (w : Nat) (prev : List Nat) (xs ys : Grid) :
    forward w prev (xs++ys) = forward w prev xs ++ forward w ((forward w prev xs).getLastD prev) ys := by
  induction xs generalizing prev with
  | nil => rfl
  | cons x xs ih =>
    simp only [List.cons_append,forward,List.getLastD_cons]
    rw [ih]

/-- Rejoin two independently checked portions of a forward sweep. -/
theorem right_split (w pos : Nat) (candidates front : Grid)
    (nonempty : candidates.take pos ≠ [])
    (first : right w (candidates.take pos) = front.take pos)
    (second : forward w ((front.take pos).getLastD []) (candidates.drop pos) = front.drop pos) :
    right w candidates = front := by
  have append (a b : Grid) (ha : a ≠ []) :
      right w (a++b) = right w a ++ forward w ((right w a).getLastD []) b := by
    cases a with
    | nil => contradiction
    | cons x xs =>
      simp only [List.cons_append,right,List.getLastD_cons]
      rw [forward_append]
  calc
    right w candidates = right w (candidates.take pos ++ candidates.drop pos) := by rw [List.take_append_drop]
    _ = right w (candidates.take pos) ++
        forward w ((right w (candidates.take pos)).getLastD []) (candidates.drop pos) :=
      append _ _ nonempty
    _ = front := by rw [first,second,List.take_append_drop]
end Ruliology.CellularAutomata.WordCover
