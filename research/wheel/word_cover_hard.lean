module
public import word_cover_fast

@[expose] public section
namespace Ruliology.CellularAutomata.WordCover
open PureThreeExit
set_option maxRecDepth 100000
set_option maxHeartbeats 0
set_option Elab.async false

private def grid13_2 : Grid := wordCheckpoint 38 0x212108424 2
private theorem layer13_2 : layers (word 38 0x212108424) true 1 = grid13_2 := by
  decide +kernel

private def grid13_3 : Grid := wordCheckpoint 38 0x212108424 3
private theorem layer13_3 : layers (word 38 0x212108424) true 2 = grid13_3 := by
  rw [layers, layer13_2]
  decide +kernel

private def grid13_4 : Grid := wordCheckpoint 38 0x212108424 4
private theorem layer13_4 : layers (word 38 0x212108424) true 3 = grid13_4 := by
  rw [layers, layer13_3]
  decide +kernel

private def grid13_5 : Grid := wordCheckpoint 38 0x212108424 5
private theorem layer13_5 : layers (word 38 0x212108424) true 4 = grid13_5 := by
  rw [layers, layer13_4]
  decide +kernel

private def grid13_6 : Grid := wordCheckpoint 38 0x212108424 6
private theorem layer13_6 : layers (word 38 0x212108424) true 5 = grid13_6 := by
  rw [layers, layer13_5]
  decide +kernel

private def grid13_7 : Grid := wordCheckpoint 38 0x212108424 7
private theorem layer13_7 : layers (word 38 0x212108424) true 6 = grid13_7 := by
  rw [layers, layer13_6]
  decide +kernel

private def grid13_8 : Grid := wordCheckpoint 38 0x212108424 8
private theorem layer13_8 : layers (word 38 0x212108424) true 7 = grid13_8 := by
  rw [layers, layer13_7]
  decide +kernel

private def grid13_9 : Grid := wordCheckpoint 38 0x212108424 9
private theorem layer13_9 : layers (word 38 0x212108424) true 8 = grid13_9 := by
  rw [layers, layer13_8]
  decide +kernel

private def grid13_10 : Grid := wordCheckpoint 38 0x212108424 10
private theorem layer13_10 : layers (word 38 0x212108424) true 9 = grid13_10 := by
  rw [layers, layer13_9]
  decide +kernel

private def grid13_11 : Grid := wordCheckpoint 38 0x212108424 11
private theorem layer13_11 : layers (word 38 0x212108424) true 10 = grid13_11 := by
  rw [layers, layer13_10]
  decide +kernel

private def grid13_12 : Grid := wordCheckpoint 38 0x212108424 12
private theorem layer13_12 : layers (word 38 0x212108424) true 11 = grid13_12 := by
  rw [layers, layer13_11]
  decide +kernel

private def grid13_13 : Grid := wordCheckpoint 38 0x212108424 13
private theorem layer13_13 : layers (word 38 0x212108424) true 12 = grid13_13 := by
  rw [layers, layer13_12]
  decide +kernel

private def grid13_14 : Grid := wordCheckpoint 38 0x212108424 14
private theorem layer13_14 : layers (word 38 0x212108424) true 13 = grid13_14 := by
  rw [layers, layer13_13]
  decide +kernel

private def grid13_15 : Grid := wordCheckpoint 38 0x212108424 15
private theorem layer13_15 : layers (word 38 0x212108424) true 14 = grid13_15 := by
  rw [layers, layer13_14]
  decide +kernel

private def grid13_16 : Grid := wordCheckpoint 38 0x212108424 16
private theorem layer13_16 : layers (word 38 0x212108424) true 15 = grid13_16 := by
  rw [layers, layer13_15, fast_admit]
  decide +kernel

private def grid13_17 : Grid := wordCheckpoint 38 0x212108424 17
private theorem layer13_17 : layers (word 38 0x212108424) true 16 = grid13_17 := by
  rw [layers, layer13_16]
  decide +kernel

private def grid13_18 : Grid := wordCheckpoint 38 0x212108424 18
private theorem layer13_18 : layers (word 38 0x212108424) true 17 = grid13_18 := by
  rw [layers, layer13_17]
  decide +kernel

private def grid13_19 : Grid := wordCheckpoint 38 0x212108424 19
private theorem layer13_19 : layers (word 38 0x212108424) true 18 = grid13_19 := by
  rw [layers, layer13_18]
  decide +kernel

private def grid13_20 : Grid := wordCheckpoint 38 0x212108424 20
private theorem layer13_20 : layers (word 38 0x212108424) true 19 = grid13_20 := by
  rw [layers, layer13_19]
  decide +kernel

private def grid13_21 : Grid := wordCheckpoint 38 0x212108424 21
private theorem layer13_21 : layers (word 38 0x212108424) true 20 = grid13_21 := by
  rw [layers, layer13_20]
  decide +kernel

private def grid13_22 : Grid := wordCheckpoint 38 0x212108424 22
private theorem layer13_22 : layers (word 38 0x212108424) true 21 = grid13_22 := by
  rw [layers, layer13_21]
  decide +kernel

private def grid13_23 : Grid := wordCheckpoint 38 0x212108424 23
private theorem layer13_23 : layers (word 38 0x212108424) true 22 = grid13_23 := by
  rw [layers, layer13_22]
  decide +kernel

private def grid13_24 : Grid := wordCheckpoint 38 0x212108424 24
private theorem layer13_24 : layers (word 38 0x212108424) true 23 = grid13_24 := by
  rw [layers, layer13_23]
  decide +kernel

private def grid13_25 : Grid := wordCheckpoint 38 0x212108424 25
private theorem layer13_25 : layers (word 38 0x212108424) true 24 = grid13_25 := by
  rw [layers, layer13_24]
  decide +kernel

private def grid13_26 : Grid := wordCheckpoint 38 0x212108424 26
private theorem layer13_26 : layers (word 38 0x212108424) true 25 = grid13_26 := by
  rw [layers, layer13_25]
  decide +kernel

private def grid13_27 : Grid := wordCheckpoint 38 0x212108424 27
private theorem layer13_27 : layers (word 38 0x212108424) true 26 = grid13_27 := by
  rw [layers, layer13_26]
  decide +kernel

private def grid13_28 : Grid := wordCheckpoint 38 0x212108424 28
private theorem layer13_28 : layers (word 38 0x212108424) true 27 = grid13_28 := by
  rw [layers, layer13_27]
  decide +kernel

private def grid13_29 : Grid := wordCheckpoint 38 0x212108424 29
private theorem layer13_29 : layers (word 38 0x212108424) true 28 = grid13_29 := by
  rw [layers, layer13_28]
  decide +kernel

private def grid13_30 : Grid := wordCheckpoint 38 0x212108424 30
private theorem layer13_30 : layers (word 38 0x212108424) true 29 = grid13_30 := by
  rw [layers, layer13_29]
  decide +kernel

private def grid13_31 : Grid := wordCheckpoint 38 0x212108424 31
private theorem layer13_31 : layers (word 38 0x212108424) true 30 = grid13_31 := by
  rw [layers, layer13_30]
  decide +kernel

theorem cut13 : (layers (word 38 0x212108424) true 31).head? = some [] := by
  rw [layers, layer13_31]
  decide +kernel

end Ruliology.CellularAutomata.WordCover
