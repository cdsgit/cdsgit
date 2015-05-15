/*

loadi("/home/acook/git/lcbu-skill/scripts/git/merge/test/GMG_merge_test.il")

*/


procedure( GMG_net_test()

GMreload()

;cvidA = dbOpenCellViewByType("GMtest" "GMT_net_A" "schematic")
;cvidB = dbOpenCellViewByType("GMtest" "GMT_net_B" "schematic")
;cvidA = dbOpenCellViewByType("GMtest" "GMT_netsimple_A" "schematic")
;cvidB = dbOpenCellViewByType("GMtest" "GMT_netsimple_B" "schematic")
;cvidA = dbOpenCellViewByType("GMtest" "GMT_netmerge_A" "schematic")
;cvidB = dbOpenCellViewByType("GMtest" "GMT_netmerge_B" "schematic")
cvidA = dbOpenCellViewByType("GMtest" "GMT_netpartial_A" "schematic")
cvidB = dbOpenCellViewByType("GMtest" "GMT_netpartial_B" "schematic")

;Enable CIW logs
;asdf = 'unbound
GMG_verbose = t

GMergeGui(?cvid_A cvidA ?cvid_B cvidB)

)
