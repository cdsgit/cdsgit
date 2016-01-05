/*
Main CdsGit file.
Load this file in your .cdsinit

*/


;###ENV INITIALIZATION#######


;###### SKILL PATH ######
cdsgit_path = getShellEnvVar("CDSGIT_PATH")

printf("********************************************************\n")
printf(strcat("CdsGit - Loading SKILL\n"))
printf("********************************************************\n")


;### DEBUG ONLY ##########

hiSetBindKey("Command Interpreter" "<Key>F11" "load(\".cdsinit\")")

;###### BINARY PATHS ######
loadi(strcat(cdsgit_path "/load_paths.il"))

;### SCRIPT INITIALIZATION ##########

cdsGitAppName = "CdsGit"

cdsgit_userenvpath = "~/.cdsgitenv"

CGcoolPath = "~/.cdsgitLicense"
load(strcat(cdsgit_path "/scripts/commands/CGsysCmd.il"))
load(strcat(cdsgit_path "/scripts/commands/CGcool.il"))


;############# Unlicensed Commands #############
load(strcat(cdsgit_path "/forms/CGregister.il"))
load(strcat(cdsgit_path "/menus/ciw.menu"))


;############# CdsGit Shell #############
cdsgit_gs_path = strcat(cdsgit_path "/cdsgit-shell")
loadi(strcat(cdsgit_path "/cdsgit-shell/load.il"))

;############# CdsGit Env #############
cdsgit_ge_path = strcat(cdsgit_path "/cdsgit-env")
loadi(strcat(cdsgit_ge_path "/load.il"))

;############# Scripts #############
loadi(strcat(cdsgit_path "/scripts/load.il"))

;############# Form #############
loadi(strcat(cdsgit_path "/cdsgit-forms/load.il"))
loadi(strcat(cdsgit_path "/forms/load.il"))


;############# Merge #############
loadi(strcat(cdsgit_path "/cdsgit-merge/load.il"))

;############# Triggers #############
loadi(strcat(cdsgit_path "/triggers/load.il"))


/* TODO add in other stuff
;############# Custom DRF loading #############
loadi(strcat(cdsgit_path "/load_drf.il"))

;############# Bindkeys #############
loadi(strcat(cdsgit_path "/load_bindkeys.il"))

;############# Triggers #############
loadi(strcat(cdsgit_path "/load_triggers.il"))

;############# Cadence Env Variables #############
loadi(strcat(cdsgit_path "/load_env.il"))
*/

;############# Menus #############
loadi(strcat(cdsgit_path "/menus/load.il"))

printf("********************************************************\n")
printf(strcat("CdsGit - Done Loading SKILL\n"))
printf("********************************************************\n")

