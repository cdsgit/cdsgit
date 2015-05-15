/*

load("/home/acook/git/lcbu-skill/scripts/git/merge/test/GMG_test.il")

*/


procedure( GMG_test()

cvidA = dbOpenCellViewByType("GMtest" "GMT_pin_cellA" "schematic")
cvidB = dbOpenCellViewByType("GMtest" "GMT_pin_cellB" "schematic")

;Enable CIW logs
;asdf = 'unbound
GMG_verbose = t

GMergeGui(?cvid_A cvidA ?cvid_B cvidB)

)
