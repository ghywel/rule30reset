module
public import word_cover_fast

@[expose] public section
namespace Ruliology.CellularAutomata.WordCover
open PureThreeExit
set_option maxRecDepth 100000
set_option maxHeartbeats 0
set_option Elab.async false

private def grid5_2 : Grid := wordCheckpoint 29 0x2108424 2
private theorem layer5_2 : layers (word 29 0x2108424) true 1 = grid5_2 := by
  decide +kernel

private def grid5_3 : Grid := wordCheckpoint 29 0x2108424 3
private theorem layer5_3 : layers (word 29 0x2108424) true 2 = grid5_3 := by
  rw [layers, layer5_2]
  decide +kernel

private def grid5_4 : Grid := wordCheckpoint 29 0x2108424 4
private theorem layer5_4 : layers (word 29 0x2108424) true 3 = grid5_4 := by
  rw [layers, layer5_3]
  decide +kernel

private def grid5_5 : Grid := wordCheckpoint 29 0x2108424 5
private theorem layer5_5 : layers (word 29 0x2108424) true 4 = grid5_5 := by
  rw [layers, layer5_4]
  decide +kernel

private def grid5_6 : Grid := wordCheckpoint 29 0x2108424 6
private theorem layer5_6 : layers (word 29 0x2108424) true 5 = grid5_6 := by
  rw [layers, layer5_5]
  decide +kernel

private def grid5_7 : Grid := wordCheckpoint 29 0x2108424 7
private theorem layer5_7 : layers (word 29 0x2108424) true 6 = grid5_7 := by
  rw [layers, layer5_6]
  decide +kernel

private def grid5_8 : Grid := wordCheckpoint 29 0x2108424 8
private theorem layer5_8 : layers (word 29 0x2108424) true 7 = grid5_8 := by
  rw [layers, layer5_7]
  decide +kernel

private def grid5_9 : Grid := wordCheckpoint 29 0x2108424 9
private theorem layer5_9 : layers (word 29 0x2108424) true 8 = grid5_9 := by
  rw [layers, layer5_8]
  decide +kernel

private def grid5_10 : Grid := wordCheckpoint 29 0x2108424 10
private theorem layer5_10 : layers (word 29 0x2108424) true 9 = grid5_10 := by
  rw [layers, layer5_9]
  decide +kernel

private def grid5_11 : Grid := wordCheckpoint 29 0x2108424 11
private theorem layer5_11 : layers (word 29 0x2108424) true 10 = grid5_11 := by
  rw [layers, layer5_10]
  decide +kernel

private def grid5_12 : Grid := wordCheckpoint 29 0x2108424 12
private theorem layer5_12 : layers (word 29 0x2108424) true 11 = grid5_12 := by
  rw [layers, layer5_11]
  decide +kernel

private def grid5_13 : Grid := wordCheckpoint 29 0x2108424 13
private theorem layer5_13 : layers (word 29 0x2108424) true 12 = grid5_13 := by
  rw [layers, layer5_12]
  decide +kernel

private def grid5_14 : Grid := wordCheckpoint 29 0x2108424 14
private theorem layer5_14 : layers (word 29 0x2108424) true 13 = grid5_14 := by
  rw [layers, layer5_13]
  decide +kernel

private def grid5_15 : Grid := wordCheckpoint 29 0x2108424 15
private theorem layer5_15 : layers (word 29 0x2108424) true 14 = grid5_15 := by
  rw [layers, layer5_14]
  decide +kernel

private def cand5 : Grid := wordStage 29 0x2108424 16 0
private def front5 : Grid := wordStage 29 0x2108424 16 1
private theorem lift5 : lift 15 (admit true (word 29 0x2108424).length 16) 0 grid5_15 = cand5 := by
  rw [fast_admit]
  decide +kernel
private theorem right5 : right 16 cand5 = front5 := by decide +kernel

private def grid5_16 : Grid := wordCheckpoint 29 0x2108424 16
private theorem layer5_16 : layers (word 29 0x2108424) true 15 = grid5_16 := by
  rw [layers, layer5_15, lift5, right5]
  decide +kernel

private def grid5_17 : Grid := wordCheckpoint 29 0x2108424 17
private theorem layer5_17 : layers (word 29 0x2108424) true 16 = grid5_17 := by
  rw [layers, layer5_16]
  decide +kernel

private def grid5_18 : Grid := wordCheckpoint 29 0x2108424 18
private theorem layer5_18 : layers (word 29 0x2108424) true 17 = grid5_18 := by
  rw [layers, layer5_17]
  decide +kernel

private def grid5_19 : Grid := wordCheckpoint 29 0x2108424 19
private theorem layer5_19 : layers (word 29 0x2108424) true 18 = grid5_19 := by
  rw [layers, layer5_18]
  decide +kernel

private def grid5_20 : Grid := wordCheckpoint 29 0x2108424 20
private theorem layer5_20 : layers (word 29 0x2108424) true 19 = grid5_20 := by
  rw [layers, layer5_19]
  decide +kernel

private def grid5_21 : Grid := wordCheckpoint 29 0x2108424 21
private theorem layer5_21 : layers (word 29 0x2108424) true 20 = grid5_21 := by
  rw [layers, layer5_20]
  decide +kernel

private def grid5_22 : Grid := wordCheckpoint 29 0x2108424 22
private theorem layer5_22 : layers (word 29 0x2108424) true 21 = grid5_22 := by
  rw [layers, layer5_21]
  decide +kernel

theorem cut5 : (layers (word 29 0x2108424) true 22).head? = some [] := by
  rw [layers, layer5_22]
  decide +kernel

end Ruliology.CellularAutomata.WordCover
