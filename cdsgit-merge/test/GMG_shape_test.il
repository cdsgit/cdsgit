/*

loadi("/home/acook/git/lcbu-skill/scripts/git/merge/test/GMG_shape_test.il")

*/


procedure( GMG_shape_test()

cvidA = dbOpenCellViewByType("GMtest" "GMT_wire_A" "schematic")
cvidB = dbOpenCellViewByType("GMtest" "GMT_wire_B" "schematic")

;Enable CIW logs
;asdf = 'unbound
GMG_verbose = t

GMergeGui(?cvid_A cvidA ?cvid_B cvidB)

)
