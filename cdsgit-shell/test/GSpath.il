   /*

   loadi(strcat(cdsgit_gs_path "/test/GSpath.il"))


   */


procedure( TST_GSpath()

   ;(list(path rev loop))
   testpaths = list(

      ;Forward
      list( "asdf/1234/asdf" nil 1)
      list( "/asdf/1234/asdf"  nil 1)
      list( "/asdf/1234/asdf/"  nil 1)
      list( "asdf"  nil 1)

      ;Rev
      list( "asdf/1234/asdf" t 1)
      list( "/asdf/1234/asdf"  t 1)
      list( "/asdf/1234/asdf/"  t 1)
      list( "asdf"  t 1)

      ;Loop
      list( "asdf/1234/mnvb/ghkghk" t 2)
      list( "asdf/1234/mnvb/ghkghk" t 3)
      list( "asdf/1234/mnvb/ghkghk" t 10)


   )

   pathexpected = list(
      "1234/asdf"
      "asdf/1234/asdf"
      "asdf/1234/asdf/"
      ""

      "asdf/1234"
      "/asdf/1234"
      "/asdf/1234/asdf"
      ""

      "asdf/1234"
      "asdf"
      ""

   )
   depthexpected = list(
      1
      2
      3
      0

      1
      2
      3
      0

      1
      0
      0
   )



   i = 1
   foreach(pathList testpaths

      path = nthelem(1 pathList)
      reverse = nthelem(2 pathList)
      loop = nthelem(3 pathList)

      allpassed = t

      gsp = GSpath(path)
      result=Trim(gsp ?reverse reverse ?loop loop)
      depth = Depth(gsp)

      pexpected = nthelem(i pathexpected)
      dexpected = nthelem(i depthexpected)

      if(result != pexpected && depth != dexpected then
         printf("TEST FAILED\nSent-%s\nExpected-%s\nReturned-%s Depthexpected %L Depth %L\n" path pexpected result dexpected depth)
         allpassed = nil
      else
         printf("TEST PASSED\n\tSent-%s\n\tLoop-%d\n\tReturned-%s\n\tDepth-%L\n" path loop result depth)
      )
      i = i+1
   )

   if(allpassed then
      printf("GSpath all passed\n")
   else
      error("GSpath Failed")
   )

)

procedure( TST_GSpath_IsCadence()

   searchdirs = list(
      "/home/acook/cliosoft/1335/cadence/1335/cdsinfo.tag"
      "/home/acook/cliosoft/1335/cadence/1335/1335/schematic/sch.oa"
      "/home/acook/cliosoft/1335/cadence/verilogIn.log"
      "/home/acook/cliosoft/1335/cadence/somjunkpath//"
   )

   expectedresult = list(
      t
      t
      nil
      nil
   )
   i=1
   allpassed = t
   foreach(path searchdirs
      gs = GitShell(?path path)
      gsp = GSpath(path ?gs gs)

      result = IsCadence(gsp)
      expected = nthelem(i expectedresult)

      if(result != expected then
         printf("TEST FAILED\nSent-%s\nExpected-%L\nReturned-%L\n"  path expected result)
         allpassed = nil
      else
         printf("TEST PASSED\n\tSent-%s\n\tReturned-%L\n" path result )
      )
      i = i+1

   )

   if(allpassed then
      printf("GSpath all passed\n")
   else
      error("GSpath Failed")
   )
)

procedure( TST_GSpath_DepthFromPath()

   dirLlist = list(
      "/home/acook/cliosoft/1335/"
      "/home/acook/cliosoft/1335/"
      "/home/acook///"
      "/home/acook///"
      "asdf/asdf"
      ""
      "asdf/asdf"
   )
   dirRlist = list(
      "1335/asdf.txt"
      "1234/asdf.txt"
      "/home/acook/cliosoft/1335/cadence/1335/1335/schematic/sch.oa"
      "/home/acook/cliosoft/1335/cadence/verilogIn.log"
      "asdf/asdf.txt"
      "asdf/asdf.txt"
      "asdf/asdf"
   )

   expectedresult = list(
      1
      1
      7
      4
      0
      1
      0
   )

   allpassed = t
   for(i 1 length(dirLlist)

      dirL = nthelem(i dirLlist)
      dirR = nthelem(i dirRlist)

      gs = GitShell(?path dirL)
      gsp = GSpath(dirR ?gs gs)

      result = DepthFromPath(gsp)

      expected = nthelem(i expectedresult)

      if(result != expected then
         printf("TEST FAILED\ndirL-%s\ndirR-%s\nExpected-%L\nReturned-%L\n"  dirL dirR expected result)
         allpassed = nil
      else
         printf("TEST PASSED\n\tdirL-%s\n\tdirR-%s\n\tReturned-%L\n" dirL dirR result )
      )

   )

   if(allpassed then
      printf("GSpath all passed\n")
   else
      error("GSpath Failed")
   )



)

procedure( TST_GSpath_IsInPath()

   dirLlist = list(
      "/home/acook/git"
      "/asdf/asdf/asdf"
      "/1234/asdf"
      "/1234/asdf1"
   )
   dirRlist = list(
      "/home/acook/git/fgj.tret"
      "/asdf/asdf"
      "/1234/asdf"
      "/1234/asdf/asdf"
   )

   expectedresult = list(
      t
      nil
      t
      nil
   )

   allpassed = t
   for(i 1 length(dirLlist)

      dirL = nthelem(i dirLlist)
      dirR = nthelem(i dirRlist)

      gs = GSpath( dirR )

      result = IsInPath(gs dirL)

      expected = nthelem(i expectedresult)

      if(result != expected then
         printf("TEST FAILED\ndirL-%s\ndirR-%s\nExpected-%L\nReturned-%L\n"  dirL dirR expected result)
         allpassed = nil
      else
         printf("TEST PASSED\n\tdirL-%s\n\tdirR-%s\n\tReturned-%L\n" dirL dirR result )
      )

   )

   if(allpassed then
      printf("GSpath all passed\n")
   else
      error("GSpath Failed")
   )



)