/*

LCBU env test

load("/home/acook/git/lcbu-skill/scripts/env/LCBUenvTest.il")
*/

procedure( TST_GitEnv()

;Store original values
lcbu_settings_path_orig          = lcbu_settings_path
lcbu_settings_path_template_orig = lcbu_settings_path_template

env_root_path = strcat(lcbu_path "/scripts/env")

lcbu_settings_path          = strcat(env_root_path "/test/user.env")
lcbu_user_settings_path     = strcat(env_root_path "/test/user.env.default")
lcbu_settings_path_template = strcat(lcbu_path     "/default.env")


lcbu_verbose = t
sstatus debugMode t


;###### SKILL PATH ######
if( !getShellEnvVar("LCBU_SKILL")  then
   setShellEnvVar("LCBU_SKILL=/home/linear/git/lcbu-skill")
);if

lcbu_path = getShellEnvVar("LCBU_SKILL")

;###### SETTINGS PATH ######
load(strcat(env_root_path "/LCBUenv.il"))
load(strcat(env_root_path "/LCBUenvCheck.il"))


;#####################################
;##############BEGIN TEST
;#####################################

testPrefix = "\n********************\nLCBUenvTest: "
testSufix  = "\n********************\n\n"
testPass   = "TEST PASSED - "
testFail   = "TEST FAILED - "

for(i 0 1
   if(i == 0 then
      ;Delete the current settings
      system(strcat("rm " lcbu_settings_path))
   )

   if(i ==1 then
      ;Create a scratch version of the user env
      system(strcat("cp " lcbu_user_settings_path " " lcbu_settings_path))
   )

;CHECK ENV
   testName = "Checking ENV"
   testEnv = LCBUenvCheck()
   if( i == 0 && !testEnv || i == 1 && testEnv then
      error(strcat(testPrefix testFail testName testSufix))
   else
      printf(strcat(testPrefix testPass testName testSufix))
   )

;GET VALID ENV
   testName = "Getting Valid ENV"
   LCBUenvGetVar("LCBU_LIB_PATH")
   printf(strcat(testPrefix testPass testName testSufix))

;GET INVALID ENV
   testName = "Getting Invalid ENV"
   success = errset(LCBUenvGetVar("LCBUasdf"))
   if(success then
      error(strcat(testPrefix testFail testName testSufix))
   else
      printf(strcat(testPrefix testPass testName testSufix))
   )

;SET VALID ENV



   testName = "Set Valid ENV"

   testVar   = "LCBU_SKILL"
   testValue = "JUNK"

   LCBUenvSetVar(testVar testValue);

   ;Write a couple more random things
   LCBUenvSetVar("LCBU_SKILL" "COOL1");
   LCBUenvSetVar("LCBU_LIB_PATH" "MORE1");

   ;Check that the ENV got set
   returnedValue = LCBUenvGetVar(testVar)

   ;Set the ENV again
   modified = LCBUenvSetVar(testVar testValue);

   if(testValue != returnedValue && !modified then
      error(strcat(testPrefix testFail testName " Set: " testValue " Returned: " returnedValue testSufix))
   else
      printf(strcat(testPrefix testPass testName testSufix))
   )


;SET INVALID ENV
   testName = "Set Invalid ENV"
   success = errset(LCBUenvSetVar("ASDF" "JUNK"));
   if(success then
      error(strcat(testPrefix testFail testName testSufix))
   else
      printf(strcat(testPrefix testPass testName testSufix))
   )

;SET VALID ENV SHELL
   testName = "Set Valid ENV Shell"
   LCBUenvSetShellVar("LCBU_LIB_PATH")
   printf(strcat(testPrefix testPass testName testSufix))

;SET INVALID ENV SHELL
   testName = "Set Invalid ENV Shell"
   success = errset(LCBUenvSetShellVar("LCBUasdf"));
   if(success then
      error(strcat(testPrefix testFail testName testSufix))
   else
      printf(strcat(testPrefix testPass testName testSufix))
   )


);




;Set back original values
lcbu_settings_path          = lcbu_settings_path_orig
lcbu_settings_path_template = lcbu_settings_path_template_orig

);procedure