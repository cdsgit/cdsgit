/*
   Setup paths for cdsgit
*/

if( 'boundp('cdsgit_path_set) then

   cdsgit_apps_dir = "/home/linear/git/lcbu-apps/"

   orig_path = getShellEnvVar("PATH")


   cdsgit_gui_command = "git-gui.sh"

   git_path = strcat(cdsgit_apps_dir "/git/bin:")
   git_gui_path = strcat(cdsgit_apps_dir "/git-gui:")
   git_cola_path = strcat(cdsgit_apps_dir "/git-cola:")
   tcl_path = strcat(cdsgit_apps_dir "/tcl/bin:")

   new_path = strcat(git_path git_gui_path git_cola_path tcl_path orig_path)

   setShellEnvVar("PATH" new_path)

   cdsgit_path_set = t

)