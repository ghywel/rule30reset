module
public import word_cover_fast

@[expose] public section
namespace Ruliology.CellularAutomata.WordCover
open PureThreeExit
set_option maxRecDepth 100000
set_option maxHeartbeats 0
set_option Elab.async false

private def grid0_2 : Grid := wordCheckpoint 20 0x12121 2
private theorem layer0_2 : layers (word 20 0x12121) true 1 = grid0_2 := by
  decide +kernel

private def grid0_3 : Grid := wordCheckpoint 20 0x12121 3
private theorem layer0_3 : layers (word 20 0x12121) true 2 = grid0_3 := by
  rw [layers, layer0_2]
  decide +kernel

private def grid0_4 : Grid := wordCheckpoint 20 0x12121 4
private theorem layer0_4 : layers (word 20 0x12121) true 3 = grid0_4 := by
  rw [layers, layer0_3]
  decide +kernel

private def grid0_5 : Grid := wordCheckpoint 20 0x12121 5
private theorem layer0_5 : layers (word 20 0x12121) true 4 = grid0_5 := by
  rw [layers, layer0_4]
  decide +kernel

private def grid0_6 : Grid := wordCheckpoint 20 0x12121 6
private theorem layer0_6 : layers (word 20 0x12121) true 5 = grid0_6 := by
  rw [layers, layer0_5]
  decide +kernel

private def grid0_7 : Grid := wordCheckpoint 20 0x12121 7
private theorem layer0_7 : layers (word 20 0x12121) true 6 = grid0_7 := by
  rw [layers, layer0_6]
  decide +kernel

private def grid0_8 : Grid := wordCheckpoint 20 0x12121 8
private theorem layer0_8 : layers (word 20 0x12121) true 7 = grid0_8 := by
  rw [layers, layer0_7]
  decide +kernel

private def grid0_9 : Grid := wordCheckpoint 20 0x12121 9
private theorem layer0_9 : layers (word 20 0x12121) true 8 = grid0_9 := by
  rw [layers, layer0_8]
  decide +kernel

private def grid0_10 : Grid := wordCheckpoint 20 0x12121 10
private theorem layer0_10 : layers (word 20 0x12121) true 9 = grid0_10 := by
  rw [layers, layer0_9]
  decide +kernel

private def grid0_11 : Grid := wordCheckpoint 20 0x12121 11
private theorem layer0_11 : layers (word 20 0x12121) true 10 = grid0_11 := by
  rw [layers, layer0_10]
  decide +kernel

private def grid0_12 : Grid := wordCheckpoint 20 0x12121 12
private theorem layer0_12 : layers (word 20 0x12121) true 11 = grid0_12 := by
  rw [layers, layer0_11]
  decide +kernel

private def grid0_13 : Grid := wordCheckpoint 20 0x12121 13
private theorem layer0_13 : layers (word 20 0x12121) true 12 = grid0_13 := by
  rw [layers, layer0_12]
  decide +kernel

private def grid0_14 : Grid := wordCheckpoint 20 0x12121 14
private theorem layer0_14 : layers (word 20 0x12121) true 13 = grid0_14 := by
  rw [layers, layer0_13]
  decide +kernel

private def grid0_15 : Grid := wordCheckpoint 20 0x12121 15
private theorem layer0_15 : layers (word 20 0x12121) true 14 = grid0_15 := by
  rw [layers, layer0_14]
  decide +kernel

private def grid0_16 : Grid := wordCheckpoint 20 0x12121 16
private theorem layer0_16 : layers (word 20 0x12121) true 15 = grid0_16 := by
  rw [layers, layer0_15, fast_admit]
  decide +kernel

private def grid0_17 : Grid := wordCheckpoint 20 0x12121 17
private theorem layer0_17 : layers (word 20 0x12121) true 16 = grid0_17 := by
  rw [layers, layer0_16]
  decide +kernel

theorem cut0 : (layers (word 20 0x12121) true 17).head? = some [] := by
  rw [layers, layer0_17]
  decide +kernel

private def grid1_2 : Grid := wordCheckpoint 23 0x484842 2
private theorem layer1_2 : layers (word 23 0x484842) true 1 = grid1_2 := by
  decide +kernel

private def grid1_3 : Grid := wordCheckpoint 23 0x484842 3
private theorem layer1_3 : layers (word 23 0x484842) true 2 = grid1_3 := by
  rw [layers, layer1_2]
  decide +kernel

private def grid1_4 : Grid := wordCheckpoint 23 0x484842 4
private theorem layer1_4 : layers (word 23 0x484842) true 3 = grid1_4 := by
  rw [layers, layer1_3]
  decide +kernel

private def grid1_5 : Grid := wordCheckpoint 23 0x484842 5
private theorem layer1_5 : layers (word 23 0x484842) true 4 = grid1_5 := by
  rw [layers, layer1_4]
  decide +kernel

private def grid1_6 : Grid := wordCheckpoint 23 0x484842 6
private theorem layer1_6 : layers (word 23 0x484842) true 5 = grid1_6 := by
  rw [layers, layer1_5]
  decide +kernel

private def grid1_7 : Grid := wordCheckpoint 23 0x484842 7
private theorem layer1_7 : layers (word 23 0x484842) true 6 = grid1_7 := by
  rw [layers, layer1_6]
  decide +kernel

private def grid1_8 : Grid := wordCheckpoint 23 0x484842 8
private theorem layer1_8 : layers (word 23 0x484842) true 7 = grid1_8 := by
  rw [layers, layer1_7]
  decide +kernel

private def grid1_9 : Grid := wordCheckpoint 23 0x484842 9
private theorem layer1_9 : layers (word 23 0x484842) true 8 = grid1_9 := by
  rw [layers, layer1_8]
  decide +kernel

private def grid1_10 : Grid := wordCheckpoint 23 0x484842 10
private theorem layer1_10 : layers (word 23 0x484842) true 9 = grid1_10 := by
  rw [layers, layer1_9]
  decide +kernel

private def grid1_11 : Grid := wordCheckpoint 23 0x484842 11
private theorem layer1_11 : layers (word 23 0x484842) true 10 = grid1_11 := by
  rw [layers, layer1_10]
  decide +kernel

private def grid1_12 : Grid := wordCheckpoint 23 0x484842 12
private theorem layer1_12 : layers (word 23 0x484842) true 11 = grid1_12 := by
  rw [layers, layer1_11]
  decide +kernel

private def grid1_13 : Grid := wordCheckpoint 23 0x484842 13
private theorem layer1_13 : layers (word 23 0x484842) true 12 = grid1_13 := by
  rw [layers, layer1_12]
  decide +kernel

private def grid1_14 : Grid := wordCheckpoint 23 0x484842 14
private theorem layer1_14 : layers (word 23 0x484842) true 13 = grid1_14 := by
  rw [layers, layer1_13]
  decide +kernel

private def grid1_15 : Grid := wordCheckpoint 23 0x484842 15
private theorem layer1_15 : layers (word 23 0x484842) true 14 = grid1_15 := by
  rw [layers, layer1_14]
  decide +kernel

private def grid1_16 : Grid := wordCheckpoint 23 0x484842 16
private theorem layer1_16 : layers (word 23 0x484842) true 15 = grid1_16 := by
  rw [layers, layer1_15, fast_admit]
  decide +kernel

private def grid1_17 : Grid := wordCheckpoint 23 0x484842 17
private theorem layer1_17 : layers (word 23 0x484842) true 16 = grid1_17 := by
  rw [layers, layer1_16]
  decide +kernel

private def grid1_18 : Grid := wordCheckpoint 23 0x484842 18
private theorem layer1_18 : layers (word 23 0x484842) true 17 = grid1_18 := by
  rw [layers, layer1_17]
  decide +kernel

theorem cut1 : (layers (word 23 0x484842) true 18).head? = some [] := by
  rw [layers, layer1_18]
  decide +kernel

private def grid3_2 : Grid := wordCheckpoint 26 0x484242 2
private theorem layer3_2 : layers (word 26 0x484242) true 1 = grid3_2 := by
  decide +kernel

private def grid3_3 : Grid := wordCheckpoint 26 0x484242 3
private theorem layer3_3 : layers (word 26 0x484242) true 2 = grid3_3 := by
  rw [layers, layer3_2]
  decide +kernel

private def grid3_4 : Grid := wordCheckpoint 26 0x484242 4
private theorem layer3_4 : layers (word 26 0x484242) true 3 = grid3_4 := by
  rw [layers, layer3_3]
  decide +kernel

private def grid3_5 : Grid := wordCheckpoint 26 0x484242 5
private theorem layer3_5 : layers (word 26 0x484242) true 4 = grid3_5 := by
  rw [layers, layer3_4]
  decide +kernel

private def grid3_6 : Grid := wordCheckpoint 26 0x484242 6
private theorem layer3_6 : layers (word 26 0x484242) true 5 = grid3_6 := by
  rw [layers, layer3_5]
  decide +kernel

private def grid3_7 : Grid := wordCheckpoint 26 0x484242 7
private theorem layer3_7 : layers (word 26 0x484242) true 6 = grid3_7 := by
  rw [layers, layer3_6]
  decide +kernel

private def grid3_8 : Grid := wordCheckpoint 26 0x484242 8
private theorem layer3_8 : layers (word 26 0x484242) true 7 = grid3_8 := by
  rw [layers, layer3_7]
  decide +kernel

private def grid3_9 : Grid := wordCheckpoint 26 0x484242 9
private theorem layer3_9 : layers (word 26 0x484242) true 8 = grid3_9 := by
  rw [layers, layer3_8]
  decide +kernel

private def grid3_10 : Grid := wordCheckpoint 26 0x484242 10
private theorem layer3_10 : layers (word 26 0x484242) true 9 = grid3_10 := by
  rw [layers, layer3_9]
  decide +kernel

private def grid3_11 : Grid := wordCheckpoint 26 0x484242 11
private theorem layer3_11 : layers (word 26 0x484242) true 10 = grid3_11 := by
  rw [layers, layer3_10]
  decide +kernel

private def grid3_12 : Grid := wordCheckpoint 26 0x484242 12
private theorem layer3_12 : layers (word 26 0x484242) true 11 = grid3_12 := by
  rw [layers, layer3_11]
  decide +kernel

private def grid3_13 : Grid := wordCheckpoint 26 0x484242 13
private theorem layer3_13 : layers (word 26 0x484242) true 12 = grid3_13 := by
  rw [layers, layer3_12]
  decide +kernel

private def grid3_14 : Grid := wordCheckpoint 26 0x484242 14
private theorem layer3_14 : layers (word 26 0x484242) true 13 = grid3_14 := by
  rw [layers, layer3_13]
  decide +kernel

private def grid3_15 : Grid := wordCheckpoint 26 0x484242 15
private theorem layer3_15 : layers (word 26 0x484242) true 14 = grid3_15 := by
  rw [layers, layer3_14]
  decide +kernel

private def grid3_16 : Grid := wordCheckpoint 26 0x484242 16
private theorem layer3_16 : layers (word 26 0x484242) true 15 = grid3_16 := by
  rw [layers, layer3_15, fast_admit]
  decide +kernel

private def grid3_17 : Grid := wordCheckpoint 26 0x484242 17
private theorem layer3_17 : layers (word 26 0x484242) true 16 = grid3_17 := by
  rw [layers, layer3_16]
  decide +kernel

theorem cut3 : (layers (word 26 0x484242) true 17).head? = some [] := by
  rw [layers, layer3_17]
  decide +kernel

private def grid6_2 : Grid := wordCheckpoint 29 0x12108421 2
private theorem layer6_2 : layers (word 29 0x12108421) true 1 = grid6_2 := by
  decide +kernel

private def grid6_3 : Grid := wordCheckpoint 29 0x12108421 3
private theorem layer6_3 : layers (word 29 0x12108421) true 2 = grid6_3 := by
  rw [layers, layer6_2]
  decide +kernel

private def grid6_4 : Grid := wordCheckpoint 29 0x12108421 4
private theorem layer6_4 : layers (word 29 0x12108421) true 3 = grid6_4 := by
  rw [layers, layer6_3]
  decide +kernel

private def grid6_5 : Grid := wordCheckpoint 29 0x12108421 5
private theorem layer6_5 : layers (word 29 0x12108421) true 4 = grid6_5 := by
  rw [layers, layer6_4]
  decide +kernel

private def grid6_6 : Grid := wordCheckpoint 29 0x12108421 6
private theorem layer6_6 : layers (word 29 0x12108421) true 5 = grid6_6 := by
  rw [layers, layer6_5]
  decide +kernel

private def grid6_7 : Grid := wordCheckpoint 29 0x12108421 7
private theorem layer6_7 : layers (word 29 0x12108421) true 6 = grid6_7 := by
  rw [layers, layer6_6]
  decide +kernel

private def grid6_8 : Grid := wordCheckpoint 29 0x12108421 8
private theorem layer6_8 : layers (word 29 0x12108421) true 7 = grid6_8 := by
  rw [layers, layer6_7]
  decide +kernel

private def grid6_9 : Grid := wordCheckpoint 29 0x12108421 9
private theorem layer6_9 : layers (word 29 0x12108421) true 8 = grid6_9 := by
  rw [layers, layer6_8]
  decide +kernel

private def grid6_10 : Grid := wordCheckpoint 29 0x12108421 10
private theorem layer6_10 : layers (word 29 0x12108421) true 9 = grid6_10 := by
  rw [layers, layer6_9]
  decide +kernel

private def grid6_11 : Grid := wordCheckpoint 29 0x12108421 11
private theorem layer6_11 : layers (word 29 0x12108421) true 10 = grid6_11 := by
  rw [layers, layer6_10]
  decide +kernel

private def grid6_12 : Grid := wordCheckpoint 29 0x12108421 12
private theorem layer6_12 : layers (word 29 0x12108421) true 11 = grid6_12 := by
  rw [layers, layer6_11]
  decide +kernel

private def grid6_13 : Grid := wordCheckpoint 29 0x12108421 13
private theorem layer6_13 : layers (word 29 0x12108421) true 12 = grid6_13 := by
  rw [layers, layer6_12]
  decide +kernel

private def grid6_14 : Grid := wordCheckpoint 29 0x12108421 14
private theorem layer6_14 : layers (word 29 0x12108421) true 13 = grid6_14 := by
  rw [layers, layer6_13]
  decide +kernel

private def grid6_15 : Grid := wordCheckpoint 29 0x12108421 15
private theorem layer6_15 : layers (word 29 0x12108421) true 14 = grid6_15 := by
  rw [layers, layer6_14]
  decide +kernel

private def grid6_16 : Grid := wordCheckpoint 29 0x12108421 16
private theorem layer6_16 : layers (word 29 0x12108421) true 15 = grid6_16 := by
  rw [layers, layer6_15, fast_admit]
  decide +kernel

private def grid6_17 : Grid := wordCheckpoint 29 0x12108421 17
private theorem layer6_17 : layers (word 29 0x12108421) true 16 = grid6_17 := by
  rw [layers, layer6_16]
  decide +kernel

private def grid6_18 : Grid := wordCheckpoint 29 0x12108421 18
private theorem layer6_18 : layers (word 29 0x12108421) true 17 = grid6_18 := by
  rw [layers, layer6_17]
  decide +kernel

private def grid6_19 : Grid := wordCheckpoint 29 0x12108421 19
private theorem layer6_19 : layers (word 29 0x12108421) true 18 = grid6_19 := by
  rw [layers, layer6_18]
  decide +kernel

private def grid6_20 : Grid := wordCheckpoint 29 0x12108421 20
private theorem layer6_20 : layers (word 29 0x12108421) true 19 = grid6_20 := by
  rw [layers, layer6_19]
  decide +kernel

private def grid6_21 : Grid := wordCheckpoint 29 0x12108421 21
private theorem layer6_21 : layers (word 29 0x12108421) true 20 = grid6_21 := by
  rw [layers, layer6_20]
  decide +kernel

private def grid6_22 : Grid := wordCheckpoint 29 0x12108421 22
private theorem layer6_22 : layers (word 29 0x12108421) true 21 = grid6_22 := by
  rw [layers, layer6_21]
  decide +kernel

theorem cut6 : (layers (word 29 0x12108421) true 22).head? = some [] := by
  rw [layers, layer6_22]
  decide +kernel

private def grid7_2 : Grid := wordCheckpoint 30 0x24210908 2
private theorem layer7_2 : layers (word 30 0x24210908) true 1 = grid7_2 := by
  decide +kernel

private def grid7_3 : Grid := wordCheckpoint 30 0x24210908 3
private theorem layer7_3 : layers (word 30 0x24210908) true 2 = grid7_3 := by
  rw [layers, layer7_2]
  decide +kernel

private def grid7_4 : Grid := wordCheckpoint 30 0x24210908 4
private theorem layer7_4 : layers (word 30 0x24210908) true 3 = grid7_4 := by
  rw [layers, layer7_3]
  decide +kernel

private def grid7_5 : Grid := wordCheckpoint 30 0x24210908 5
private theorem layer7_5 : layers (word 30 0x24210908) true 4 = grid7_5 := by
  rw [layers, layer7_4]
  decide +kernel

private def grid7_6 : Grid := wordCheckpoint 30 0x24210908 6
private theorem layer7_6 : layers (word 30 0x24210908) true 5 = grid7_6 := by
  rw [layers, layer7_5]
  decide +kernel

private def grid7_7 : Grid := wordCheckpoint 30 0x24210908 7
private theorem layer7_7 : layers (word 30 0x24210908) true 6 = grid7_7 := by
  rw [layers, layer7_6]
  decide +kernel

private def grid7_8 : Grid := wordCheckpoint 30 0x24210908 8
private theorem layer7_8 : layers (word 30 0x24210908) true 7 = grid7_8 := by
  rw [layers, layer7_7]
  decide +kernel

private def grid7_9 : Grid := wordCheckpoint 30 0x24210908 9
private theorem layer7_9 : layers (word 30 0x24210908) true 8 = grid7_9 := by
  rw [layers, layer7_8]
  decide +kernel

private def grid7_10 : Grid := wordCheckpoint 30 0x24210908 10
private theorem layer7_10 : layers (word 30 0x24210908) true 9 = grid7_10 := by
  rw [layers, layer7_9]
  decide +kernel

private def grid7_11 : Grid := wordCheckpoint 30 0x24210908 11
private theorem layer7_11 : layers (word 30 0x24210908) true 10 = grid7_11 := by
  rw [layers, layer7_10]
  decide +kernel

private def grid7_12 : Grid := wordCheckpoint 30 0x24210908 12
private theorem layer7_12 : layers (word 30 0x24210908) true 11 = grid7_12 := by
  rw [layers, layer7_11]
  decide +kernel

private def grid7_13 : Grid := wordCheckpoint 30 0x24210908 13
private theorem layer7_13 : layers (word 30 0x24210908) true 12 = grid7_13 := by
  rw [layers, layer7_12]
  decide +kernel

private def grid7_14 : Grid := wordCheckpoint 30 0x24210908 14
private theorem layer7_14 : layers (word 30 0x24210908) true 13 = grid7_14 := by
  rw [layers, layer7_13]
  decide +kernel

private def grid7_15 : Grid := wordCheckpoint 30 0x24210908 15
private theorem layer7_15 : layers (word 30 0x24210908) true 14 = grid7_15 := by
  rw [layers, layer7_14]
  decide +kernel

theorem cut7 : (layers (word 30 0x24210908) true 15).head? = some [] := by
  rw [layers, layer7_15, fast_admit]
  decide +kernel

private def grid9_2 : Grid := wordCheckpoint 30 0x24210909 2
private theorem layer9_2 : layers (word 30 0x24210909) true 1 = grid9_2 := by
  decide +kernel

private def grid9_3 : Grid := wordCheckpoint 30 0x24210909 3
private theorem layer9_3 : layers (word 30 0x24210909) true 2 = grid9_3 := by
  rw [layers, layer9_2]
  decide +kernel

private def grid9_4 : Grid := wordCheckpoint 30 0x24210909 4
private theorem layer9_4 : layers (word 30 0x24210909) true 3 = grid9_4 := by
  rw [layers, layer9_3]
  decide +kernel

private def grid9_5 : Grid := wordCheckpoint 30 0x24210909 5
private theorem layer9_5 : layers (word 30 0x24210909) true 4 = grid9_5 := by
  rw [layers, layer9_4]
  decide +kernel

private def grid9_6 : Grid := wordCheckpoint 30 0x24210909 6
private theorem layer9_6 : layers (word 30 0x24210909) true 5 = grid9_6 := by
  rw [layers, layer9_5]
  decide +kernel

private def grid9_7 : Grid := wordCheckpoint 30 0x24210909 7
private theorem layer9_7 : layers (word 30 0x24210909) true 6 = grid9_7 := by
  rw [layers, layer9_6]
  decide +kernel

private def grid9_8 : Grid := wordCheckpoint 30 0x24210909 8
private theorem layer9_8 : layers (word 30 0x24210909) true 7 = grid9_8 := by
  rw [layers, layer9_7]
  decide +kernel

private def grid9_9 : Grid := wordCheckpoint 30 0x24210909 9
private theorem layer9_9 : layers (word 30 0x24210909) true 8 = grid9_9 := by
  rw [layers, layer9_8]
  decide +kernel

private def grid9_10 : Grid := wordCheckpoint 30 0x24210909 10
private theorem layer9_10 : layers (word 30 0x24210909) true 9 = grid9_10 := by
  rw [layers, layer9_9]
  decide +kernel

private def grid9_11 : Grid := wordCheckpoint 30 0x24210909 11
private theorem layer9_11 : layers (word 30 0x24210909) true 10 = grid9_11 := by
  rw [layers, layer9_10]
  decide +kernel

private def grid9_12 : Grid := wordCheckpoint 30 0x24210909 12
private theorem layer9_12 : layers (word 30 0x24210909) true 11 = grid9_12 := by
  rw [layers, layer9_11]
  decide +kernel

private def grid9_13 : Grid := wordCheckpoint 30 0x24210909 13
private theorem layer9_13 : layers (word 30 0x24210909) true 12 = grid9_13 := by
  rw [layers, layer9_12]
  decide +kernel

private def grid9_14 : Grid := wordCheckpoint 30 0x24210909 14
private theorem layer9_14 : layers (word 30 0x24210909) true 13 = grid9_14 := by
  rw [layers, layer9_13]
  decide +kernel

private def grid9_15 : Grid := wordCheckpoint 30 0x24210909 15
private theorem layer9_15 : layers (word 30 0x24210909) true 14 = grid9_15 := by
  rw [layers, layer9_14]
  decide +kernel

theorem cut9 : (layers (word 30 0x24210909) true 15).head? = some [] := by
  rw [layers, layer9_15, fast_admit]
  decide +kernel

end Ruliology.CellularAutomata.WordCover
