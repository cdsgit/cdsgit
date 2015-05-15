/*

load("/home/acook/git/lcbu-skill/scripts/git/merge/pins/GITcreatePinTest.il")

*/

loadi(strcat(git_path "/merge/GMergeLoad.il"))


cvidA = dbOpenCellViewByType("GMtest" "GMT_createPin_A" "schematic" nil "w")
cvidB = dbOpenCellViewByType("GMtest" "GMT_createPin_B" "schematic" nil "r")

refPin = car(cvidA->terminals)

refPinObj = makeInstance( 'GMschPin ?obj refPin ?srcCv cvidA ?dstCv cvidB)

Create(refPinObj)

printf("Type cont() to cleanup\n")
break()
schDelete(refPinObj->genObj)