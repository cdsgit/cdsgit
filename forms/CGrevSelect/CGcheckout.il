;Checkout a revision


procedure( CGcheckoutForm(gs)

   importSkillVar(cdsGitAppName)

   formTitle = sprintf(nil "%s Checkout Revision %s" cdsGitAppName gs->path)
   formCB = "CGcheckoutFormCB()"

   Status(gs ?showInfo nil)
   if( gs->modified then
      ErrorCG(gs "Cannot Checkout, you have uncommited modifications\n")
   )

   CGrevSelectForm(gs ?formTitle formTitle ?formCB formCB)

)



procedure( CGcheckoutFormCB()

   revSelected = CGgetRFchoices(cgrevselect_form->rf_revs)
   gs = cgrevselect_form->gs

   if( !gs->valid then
      ErrorCG(gs "Object is not in a valid git repository")
   )

   if(revSelected then

      gitSHA = nthelem(1 revSelected)

      Status(gs ?showInfo nil)
      if( gs->modified then
         ErrorCG(gs "Cannot Checkout, you have uncommited modifications\n")
      else
         Checkout(gs gitSHA)
         Reset(gs gs->path)
      )


      ddUpdateLibList();

   else
      Info(gs "Please make a selection")
   )

)
