procedure( CGlmgrState(_menuName lib _c _v _f _cat)
let( (menuState)

   menuState = nil

   ;Only check status if something is selected
   if(lib && lib != "" then
      gs = CGMlmgrCB_gs(lib _c _v ?skipRoot t)
      menuState = gs->valid
   )

   lmgrSensitizeMenuItems( '("CGMgui") menuState)
   lmgrSensitizeMenuItems( '("CGMstatus" "CGMdiff" "CGMcheckout" "CGMexport") menuState)
   lmgrSensitizeMenuItems( '("CGMadd" "CGMreset" "CGMcommit" "CGMdiscard") menuState)

   lmgrSensitizeMenuItems( '("gitMenuRemote" "gitMenuBranch" "gitMenuMerge") menuState)
   lmgrSensitizeMenuItems( '("CGMprRepo") menuState)

   t
);let
)