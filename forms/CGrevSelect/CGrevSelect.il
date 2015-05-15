/* Testing
CGrevSelectForm(GitShell(?path "../cdsgit-testrepo"))

*/


procedure( CGrevSelectForm(gs @key (formTitle "") (formCB "") (lcvSel t) ) ;TODO lcvSel nil

   ;Form Parameters
   grid = Gridder(?verbose gs->verbose)
   gridW = grid->width
   revList = Log(gs)

   branchList = Branch(gs)



   ;################ FRAME A ##############
   s_lib  = hiCreateStringField( ?name 's_lib  ?prompt "Library" ?defValue gs->libName  ?editable nil)
   s_cell = hiCreateStringField( ?name 's_cell ?prompt "Cell"    ?defValue gs->cellName ?editable nil)
   s_view = hiCreateStringField( ?name 's_view ?prompt "View"    ?defValue gs->viewName ?editable nil)
   b_browse = hiCreateButton(
            ?name     'b_browse
            ?buttonText "Browse"
            ?callback  "CGrevSelectFormBrowseCB()"
            ) ;


   c_branch = hiCreateCyclicField(
      ?name 'c_branch
      ?prompt "Branch"
      ?choices gs->branches
      ?value gs->branch
      ?callback "CGrevSelectFormRefersh()"
   ) ;CycField


   reportHeader = list(
      list( "SHA ID" 100 'left 'string t )
      list( "Author" 150 'left 'string t )
      list( "Date" 100 'left 'string t )
      list( "Log" 350 'left 'string t)
      )


   rf_revs = hiCreateReportField(
            ?name 'rf_revs
               ?title formTitle
               ?titleAlignment 'center
               ?headers reportHeader
               ?choices revList
               ?selectMode 'single
               ?doubleClickCB formCB
               ?callback ""
            )

   if( lcvSel then
      NewField(grid ?field s_lib     ?appendField t ?w 5 ?h 1 ?prompt gridW*1 )
      NewField(grid ?field s_cell    ?appendField t ?w 5 ?h 1 ?prompt gridW*1 )
      NewField(grid ?field s_view    ?appendField t ?w 5 ?h 1 ?prompt gridW*1 )
      NewField(grid ?field b_browse  ?appendField t ?w 5 ?h 1 ?prompt gridW*1 )
   )

   NewField(grid ?field c_branch  ?appendField t ?w 5 ?h 1 ?prompt gridW*1 )
   NewField(grid ?field rf_revs   ?appendField t ?w 5 ?h 4 ?prompt 10 )

   cgrevselect_form = hiCreateAppForm(
               ?name 'cgrevselect_form
               ?formTitle formTitle
               ?callback formCB
               ?fields         grid->fields
               ?attachmentList grid->attachmentList
               ?initialSize    FormSize(grid)
               ?minSize        FormSize(grid)
               ?buttonLayout  'OKCancelApply
               ?dontBlock     t
         )

   cgrevselect_form->gs = gs

   hiDisplayForm(cgrevselect_form)

)

procedure( CGrevSelectFormRefersh()
   gs = cgrevselect_form->gs
   bname = cgrevselect_form->c_branch->value
   cgrevselect_form->rf_revs->choices = Log(gs ?branchname bname)
)

procedure( CGrevSelectFormBrowseCB()

      CGlibSelectForm(cgrevselect_form 's_lib 's_cell 's_view )


      libName  = cgrevselect_form->s_lib->value
      cellName = cgrevselect_form->s_cell->value
      viewName = cgrevselect_form->s_view->value

      ;Clear choices
      cgrevselect_form->c_branch->choices = list("")
      cgrevselect_form->c_branch->value   = ""
      cgrevselect_form->rf_revs->choices  = list()

      ;Recompute the gs
      gs = CGMlmgrCB_gs(libName cellName viewName)
      cgrevselect_form->gs = gs

      if( gs->valid then
         ;Update the branches
         branchList = Branch(gs)
         cgrevselect_form->c_branch->choices = gs->branches
         cgrevselect_form->c_branch->value   = gs->branch
         CGrevSelectFormRefersh()
      )

)