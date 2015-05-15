/*
   Used to call a system command outside of GitShell
*/
procedure( CGsysCmd(sysCommand)

   verbose = t

   tmpFile = makeTempFileName("/tmp/cdsgit")

   sysCommand = strcat(sysCommand " &> " tmpFile)

   if(verbose && sysCommand printf("CMD\n%s\nCMDEND\n",sysCommand))

   exitStatus = system(sysCommand)

   if( exitStatus != 0 then
      error("CGsysCmd: system command failed, returned non-0")
   )

   response = CGsysCmdScanFile(tmpFile)

   if(verbose && response printf("EXITSTATUS=%L\nRESPONSE:\n%s\nRESPONSEEND\n",exitStatus,response))

   deleteFile(tmpFile)

   response

)


procedure( CGsysCmdScanFile( fin )
   response = ""
   str = t
   fin = infile(tmpFile)
   while(str
      gets(str fin)
      if(str then
         response = strcat(response str)
      )
   )
   response
)