
procedure(CGsaveTrigger(args)

   cdsgit_png_size = 800

   cellName = args->cellName
   libName  = args->libName
   viewName = args->viewName

   printf("CdsGit CGsaveTrigger(): Creating png of cell\n")

   ;Create png
   if(
      args->cellViewType == "schematicSymbol" ||
      args->cellViewType == "maskLayout" ||
      args->cellViewType == "schematic"
      then

      ;Create the ams netlist
      hiGenerateThumbnails(?lib libName ?cell cellName ?view viewName
         ?sizes cdsgit_png_size ?verbose t)
   )

)


/* OLD stuff

if( args->cellViewType == "schematic" then
   printf("Running schematic post save trigger - Generate vams netlist\n")

   ;Create the ams netlist
   ;envSetVal("amsDirect.vlog" "allowDeviantBuses" `cyclic "warn")
   ;amsNetlist( libName cellName viewName ?netlist t)
);

schRegPostCheckTrigger('GITcheckTrigger)
;dbRegPostSaveTrigger('GITsaveTrigger)


*/