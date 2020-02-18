;Export a revision


procedure( CGexportForm(gs)

   importSkillVar(cdsGitAppName)

   formTitle = sprintf(nil "%s Export Revision %s" cdsGitAppName gs->path)
   formCB = "CGexportFormCB()"

   CGrevSelectForm(gs ?formTitle formTitle ?formCB formCB)

)



procedure( CGexportFormCB()

   gs = cgrevselect_form->gs
   revSelected = CGgetRFchoices(cgrevselect_form->rf_revs)

   if( !gs->valid then
      ErrorCG(gs "Object is not in a valid git repository")
   )

   if(revSelected then

      gitSHA = nthelem(1 revSelected)

      if( isDir( strcat(gs->path "_" gitSHA)) then
         Info(gs "Export path already exists!")
      else
         Export(gs gitSHA)
      )


      ;TODO: Create a lib if needed
      ;ddCreateLib("MOREJUNK" "./MOREJUNK")

      ;A usefull function
      ;ddSetForcedLib

      ddUpdateLibList();

   else
      Info(gs "Please make a selection")
   )

)
