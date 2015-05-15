

procedure( CGcool()

let( (startDate endDate company cool_actual actual actual_parsed genCmd ideal getCmd)

   cool = nil

   ideal  = nil
   actual = nil
   cool   = nil

   coolVerbose = nil

   currentDate = CGsysCmd("date +%y%m%d")

   getCmd = strcat( "cat " CGcoolPath)

   if( isFile(CGcoolPath) then
      actual = CGsysCmd(getCmd)
      actual = nthelem(1 parseString(actual))

      actual_parsed = parseString(actual "-")

      if( length(actual_parsed)==4 then

         startDate = nthelem(1 actual_parsed)
         endDate   = nthelem(2 actual_parsed)
         company   = nthelem(3 actual_parsed)

         actual = car( parseString(nthelem(4 actual_parsed)))

         if(coolVerbose printf("%L\n%L\n%L\n%L" startDate endDate company actual))

         genCmd = sprintf(nil "echo $user \"CdsGit1234\" %s %s %s | sha1sum -" startDate endDate company)
         ideal  = CGsysCmd(genCmd)

         ideal = nthelem(1 parseString(ideal))
      )
   )


   if(coolVerbose printf("actual-%L\nideal-%L\n" ideal actual))

   if( ideal && actual && (ideal == actual) then
      ;Convert date to number
      startDate   = atoi(startDate)
      endDate     = atoi(endDate)
      currentDate = atoi(currentDate)

      if(coolVerbose printf("s-%L\ne-%L\nc-%L\n" startDate endDate currentDate))

      if( startDate && endDate && currentDate then
         if( currentDate >= startDate && currentDate <= endDate then
            cool = t
         )
      )
   )

   if( !cool then
      hiDisplayAppDBox(?name 'gitLicenseWarn
            ?dboxBanner "CdsGit License Warning"
            ?dboxText sprintf(nil "Your Copy of CdsGit is not Licensed\nPlease enter your Registration Code!")
            ?buttonLayout 'Close
            ;?dialogStyle 'modeless
         )
   )

   cool


);let
);procedure
