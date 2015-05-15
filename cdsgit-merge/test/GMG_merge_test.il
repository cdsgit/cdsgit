/*

loadi("/home/acook/git/lcbu-skill/scripts/git/merge/test/GMG_merge_test.il")

*/


procedure( GMG_merge_test()

GMreload()

cvidA = dbOpenCellViewByType("GMtest" "GMT_mergePin_A" "schematic")
cvidB = dbOpenCellViewByType("GMtest" "GMT_mergePin_B" "schematic")

;Enable CIW logs
;asdf = 'unbound
GMG_verbose = t

GMergeGui(?cvid_A cvidA ?cvid_B cvidB)

)
