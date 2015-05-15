;GitShell
;Inteface from SKILL to git commands

loadi(strcat(cdsgit_gs_path "/GitShell.ils"))



;Utilities
loadi(strcat(cdsgit_gs_path "/GSstr.ils"))
   loadi(strcat(cdsgit_gs_path "/GSpath.ils"))
   loadi(strcat(cdsgit_gs_path "/GSpath/Trim.ils"))
   loadi(strcat(cdsgit_gs_path "/GSpath/Depth.ils"))
   loadi(strcat(cdsgit_gs_path "/GSpath/IsCadence.ils"))
   loadi(strcat(cdsgit_gs_path "/GSpath/ToList.ils"))
   loadi(strcat(cdsgit_gs_path "/GSpath/Clone.ils"))
   loadi(strcat(cdsgit_gs_path "/GSpath/DepthFromPath.ils"))
   loadi(strcat(cdsgit_gs_path "/GSpath/Convolve.ils"))
   loadi(strcat(cdsgit_gs_path "/GSpath/Subtract.ils"))
   loadi(strcat(cdsgit_gs_path "/GSpath/Type.ils"))
   loadi(strcat(cdsgit_gs_path "/GSpath/IsInPath.ils"))
   loadi(strcat(cdsgit_gs_path "/GSpath/FullPath.ils"))
   loadi(strcat(cdsgit_gs_path "/GSpath/GetLib.ils"))


;Reporting
loadi(strcat(cdsgit_gs_path "/GitShell/Error.ils"))
loadi(strcat(cdsgit_gs_path "/GitShell/Info.ils"))
loadi(strcat(cdsgit_gs_path "/GitShell/Dialog.ils"))
loadi(strcat(cdsgit_gs_path "/GitShell/Depth.ils"))
loadi(strcat(cdsgit_gs_path "/GitShell/SetFilter.ils"))
loadi(strcat(cdsgit_gs_path "/GitShell/AddGSpath.ils"))
loadi(strcat(cdsgit_gs_path "/GitShell/SetRoot.ils"))

;Shell
loadi(strcat(cdsgit_gs_path "/GitShell/Check.ils"))
loadi(strcat(cdsgit_gs_path "/GitShell/Cmd.ils"))

;GitCommands (main)
loadi(strcat(cdsgit_gs_path "/GitShell/Log.ils"))
loadi(strcat(cdsgit_gs_path "/GitShell/Status.ils"))
loadi(strcat(cdsgit_gs_path "/GitShell/Root.ils"))
loadi(strcat(cdsgit_gs_path "/GitShell/Commit.ils"))
loadi(strcat(cdsgit_gs_path "/GitShell/CommitMsg.ils"))
loadi(strcat(cdsgit_gs_path "/GitShell/CloneRepo.ils"))
loadi(strcat(cdsgit_gs_path "/GitShell/Gui.ils"))
loadi(strcat(cdsgit_gs_path "/GitShell/Branch.ils"))
loadi(strcat(cdsgit_gs_path "/GitShell/Merge.ils"))
loadi(strcat(cdsgit_gs_path "/GitShell/Export.ils"))
loadi(strcat(cdsgit_gs_path "/GitShell/Checkout.ils"))
loadi(strcat(cdsgit_gs_path "/GitShell/CheckFormat.ils"))
loadi(strcat(cdsgit_gs_path "/GitShell/Init.ils"))
;Remote
loadi(strcat(cdsgit_gs_path "/GitShell/Push.ils"))
loadi(strcat(cdsgit_gs_path "/GitShell/Pull.ils"))
loadi(strcat(cdsgit_gs_path "/GitShell/Fetch.ils"))


;GitOperations
loadi(strcat(cdsgit_gs_path "/GitShell/Reset.ils"))
loadi(strcat(cdsgit_gs_path "/GitShell/Add.ils"))
loadi(strcat(cdsgit_gs_path "/GitShell/Discard.ils"))

;Cadence Operations
loadi(strcat(cdsgit_gs_path "/GitShell/GetLibs.ils"))
loadi(strcat(cdsgit_gs_path "/GitShell/Refresh.ils"))

