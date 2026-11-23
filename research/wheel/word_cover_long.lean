module
public import word_cover_split

@[expose] public section
namespace Ruliology.CellularAutomata.WordCover
open PureThreeExit
set_option maxRecDepth 100000
set_option maxHeartbeats 0
set_option Elab.async false

private def grid10_2 : Grid := wordCheckpoint 31 0x10842108 2
private theorem layer10_2 : layers (word 31 0x10842108) true 1 = grid10_2 := by
  decide +kernel

private def grid10_3 : Grid := wordCheckpoint 31 0x10842108 3
private theorem layer10_3 : layers (word 31 0x10842108) true 2 = grid10_3 := by
  rw [layers, layer10_2]
  decide +kernel

private def grid10_4 : Grid := wordCheckpoint 31 0x10842108 4
private theorem layer10_4 : layers (word 31 0x10842108) true 3 = grid10_4 := by
  rw [layers, layer10_3]
  decide +kernel

private def grid10_5 : Grid := wordCheckpoint 31 0x10842108 5
private theorem layer10_5 : layers (word 31 0x10842108) true 4 = grid10_5 := by
  rw [layers, layer10_4]
  decide +kernel

private def grid10_6 : Grid := wordCheckpoint 31 0x10842108 6
private theorem layer10_6 : layers (word 31 0x10842108) true 5 = grid10_6 := by
  rw [layers, layer10_5]
  decide +kernel

private def grid10_7 : Grid := wordCheckpoint 31 0x10842108 7
private theorem layer10_7 : layers (word 31 0x10842108) true 6 = grid10_7 := by
  rw [layers, layer10_6]
  decide +kernel

private def grid10_8 : Grid := wordCheckpoint 31 0x10842108 8
private theorem layer10_8 : layers (word 31 0x10842108) true 7 = grid10_8 := by
  rw [layers, layer10_7]
  decide +kernel

private def grid10_9 : Grid := wordCheckpoint 31 0x10842108 9
private theorem layer10_9 : layers (word 31 0x10842108) true 8 = grid10_9 := by
  rw [layers, layer10_8]
  decide +kernel

private def grid10_10 : Grid := wordCheckpoint 31 0x10842108 10
private theorem layer10_10 : layers (word 31 0x10842108) true 9 = grid10_10 := by
  rw [layers, layer10_9]
  decide +kernel

private def grid10_11 : Grid := wordCheckpoint 31 0x10842108 11
private theorem layer10_11 : layers (word 31 0x10842108) true 10 = grid10_11 := by
  rw [layers, layer10_10]
  decide +kernel

private def grid10_12 : Grid := wordCheckpoint 31 0x10842108 12
private theorem layer10_12 : layers (word 31 0x10842108) true 11 = grid10_12 := by
  rw [layers, layer10_11]
  decide +kernel

private def grid10_13 : Grid := wordCheckpoint 31 0x10842108 13
private theorem layer10_13 : layers (word 31 0x10842108) true 12 = grid10_13 := by
  rw [layers, layer10_12]
  decide +kernel

private def grid10_14 : Grid := wordCheckpoint 31 0x10842108 14
private theorem layer10_14 : layers (word 31 0x10842108) true 13 = grid10_14 := by
  rw [layers, layer10_13]
  decide +kernel

private def grid10_15 : Grid := wordCheckpoint 31 0x10842108 15
private theorem layer10_15 : layers (word 31 0x10842108) true 14 = grid10_15 := by
  rw [layers, layer10_14]
  decide +kernel

private def cand10 : Grid := wordStage 31 0x10842108 16 0
private def front10 : Grid := wordStage 31 0x10842108 16 1
private theorem lift10 : lift 15 (admit true (word 31 0x10842108).length 16) 0 grid10_15 = cand10 := by
  rw [fast_admit]
  decide +kernel
private theorem right10a : right 16 (cand10.take 15) = front10.take 15 := by decide +kernel
private theorem right10b : forward 16 ((front10.take 15).getLastD []) (cand10.drop 15) = front10.drop 15 := by decide +kernel
private theorem right10 : right 16 cand10 = front10 := right_split _ _ _ _ (by decide +kernel) right10a right10b

private def grid10_16 : Grid := wordCheckpoint 31 0x10842108 16
private theorem layer10_16 : layers (word 31 0x10842108) true 15 = grid10_16 := by
  rw [layers, layer10_15, lift10, right10]
  decide +kernel

private def grid10_17 : Grid := wordCheckpoint 31 0x10842108 17
private theorem layer10_17 : layers (word 31 0x10842108) true 16 = grid10_17 := by
  rw [layers, layer10_16]
  decide +kernel

private def grid10_18 : Grid := wordCheckpoint 31 0x10842108 18
private theorem layer10_18 : layers (word 31 0x10842108) true 17 = grid10_18 := by
  rw [layers, layer10_17]
  decide +kernel

private def grid10_19 : Grid := wordCheckpoint 31 0x10842108 19
private theorem layer10_19 : layers (word 31 0x10842108) true 18 = grid10_19 := by
  rw [layers, layer10_18]
  decide +kernel

private def grid10_20 : Grid := wordCheckpoint 31 0x10842108 20
private theorem layer10_20 : layers (word 31 0x10842108) true 19 = grid10_20 := by
  rw [layers, layer10_19]
  decide +kernel

private def grid10_21 : Grid := wordCheckpoint 31 0x10842108 21
private theorem layer10_21 : layers (word 31 0x10842108) true 20 = grid10_21 := by
  rw [layers, layer10_20]
  decide +kernel

private def grid10_22 : Grid := wordCheckpoint 31 0x10842108 22
private theorem layer10_22 : layers (word 31 0x10842108) true 21 = grid10_22 := by
  rw [layers, layer10_21]
  decide +kernel

theorem cut10 : (layers (word 31 0x10842108) true 22).head? = some [] := by
  rw [layers, layer10_22]
  decide +kernel

private def grid11_2 : Grid := wordCheckpoint 33 0x21084842 2
private theorem layer11_2 : layers (word 33 0x21084842) true 1 = grid11_2 := by
  decide +kernel

private def grid11_3 : Grid := wordCheckpoint 33 0x21084842 3
private theorem layer11_3 : layers (word 33 0x21084842) true 2 = grid11_3 := by
  rw [layers, layer11_2]
  decide +kernel

private def grid11_4 : Grid := wordCheckpoint 33 0x21084842 4
private theorem layer11_4 : layers (word 33 0x21084842) true 3 = grid11_4 := by
  rw [layers, layer11_3]
  decide +kernel

private def grid11_5 : Grid := wordCheckpoint 33 0x21084842 5
private theorem layer11_5 : layers (word 33 0x21084842) true 4 = grid11_5 := by
  rw [layers, layer11_4]
  decide +kernel

private def grid11_6 : Grid := wordCheckpoint 33 0x21084842 6
private theorem layer11_6 : layers (word 33 0x21084842) true 5 = grid11_6 := by
  rw [layers, layer11_5]
  decide +kernel

private def grid11_7 : Grid := wordCheckpoint 33 0x21084842 7
private theorem layer11_7 : layers (word 33 0x21084842) true 6 = grid11_7 := by
  rw [layers, layer11_6]
  decide +kernel

private def grid11_8 : Grid := wordCheckpoint 33 0x21084842 8
private theorem layer11_8 : layers (word 33 0x21084842) true 7 = grid11_8 := by
  rw [layers, layer11_7]
  decide +kernel

private def grid11_9 : Grid := wordCheckpoint 33 0x21084842 9
private theorem layer11_9 : layers (word 33 0x21084842) true 8 = grid11_9 := by
  rw [layers, layer11_8]
  decide +kernel

private def grid11_10 : Grid := wordCheckpoint 33 0x21084842 10
private theorem layer11_10 : layers (word 33 0x21084842) true 9 = grid11_10 := by
  rw [layers, layer11_9]
  decide +kernel

private def grid11_11 : Grid := wordCheckpoint 33 0x21084842 11
private theorem layer11_11 : layers (word 33 0x21084842) true 10 = grid11_11 := by
  rw [layers, layer11_10]
  decide +kernel

private def grid11_12 : Grid := wordCheckpoint 33 0x21084842 12
private theorem layer11_12 : layers (word 33 0x21084842) true 11 = grid11_12 := by
  rw [layers, layer11_11]
  decide +kernel

private def grid11_13 : Grid := wordCheckpoint 33 0x21084842 13
private theorem layer11_13 : layers (word 33 0x21084842) true 12 = grid11_13 := by
  rw [layers, layer11_12]
  decide +kernel

private def grid11_14 : Grid := wordCheckpoint 33 0x21084842 14
private theorem layer11_14 : layers (word 33 0x21084842) true 13 = grid11_14 := by
  rw [layers, layer11_13]
  decide +kernel

private def grid11_15 : Grid := wordCheckpoint 33 0x21084842 15
private theorem layer11_15 : layers (word 33 0x21084842) true 14 = grid11_15 := by
  rw [layers, layer11_14]
  decide +kernel

private def grid11_16 : Grid := wordCheckpoint 33 0x21084842 16
private theorem layer11_16 : layers (word 33 0x21084842) true 15 = grid11_16 := by
  rw [layers, layer11_15, fast_admit]
  decide +kernel

private def grid11_17 : Grid := wordCheckpoint 33 0x21084842 17
private theorem layer11_17 : layers (word 33 0x21084842) true 16 = grid11_17 := by
  rw [layers, layer11_16]
  decide +kernel

private def grid11_18 : Grid := wordCheckpoint 33 0x21084842 18
private theorem layer11_18 : layers (word 33 0x21084842) true 17 = grid11_18 := by
  rw [layers, layer11_17]
  decide +kernel

private def grid11_19 : Grid := wordCheckpoint 33 0x21084842 19
private theorem layer11_19 : layers (word 33 0x21084842) true 18 = grid11_19 := by
  rw [layers, layer11_18]
  decide +kernel

private def grid11_20 : Grid := wordCheckpoint 33 0x21084842 20
private theorem layer11_20 : layers (word 33 0x21084842) true 19 = grid11_20 := by
  rw [layers, layer11_19]
  decide +kernel

private def grid11_21 : Grid := wordCheckpoint 33 0x21084842 21
private theorem layer11_21 : layers (word 33 0x21084842) true 20 = grid11_21 := by
  rw [layers, layer11_20]
  decide +kernel

private def grid11_22 : Grid := wordCheckpoint 33 0x21084842 22
private theorem layer11_22 : layers (word 33 0x21084842) true 21 = grid11_22 := by
  rw [layers, layer11_21]
  decide +kernel

theorem cut11 : (layers (word 33 0x21084842) true 22).head? = some [] := by
  rw [layers, layer11_22]
  decide +kernel

end Ruliology.CellularAutomata.WordCover
