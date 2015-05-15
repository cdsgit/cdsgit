procedure( CGregisterForm()

   s_registration   = hiCreateStringField(  ?name    's_registration
            ?prompt     "Registration Code"
            ?value      ""
   )

   cgregister_form = hiCreateAppForm(
               ?name 'cgregister_form
               ?formTitle "Register CdsGit"
               ?callback  "CGregisterFormCB()"
               ?fields        list(
                                 list(s_registration 10:10 600:100 120)
                              )
               ?buttonLayout  'OKCancelApply
               ?dontBlock     nil
         )

   hiDisplayForm(cgregister_form)


)

procedure( CGregisterFormCB()
   cgregister_code = cgregister_form->s_registration->value

   fout = outfile(CGcoolPath "w")
   fprintf(fout "%s\n" cgregister_code)
   close(fout)

   printf("Registration Code Set to %s\n" cgregister_code)
)