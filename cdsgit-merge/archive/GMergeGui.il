/*

Aaron Cook
11/2/2013

Gui to merge schematics/symbols/layouts

load("/home/acook/git/lcbu-skill/scripts/git/merge/GMergeGui.il")


TODO:

   Consider using tree table instead of report form
   CCSListBoxForm.il in examples has some nice stuff

*/

procedure( GMergeGui( @key (cvid_A nil) (cvid_B nil) )


;#### PRECONDITION #####
;Genearte GMG_master_data


;#### TITLE #####
form_title = "Merge GUI"

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
textLib_A  = hiCreateStringField( ?name 'textLib_A  ?prompt "Library" ?defValue textLib_A_value  ?editable t)
textCell_A = hiCreateStringField( ?name 'textCell_A ?prompt "Cell"    ?defValue textCell_A_value ?editable t)
textView_A = hiCreateStringField( ?name 'textView_A ?prompt "View"    ?defValue textView_A_value ?editable t)
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

;Filter
filter_startx = 20
filter_starty = 0
filter_width = 300
filter_height = 30
filter_label_offset = 80

;Diff style
diff_startx = filter_startx
diff_starty = filter_height + filter_starty
diff_width  = 300
diff_height = 30
diff_label_offset = 80


frame_starty   = diff_starty + diff_height
frame_width    = 300
frame_spacing  = 5
;frame height defined last

;LCV
lcv_starty = frame_starty + 20
lcv_startx = 20
lcv_yspace = 0
lcv_width  = 300-40
lcv_height = 30
lcv_label_offset = 80
lcv_totaly = 5*lcv_height + 10

frame_height   = 300 + lcv_totaly

;frames
frameA_startx = frame_spacing
frameM_startx = 2*frame_spacing+frame_width
frameB_startx = 3*frame_spacing+frame_width*2

;move button
mbutton_height = 30
mbutton_width  = frame_width-10
mbutton_starty = frame_starty+frame_height-30-15
mbutton_startx = 5

;report fieldHINTS
rfield_height = 200
rfield_width  = frame_width-10
rfield_starty = frame_starty+20 + lcv_totaly
rfield_startx = 5

;details frame
frameD_startx = frame_spacing
frameD_starty = frame_starty+frame_height +frame_spacing
frameD_width = frame_width * 3
frameD_height = 130

textD_spacing = 5
textD_yoffset = 15
textD_startx = frameD_startx + textD_spacing
textD_starty = frameD_starty + textD_spacing + textD_yoffset
textD_width  = frameD_width - 2*textD_spacing
textD_height  = frameD_height - 2*textD_spacing - textD_yoffset


;Check boxes
cb_width  = frame_width/2 - frame_spacing
cb_height = filter_height
cb_starty = filter_starty
cb_xcol1 = frameB_startx + frame_spacing
cb_xcol2 = cb_xcol1 + cb_width
cb_label_offset = 80

;################ FORM ##############

hiCreateAppForm(
		?name 'GMergeGui_form
		?formTitle form_title

      ;Fiels = list(item xstart:ystart width:height offset)

		?fields list(

            ;Frames
            list(frame_A frameA_startx:frame_starty  frame_width:frame_height 15 )
			   list(frame_M frameM_startx:frame_starty  frame_width:frame_height 15 )
            list(frame_B frameB_startx:frame_starty  frame_width:frame_height 15 )
            list(frame_D frameD_startx:frameD_starty  frameD_width:frameD_height 15 )

            ;MISC
            list(cyclic_typeFilter filter_startx:filter_starty  filter_width:filter_height filter_label_offset )
            list(cyclic_diffFilter filter_startx+150:filter_starty  filter_width:filter_height 30 )
            list(button_recompute   frameM_startx:filter_starty  filter_width:filter_height filter_label_offset )
            list(button_highlight   frameM_startx:filter_starty+30  filter_width:filter_height filter_label_offset )

            list(toggle_editmode    cb_xcol1:cb_starty            cb_width:cb_height cb_label_offset )
            list(toggle_autoZoom    cb_xcol1:cb_starty+cb_height  cb_width:cb_height cb_label_offset )
            list(toggle_netdiff     cb_xcol2:cb_starty            cb_width:cb_height cb_label_offset )


            list(radio_startPoint   diff_startx:diff_starty      diff_width:diff_height     diff_label_offset )


            ;FRAME A
            list(textLib_A        frameA_startx+lcv_startx:lcv_starty                            lcv_width:lcv_height  lcv_label_offset)
            list(textCell_A       frameA_startx+lcv_startx:lcv_starty+lcv_height+lcv_yspace      lcv_width:lcv_height  lcv_label_offset)
            list(textView_A       frameA_startx+lcv_startx:lcv_starty+2*lcv_height+2*lcv_yspace  lcv_width:lcv_height  lcv_label_offset)
            list(button_browse_A  frameA_startx+lcv_startx:lcv_starty+3*lcv_height+3*lcv_yspace  lcv_width:lcv_height  0)
            list(button_open_A    frameA_startx+lcv_startx:lcv_starty+4*lcv_height+4*lcv_yspace  lcv_width:lcv_height  0)


            list(button_move_A  frameA_startx+mbutton_startx:mbutton_starty  mbutton_width:mbutton_height )
            list(rfield_A       frameA_startx+rfield_startx:rfield_starty    rfield_width:rfield_height   )

            ;FRAME M
            list(rfield_M       frameM_startx+rfield_startx:lcv_starty    rfield_width:rfield_height+(rfield_starty-lcv_starty)   )
            list(button_move_M  frameM_startx+mbutton_startx:mbutton_starty  mbutton_width:mbutton_height )

            ;FRAME B
            list(textLib_B        frameB_startx+lcv_startx:lcv_starty                            lcv_width:lcv_height  lcv_label_offset)
            list(textCell_B       frameB_startx+lcv_startx:lcv_starty+lcv_height+lcv_yspace      lcv_width:lcv_height  lcv_label_offset)
            list(textView_B       frameB_startx+lcv_startx:lcv_starty+2*lcv_height+2*lcv_yspace  lcv_width:lcv_height  lcv_label_offset)
            list(button_browse_B  frameB_startx+lcv_startx:lcv_starty+3*lcv_height+3*lcv_yspace  lcv_width:lcv_height  0)
            list(button_open_B    frameB_startx+lcv_startx:lcv_starty+4*lcv_height+4*lcv_yspace  lcv_width:lcv_height  0)

            list(button_move_B  frameB_startx+mbutton_startx:mbutton_starty  mbutton_width:mbutton_height )
            list(rfield_B       frameB_startx+rfield_startx:rfield_starty    rfield_width:rfield_height   )

            ;FRAME D
            list(text_D textD_startx:textD_starty  textD_width:textD_height 15 )


		   )
		?buttonLayout 'OKCancelApply
		?formType 'nonOptions
		?unmapAfterCB t
		?initialSize t
		;?callback list( "Cleanup(GMdiffPairObj)" "Cleanup(GMdiffPairObj)" "Cleanup(GMdiffPairObj)")
		)

;#### UPDATE REPORT VALUES #####
GMG_computeDiff(?showDialog nil)

hiDisplayForm(GMergeGui_form)

Cleanup(GMdiffPairObj)

);
