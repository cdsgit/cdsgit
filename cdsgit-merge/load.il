/*

load(strcat(lcbu_path "/scripts/git/merge/GMergeLoad.il"))

DEPENDANCIES:
Gridder

*/

git_merge_path = strcat(cdsgit_path "/cdsgit-merge")

;Debugging symbols
GITmg_verbose = nil


;GUI
loadi(strcat(git_merge_path "/GMergeGui.il"))
loadi(strcat(git_merge_path "/GMergeGuiCB.il"))

;Methods
loadi(strcat(git_merge_path "/GMrunDiff.il"))
loadi(strcat(git_merge_path "/pins/GITcreatePin.il"))


;Classes (order matters here) (tabs indicate inheritance scheme)
loadi(strcat(git_merge_path "/classes/GMgeneric.ils"))
loadi(strcat(git_merge_path "/classes/GMdiffPairs.ils"))

loadi(strcat(git_merge_path "/classes/GMdiff/GMdiff.ils"))
   loadi(strcat(git_merge_path "/classes/GMdiff/GMobj.ils"))
      loadi(strcat(git_merge_path "/classes/GMdiff/GMschInst.ils"))
         loadi(strcat(git_merge_path "/classes/GMdiff/GMschPin.ils"))
      loadi(strcat(git_merge_path "/classes/GMdiff/GMschShape.ils"))
         loadi(strcat(git_merge_path "/classes/GMdiff/GMschLabel.ils"))
         loadi(strcat(git_merge_path "/classes/GMdiff/GMschWire.ils"))
      loadi(strcat(git_merge_path "/classes/GMdiff/GMnetGroup.ils"))


;Display Resources
;drLoadDrf(strcat(git_merge_path "/display/GITmerge.drf"))

;Functions
loadi(strcat(git_merge_path "/GMcreateBackup.ils"))


;Tests
loadi(strcat(git_merge_path "/test/GMG_merge_test.il"))
loadi(strcat(git_merge_path "/test/GMG_net_test.il"))
loadi(strcat(git_merge_path "/test/GMG_real_test.il"))
loadi(strcat(git_merge_path "/test/GMG_shape_test.il"))
loadi(strcat(git_merge_path "/test/GMG_test.il"))


/* Breaks make script
procedure( GMreload()
   loadi(strcat(git_merge_path "/load.il"))
)
*/
