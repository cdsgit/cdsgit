/*

load("/home/acook/git/lcbu-skill/scripts/git/merge/test/GMG_test.il")

*/


procedure( GMG_real_test()

;cvidA = dbOpenCellViewByType("1342" "BANDGAP" "schematic_revH")
;cvidB = dbOpenCellViewByType("1342" "BANDGAP" "schematic_revI")
cvidA = dbOpenCellViewByType("1342" "REG_HV_CORE_42" "schematic")
cvidB = dbOpenCellViewByType("1342" "REG_HV_CORE_42" "schematic_1")


;Enable CIW logs
;asdf = 'unbound
GMG_verbose = t

GMergeGui(?cvid_A cvidA ?cvid_B cvidB)

)

