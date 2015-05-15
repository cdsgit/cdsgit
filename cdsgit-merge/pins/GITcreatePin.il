; SKILL to create and place the pins on the insterms in a schematic
; CCS 11158496

procedure( GITcreatePin(cvid refPin)

ip = dbOpenCellViewByType(  "basic" "ipin"  "symbol" "" "r")
op = dbOpenCellViewByType(  "basic" "opin"  "symbol" "" "r")
iop = dbOpenCellViewByType( "basic" "iopin" "symbol" "" "r")

;Use the GMschPin class to get pin properties
refPinObj = makeInstance( 'GMschPin ?obj refPin )

case(refPin->direction
   ("input"
      dir = ip
   )
   ("output"
      dir = op
   )
   ("inputOutput"
      dir = iop
   )
)

pFig = car(refPin->figs)

pLocation    = Location(refPinObj)
pDirection   = Direction(refPinObj)
pOrientation = Orientation(refPinObj)

/*
schCreatePin(
d_cvId
d_master
t_termName
t_direction
g_offSheetP
l_origin
t_orientation
[g_powerSens]
[g_groundSens]
[g_sigType]
)
*/

schCreatePin(
   cvid
   dir
   refPin->name
   refPin->direction
   nil
   pLocation
   pOrientation
)

);procedure