/*

Aaron Cook
11/2/2013

Gui to merge schematics/symbols/layouts

load(strcat(lcbu_path "/scripts/git/merge/GMergeGuiForm.il")


TODO:

   Consider using tree table instead of report form
   CCSListBoxForm.il in examples has some nice stuff

*/

procedure( GMergeGui( @key (cvid_A nil) (cvid_B nil))


;#### TITLE #####
form_title = sprintf(nil "%s Merge GUI" cdsGitAppName)

;#### LCV #####
if( !cvid_A then
   textLib_A_value  = ""
   textCell_A_value = ""
   textView_A_value = ""
else
   textLib_A_value  = cvid_A->libName
   textCell_A_value = cvid_A->cellName
   textView_A_value = cvid_A->viewName
)

if(!cvid_B then
   textLib_B_value  = ""
   textCell_B_value = ""
   textView_B_value = ""
else
   textLib_B_value  = cvid_B->libName
   textCell_B_value = cvid_B->cellName
   textView_B_value = cvid_B->viewName
)

;#### REPORT HEADER #####

reportHeader = list(
    list( "Name" 150 'left 'string t )
    list( "Type" 80 'left 'string t )
    list( "Diff"   50  'left 'string t )
    )

rfield_choices = list( list("--" "--" "--" "--") )

;################ MAIN FORM ##############
radio_startPoint = hiCreateRadioField(
   ?name 'radio_startPoint
   ?prompt "Diff Destination"
   ?value "B"
   ?choices '("A" "B")
   ?callback list("GMG_updateDestination()")
   )

cyclic_typeFilter = hiCreateCyclicField(
   ?name 'cyclic_typeFilter
   ?prompt "Filters:  Type"
   ?choices list("")
   ?value ""
   ?callback "GMG_filter()"
)
cyclic_diffFilter = hiCreateCyclicField(
   ?name 'cyclic_diffFilter
   ?prompt "Diff"
   ?choices list("All" "-----" "new" "partial")
   ?value "All"
   ?callback "GMG_filter()"
)

button_recompute = hiCreateButton(
   ?name     'button_recompute
   ?buttonText "Recompute"
   ?callback  "GMG_computeDiff()"
) ;
button_highlight = hiCreateButton(
   ?name     'button_highlight
   ?buttonText "Toggle Highlight"
   ?callback  "GMG_highlight()"
) ;

toggle_editmode = hiCreateToggleField(
   ?name     'toggle_editmode
   ?prompt   "Edit Mode"
   ?choices   list( '(mode "") )
   ?value     list(GMG_cellEditMode())
   ?callback  list("GMG_editMode()")
) ;
toggle_netdiff = hiCreateToggleField(
   ?name     'toggle_netdiff
   ?prompt   "Netist Diff"
   ?choices   list( '(val "") )
   ?value     list(t)
   ?callback  nil
) ;
toggle_autoZoom = hiCreateToggleField(
   ?name     'toggle_autoZoom
   ?prompt   "Auto Zoom"
   ?choices   list( '(auto "") )
   ?value     list(t)
   ?callback  nil
) ;

frame_A = hiCreateFrameField(
      ?name 'frame_A
      ?labelText "SOURCE CELL A"
        )

frame_M = hiCreateFrameField(
      ?name 'frame_M
      ?labelText "MERGED CHANGES"
        )

frame_B = hiCreateFrameField(
      ?name 'frame_B
      ?labelText "SOURCE CELL B"
        )

frame_D = hiCreateFrameField(
      ?name 'frame_D
      ?labelText "DETAILS"
        )

hint_str = "TIPS:\n
   * Use Ctrl+A to select all diff objects in the list\n
   * Double clicking an item is the same as clicking \"ADD/SUB\"\n
   * When the diff is computed, the Diff destination is copied to create the destination cell\n
   * You can recompute the diff at any time\n
   * Use the filters to orginize the diff information"

text_D = hiCreateMLTextField(
      ?name 'text_D
      ?value strcat(hint_str)
      ?editable nil
      ?enableWordWrap t
      ?hasHorizontalScrollbar nil
      )

;################ FRAME A ##############
textLib_A  = hiCreateStringField( ?name 'textLib_A  ?prompt "Library"  ?defValue textLib_A_value  ?editable t)
textCell_A = hiCreateStringField( ?name 'textCell_A ?prompt "Cell"     ?defValue textCell_A_value ?editable t)
textView_A = hiCreateStringField( ?name 'textView_A ?prompt "View"     ?defValue textView_A_value ?editable t)
button_browse_A = hiCreateButton(
         ?name     'button_browse_A
         ?buttonText "CHANGE"
         ?callback  "GMG_button_change_CB(\"A\")"
         ) ;
button_open_A = hiCreateButton(
         ?name     'button_open_A
         ?buttonText "OPEN"
         ?callback  "GMG_updateCellViews(?open \"A\")"
         ) ;

button_move_A = hiCreateButton(
      ?name 'button_move_A
      ?buttonText "ADD ----->"
      ?callback "GMG_mbutton_CB(\"A\")"
      )
rfield_A = hiCreateReportField(
      ?name 'rfield_A
      ?titleAlignment 'center
      ?headers reportHeader
      ?choices rfield_choices
      ?callback 'GMG_rfield_CB
      ?doubleClickCB "GMG_mbutton_CB(\"A\")"
      )

;################ FRAME M ##############

rfield_M = hiCreateReportField(
      ?name 'rfield_M
      ?titleAlignment 'center
      ?headers reportHeader
      ?choices rfield_choices
      ?callback 'GMG_rfield_CB
      ?doubleClickCB "GMG_mbutton_CB(\"M\")"
      )
button_move_M = hiCreateButton(
      ?name 'button_move_M
      ?buttonText "<--SUB-->"
      ?callback "GMG_mbutton_CB(\"M\")"
      )
;################ FRAME B ##############
textLib_B  = hiCreateStringField( ?name 'textLib_B  ?prompt "Library" ?defValue textLib_B_value  ?editable t)
textCell_B = hiCreateStringField( ?name 'textCell_B ?prompt "Cell"    ?defValue textCell_B_value ?editable t)
textView_B = hiCreateStringField( ?name 'textView_B ?prompt "View"    ?defValue textView_B_value ?editable t)
button_browse_B = hiCreateButton(
         ?name     'button_browse_B
         ?buttonText "CHANGE"
         ?callback  "GMG_button_change_CB(\"B\")"
         ) ;
button_open_B = hiCreateButton(
         ?name     'button_open_B
         ?buttonText "OPEN"
         ?callback  "GMG_updateCellViews(?open \"B\")"
         ) ;

button_move_B = hiCreateButton(
      ?name 'button_move_B
      ?buttonText "<-----ADD"
      ?callback "GMG_mbutton_CB(\"B\")"
      )
rfield_B = hiCreateReportField(
      ?name 'rfield_B
      ?titleAlignment 'center
      ?headers reportHeader
      ?choices rfield_choices
      ?callback 'GMG_rfield_CB
      ?doubleClickCB "GMG_mbutton_CB(\"B\")"
      )

;################ FORM SIZING ##############
g=Gridder()
g->width   = 140
g->height  = 30
g->spacing = 7
g->border  = 5


colA = 1
colM = 3
colB = 5

lRow = 4

lcvWidth = 2
lcvOffset = 60

reportRow = lRow+5
reportH = 8

frameOffset = 15
frameHeight = reportRow + reportH-lRow+2
frameRow = 3
frameWidth = 2
frameExpand = 3
dframeHeight = 5


moveRow = reportRow + reportH


NewField(g ?field frame_A  ?x colA ?y frameRow  ?w frameWidth   ?h frameHeight  ?prompt frameOffset ?expand frameExpand)
NewField(g ?field frame_M  ?x colM ?y frameRow  ?w frameWidth   ?h frameHeight  ?prompt frameOffset ?expand frameExpand)
NewField(g ?field frame_B  ?x colB ?y frameRow  ?w frameWidth   ?h frameHeight  ?prompt frameOffset ?expand frameExpand)
NewField(g ?field frame_D  ?x colA ?y moveRow+1 ?w frameWidth*3 ?h dframeHeight ?prompt frameOffset ?expand frameExpand)


;COL A
NewField(g ?field cyclic_typeFilter  ?x colA   ?y 1 ?w 2 ?h 1 ?prompt 90 )
NewField(g ?field cyclic_diffFilter  ?x colA+1 ?y 1 ?w 1 ?h 1 ?prompt 40 )

NewField(g ?field radio_startPoint  ?x colA ?y frameWidth ?w 3 ?h 1 ?prompt 100 )

NewField(g ?field textLib_A  ?x colA ?y lRow   ?w frameWidth ?h 1 ?prompt lcvOffset )
NewField(g ?field textCell_A ?x colA ?y lRow+1 ?w frameWidth ?h 1 ?prompt lcvOffset )
NewField(g ?field textView_A ?x colA ?y lRow+2 ?w frameWidth ?h 1 ?prompt lcvOffset )

NewField(g ?field button_browse_A ?x colA ?y lRow+3 ?w frameWidth ?h 1 )
NewField(g ?field button_open_A   ?x colA ?y lRow+4 ?w frameWidth ?h 1 )


NewField(g ?field rfield_A   ?x colA ?y reportRow ?w frameWidth ?h reportH ?prompt lcvOffset )

NewField(g ?field button_move_A   ?x colA ?y moveRow ?w frameWidth ?h 1 )

;COL M
NewField(g ?field button_recompute ?x colM ?y 1 ?w frameWidth ?h 1 )
NewField(g ?field button_highlight ?x colM ?y 2 ?w frameWidth ?h 1 )

NewField(g ?field rfield_M   ?x colM ?y lRow ?w frameWidth ?h reportH+(reportRow-lRow) ?prompt lcvOffset )

NewField(g ?field button_move_M   ?x colM ?y moveRow ?w frameWidth ?h 1 )


;COL B
NewField(g ?field toggle_editmode  ?x colB   ?y 1 ?w 1 ?h 1 ?prompt 80 )
NewField(g ?field toggle_autoZoom  ?x colB+1 ?y 1 ?w 1 ?h 1 ?prompt 80 )
NewField(g ?field toggle_netdiff   ?x colB   ?y 2 ?w 1 ?h 1 ?prompt 80 )

NewField(g ?field textLib_B  ?x colB ?y lRow   ?w frameWidth ?h 1 ?prompt lcvOffset )
NewField(g ?field textCell_B ?x colB ?y lRow+1 ?w frameWidth ?h 1 ?prompt lcvOffset )
NewField(g ?field textView_B ?x colB ?y lRow+2 ?w frameWidth ?h 1 ?prompt lcvOffset )

NewField(g ?field button_browse_B ?x colB ?y lRow+3 ?w frameWidth ?h 1 )
NewField(g ?field button_open_B   ?x colB ?y lRow+4 ?w frameWidth ?h 1 )

NewField(g ?field rfield_B   ?x colB ?y reportRow ?w frameWidth ?h reportH ?prompt lcvOffset )

NewField(g ?field button_move_B   ?x colB ?y moveRow ?w frameWidth ?h 1 )

;Frame D
NewField(g ?field text_D ?x colA ?y moveRow+2 ?w frameWidth*3 ?h dframeHeight-1 )


;################ FORM ##############

hiCreateAppForm(
      ?name 'GMergeGui_form
      ?formTitle form_title

      ?fields g->fields
      ?attachmentList g->attachmentList

      ?buttonLayout 'OKCancelApply
      ?formType 'nonOptions
      ?unmapAfterCB t
      ?initialSize  FormSize(g)
      ?minSize      FormSize(g)
      ?callback nil
      )

hiDisplayForm(GMergeGui_form)

);
