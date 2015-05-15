/*
load("/home/acook/git/lcbu-skill/scripts/git/merge/GITmergeGuiCB.il")
*/

;COMPUTE THE DIFF
procedure( GMG_computeDiff( @key (showDialog t) )

   if( !boundp('GMG_verbose) GMG_verbose = nil)

   if( showDialog
      response = hiDisplayAppDBox(
         ?name 'updateDestinationWarn
         ?dboxBanner "Diff Recompute Warning"
         ?dboxText "Warning: The action you have selected will recompute the diff\nYou will not be able to undo current merged changes"
         ?buttonLayout 'OKCancel
      )
   )
   if( !showDialog || response then

      GMG_updateCellViews()

      if( GMG_validateCv() then

         ;Get the destination
         destination = GMergeGui_form->radio_startPoint->value

         if(destination == "A" then
            srcCv = cvidB
            dstCv = cvidA
         else
            srcCv = cvidA
            dstCv = cvidB
         )

         netDiff = GMergeGui_form->toggle_netdiff->value

         GMrunDiff(?srcCv srcCv ?dstCv dstCv ?netDiff netDiff)
         GMG_setChoices()
         GMG_filterPopulate()
         GMergeGui_form->text_D->value = ""
      else
         GMdiffPairObj = nil
         GMG_setChoices()
         GMergeGui_form->text_D->value = "*** Cannot open current cell views for read ***"
      )
   )

)



;When and item is ADD/SUB, find the item and change it's state
procedure( GMG_updateSelected( values choices)

   foreach(value values
      selected = nthelem(1+value choices)
      diffObj = nthelem(4 selected)
      AddChange(GMdiffPairObj diffObj)
   )
   MakeChanges(GMdiffPairObj)
   HighlightDiffs(GMdiffPairObj)
)

procedure( GMG_updateCellViews( @key (open nil) )
let( (cv)
   cvidA = dbOpenCellViewByType(GMergeGui_form->textLib_A->value  GMergeGui_form->textCell_A->value GMergeGui_form->textView_A->value nil "r")
   cvidB = dbOpenCellViewByType(GMergeGui_form->textLib_B->value  GMergeGui_form->textCell_B->value GMergeGui_form->textView_B->value nil "r")

   case(open
      ("A" cv=cvidA)
      ("B" cv=cvidB)
      (t   open = nil)
   )
   if(open then
      wid = geGetCellViewWindow(cv)
      if( wid then
         hiRaiseWindow(wid)
      else
         deOpenCellView(cv->libName cv->cellName cv->viewName cv->cellViewType nil cv->mode)
      )
   )
)
)


;Callback when an item is selected
procedure( GMG_rfield_CB(fieldName selectedItems "sl")

if(GMG_verbose printf( "Report field callback, fieldName = %L, selectedItems = %L\n"
                           fieldName selectedItems ))
if(selectedItems then

   case(fieldName
   ('rfield_A
      if(GMG_verbose printf("A\n"))
   )
   ('rfield_M
      if(GMG_verbose printf("M\n"))
   )
   ('rfield_B
      if(GMG_verbose printf("B\n"))
   )
   )

   selection = car(selectedItems)
   choices = evalstring(strcat("GMergeGui_form->" fieldName "->choices"))
   choice  = nthelem(selection+1 choices)
   diffObj = nthelem(4 choice)

   GMergeGui_form->text_D->value = Details(diffObj)
)

;Deselect all
foreach(cv list(cvidA cvidB)
   wid = geGetCellViewWindow(cv)
   if(wid then geDeselectAll(wid) )
)
; Zoom both windows if a partial diff
zoomBoth = nil
foreach(selection selectedItems
   choices = evalstring(strcat("GMergeGui_form->" fieldName "->choices"))
   choice  = nthelem(selection+1 choices)
   diffObj = nthelem(4 choice)
   if( diffObj->status == "partial" zoomBoth = t)
   GMG_selectInst(diffObj)
)
if( GMergeGui_form->toggle_autoZoom->auto->value then
   if(zoomBoth then
      GMG_zoomFit('rfield_A)
      GMG_zoomFit('rfield_B)
   else
      GMG_zoomFit(fieldName)
   )

)


)

;Clears the form
procedure( GMG_clearForm()

   GMergeGui_form->text_D->value = ""

   GMergeGui_form -> rfield_A -> choices = list()
   GMergeGui_form -> rfield_M -> choices = list()
   GMergeGui_form -> rfield_B -> choices = list()

)

;Callback for changing source cells
procedure( GMG_button_change_CB(fieldName)
   case(fieldName
   ("A"
      CGlibSelectForm(GMergeGui_form 'textLib_A 'textCell_A 'textView_A )
   )
   ("B"
      CGlibSelectForm(GMergeGui_form 'textLib_B 'textCell_B 'textView_B )
   )
   )

   ;GMG_computeDiff()
   Cleanup(GMdiffPairObj)
   GMG_clearForm()

)

;Callback when an item is ADD/SUB or double clicked
procedure( GMG_mbutton_CB(fieldName)

   cellsEditable = GMG_checkEditMode()

   if(cellsEditable then
      choicesList = GMG_getChoices()

      case(fieldName
      ("A"
         values  = GMergeGui_form -> rfield_A -> value
         choices = nthelem(1 choicesList)
      )
      ("M"
         values  = GMergeGui_form -> rfield_M -> value
         choices = nthelem(2 choicesList)
      )
      ("B"
         values  = GMergeGui_form -> rfield_B -> value
         choices = nthelem(3 choicesList)
      )
      )

      choicesList = GMG_getChoices()
      choicesList = GMG_updateSelected(values choices)

      GMG_setChoices()
   )

   t
)

procedure( GMG_checkEditMode()

   if(!GMG_cellEditMode() then
      response = hiDisplayAppDBox(
         ?name 'editModeWarning
         ?dboxBanner "Edit Mode Warning"
         ?dboxText "Warning: The selected cells are not editable\nWould you like to open them for edit?"
         ?buttonLayout 'OKCancel
      )
      if(response then
            GMergeGui_form->toggle_editmode->mode->value = t
            GMG_editMode()
      )


      if(!GMG_cellEditMode() then
         error("Could not open cells for edit. Aborting")
      )
   )
   t
)

procedure( GMG_cellEditMode()
   if( GMG_validateCv() then
      editable = (cvidA->mode == "a" && cvidB->mode == "a")
   )
)

;Return a list of the report field choices
procedure( GMG_getChoices()

   choices_A = GMergeGui_form -> rfield_A -> choices
   choices_M = GMergeGui_form -> rfield_M -> choices
   choices_B = GMergeGui_form -> rfield_B -> choices

   list(choices_A choices_M choices_B)
)

procedure( GMG_validateCv()

   boundp('cvidA) && boundp('cvidB) && cvidA && cvidB

)

;Populate the report field values
procedure( GMG_setChoices()
   if( GMdiffPairObj then
      diffList    = ToReport(GMdiffPairObj)

      GMergeGui_form -> rfield_A -> choices = nil
      GMergeGui_form -> rfield_M -> choices = nil
      GMergeGui_form -> rfield_B -> choices = nil

      foreach(diff diffList
         diffObj = nthelem(4 diff)
         diffState = diffObj->merged

         if(GMG_verbose Print(diffObj))

         if(diffObj->visible then
         case( diffState
            (nil
               if( diffObj->status == "partial" then obj = diffObj->refObj
               else                                  obj = diffObj->obj    )
               if( obj->cellView == cvidA then
                  GMergeGui_form -> rfield_A -> choices = cons( diff GMergeGui_form -> rfield_A -> choices)
               else
                  GMergeGui_form -> rfield_B -> choices = cons( diff GMergeGui_form -> rfield_B -> choices)
               )
            )
            (t
               GMergeGui_form -> rfield_M -> choices = cons( diff GMergeGui_form -> rfield_M -> choices)
            )

         );case
         );if
      )
   else
      GMergeGui_form -> rfield_A -> choices = list()
      GMergeGui_form -> rfield_M -> choices = list()
      GMergeGui_form -> rfield_B -> choices = list()
   )

)


;Filter the diff results by type
procedure(GMG_filter()

tFilterValue = GMergeGui_form->cyclic_typeFilter->value
dFilterValue   = GMergeGui_form->cyclic_diffFilter->value

   GMdiffPairObj->diffList = foreach(diff GMdiffPairObj->diffList

      if(
         (tFilterValue == "All" || tFilterValue=="-----" || diff->type   == tFilterValue ) &&
         (dFilterValue == "All" || dFilterValue=="-----" || diff->status == dFilterValue )
      then
         diff->visible = t
      else
         diff->visible = nil
      )

   )
   GMG_setChoices()
)

;Populate the filter list with choices
procedure(GMG_filterPopulate()

   filterList = list( "-----" "None" "All")

   foreach(diff GMdiffPairObj->diffList
      if( !diff->type then
         error("No type for diff %d" diff->id)
      )
      if( diff->type && !member(diff->type filterList) then
         filterList = cons( sprintf(nil diff->type) filterList)
      )
   )

   GMergeGui_form->cyclic_typeFilter->choices = reverse(filterList)
   GMergeGui_form->cyclic_typeFilter->value = "All"

)

;Change which schematic is used for the starting point
procedure( GMG_updateDestination()

if( !boundp('ignoreDialog) || !ignoreDialog then

   diffComputed = GMG_computeDiff(?showDialog t)

   if(!diffComputed then
      ;Revert the radio field
      currentValue = GMergeGui_form->radio_startPoint->value
      if(currentValue == "A" then
         newValue = "B"
      else
         newValue = "A"
      )
      ignoreDialog = t
      GMergeGui_form->radio_startPoint->value = newValue

   )
else
   ignoreDialog = nil
)

)

procedure( GMG_editMode()
   if( GMG_validateCv() then
      if(GMergeGui_form->toggle_editmode->mode->value then
         dbReopen(cvidA "a")
         dbReopen(cvidB "a")
      else
         dbReopen(cvidA "r")
         dbReopen(cvidB "r")
      )
   )

)

procedure( GMG_highlight()
   if(!GMdiffPairObj->highlighted then
      HighlightDiffs(GMdiffPairObj); Highlight the diff objects
   else
      DeleteHighlights(GMdiffPairObj)
   )
)

procedure( GMG_selectInst(diffObj)

   Select(diffObj)
   /*
   geGetWindowCellView
   geGetCellViewWindow
   if( length(selectedItems) == 1 then
      Select(diffObj)  schSelectPoint
   )
   */
)

procedure( GMG_zoomFit(fieldName)
case(fieldName
   ('rfield_A cvid = cvidA)
   ('rfield_B cvid = cvidB)
   (t cvid = nil)
)
   if(cvid then
      wid = geGetCellViewWindow(cvid)
      if(wid then
         printf("wid %L\n" wid)
         insts = geGetSelSet(wid)
         bbox = GMG_getBBox(insts)
         hiZoomIn(wid bbox)
      )
   )
)

procedure(GMG_getBBox(@optional objects "l")
  let( (lx rx ly uy)
    ;; unless objects is a list of database objects already, get the
    ;; selected set and use that for the list of objects to work with
    unless(objects && forall(obj objects dbobjectp(obj))
      ;; set objects to geGetSelectedSet(), but could still be nil
      objects = geGetSelectedSet()
    ); unless
    ;; when objects is non-nil, obtain starting values for the
    ;; left- and right- most x,  and the lowest and highest y
    when(objects
      lx = xCoord(lowerLeft(car(objects)~>bBox))
      rx = xCoord(upperRight(car(objects)~>bBox))
      ly = yCoord(lowerLeft(car(objects)~>bBox))
      uy = yCoord(upperRight(car(objects)~>bBox))
      ;; iterate over each object and if any point of its
      ;; bounding box is outside the current limits of
      ;; list(lx:ly rx:uy) then store the new value
      foreach(obj objects
   lx = min(lx xCoord(lowerLeft(obj~>bBox)))
   ly = min(ly yCoord(lowerLeft(obj~>bBox)))
   uy = max(uy yCoord(upperRight(obj~>bBox)))
   rx = max(rx xCoord(upperRight(obj~>bBox)))
      ); foreach
      ;; return the calculated bounding box
      list(list(lx ly) list(rx uy))
    ); when
  ); let
); procedure CCSgetBBox


procedure( GMG_get_diff(id)
   GetDiff( GMdiffPairObj id)
)