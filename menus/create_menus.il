;############# Create the Schematic Menus #############
procedure( CdsGitSchMenuTrigger(args)
   ;Create the menus lists if they don't exist
   unless(boundp('CdsGitSchMenu) && CdsGitSchMenu
      createCdsGitSchMenu()
   );unless

   ;TODO: Do not overwrite menu
   createCdsGitSchMenu()

   list(CdsGitSchMenu)
) ; procedure
deRegUserTriggers("schematic"       nil 'CdsGitSchMenuTrigger nil)
deRegUserTriggers("schematicSymbol" nil 'CdsGitSchMenuTrigger nil)


/* Unused
;############# Create the Layout Menus #############
procedure( CdsGitLayMenuTrigger(args)
   ;Create the menus lists if they don't exist
   unless(boundp('CdsGitLayMenu) && CdsGitLayMenu
      createCdsGitLayMenu()
   );unless
   createCdsGitLayMenu()

   ;return a list of the menus
   ;;PDK menu is created only if matching process is found
   list(CdsGitLayMenu)
) ; procedure
*/

;TODO-Do I need a seperate menu for layout/schematics?
deRegUserTriggers("maskLayout"       nil 'CdsGitSchMenuTrigger nil)
deRegUserTriggers("maskLayoutXL"     nil 'CdsGitSchMenuTrigger nil)
