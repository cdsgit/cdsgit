/*


*/


;A hook for generic cellview callbacks
procedure( CGMlmgrCBcv(_menuName)
   cv = geGetEditCellView()
   CGMlmgrCB(_menuName cv->libName cv->cellName cv->viewName nil nil)
)

;Main Library manager callback
procedure( CGMlmgrCB(_menuName lib _c _v _f _cat)

   ;Menus to create the GitShell object
   createGSmenus = list(
      ;Repo
      "CGMgui"
      ;Item
      "CGMstatus"
      "CGMexport"
      "CGMcheckout"
      "CGMadd"
      "CGMreset"
      "CGMcommit"
      "CGMdiscard"
      "CGMdiff"
      ;Merge
      "CGMmrMerge"
      "CGMmrMergeAbort"
      ;Branch
      "CGMbrCreate"
      "CGMbrCheckout"
      "CGMbrDelete"
      "CGMbrRename"
      ;Remote
      "CGMrePush"
      "CGMrePull"
      "CGMreFetch"

   )

   ;Menus where the gs path is the gs->root directory
   rootGSmenus = list(
      ;Merge
      "CGMmrMerge"
      "CGMmrMergeAbort"
      ;Remote
      "CGMrePush"
      "CGMrePull"
      "CGMreFetch"
   )

   if( member( _menuName createGSmenus ) then
       gs = CGMlmgrCB_gs(lib _c _v)
   )

   if( member( _menuName rootGSmenus ) then
      SetRoot(gs)
   )

   case( _menuName
      ;Repo
      ("CGMgui"           Gui(gs)            )
      ("CGMinit"          CGPBinitForm()     )
      ("CGMstatusAll"     CGstatusAllForm()  )
      ("CGMclone"         CGcloneForm()      )
      ("CGMsetupSSH"      CGsetupSSHform()   )
      ;Item
      ("CGMstatus"        CGstatusForm(gs)   )
      ("CGMcommit"        CGstatusForm(gs)   ); Currently Commit and status do the same thing
      ("CGMexport"        CGexportForm(gs)   )
      ("CGMcheckout"      CGcheckoutForm(gs) )
      ("CGMadd"           AddCG(gs gs->path)   )
      ("CGMreset"         Reset(gs gs->path) )
      ("CGMdiscard"       Discard(gs)        )
      ;Merge
      ("CGMmrMerge"       CGBSmergeForm(gs)  )
      ("CGMmrMergeAbort"  CGmergeAbortCB(gs) )
      ;Branch
      ("CGMbrCreate"      CGBSbranchopForm(gs "create")   )
      ("CGMbrDelete"      CGBSbranchopForm(gs "delete")   )
      ("CGMbrRename"      CGBSbranchopForm(gs "rename")   )
      ("CGMbrCheckout"    CGBSbranchopForm(gs "checkout") )
      ;Remote
      ("CGMrePush"        CGremoteCB(gs "push")  )
      ("CGMrePull"        CGremoteCB(gs "pull")  )
      ("CGMreFetch"       CGremoteCB(gs "fetch") )
      ;Diff
      ("CGMdiff"          GMergeGui() )
      ;Default
      (t              ErrorCG( GitShell(?path "") strcat("Function " _menuName " has not been implemented yet!")  ) )

   )

   t

)

procedure( CGMlmgrCB_gs(lib _c _v @key (skipRoot nil) (silent t) )
   dd = ddGetObj(lib _c _v nil nil "r")

   if(!dd
      CGMlmgrCB_error("Please select a library, cell, or view")
   )

   ddPath = dd->readPath
   ddName = dd->name

   gs = GitShell( ?path ddPath ?dd dd ?name ddName ?skipRoot skipRoot ?silent silent)

   gs->libName  = lib
   gs->cellName = _c
   gs->viewName = _v

   if(gs->verbose printf("CGMlmgrCB:Name: %s Path: %s\n"  ddName ddPath))

   gs
)

procedure( CGMlmgrCB_error(errStr)
   hiDisplayAppDBox(?name 'gitShellErrorForm
      ?dboxBanner "CdsGit Library Manager Error"
      ?dboxText errStr
      ?buttonLayout 'Close
      ;?dialogStyle 'modeless
   )
   error(errStr)
)

/*
   gotLib  = nil
   gotCell = nil
   gotView = nil


   if(lib != "" gotLib  = t)
   if(_c  != "" gotCell = t)
   if(_v  != "" gotView = t )

   case( list(gotLib gotCell gotView)

      ( '(t t t)
         printf("GOT LCV\n")
      )
      ( '(t t nil)
         printf("GOT LC\n")
      )
      ( '(t nil nil)
         printf("GOT L\n")
      )
      ( t
         printf("GOT JUNK\n")
      )



   );case

*/
