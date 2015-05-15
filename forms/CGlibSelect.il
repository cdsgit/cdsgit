/*

Blocking library selection to replace dds function

load("/home/acook/git/cdsgit/forms/CGlibSelect.il")
*/


procedure( CGlibSelectForm( @optional
   (parentForm nil)
   (parentLibField nil) (parentCellField nil) (parentViewField nil)
   (formCB "CGlibSelectCB()") )

   formTitle = sprintf(nil "%s Library Browser" cdsGitAppName)

   ;Form Parameters
   grid = Gridder()
   grid->width = 80
   gridW = grid->width

   libList = ddGetLibList()~>name

   l_lib = hiCreateListBoxField(
      ?name 'l_lib
      ?prompt ""
      ?choices libList
      ?value list()
      ?defValue list()
      ?valueByPosition nil
      ?callback ""
      ?changeCB "CGlibSelectCBlib"
      ?multipleSelect nil
      ?doubleClickCB ""
      ?CBOnReselect ""
      ?keepHistory nil
      ?enabled t
      ?invisible nil
      ?help ""
   )

   l_cell = hiCreateListBoxField(
      ?name 'l_cell
      ?prompt ""
      ?choices list()
      ?value list()
      ?defValue list()
      ?valueByPosition nil
      ?callback ""
      ?changeCB "CGlibSelectCBcell"
      ?multipleSelect nil
      ?doubleClickCB ""
      ?CBOnReselect ""
      ?keepHistory t
      ?enabled t
      ?invisible nil
      ?help ""
   )

   l_view = hiCreateListBoxField(
      ?name 'l_view
      ?prompt ""
      ?choices list()
      ?value list()
      ?defValue list()
      ?valueByPosition nil
      ?callback ""
      ?changeCB "CGlibSelectCBview"
      ?multipleSelect nil
      ?doubleClickCB ""
      ?CBOnReselect ""
      ?keepHistory t
      ?enabled t
      ?invisible nil
      ?help ""
   )

   s_libfilter   = hiCreateStringField(  ?name    's_libfilter
            ?prompt     ""
            ?value      ""
            ?modifyCallback   "CGlibSelectCBfilter"
   )
   s_cellfilter   = hiCreateStringField(  ?name    's_cellfilter
            ?prompt     ""
            ?value      ""
            ?modifyCallback   "CGlibSelectCBfilter"
   )
   s_viewfilter   = hiCreateStringField(  ?name    's_viewfilter
            ?prompt     ""
            ?value      ""
            ?modifyCallback   "CGlibSelectCBfilter"
   )



   ;NewField(grid ?field l_lib  ?appendField t ?appendDir "x" ?w 2 ?h 5 ?prompt gridW*1 ?frame t ?frameLabel "Library" ?frameName "f_lib")
   ;NewField(grid ?field l_cell ?appendField t ?appendDir "x" ?w 2 ?h 5 ?prompt gridW*1 ?frame t ?frameLabel "Cell"    ?frameName "f_cell")
   ;NewField(grid ?field l_view ?appendField t ?appendDir "x" ?w 2 ?h 5 ?prompt gridW*1 ?frame t ?frameLabel "View"    ?frameName "f_view")

   NewField(grid ?field l_lib  ?x 1 ?y 1 ?w 2 ?h 8 ?prompt 0 ?frame t ?frameLabel "Library" ?frameName "f_lib")
   NewField(grid ?field l_cell ?x 3 ?y 1 ?w 2 ?h 8 ?prompt 0 ?frame t ?frameLabel "Cell"    ?frameName "f_cell")
   NewField(grid ?field l_view ?x 5 ?y 1 ?w 2 ?h 8 ?prompt 0 ?frame t ?frameLabel "View"    ?frameName "f_view")

   NewField(grid ?field s_libfilter  ?x 1 ?y 9 ?w 2 ?h 1 ?prompt 0 )
   NewField(grid ?field s_cellfilter ?x 3 ?y 9 ?w 2 ?h 1 ?prompt 0 )
   NewField(grid ?field s_viewfilter ?x 5 ?y 9 ?w 2 ?h 1 ?prompt 0 )

   NewField(grid ?field nil ?x 1 ?y 9 ?w 6 ?h 1 ?frame t ?frameLabel "Filter" ?frameName "f_filter" ?frameExpand '(10 15 10 10) )

   cglibselect_form = hiCreateAppForm(
               ?name 'cglibselect_form
               ?formTitle formTitle
               ?callback  formCB
               ?fields         grid->fields
               ?attachmentList grid->attachmentList
               ?initialSize    FormSize(grid)
               ?minSize        FormSize(grid)
               ?buttonLayout  'OKCancelApply
               ?dontBlock     nil
         )

   ;Storage for filter
   cglibselect_form->storedLibs  = libList
   cglibselect_form->storedCells = list()
   cglibselect_form->storedViews = list()

   ;Store the parent form
   cglibselect_form->parentForm      = parentForm
   cglibselect_form->parentLibField  = parentLibField
   cglibselect_form->parentCellField = parentCellField
   cglibselect_form->parentViewField = parentViewField

   ;Storage for the final choice
   cglibselect_form->lib
   cglibselect_form->cell
   cglibselect_form->view


   hiDisplayForm(cglibselect_form)

)

procedure( CGlibSelectCB()

   ;Retrieve the parent information
   parentForm = cglibselect_form->parentForm
   parentLibField  = cglibselect_form->parentLibField
   parentCellField = cglibselect_form->parentCellField
   parentViewField = cglibselect_form->parentViewField

   get(parentForm parentLibField)->value  = cglibselect_form->lib
   get(parentForm parentCellField)->value = cglibselect_form->cell
   get(parentForm parentViewField)->value = cglibselect_form->view

)

procedure( CGlibSelectCBlib()

   current_lib = car(cglibselect_form->l_lib->value)
   cglibselect_form->current_lib = current_lib

   if( current_lib then
      cellList = ddGetObj(current_lib)~>cells~>name
      cglibselect_form->l_cell->choices = cellList
      cglibselect_form->storedCells = cellList
      cglibselect_form->lib = current_lib
   else
      cglibselect_form->l_cell->choices = list()
      cglibselect_form->storedCells = list()
      cglibselect_form->lib = ""
   )
   CGlibSelectCBcell()

)

procedure( CGlibSelectCBcell()

   current_cell = car(cglibselect_form->l_cell->value)
   cglibselect_form->current_cell = current_cell

   if( current_cell then
      viewList = ddGetObj(cglibselect_form->current_lib current_cell)~>views~>name
      cglibselect_form->l_view->choices = viewList
      cglibselect_form->storedViews = viewList
      cglibselect_form->cell =  current_cell
   else
      cglibselect_form->l_view->choices = list()
      cglibselect_form->storedViews = list()
      cglibselect_form->cell = ""
   )
   CGlibSelectCBview()

)

procedure( CGlibSelectCBview()
   current_view = car(cglibselect_form->l_view->value)
   cglibselect_form->current_view = current_view

   if(current_view then
      cglibselect_form->view = current_view
   else
      cglibselect_form->view = ""
   )
)


;Filter a list
procedure( CGlibSelectCBfilter(fieldName filterStr sourceOfChange)

   case( fieldName
      ('s_libfilter
         filterList = cglibselect_form->l_lib
         filterChoices = cglibselect_form->storedLibs
      )
      ('s_cellfilter
         filterList = cglibselect_form->l_cell
         filterChoices = cglibselect_form->storedCells
      )
      ('s_viewfilter
         filterList = cglibselect_form->l_view
         filterChoices = cglibselect_form->storedViews
      )

   )

   if( !filterStr || filterStr == "" then
      newChoices = filterChoices
   else
      newChoices = setof( str filterChoices rexMatchp( filterStr str ))
   )


   filterList->choices = newChoices


   cond(

      ( newChoices && length(newChoices) == 1
         filterList->value = newChoices
      )
      ( filterStr && filterStr != ""
         if( member(filterStr newChoices) then
            filterList->value = list(filterStr)
         )
      )
      (t
         filterList->value = list()
      )
   )

   t
)