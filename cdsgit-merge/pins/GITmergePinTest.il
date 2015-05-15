/*

load("/home/acook/git/lcbu-skill/scripts/git/merge/pins/GITmergePinTest.il")

*/
loadi(strcat(git_path "/merge/GMergeLoad.il"))

cvidA = dbOpenCellViewByType("GMtest" "GMT_pin_cellA" "schematic")
cvidB = dbOpenCellViewByType("GMtest" "GMT_pin_cellB" "schematic")

diffPobj = GITmp_diffPins(cvidA cvidB)

pinsList = ToReport(diffPobj)
