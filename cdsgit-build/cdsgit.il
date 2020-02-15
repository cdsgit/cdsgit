






cdsgit_path = getShellEnvVar("CDSGIT_PATH")




hiSetBindKey("Command Interpreter" "<Key>F11" "load(\".cdsinit\")")




cdsGitAppName = "CdsGit"

cdsgit_userenvpath = "~/.cdsgitenv"

CGcoolPath = "~/.cdsgitLicense"

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
            
         )
   )

   cool


)
)

procedure( CGregisterForm()

   s_registration   = hiCreateStringField(  ?name    's_registration
            ?prompt     "Registration Code"
            ?value      ""
   )

   cgregister_form = hiCreateAppForm(
               ?name 'cgregister_form
               ?formTitle "Register CdsGit"
               ?callback  "CGregisterFormCB()"
               ?fields        list(
                                 list(s_registration 10:10 600:100 120)
                              )
               ?buttonLayout  'OKCancelApply
               ?dontBlock     nil
         )

   hiDisplayForm(cgregister_form)


)

procedure( CGregisterFormCB()
   cgregister_code = cgregister_form->s_registration->value

   fout = outfile(CGcoolPath "w")
   fprintf(fout "%s\n" cgregister_code)
   close(fout)

   printf("Registration Code Set to %s\n" cgregister_code)
)

procedure( CGciwMenu()

   ciwMenuInit()

   hiCreateMenu(
         'cdsgitMenu
         "CdsGit"
         list(
            hiCreateMenuItem(?name 'gititem1 ?itemText "Register"             ?callback "CGregisterForm()")
         )
   )

  
   menus = hiGetBannerMenus( hiGetCIWindow() )
   alreadyOnBanner = nil

   ismember=member('cdsgitMenu menus)
   if(length(ismember) > 0 then
     alreadyOnBanner = t
     menuPosition=hiGetNumMenus(hiGetCIWindow())-length(ismember)
   )

   if( alreadyOnBanner == t
    then
      hiDeleteBannerMenu( hiGetCIWindow() menuPosition )
   )

   ismember=member('gitMenu menus)
   if(length(ismember) > 0 then
     alreadyOnBanner = t
     menuPosition=hiGetNumMenus(hiGetCIWindow())-length(ismember)
   )

   if( alreadyOnBanner == t
    then
      hiDeleteBannerMenu( hiGetCIWindow() menuPosition )
   )

   numMenus = hiGetNumMenus( hiGetCIWindow() )
   hiInsertBannerMenu( hiGetCIWindow() 'cdsgitMenu numMenus )

)

CGciwMenu()



cdsgit_gs_path = strcat(cdsgit_path "/cdsgit-shell")
defclass( GitShell

   ()
   (
      (name     @initform nil @initarg name) 
      (path     @initform nil @initarg path) 
      (pathOrig @initform nil @initarg path) 
      (dd       @initform nil @initarg dd)   
      (paths    @initform list() )           
      (libList  @initform nil )              

      
      (libName  @initform "")
      (cellName @initform "")
      (viewName @initform "")

      
      (verbose  @initform t   @initarg verbose) 
      (silent   @initform nil @initarg silent)  

      
      (valid    @initform nil ) 
      (clean    @initform nil ) 
      (root     @initform nil ) 
      (url      @initform nil @initarg url ) 
      (depth    @initform nil ) 
      (filter       @initform nil ) 
      (ideal_filter @initform 3   ) 

      
      (response   @initform nil)
      (lastCmd    @initform nil)
      (exitStatus @initform nil)
      (sysErr     @initform nil)

      
      (staged     @initform nil)
      (unstaged   @initform nil)
      (conflicted @initform nil)
      (revision   @initform nil)

      
      (branch   @initform nil)
      (branches @initform nil)

   )

)









procedure( GitShell( @key (path nil) (name nil) (dd nil) (silent t) (url nil) (skipRoot nil) (skipCheck nil) )

   if(!path then
      error("Must provide a path to GitShell")
   )

   gs = makeInstance( 'GitShell ?path path ?name name ?dd dd ?silent silent ?url url)

   
   gs->pathOrig = path

   if(dd then
      if(gs->verbose printf("GitShell: dd type-%L\n" dd->type))
   )
   Depth(gs)

   
   if( !skipCheck then
      Check(gs)
   else
      gs->valid = nil
   )

   
   if( gs->valid && !skipRoot then
      Root(gs)
   )


   
   GetLibs(gs)

   gs

)

defclass( GSstr
   ()
   (
      (str    @initform nil @initarg str)
      (length @initform nil)
   )
)

procedure( GSstr(str)

   gss = makeInstance( 'GSstr ?str str)

)


defmethod( ReverseCG (( gss GSstr))

   resultStr=""
   len = LengthCG(gss)

   for(i 1 len
      resultStr = strcat(resultStr GetChar(gss len-(i-1)) )
   )
   gss->str = resultStr

   resultStr
)


defmethod( LengthCG (( gss GSstr))
   len = strlen(gss->str)
   gss->length = len
   len
)

defmethod( GetChar (( gss GSstr) index @key (str nil) )

   if( !str str = gss->str)

   if( index <1            error("GSstr GetChar: index must be > 0") )
   if( index > strlen(str) error("GSstr GetChar: String length exceeded") )
   if( !str                error("GSstr GetChar: str is nil") )

   if(!getchar(str index) break())
   c = sprintf(nil "%s" getchar(str index) )
   c
)


defmethod( StripCG (( gss GSstr ) @key (str_begin t) (str_end t) (rexStr " \t\n") )

   str = gss->str

   if( str_begin then
      rexObj = rexCompile( strcat("^[" rexStr "]*") )
      str = rexReplace( str "" 0)
   )
   if( str_end then
      rexObj = rexCompile( strcat("[" rexStr "]*$") )
      str = rexReplace( str "" 0)
   )
   gss->str = str

   str
)
defclass( GSpath
   ( GSstr )
   (
      (depth          @initform nil )
      (indexStatus    @initform nil @initarg indexStatus )
      (treeStatus     @initform nil @initarg treeStatus  )
      (conflictStatus @initform nil )
      (status         @initform ""  )
      (gs             @initform nil @initarg gs          ) 
      (verbose        @initform nil )
      (isFile         @initform nil @initarg isFile ) 
      (isDir          @initform nil @initarg isDir  ) 
      (valid          @initform nil )
      (libPath        @initform nil )
      (libDepth       @initform nil )
      (pathDepth      @initform nil )
   )
)


procedure( GSpath(str @key (indexStatus nil) (treeStatus nil) (gs nil) )

   newGsp = makeInstance( 'GSpath
      ?str str
      ?indexStatus    indexStatus
      ?treeStatus     treeStatus
      ?gs gs
   )

   TypeCG(newGsp)

   newGsp

)


defmethod( CloneCG ((gsp GSpath) @key (str gsp->str) )

   gsp_clone = GSpath( str
      ?indexStatus gsp->indexStatus
      ?treeStatus gsp->treeStatus
      ?gs gsp->gs
   )

   gsp_clone->libDepth  = gsp->libDepth
   gsp_clone->pathDepth = gsp->pathDepth
   gsp_clone->libPath   = gsp->libPath
   gsp_clone->verbose   = gsp->verbose
   gsp_clone->depth     = gsp->depth

   TypeCG(gsp_clone)

   gsp_clone
)

let(
()


defmethod( Trim (( gsp GSpath ) @key (loop 1) (reverse t))

   
   

   if(reverse ReverseCG(gsp) )

   for(i 1 loop
      resultStr = trimHelper(gsp)
   )

   if(reverse ReverseCG(gsp) )

   gsp->str
)




procedure( trimHelper(gsp)

   strVerbose = nil

   seperator = "/"

   resultStr = ""

   len = LengthCG(gsp)

   found = nil

   for( cindex 1 len
      c = GetChar(gsp cindex)

      if(strVerbose printf("%s %s %L %L\n" c seperator c==seperator found))

      cond(
         ( !found && c==seperator
            found= t
         )
         ( found
            resultStr = strcat(resultStr c)
         )
      )

   )
   gsp->str = resultStr

)

)

defmethod( Depth (( gsp GSpath))

   depth = 0
   clast = ""

   len = LengthCG(gsp)

   for( cindex 1 len
      c = GetChar(gsp cindex)
      if( c=="/" && clast!="/" depth = depth+1)
      clast = c
   )

   gsp->depth = depth

   depth
)

defmethod( IsCadence (( gsp GSpath ))

   
   tmp_gsp = GSpath(gsp->str)

   rootdir = Trim(tmp_gsp)

   
   if( isDir(rootdir) then
      syscmd = strcat("find " rootdir " -maxdepth 3 -name master.tag -print -quit")
      response = Cmd(gsp->gs syscmd)
   else
      response = nil
   )

   result = nil
   if(response && response != ""
      result = t
   )

   result

)

defmethod( ToList (( gsp GSpath))

   list(gsp->indexStatus gsp->treeStatus gsp->str gsp->conflictStatus)

)



defmethod( DepthFromPath ((  gsp GSpath  ))

   gspL = GSpath(gsp->gs->path)
   gspR = gsp

   if( gspL && gspL != "" && gspR && gspR != "" then
      resultStr=Convolve(gspR gspL)
      if( gsp->verbose printf("\tResult %s\n" resultStr) )
      depth = Depth(GSpath(resultStr))
   else
      depth = Depth(gsp)
   )
)



defmethod( Convolve (( gspR GSpath ) gspL )
let( (i)
   strL  = gspL
   strR  = gspR

   if( GetChar(strL 1)!="/" || GetChar(strR 1) == "/" then
      error("GSpath Convolve: strL must be a full path, strR must be a relative path\nstrL%L strR%L" strL strR)
   )

   

   if(gsp->verbose printf("String Convolve\n\tstrL-%s\n\tstrR-%s\n" strL->str strR->str) )

   lenL = LengthCG(strL)
   lenR = LengthCG(strR)


   
   
   
   if(lenR > lenL then
      i = lenR-lenL+1
   else
      i=1
   )
   fullmatch = nil

   if( gsp->verbose printf("\tlenL-%d lenR-%d\n" lenL lenR) )

   while( !fullmatch && i<=lenR

      
      if(lenL < lenR-(i-1) then
         lenj = lenL
      else
         lenj = lenR-(i-1)
      )

      j=1
      fullmatch = t
      while( fullmatch && j<=lenj

         cA = GetChar(strL lenL-(j-1) )
         cB = GetChar(strR lenR-(i-1)-(j-1))
         if( gsp->verbose printf("\t\ti-%d j-%d lenj-%d cA-%s cB-%s\n" i j lenj cA cB) )
         if(cA != cB then
            fullmatch = nil
         else
            j=j+1
         )
      )


      if( fullmatch then
         matchIndex = lenR-(i-2)
      else
         i=i+1
      )
   )

   if( !fullmatch then
      result = strR->str
   else
      result = substring(strR->str matchIndex)
      if( matchIndex > lenR then
         result = ""
      )
   )

   result = GSpath(result)
)
)

defmethod( Subtract (( gsp GSpath ) gspS )

if( GetChar(gsp 1)!="/" || GetChar(ogsp 1) !="/" then
   error("GSpath Subtract: Paths not be relative\nPath-%s OtherPath-%s" gsp->str gspS->str)
)
if( LengthCG(gsp) < LengthCG(gspS) then
   error("GSpath Subtract: Paths not be relative\nPath-%s OtherPath-%s" gsp->str gspS->str)
)

if( !IsInPath(gsp gspS)
      error("GSpath Subtract: One path must be a subdirectory of the other\nPath-%s OtherPath-%s" gsp->str gspS->str)
)

if(  LengthCG(gsp) > LengthCG(gspS) then
   tmpStr = substring( gsp->str LengthCG(gspS)+1 )
else
   tmpStr = ""
)

resultPath = GSpath( tmpStr )
resultPath

)

defmethod( TypeCG ((gsp GSpath))

      gsp->isDir  = isDir(gsp->str)
      gsp->isFile = isFile(gsp->str)

      if( gsp->isDir || gsp->isFile then
         gsp->valid = t
      else
         gsp->valid = nil
      )
      if( gsp->isDir && gsp->isFile then
         error("GSpath Type: Path %s is a file and directory! How can this be?!?!" gsp->str)
      )
)


defmethod( IsInPath (( gsp GSpath) otherPath)

ogsp = nil

if( classp( otherPath 'GSpath ) then
   ogsp = otherPath
else
   ogsp = GSpath(otherPath)
)


if( GetChar(gsp 1)!="/" || GetChar(ogsp 1) !="/" then
   error("GSpath IsInPath: Paths not be relative\nPath-%s OtherPath-%s" gsp->str otherPath->str)
)

matched = nil
if( LengthCG(gsp) < LengthCG(ogsp) then
   matched = nil
else

   matched = t
   for(i 1 LengthCG(ogsp)

      cho = GetChar(ogsp i)
      chi = GetChar(gsp i)

      if( cho != chi then
         matched = nil
      )

   )
)

if( gsp->verbose then
   printf("\tGSpath IsInPath: %L %s is in %s\n" matched gsp->str ogsp->str )
)

matched

)

defmethod( FullPath ((  gsp GSpath  ))

   if( !gsp->gs then
      error("GSpath FullPath: gs object required")
   )

   fullStr = strcat(gsp->gs->root->str "/" gsp->str)
   fullGsp = CloneCG(gsp ?str fullStr)
   fullGsp
)

defmethod( GetLib (( gsp GSpath ) )

   if( gsp->gs then
      fullPath = FullPath( gsp )

      foreach( lib gsp->gs->libList
         if( IsInPath( fullPath lib) then
            gsp->libPath = lib
         )
      )
   else
      gsp->libPath = nil
   )

   if( gsp->libPath then

      gsp->libDepth = Depth(Subtract(gsp->libPath gsp->gs->root))

      
      dbPath = Convolve(gsp gsp->libPath)
      gsp->pathDepth = Depth(dbPath)

   )

   
   
   if( !gsp->libPath then
      gsp->libDepth  = 0
      gsp->pathDepth = 0
      gsp->libPath   = GSpath("")
   )

)



defmethod( ErrorCG (( gs GitShell ) errStr)


   hiDisplayAppDBox(?name 'gitShellErrorForm
      ?dboxBanner "CdsGit GitShell Error"
      ?dboxText errStr
      ?buttonLayout 'Close
      
   )

   error(sprintf(nil "Error GitShell: %s" errStr))

)


defmethod( Info (( gs GitShell ) infoStr)


   hiDisplayAppDBox(?name 'gitShellInfoForm
      ?dboxBanner "CdsGit GitShell Info"
      ?dboxText infoStr
      ?buttonLayout 'Close
      
   )

)


defmethod( Dialog (( gs GitShell ) infoStr)

   response = hiDisplayAppDBox(?name 'gitShellInfoForm
      ?dboxBanner "CdsGit GitShell Prompt"
      ?dboxText infoStr
      ?buttonLayout 'UserDefined
      ?buttons list("Yes" "No")
      ?callback list(nil nil)
      
   )

   if(response == 1 then
      response = t
   else
      response = nil
   )

)

defmethod( Depth (( gs GitShell ))


   if( gs->dd then
      case( gs->dd->type
         ('ddLibType
            gs->depth = "Library"
            gs->ideal_filter = 3
         )
         ('ddCellType
            gs->depth = "Cell"
            gs->ideal_filter = 2
         )
         ('ddViewType
            gs->depth = "View"
            gs->ideal_filter = 1
         )
         (t
            ErrorCG(gs "Depth(gs) failed: dd->type is unknown!")
         )
      )
   else
      gs->depth = "Repository"
      gs->ideal_filter = 0
   )


   if(gs->verbose printf("Depth set to %L\n" gs->depth))

)

defmethod( SetFilter (( gs GitShell ))

   gs->path = gs->pathOrig

   case( gs->depth
      ("Repository"
         gs->filter = 3
         gs->path = gs->root->str
      )
      ("Library"
         gs->filter = 3
      )
      ("Cell"
         gs->filter = 2
      )
      ("View"
         gs->filter = 1
      )
      ( "File"
         gs->filter = 0
      )
      ( t
         gs->filter = 0
      )
   )

   if(gs->verbose printf("Filter set to %L\n" gs->filter))

)
defmethod( AddGSpath (( gs GitShell ) gsp)

   gs->paths = append( gs->paths list(gsp) )

)

defmethod( SetRoot (( gs GitShell ))

   gs->path     = gs->root->str
   gs->pathOrig = gs->root->str
   gs->dd = nil
   Depth(gs)

)


defmethod( Check (( gs GitShell ))

   if( !isDir(gs->path) && gs->path != ""
      ErrorCG(gs sprintf(nil "GitShell Check -- %L not a directory.\nSupport for files needs to be added" gs->path) )
   )

   syscmd = strcat("cd " gs->path " && git rev-parse --is-inside-work-tree ")

   result=Cmd(gs syscmd ?ignoreFatal t)

   if(result!="true\n" then
      gs->valid = nil
      if( !gs->silent ErrorCG(gs sprintf(nil "Not a valid Git repository %s" gs->path)) )
   else
      gs->valid = t
   )

   t
)


let(
()



defmethod( Cmd (( gs GitShell ) sysCommand @key (ignoreFatal nil))

   tmpFile = makeTempFileName("/tmp/cdsgit")

   sysCommand = strcat(sysCommand " &> " tmpFile)

   if(gs->verbose && sysCommand printf("CMD\n%s\nCMDEND\n",sysCommand))

   gs->lastCmd = sysCommand

   gs->exitStatus = system(sysCommand)

   if(gs->exitStatus==0 then

      response = scanFile(tmpFile)
   else
      response = nil
      gs->sysErr = scanFile(tmpFile)
   )

   deleteFile(tmpFile)

   gs->response = response

   if(gs->verbose && response printf("EXITSTATUS=%L\nRESPONSE:\n%s\nRESPONSEEND\n",gs->exitStatus,gs->response))


   if( !ignoreFatal then
      if( response && response != "" then
         responseParse = parseString(response "\n")

         if( pcreMatchp( "^fatal" car(responseParse)) || pcreMatchp( "^error" car(responseParse))  then
            ErrorCG(gs sprintf(nil "Git command returned fatal:\n%s" response))
         )
      )
   )

   response
)

procedure( scanFile( fin )
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

) 




let(
()

defmethod( Log (( gs GitShell ) @key (branchname "") )
let( (path)

   path = gs->path

   if( !branchname then
      ErrorCG(gs "GitShell Log: branchname cannot be nil")
   )

   if(gs->verbose printf("LCBUgitRevs: Reading git log\n"))

   gitLogCmd = strcat("cd " gs->path " && git log --abbrev-commit --date=short --full-history " branchname " -- .")

   response = Cmd(gs gitLogCmd)

   if( response=="" || !response
      ErrorCG(gs sprintf(nil "Path %s has an empty git log\nDo revisions of it exist in the repository?" gs->path))
   )

   lineList = parseString(response "\n")

   logCount = 0

   revList = list()

   foreach(line lineList


      case( GSstrMatch(line)

         ("commit"

            
            if(logCount > 0 then
               gitLog = StripCG(GSstr(gitLog))
               revList = cons(list(gitCommit gitAuthor gitDate gitLog) revList)
            )


            printf("COMMIT\t%s\n" line)

            logCount = logCount + 1
            gitLog = ""

            rexCompile("commit[ ]*")
            gitCommit = rexReplace(line "" 0)

            printf("REX COMMIT\t%s\n" gitCommit)
         )
         ("author"
            printf("AUTHOR\t%s\n" line)

            
            rexCompile("Author:[ ]*")
            gitAuthor = rexReplace(line "" 0)
            rexCompile("[ ]*<[a-zA-Z0-9\\.@]+>")
            gitAuthor = rexReplace(gitAuthor "" 0)

            printf("REX AUTHOR\t%s\n" gitAuthor)

         )
         ("date"
            printf("DATE\t%s\n" line)

            rexCompile("Date:[ ]*")
            gitDate = rexReplace(line "" 0)

            printf("REX DATE\t%s\n" gitDate)
         )
         (t
            gitLog = strcat(gitLog line)
         )

      )

      

      

      if(gs->verbose printf("\t|%s\n" line))

   )
   
   revList = cons(list(gitCommit gitAuthor gitDate gitLog) revList)

   revList = reverse(revList)

   revList
)
)


procedure( GSstrMatch(str)

result = nil

   match = rexMatchp("^commit [a-f0-9]+$" str)
   if(match result = "commit" )

   match = rexMatchp("Author: [a-zA-Z ]" str)
   if(match result = "author" )

   match = rexMatchp("Date:[ ]*[0-9]+-[0-9]+-[0-9]+$" str)
   if(match result = "date" )


result

)

)

let(

()



defmethod( Status (( gs GitShell ) @key (showInfo t) )

   

   gs->clean = nil
   gs->paths = list()

   status_cmd =  strcat("cd " gs->path " && git status --porcelain .")
   response = Cmd(gs status_cmd)

   if(!response then
      ErrorCG(gs sprintf(nil "git status on path %s failed" gs->path))
   )

   if(response=="" then
      if( showInfo then
         Info(gs sprintf(nil "Path %s is clean" gs->path))
      )
      gs->clean = t
   else

      response_list = parseString(response "\n")


      foreach(line response_list

         if(gs->verbose printf("%s\n" line))

         
         regexp = "^[ MADRCU?]+[ MADRCU?]+[ ]+"
         matched = rexMatchp(regexp,line)
         gitstatus = rexSubstitute("\\0")

         
         matched = rexMatchp(regexp,line)
         gitpath = rexReplace(line,"",0)

         if(gs->verbose printf("\tGitShell Status: Matched %L Status %s Path %s\n" matched gitstatus gitpath))

         
         indexStatus = getchar( gitstatus 1)
         treeStatus  = getchar( gitstatus 2)

         gsp = GSpath(gitpath ?indexStatus indexStatus ?treeStatus treeStatus ?gs gs)
         GetLib(gsp)
         if(gs->verbose printf("\tGitShell Status: path %L lib %L libDepth %L depth %L\n" gsp->str gsp->libPath->str gsp->libDepth gsp->pathDepth) )
         AddGSpath(gs gsp)
      )

   )

   StatusToList(gs)

   t

)

defmethod( StatusToList (( gs GitShell ))
let( (path)

   gs->staged     = list()
   gs->unstaged   = list()
   gs->conflicted = list()

   SetFilter(gs)

   foreach( gsp gs->paths

      
      gsp_tmp = CloneCG(gsp)

      trim_depth  = gs->filter - (3 - gsp_tmp->pathDepth)

      Trim(gsp_tmp ?loop trim_depth)
      path = gsp_tmp->str

      if( gs->verbose printf("\tPath %s Filter %L Trim %L NewPath %s\n" gsp->str gs->filter trim_depth gsp_tmp->str) )

      GSparseStatus(gsp_tmp)
      gsList = gsp_tmp->status
      statusList = get(gs,gsList)

      
      existing_paths = setof( slist statusList nthelem( 3 slist ) == gsp_tmp->str)

      addToList = nil

      if( !existing_paths then
         addToList = t
      else
         indexStatusE = nthelem(1 car(existing_paths) )
         treeStatusE  = nthelem(2 car(existing_paths) )
         
         if( gsp->indexStatus != indexStatusE || gsp->treeStatus != treeStatusE then
            addToList = t
         )
         addToList = nil
      )

      if(addToList then
         if( gs->verbose printf("\tStatusToList-Adding %L\n" ToList(gsp_tmp) ) )
         statusList=append(statusList list( ToList(gsp_tmp) ) )
         putprop(gs,statusList,gsList)
      )

   )

   
   gs->unstaged = append(gs->unstaged gs->conflicted)

)
)



procedure( GSparseStatus(gsp)
let( (indexStatus treeStatus)

   indexStatus = gsp->indexStatus
   treeStatus  = gsp->treeStatus

   cond(
      ( rexMatchp("[ADU]" indexStatus) && rexMatchp("[ADU]" treeStatus)
         gsp->status = "conflicted"
         gsp->conflictStatus = t
      )
      ( rexMatchp("[ ?]" indexStatus)
         gsp->status = "unstaged"
      )
      ( t
         gsp->status = "staged"
      )
   )
   gsp
)

)
)
defmethod( Root (( gs GitShell ))

   syscmd = strcat("cd " gs->path " && git rev-parse --show-toplevel")

   result=Cmd(gs syscmd)

   if(!result then
      ErrorCG(gs sprintf(nil "Not a valid path %s\nCommand:%s" oppath syscmd))
   else
      gss_result=GSpath(result)
      StripCG(gss_result)
      gs->root = gss_result
   )

   t
)
defmethod( Commit (( gs GitShell ) commit_log @key (merge nil) )


   if( commit_log != "" || merge then
      
      tmpFile = makeTempFileName("/tmp/cdsgit")
      fout = outfile(tmpFile "w")
      fprintf(fout "%s" commit_log)
      close(fout)

      commit_cmd = ""
      if( merge then
         commit_path = ""
         commit_cmd = strcat("git commit")
      else
         commit_cmd = strcat("git commit -F " tmpFile)
         commit_path = strcat("-- " gs->path)
      )

      if( gs->path && gs->path != "" then
         syscmd = strcat("cd " gs->root->str " && " commit_cmd " " commit_path)

         result=Cmd(gs syscmd)

         if(!result then
            ErrorCG(gs sprintf(nil "Not a valid path %s\nCommand:%s" gs->path syscmd))
         )
      )
   else
      Info(gs "Commit message cannot be blank!")
   )

   t
)
defmethod( CloneRepo (( gs GitShell ))

   usr_response = Dialog(gs sprintf(nil "Press Close to begin cloning\nPlease be patient, cadence will hang while the cloning occurs!\n URL\n  %s\nDestination\n  %s" gs->url gs->path) )

   if( usr_response then
      if( gs->url && gs->url != "" then
         syscmd = strcat("git clone -- " gs->url " " gs->path)

         result=Cmd(gs syscmd)

         if(!result then
            ErrorCG(gs sprintf(nil "Not a valid url %s\nCommand:%s" gs->url syscmd))
         else

            badresult = car( parseString(result) ) == "fatal:"

            if(badresult then
               ErrorCG(gs sprintf(nil "Clone Failed!\n URL\n  %s\nDestination\n  %s\nResponse\n  %s" gs->url gs->path response) )
            )

            Info(gs sprintf(nil "Clone Success!\n URL\n  %s\nDestination\n  %s" gs->url gs->path) )
         )
      else
         ErrorCG(gs sprintf(nil "Please enter a URL to clone!\n %L" gs->url) )
      )
   )

   t
)


defmethod( Gui (( gs GitShell ))

   printf(strcat("Starting git in " gs->root->str "\n"))

   
   system(strcat("cd " gs->root->str " && git-gui &"))


t
)



defmethod( Branch (( gs GitShell ) @key (args "") (showCurrent t) )


   gs->branches = list()

   syscmd = strcat("cd " gs->root->str " && git branch " args )

   result=Cmd(gs syscmd)

   if(!result then
      ErrorCG(gs sprintf(nil "Not a valid path %s\nCommand:%s" gs->root->str syscmd))
   else

      foreach(line parseString(result "\n")

         
         bline = parseString(line " ")

         on_branch = nil
         if( length(bline) ==1 then
            bname = car(bline)
         else
            on_branch = t
            bname = cadr(bline)
            gs->branch = bname
         )

         if( showCurrent || !on_branch then
            gs->branches = append(gs->branches list(bname))
         )

      )


   )


   t

)



defmethod( Merge (( gs GitShell ) merge_args)

   if( merge_args && merge_args != "" then
      syscmd = strcat("cd " gs->root->str " && git merge " merge_args)
      result=Cmd(gs syscmd)

      if(!result then
         ErrorCG(gs sprintf(nil "Merge failed\nCommand:%s" syscmd))
      )
   )

   parsed_result = parseString(result)

   first_line = car(parsed_result)

   if( first_line then
      cond(
         (rexMatchp("^warning" first_line) result = "warning")
         (rexMatchp("^error" first_line)
            ErrorCG(gs sprintf(nil "Cannot Merge. Do you have modified files in your work tree?\n\n'git merge' returned:\n%s" result))
         )
         (t result = t)
      )
   else
      result = t
   )
   result
)
defmethod( Export (( gs GitShell ) gitSHA)

   if( gitSHA && gitSHA !="" then

      tmpDir = makeTempFileName("/tmp/cdsgit-shell-export/")

      Cmd(gs strcat("mkdir -p " tmpDir) )

      Cmd(gs strcat("cd " gs->path " && git archive " gitSHA " . | tar -x -C " tmpDir) )

      Cmd(gs strcat("mv " tmpDir  " " gs->path "_" gitSHA) )

   else

      ErrorCG(gs "Must select a valid SHA")

   )

   t
)





defmethod( Checkout (( gs GitShell ) gitSHA @key (oppath ".") (args nil) )

   if( args then
      Cmd(gs strcat("cd " gs->path " && git checkout " args) )
   else
      if( gitSHA && gitSHA !="" then
         Cmd(gs strcat("cd " gs->path " && git checkout " gitSHA " -- " oppath) )
      else
         ErrorCG(gs "GitShell Checkout: Must select a valid SHA")
      )
   )

   t
)


defmethod( CheckFormat (( gs GitShell ) refname)

   if( refname && refname != "" then
      response = Cmd(gs strcat("git check-ref-format --branch \"" refname "\"") )

   else
      ErrorCG(gs "GitShell CheckFormat: refname must be a string")
   )
   response

)





defmethod( Init (( gs GitShell ) @key (args "") )

   if( !gs->path || !isDir(gs->path) then
      break()
      ErrorCG(gs sprintf(nil "GitShell Init: %L is not a directory" gs->path) )
   )

   syscmd = strcat("cd " gs->path " && git init " args)

   result=Cmd(gs syscmd)


)

defmethod( Push (( gs GitShell ) @key (remote "origin") (args ""))

   syscmd = strcat("cd " gs->root->str " && git push " remote " " args)
   result=Cmd(gs syscmd)

   if(!result then
      ErrorCG(gs sprintf(nil "Push failed\nCommand:%s\nResponse%s" syscmd result))
   else
      Info(gs result)
   )

)

defmethod( Pull (( gs GitShell ) @key (remote "origin") (args ""))

   
   Branch(gs)

   syscmd = strcat("cd " gs->root->str " && git pull " remote " " gs->branch " " args)
   result=Cmd(gs syscmd)

   if(!result then
      ErrorCG(gs sprintf(nil "Pull failed\nCommand:%s\nResponse%s" syscmd result))
   else
      Info(gs result)
   )

)

defmethod( Fetch (( gs GitShell ) @key (remote "origin") (args ""))

   syscmd = strcat("cd " gs->root->str " && git fetch " remote " " args)
   result=Cmd(gs syscmd)

   if(!result then
      ErrorCG(gs sprintf(nil "Fetch failed\nCommand:%s\nResponse%s" syscmd result))
   else
      if( result == "" then
         Info(gs "Fetch Complete (nothing to fetch)")
      else
         Info(gs result)
      )
   )

)
defmethod( Reset (( gs GitShell ) oppath)

   if( oppath && oppath != "" then

      syscmd = strcat("cd " gs->root->str " && git reset HEAD -- " oppath)

      result=Cmd(gs syscmd)

      if(!reset then
         ErrorCG(gs sprintf(nil "Not a valid path %s\nCommand:%s" oppath syscmd))
      )
   )
   t
)
defmethod( AddCG (( gs GitShell ) oppath)

   if( oppath && oppath != "" then
      syscmd = strcat("cd " gs->root->str " && git add --all -- " oppath)
      result=Cmd(gs syscmd)

      if(!result then
         ErrorCG(gs sprintf(nil "Not a valid path %s\nCommand:%s" oppath syscmd))
      )
   )

   t
)



defmethod( Discard (( gs GitShell ))


   Status(gs ?showInfo nil)

   Info(gs "Discard needs to be worked on")

   
   


   if( gs->clean then
      Info(gs strcat("Nothing to discard in " gs->path) )
   else
      response = Dialog(gs strcat("All unstaged changes in " gs->path " will be lost!\nProceed?") )

      if(response then
         Cmd(gs strcat("cd " gs->path " && git checkout -- ." ) )
      )
   )

   t
)


defmethod( GetLibs (( gs GitShell ))

   gs->libList = list()

   if( gs->root then

      ddList = ddGetLibList()
      pathList = list()

      foreach( dd ddList
         libPath = GSpath(ddGetObjReadPath(dd))
         if( IsInPath(libPath gs->root) then
            if( gs->verbose printf("GitShell GetLibs: Adding %s to libList\n" libPath->str ) )

            gs->libList = append(gs->libList list(libPath) )
         )
      )

   )

   gs
)





cdsgit_ge_path = strcat(cdsgit_path "/cdsgit-env")
defclass( GitEnv
   ()
   (
      ( global_path  @initform nil @initarg global_path)
      ( user_path    @initform nil @initarg user_path)
      ( prefix       @initform nil @initarg prefix )
      ( varList      @initform nil )
      ( verbose      @initform t   )
   )
)


inSkill(
procedure( GitEnv()

   let( (global_path user_path prefix ge)

      
      global_path = strcat(cdsgit_path "/global.env")
      user_path   = cdsgit_userenvpath
      prefix      = "CDSGIT"

      ge = makeInstance( 'GitEnv ?global_path global_path ?user_path user_path ?prefix prefix)

      ge
   )
)
)



defmethod( Check (( ge GitEnv ))

   usingDefaults = t

   
   envVars = '(
   "LCBU_LIB_PATH"
   "LCBU_SKILL"
   )

   mismatchString = ""

   
   foreach( envVar envVars

      defaultValue = GetCG(ge envVar ?forcedPath ge->global_path)
      setValue     = GetCG(ge envVar)

      if( defaultValue != setValue then
         mismatchString = strcat( mismatchString "\n" envVar " " setValue)
         usingDefaults = nil
      )

   )

   
   if( !usingDefaults then

   hiDisplayAppDBox(?name 'hiform
      ?dboxBanner "LCBU Setup"
      ?dboxText sprintf(nil "Info: You are overriding the following default paths:\n%s\n\nBe aware that your data may be different than what is in %s"
                           mismatchString ge->global_path
                        )
      ?buttonLayout 'Close
      ?dialogStyle 'modeless
      )
   )

   
   usingDefaults
)


defmethod( Create (( ge GitEnv ) @key (writeString "") )

   fout = outfile(ge->user_path "w")

   fprintf(fout writeString)

   close(fout)

   if( ge->verbose printf("GitEnv Create: Settings file created %s\n" ge->user_path) )

)



defmethod( GetAll (( ge GitEnv ) settingsPath)

   if( ge->verbose printf("GitEnv GetAll: Getting all variables from %s\n" settingsPath) )

   envString = OpenCG(ge settingsPath)

   ge->varList = Parse(ge envString)

   ge->varList

)




defmethod( GetCG (( ge GitEnv ) varName @key (forcedPath nil))

   if( ge->verbose printf("========GitEnv Git============\n"))

   varValue = nil

   if(forcedPath then
      if( ge->verbose printf(strcat("GitEnv Git: Getting variable " varName " from forcedPath " forcedPath "\n")))
      envList = GetAll(ge forcedPath)
      envVar = SearchCG(ge varName)
   else

      
      if( ge->verbose printf(strcat("GitEnv Git: Getting variable " varName " from " ge->user_path "\n")))
      envList = GetAll(ge ge->user_path)
      varValue = SearchCG(ge varName)

      
      if( !varValue then
         if( ge->verbose printf(strcat("GitEnv Git: Getting variable " varName " from " ge->global_path "\n")))
         envList = GetAll(ge ge->global_path)
         envVar = SearchCG(ge varName)
      )
   )

   
   if(!envVar && !forcedPath then
      error(strcat("GitEnv Git: Could not find the enviornment variable " varName \
      ".\n It must be specified in one of:\n\tUser settings - " ge->user_path "\n\t Default settings - " ge->global_path))
   )

   if( ge->verbose && varValue printf(strcat("GitEnv Git: Returning variable " varName " value " envVar->value " from " ge->global_path "\n")))


   Format(envVar) 

   envVar->value

)




defmethod( Open (( ge GitEnv ) settingsPath)

   if( ge->verbose printf("GitEnv Open: Loading variables from File\n"))

   
   
   if( !isFile(ge->user_path) then
      if( ge->verbose printf(strcat("\tGitEnv Open: LCBU settings file " ge->user_path " not found, creating empty file\n")))
      Create(ge)
   else
      if( !isFile(settingsPath) then
         error(strcat("GitEnv Open: File " settingsPath " not found" \
                  "\n\tCheck that both \"ge->user_path\" and \"ge->user_path_template\" are properly defined"))
      else
         if( ge->verbose printf(strcat("\tGitEnv Open:  user settings file found " settingsPath "\n")))
      )
   )

   
   fin = infile(settingsPath)

   fileString = ""

   while( gets(s fin)
      fileString = strcat(fileString s)
   )

   close(fin)

   fileString

)


defmethod( Parse (( ge GitEnv ) envString )

   if( ge->verbose printf(strcat("GitEnv Parse: Parsing variables from string\n")))

   stringList = parseString(envString "\n")

   envList = list()

   foreach(line stringList

      newEnvVar = ParseLine(ge line)

      if(newEnvVar then
         envList = cons( newEnvVar envList)
      else
         if( ge->verbose printf(strcat("GitEnv Parse: **inValid** String \"" line "\"\n")))
      )

   )

   envList

)


defmethod( ParseLine (( ge GitEnv ) line )

   validString = pcreMatchp(strcat("^" ge->prefix "\\w+\\s*=\\s*\\S+") line)

   if(validString then
      if( ge->verbose printf(strcat("\tParseLine Valid String \"" line "\"\n")))

      pcreMatchp(strcat("^" ge->prefix "\\w+") line)

      pcreVarName = pcreSubstitute( "\\0" )

      if( ge->verbose printf(strcat("\t\tVariable \"" pcreVarName "\"\n")))

      
      pcreObj = pcreCompile(".*=[ \t]*|[ \t]+$")
      pcreVarValue = pcreReplace(pcreObj line "" 0)

      if( ge->verbose printf(strcat("\t\tValue \"" pcreVarValue "\"\n")))

      returnEnvVar = GitEnvVar(?name pcreVarName ?value pcreVarValue)

   else
      returnEnvVar = nil
   )

   returnEnvVar

)


defmethod( Refresh (( ge GitEnv ))


   

)

defmethod( Search (( ge GitEnv ) varName )
   returnVar = nil
   foreach(envVar ge->varList

      currentName = envVar->name
      if( currentName == varName then
         varValue = envVar->value
         returnVar = envVar
         if( ge->verbose printf( "GitEnv Search: Found variable \"%s\" value \"%s\"\n" returnVar->name returnVar->value) )
      )

   )

   if(!returnVar printf( "GitEnv Search: Did not find variable %s\n" varName) )

   returnVar

)
defmethod( SetCG (( ge GitEnv ) setName setValue )

   if( ge->verbose printf("========GitEnv Set============\n"))

   printf(strcat("GitEnv Set: Setting variable " setName " to " setValue " in " ge->user_path "\n"))

   globalValue = GetCG(ge setName ?forcedPath ge->global_path)

   
   line =  strcat(setName " = " setValue)
   envVar = ParseLine(ge line)
   if(!envVar then
      error(strcat("GitEnv Set: Variable " setName " and value " setValue " are not valid!\n"))
   )
   Format(envVar)

   if(!globalVar then
      error(strcat("GitEnv Set: Variable " setName " does not exist in the global settings " ge->global_path \
       "\nThe variable must be defined in the global settings to be added to a user's settings"))
   )

   
   matchedDefault = ( envVar->value == globalValue )

   if( ge->verbose && matchedDefault printf(strcat("GitEnv Set value matched global, removing from user env if it exists\n")))

   foutString = ""

   envString = OpenCG(ge ge->user_path)
   strList = parseString(envString "\n")

   writeFile = nil
   foundVar = nil

   
   foreach(line strList
      envVar  = ParseLine(ge line)
      if(envVar then
         varName  = envVar->name
         varValue = envVar->value

         
         if( varName == setName then
            foundVar = t
            writeFile = t
            if( ge->verbose printf(strcat("GitEnv Set found variable in user's settings\n")))
            if(varValue != setValue then
               if( ge->verbose printf(strcat("\tOverwritting mismatched value\n")))
               line =  strcat(setName " = " setValue)
            )
            
            if( matchedDefault
               line = ""
            )
         )
      )

      if(line != ""
         foutString = strcat(foutString line "\n")
      )

   )

   
   if(!foundVar && !matchedDefault then
      if( ge->verbose printf(strcat("GitEnv Set variable not found in user's settings, adding\n")))
      line =  strcat(setName " = " setValue)
      foutString = strcat(foutString line "\n")
      writeFile = t
   )


   if(writeFile then
      if( ge->verbose printf(strcat("GitEnv Set Updates needed, rewriting user's settings\n")))
      Create(ge ?writeString foutString)
   else
      if( ge->verbose printf(strcat("GitEnv Set did not rewrite user's settings\n")))

   )

   
   writeFile

)


defmethod( SetShell (( ge GitEnv ) varName @key (override t) )

   shellResponse = getShellEnvVar(varName)

   if( ge->verbose && override printf("GitEnv SetShell: Override shell is set true\n"))

   if( !shellResponse || override then

      if( ge->verbose printf(strcat("GitEnv SetShell: Setting Shell variable " varName " to " varName "\n")))
      varValue = GetCG(ge varName)
      setShellEnvVar(strcat(varName "=" varValue))

      shellResponse = getShellEnvVar(varName)

      if(shellResponse then
         if( ge->verbose printf(strcat("GitEnv SetShell: Retreived shell variable " varName "=" shellResponse "\n")))
      else
         error("GitEnv SetShell: env variable " varName " was not set properly in the shell")
      )
   )

   list(varName varValue)

)
defclass( GitEnvVar
   ()
   (
      ( name        @initform nil @initarg name    )
      ( type        @initform nil @initarg type    )
      ( value       @initform nil @initarg value   )
      ( isShell     @initform nil @initarg isShell ) 
      ( inform      @initform nil @initarg inform  ) 
   )
)


procedure( GitEnvVar( @key (name nil) (type nil) (value nil) (inform nil) )

   isShell = nil

   case(type
      ("shell"
         isShell = t
      )
      (t
         nil
      )
   )

   makeInstance( 'GitEnvVar
      ?name    name
      ?type    type
      ?value   value
      ?inform  inform
      ?isShell isShell

   )
)

defmethod( Format (( gev GitEnvVar ) @key (toB nil) (toS nil) )

   

   case( envVar->type
      ("boolean"
         Bool(ge varValue ?toB t)
      )
      ("shell"
         SetShell(ge)
      )


   )



)

defmethod( Bool (( gev GitEnvVar ) @key (toB nil) (toS nil) )

   varValue = gev->value

   if(toS then
      
      if(varValue == nil varValue = "nil")
      if(varValue == t   varValue = "t")
   )
   if(toB then
      if(varValue == "nil" varValue = nil)
      if(varValue == "t"   varValue = t)
   )

   gev->value = varValue
)



procedure( CGlmgrState(_menuName lib _c _v _f _cat)
let( (menuState)

   menuState = nil

   
   if(lib && lib != "" then
      gs = CGMlmgrCB_gs(lib _c _v ?skipRoot t)
      menuState = gs->valid
   )

   lmgrSensitizeMenuItems( '("CGMgui") menuState)
   lmgrSensitizeMenuItems( '("CGMstatus" "CGMdiff" "CGMcheckout" "CGMexport") menuState)
   lmgrSensitizeMenuItems( '("CGMadd" "CGMreset" "CGMcommit" "CGMdiscard") menuState)

   lmgrSensitizeMenuItems( '("gitMenuRemote" "gitMenuBranch" "gitMenuMerge") menuState)
   lmgrSensitizeMenuItems( '("CGMprRepo") menuState)

   t
)
)




procedure( CGMlmgrCBcv(_menuName)
   cv = geGetEditCellView()
   CGMlmgrCB(_menuName cv->libName cv->cellName cv->viewName nil nil)
)


procedure( CGMlmgrCB(_menuName lib _c _v _f _cat)

   
   createGSmenus = list(
      
      "CGMgui"
      
      "CGMstatus"
      "CGMexport"
      "CGMcheckout"
      "CGMadd"
      "CGMreset"
      "CGMcommit"
      "CGMdiscard"
      "CGMdiff"
      
      "CGMmrMerge"
      "CGMmrMergeAbort"
      
      "CGMbrCreate"
      "CGMbrCheckout"
      "CGMbrDelete"
      "CGMbrRename"
      
      "CGMrePush"
      "CGMrePull"
      "CGMreFetch"

   )

   
   rootGSmenus = list(
      
      "CGMmrMerge"
      "CGMmrMergeAbort"
      
      "CGMrePush"
      "CGMrePull"
      "CGMreFetch"
   )

   if( member( _menuName createGSmenus ) then
       gs = CGMlmgrCB_gs(lib _c _v)
   )

   if( member( _menuName rootGSmenus ) then
      SetRoot(gs)
   )

   case( _menuName
      
      ("CGMgui"           Gui(gs)            )
      ("CGMinit"          CGPBinitForm()     )
      ("CGMstatusAll"     CGstatusAllForm()  )
      ("CGMclone"         CGcloneForm()      )
      ("CGMsetupSSH"      CGsetupSSHform()   )
      
      ("CGMstatus"        CGstatusForm(gs)   )
      ("CGMcommit"        CGstatusForm(gs)   )
      ("CGMexport"        CGexportForm(gs)   )
      ("CGMcheckout"      CGcheckoutForm(gs) )
      ("CGMadd"           AddCG(gs gs->path)   )
      ("CGMreset"         Reset(gs gs->path) )
      ("CGMdiscard"       Discard(gs)        )
      
      ("CGMmrMerge"       CGBSmergeForm(gs)  )
      ("CGMmrMergeAbort"  CGmergeAbortCB(gs) )
      
      ("CGMbrCreate"      CGBSbranchopForm(gs "create")   )
      ("CGMbrDelete"      CGBSbranchopForm(gs "delete")   )
      ("CGMbrRename"      CGBSbranchopForm(gs "rename")   )
      ("CGMbrCheckout"    CGBSbranchopForm(gs "checkout") )
      
      ("CGMrePush"        CGremoteCB(gs "push")  )
      ("CGMrePull"        CGremoteCB(gs "pull")  )
      ("CGMreFetch"       CGremoteCB(gs "fetch") )
      
      (t              ErrorCG( GitShell(?path "") strcat("Function " _menuName " has not been implemented yet!")  ) )

   )

   t

)

procedure( CGMlmgrCB_gs(lib _c _v @key (skipRoot nil) (silent t) )
   dd = ddGetObj(lib _c _v nil nil "r")

   if(!dd
      CGMlmgrCB_error("Please select a library, cell, or view")
   )

   ddPath = dd->readPath
   ddName = dd->name

   gs = GitShell( ?path ddPath ?dd dd ?name ddName ?skipRoot skipRoot ?silent silent)

   gs->libName  = lib
   gs->cellName = _c
   gs->viewName = _v

   if(gs->verbose printf("CGMlmgrCB:Name: %s Path: %s\n"  ddName ddPath))

   gs
)

procedure( CGMlmgrCB_error(errStr)
   hiDisplayAppDBox(?name 'gitShellErrorForm
      ?dboxBanner "CdsGit Library Manager Error"
      ?dboxText errStr
      ?buttonLayout 'Close
      
   )
   error(errStr)
)






procedure( CGgitLibs()

   gitRepoList = list()

   ddList = ddGetLibList()

   foreach( dd ddList

      path = ddGetObjReadPath(dd)
      gs = GitShell(?silent t ?path path ?dd dd)

      if(gs->valid then
         printf("Library %s found git repo %s\n" gs->dd->name gs->root)
         if(!member(gs->root gitRepoList) then
            gitRepoList = append(gitRepoList list(gs->root))
         )
      else
         printf("Library %s not a  git repo\n" gs->dd->name)
      )


   )
   gitRepoList


)
procedure( CGmergeAbortCB(gs)

   response = Dialog(gs "Aborting Merge will cause all uncommitted changes to be lost!!\nProceed?")

   if( response then
      MergeCG(gs "--abort")
   )

)

procedure( CGremoteCB(gs remote_op)

   case(remote_op
      ("pull"  Pull(gs)  )
      ("push"  Push(gs)  )
      ("fetch" Fetch(gs) )
   )


)

procedure( CGgetRFchoices(report_field)

   rf_choices = nil

   rf_branches_value = report_field->value

   if( rf_branches_value then
      if( length(rf_branches_value) == 1 then
         rf_value = car(rf_branches_value)
         rf_choices = nthelem(rf_value+1 report_field->choices)
      else
         rf_choices = list()
         foreach( rf_value rf_branches_value
            rf_choices = append( rf_choices list(nthelem(rf_value+1 report_field->choices)) )
         )
      )
   )

   rf_choices

)

procedure( CGappendRFchoices(report_field append_choice)

   report_field->choices = append(report_field->choices list(append_choice))

   report_field

)



cdsgitform_path = strcat(cdsgit_path "/cdsgit-forms")



defclass( Gridder

   () 
   (
      (fields         @initform nil @initarg fields)
      (attachmentList @initform nil @initarg attachmentList)

      (height @initform 30  @initarg height)
      (width  @initform 100 @initarg width)
      (rows   @initform 0 )
      (cols   @initform 0 )

      (border  @initform 10  @initarg border)
      (spacing @initform 10 @initarg spacing)

      (size @initform nil)

      (xfudge @initform 30) 
      (ymin   @initform 200)

      (verbose @initform nil) 

      
      (lastx @initform nil)
      (lasty @initform nil)
      (lastw @initform nil)
      (lasth @initform nil)
   )
)



procedure( Gridder( @key (verbose nil))
let(
   (grid)
   grid = makeInstance('Gridder)
   grid->verbose = verbose
   grid
)
)


defmethod( NewField (( g Gridder ) @key
   (field nil)
   (x nil) (y nil) (w nil) (h nil)
   (prompt nil) (attach "scale") (expand 0)
   (overlap nil)
   (appendField nil) (appendDir "y")
   (frame nil) (frameLabel "") (frameName nil) (frameExpand list(5 15 5 5) )
)

   if( !field && !frame then
      error("Gridder: You must specify the field object to add")
   )


   if( overlap || appendField then
      x = g->lastx
      y = g->lasty
   )

   if( appendField && !x && !y then
      x = 1
      y = 1
      appendField = nil
   )

   if( appendField then
      case( appendDir
         ("x" x = x+g->lastw)
         ("y" y = y+g->lasth)
         (t error("Gridder: Can only append in x or y"))
      )
   )


   
   if( x < 1 then
      error("Gridder NewField: x must be > 1")
   )
   if( y < 1 then
      error("Gridder NewField: y must be > 1")
   )
   if( prompt then
   if( prompt > w*g->width || prompt < 0 then
      error("Gridder NewField: prompt size cannot exceed width and must be >= 0")
   )
   )

   g->lastx = x
   g->lasty = y
   g->lastw = w
   g->lasth = h

   
   case( type(expand)
      ( 'list
         case( length(expand)
            (2 
               expandX = nthelem(1 expand)
               expandY = nthelem(2 expand)
               expandW = nthelem(1 expand)
               expandH = nthelem(2 expand)
            )
            (4 
               expandX = nthelem(1 expand)
               expandY = nthelem(2 expand)
               expandW = nthelem(3 expand)
               expandH = nthelem(4 expand)
            )
            (t error("Gridder: expand list must be length of 2 or 4 (x,y) or (x,y,w,h)") )
         )
      )
      ( 'fixnum
         expandX=expand expandY=expand expandW=expand expandH=expand
      )
      ( t error("Gridder: expand must be a list or fixnum") )
   )

   
   xpos  = g->border + g->spacing*x + g->width*(x-1) - expandX
   width = g->width * w + g->spacing*(w-1) + 2*expandW

   
   ypos   = g->border + g->spacing*y + g->height*(y-1) - expandY
   height = g->height * h + g->spacing*(h-1) + 2*expandH

   
   if(x+(w-1) > g->cols then
      g->cols = x+(w-1)
   )
   if(y+(h-1) > g->rows then
      g->rows = y+(h-1)
   )



   
   

   if( field then
      if(prompt then
         field = list( field xpos:ypos width:height prompt)
      else
         field = list( field xpos:ypos width:height)
      )
   )

   
   case( attach
      
      ("scale"
         attachment = inSkill(list( hicTopPercentSet|hicLeftPercentSet|
            hicRightPercentSet|hicBottomPercentSet ))
      )
      
      ("fix"
         attachment = inSkill(list( hicLeftPositionSet |hicTopPositionSet|
            hicRightPercentSet|hicBottomPercentSet ))
      )
      
      ("position"
         attachment = inSkill(list( hicLeftPositionSet |hicTopPositionSet|
            hicRightPositionSet|hicBottomPositionSet ))
      )
      
      (t
         attachment = attach
      )
   )

   
   if(frame then
      if( !frameName then
         error("Gridder: Must provide a frameName when adding frame")
      )

      tmp_frame=evalstring(strcat("hiCreateFrameField( ?name '" frameName " ?labelText \"" frameLabel "\")" ))
      NewField(g ?field tmp_frame ?x x ?y y ?w w ?h h ?prompt 0 ?attach attach ?expand frameExpand)
   )

   if( field then
      g->fields         = append(g->fields         list(field))
      g->attachmentList = append(g->attachmentList attachment)
   )

)


defmethod( FormSize (( g Gridder) )

   w = g->width *g->cols + (g->cols+1)*g->spacing + 2*g->border
   h = g->height*g->rows + (g->rows+1)*g->spacing + 2*g->border + g->xfudge

   if(w < g->ymin then
      w = g->ymin
   )

   formSize = list(w h)

   g->size = formSize

   if(g->verbose printf("FormSize %L\n" formSize))

   formSize

)

inSkill(

procedure( gridder_demo()

   g = Gridder()

   b_run =hiCreateButton(
            ?name 'run_button
            ?buttonText "Run"
            ?callback ""
   )

   

   fields = list()
   for( i 1 3
      for(j 1 3

         ename = sprintf(nil "field_%d_%d" i j)

         b = hiCreateButton(
            ?name evalstring(strcat("'" ename))
            ?buttonText ename
            ?callback ""
         )

         NewField(g ?field b ?x i ?y j ?w 1 ?h 1 ?prompt 0 ?attach "scale")

      )
   )
   formSize = FormSize(g)

   gridderDemoForm = hiCreateAppForm( ?name    'gridderDemoForm
            ?formTitle  "Gridder Test"
            ?fields     
               g->fields
            
            ?attachmentList g->attachmentList
            ?buttonLayout  'OKCancelDef
            ?initialSize   formSize
            ?minSize formSize
            ?callback   t
   )

   hiDisplayForm(gridderDemoForm)

)
)








procedure( CGstatusForm(gs)

   importSkillVar(cdsGitAppName)

   
   formHeader = sprintf(nil "%s Status" cdsGitAppName)
   formHeader = sprintf(nil "%s Status of Path: %s" cdsGitAppName gs->path)


   
   Status(gs)

   
   grid = Gridder(?verbose gs->verbose)
   gridW = grid->width
   toggleCB = "CGstatusFormToggleCB()"
   radioCB  = "CGstatusFormRadioCB()"
   diffCB   = "CGstatusFormDiffCB()"
   commitCB = "CGstatusFormCommitCB()"
   rescanCB = "CGstatusFormUpdate()"

   reportHeader = list(
      list( "Index Status" 1*gridW 'left 'string t )
      list( "Tree  Status" 1*gridW 'left 'string t )
      list( "Path"         3*gridW 'left 'string t )
      list( "Conflict"     1*gridW 'left 'string t )
      )

   if( t then

      fr_gspath = hiCreateFrameField( ?name 'fr_gspath ?labelText formHeader )

      r_filter=hiCreateRadioField(
         ?name 'r_filter
         ?prompt "Depth"
         ?value gs->depth
         ?choices '("Repository" "Library" "Cell" "View" "Files")
         ?callback list(radioCB)
      )

      fr_staged = hiCreateFrameField( ?name 'fr_staged ?labelText "Staged for Commit (Will Commit)")

      rf_staged = hiCreateReportField(
               ?name 'rf_staged
               ?headers reportHeader
               ?choices gs->staged
               ?selectMode 'extended
               ?callback 'CGstatusFormReportCB
               ?doubleClickCB toggleCB
            )

      fr_unstaged = hiCreateFrameField( ?name 'fr_unstaged ?labelText "Unstaged Changes")

      rf_unstaged = hiCreateReportField(
               ?name 'rf_unstaged
               ?headers reportHeader
               ?choices gs->unstaged
               ?selectMode 'extended
               ?callback 'CGstatusFormReportCB
               ?doubleClickCB toggleCB
            )

      fr_commit  = hiCreateFrameField( ?name 'fr_commit ?labelText "Commit Message")

      s_commit   = hiCreateMLTextField(  ?name    's_commit
               ?prompt     ""
               ?value      ""
               ?editable   t
               ?hasVerticalScrollbar t
               ?hasHorizontalScrollbar nil
      )

      b_rescan = hiCreateButton(
         ?name 'b_rescan
         ?buttonText "Rescan"
         ?callback rescanCB
      )

      b_toggle = hiCreateButton(
         ?name 'b_toggle
         ?buttonText "Toggle"
         ?callback toggleCB
      )

      b_diff = hiCreateButton(
         ?name 'b_diff
         ?buttonText "Diff"
         ?callback diffCB
      )

      b_commit = hiCreateButton(
         ?name 'b_commit
         ?buttonText "Commit"
         ?callback commitCB
      )

      totalW = 6

      NewField(grid ?field fr_gspath     ?x 1 ?y 1  ?w totalW ?h 20 ?prompt 10 ?expand '(10 0 10 10))
      NewField(grid ?field r_filter      ?x 1 ?y 2  ?w totalW ?h 1 ?prompt 100)
      NewField(grid ?field fr_unstaged   ?x 1 ?y 3  ?w totalW ?h 5 ?prompt 10 ?expand '(10 0))
      NewField(grid ?field rf_unstaged   ?x 1 ?y 4  ?w totalW ?h 4 ?prompt 10)
      NewField(grid ?field fr_staged     ?x 1 ?y 8  ?w totalW ?h 5 ?prompt 10 ?expand '(10 0))
      NewField(grid ?field rf_staged     ?x 1 ?y 9  ?w totalW ?h 4 ?prompt 10)
      NewField(grid ?field fr_commit     ?x 1 ?y 13 ?w totalW ?h 4 ?prompt 10 ?expand '(10 0))
      NewField(grid ?field s_commit      ?x 1 ?y 14 ?w totalW ?h 3 ?prompt 10)
      NewField(grid ?field b_rescan      ?x 1 ?y 17 ?w totalW ?h 1 ?prompt 10)
      NewField(grid ?field b_toggle      ?x 1 ?y 18 ?w totalW ?h 1 ?prompt 10)
      NewField(grid ?field b_diff        ?x 1 ?y 19 ?w totalW ?h 1 ?prompt 10)
      NewField(grid ?field b_commit      ?x 1 ?y 20 ?w totalW ?h 1 ?prompt 10)

      cgstatus_form = hiCreateAppForm(
                  ?name 'cgstatus_form
                  ?formTitle formHeader
                  ?callback ""
                  ?fields         grid->fields
                  ?attachmentList grid->attachmentList
                  ?initialSize    FormSize(grid)
                  ?minSize        FormSize(grid)
                  ?buttonLayout  'OKCancelDef
                  ?dontBlock      t
            )
      cgstatus_form->gs = gs

      hiDisplayForm(cgstatus_form)
   )
)


procedure( CGstatusFormToggleCB()
   gs = cgstatus_form->gs
   staged = cgstatus_form->rf_staged->value
   unstaged = cgstatus_form->rf_unstaged->value

   
   if( staged || unstaged then

      if(staged && unstaged then
         error("Cannot select both a staged and unstaged item")
      )
      if(staged then
         if(gs->verbose printf("Toggle staged\n"))
         fvalues  = cgstatus_form->rf_staged->value
         fchoices = cgstatus_form->rf_staged->choices
         operation = "reset"
      )
      if(unstaged then
         if(gs->verbose printf("Toggle unstaged\n"))
         fvalues  = cgstatus_form->rf_unstaged->value
         fchoices = cgstatus_form->rf_unstaged->choices
         operation = "add"
      )
      if( !unstaged && !staged
         warn("Nothing selected!")
      )

      foreach(fvalue fvalues
         fchoice = nthelem(fvalue+1 fchoices)
         oppath = nthelem(3 fchoice)

         case(operation
            ("add"     AddCG(gs oppath ) )
            ("reset" Reset(gs oppath ) )
            (t error("invalied Toggle operation"))
         )
      )
      CGstatusFormUpdate()
   )
)


procedure( CGstatusFormRadioCB()
   gs = cgstatus_form->gs
   if(gs->verbose printf("CGstatusFormRadioCB\n") )
   gs->depth = cgstatus_form->r_filter->value
   SetFilter(gs)
   CGstatusFormUpdate()
)


procedure( CGstatusFormReportCB(fieldName selectedItems "sl")
   gs = cgstatus_form->gs
   if(gs->verbose printf( "Report field callback, fieldName = %L, selectedItems = %L\n" fieldName selectedItems ))
   
   if(selectedItems then
      case(fieldName
         ('rf_staged
            if(gs->verbose printf("Clean unstaged %L\n" cgstatus_form->rf_unstaged->value))
            cgstatus_form->rf_unstaged->value = nil
            cgstatus_form->b_toggle->_buttonText = "Unstage Selected"
         )
         ('rf_unstaged
            if(gs->verbose printf("Clean rf_staged %L\n" cgstatus_form->rf_staged->value))
            cgstatus_form->rf_staged->value = nil
            cgstatus_form->b_toggle->_buttonText = "Stage Selected"
         )
      )
   )
)


procedure( CGstatusFormCommitCB()

   CGcommitFormCB(cgstatus_form)
   CGstatusFormUpdate()
   cgstatus_form->s_commit->value=""

)

procedure( CGcommitFormCB(theForm)

   gs = theForm->gs
   commit_message = theForm->s_commit->value

   Commit(gs commit_message)
)

procedure( CGstatusFormUpdate()

   gs = cgstatus_form->gs

   
   Status(gs ?showInfo nil)

   
   

   
   cgstatus_form->rf_staged->value   = nil
   cgstatus_form->rf_unstaged->value = nil
   cgstatus_form->rf_staged->choices   = gs->staged
   cgstatus_form->rf_unstaged->choices = gs->unstaged


)




procedure( CGmergeResolveForm(gs)

   importSkillVar(cdsGitAppName)

   
   formHeader = sprintf(nil "%s Merge Resolve" cdsGitAppName)
   formHeader = sprintf(nil "%s Merge Resolve of Path: %s" cdsGitAppName gs->path)


   
   Status(gs)

   
   grid = Gridder(?verbose gs->verbose)
   gridW = grid->width
   radioCB  = "CGmergeResolveFormRadioCB()"
   rescanCB = "CGmergeResolveFormUpdate()"

   reportHeader = list(
      list( "Index Status" 1*gridW 'left 'string t )
      list( "Tree  Status" 1*gridW 'left 'string t )
      list( "Path"         3*gridW 'left 'string t )
      list( "Conflict"     1*gridW 'left 'string t )
      )

   if( t then

      fr_gspath = hiCreateFrameField( ?name 'fr_gspath ?labelText formHeader )

      r_filter=hiCreateRadioField(
         ?name 'r_filter
         ?prompt "Depth"
         ?value gs->depth
         ?choices '("Repository" "Library" "Cell" "View" "Files")
         ?callback list(radioCB)
      )

      fr_conflict = hiCreateFrameField( ?name 'fr_conflict ?labelText "Conflicted")

      rf_conflict = hiCreateReportField(
               ?name 'rf_conflict
               ?headers reportHeader
               ?choices gs->conflicted
               ?selectMode 'single
               ?callback ""
               ?doubleClickCB ""
            )

      fr_ours = hiCreateFrameField( ?name 'fr_ours ?labelText "Ours")

      rf_ours = hiCreateReportField(
               ?name 'rf_ours
               ?headers reportHeader
               ?choices list()
               ?selectMode 'single
               ?callback 'CGstatusFormReportCB
               ?doubleClickCB ""
            )

      fr_ours = hiCreateFrameField( ?name 'fr_ours ?labelText "Ours")

      rf_ours = hiCreateReportField(
               ?name 'rf_ours
               ?headers reportHeader
               ?choices list()
               ?selectMode 'single
               ?callback ""
               ?doubleClickCB ""
            )


      fr_theirs = hiCreateFrameField( ?name 'fr_theirs ?labelText "Theirs")

      rf_theirs = hiCreateReportField(
               ?name 'rf_theirs
               ?headers reportHeader
               ?choices list()
               ?selectMode 'extended
               ?callback ""
               ?doubleClickCB ""
            )


      b_rescan = hiCreateButton(
         ?name 'b_rescan
         ?buttonText "Rescan"
         ?callback rescanCB
      )

      b_add_ours = hiCreateButton(
         ?name 'b_add_ours
         ?buttonText "<---Ours"
         ?callback "CGmergeResolveFormAddCB(\"ours\")"
      )

      b_add_theirs = hiCreateButton(
         ?name 'b_add_theirs
         ?buttonText "Theirs--->"
         ?callback "CGmergeResolveFormAddCB(\"theirs\")"
      )

      
      b_manual_merge = hiCreateButton(
         ?name 'b_manual_merge
         ?buttonText "Manual Merge"
         ?callback ""
      )

      b_commit = hiCreateButton(
         ?name 'b_commit
         ?buttonText "Commit"
         ?callback "CGmergeResolveFormCommitCB()"
      )


      frameW = 3
      totalW = 3*frameW

      NewField(grid ?field fr_gspath     ?x 1 ?y 1  ?w totalW ?h 10 ?prompt 10 ?expand '(10 0 10 10))
      NewField(grid ?field r_filter      ?x 1 ?y 2  ?w totalW ?h 1  ?prompt 100)

      NewField(grid ?field fr_ours   ?x 1 ?y 3  ?w frameW ?h 5 ?prompt 10 ?expand '(10 0 5 0))
      NewField(grid ?field rf_ours   ?x 1 ?y 4  ?w frameW ?h 4 ?prompt 10)

      NewField(grid ?field fr_conflict   ?x 1+frameW ?y 3  ?w frameW ?h 5 ?prompt 10 ?expand '(10 0 5 0))
      NewField(grid ?field rf_conflict   ?x 1+frameW ?y 4  ?w frameW ?h 4 ?prompt 10)

      NewField(grid ?field fr_theirs   ?x 1+frameW*2 ?y 3  ?w frameW ?h 5 ?prompt 10 ?expand '(10 0 5 0))
      NewField(grid ?field rf_theirs   ?x 1+frameW*2 ?y 4  ?w frameW ?h 4 ?prompt 10)

      NewField(grid ?field b_add_ours     ?x 1          ?y 8  ?w frameW ?h 1 ?prompt 10)
      NewField(grid ?field b_rescan       ?x 1+frameW   ?y 8  ?w frameW ?h 1 ?prompt 10)
      NewField(grid ?field b_add_theirs   ?x 1+frameW*2 ?y 8  ?w frameW ?h 1 ?prompt 10)

      NewField(grid ?field b_manual_merge ?x 1+frameW   ?y 9  ?w frameW ?h 1 ?prompt 10)
      NewField(grid ?field b_commit       ?x 1+frameW   ?y 10 ?w frameW ?h 1 ?prompt 10)


      cgmergeresolve_form = hiCreateAppForm(
                  ?name 'cgmergeresolve_form
                  ?formTitle formHeader
                  ?callback ""
                  ?fields         grid->fields
                  ?attachmentList grid->attachmentList
                  ?initialSize    FormSize(grid)
                  ?minSize        FormSize(grid)
                  ?buttonLayout  'OKCancelDef
                  ?dontBlock      t
            )
      cgmergeresolve_form->gs = gs

      hiDisplayForm(cgmergeresolve_form)
   )
)



procedure( CGmergeResolveFormRadioCB()
   gs = cgmergeresolve_form->gs
   if(gs->verbose printf("CGmergeResolveFormRadioCB\n") )
   gs->depth = cgmergeresolve_form->r_filter->value
   SetFilter(gs)
   CGmergeResolveFormUpdate()
)

procedure( CGmergeResolveFormAddCB(option)
   gs = cgmergeresolve_form->gs

   fvalue   = car(cgmergeresolve_form->rf_conflict->value)
   if( fvalue then
      fchoices = cgmergeresolve_form->rf_conflict->choices
      fchoice = nthelem(fvalue+1 fchoices)
      oppath = nthelem(3 fchoice)

      Checkout(gs strcat("--" option) ?oppath oppath)
      AddCG(gs oppath)

      case( option
         ("ours"   cgmergeresolve_form->rf_ours   = CGappendRFchoices(cgmergeresolve_form->rf_ours   fchoice) )
         ("theirs" cgmergeresolve_form->rf_theirs = CGappendRFchoices(cgmergeresolve_form->rf_theirs fchoice) )

      )
   )

   
   CGmergeResolveFormUpdate()

)

procedure( CGmergeResolveFormCommitCB()
   gs = cgmergeresolve_form->gs

   fchoices = cgmergeresolve_form->rf_conflict->choices

   if( fchoices then
      Info(gs "Please Resolve All Conflicts Before Commit!")
   else
      Commit(gs "" ?merge t)
   )
   hiFormClose(cgmergeresolve_form)
   hiFormClose(cgbranchsel_form)

   Info(gs "Merge Complete!")

)

procedure( CGmergeResolveFormUpdate( @key ( clear_ours nil ) ( clear_theirs nil) )

   gs = cgmergeresolve_form->gs

   
   Status(gs ?showInfo nil)

   
   cgmergeresolve_form->rf_theirs->value = nil
   cgmergeresolve_form->rf_ours->value   = nil
   if(clear_theirs cgmergeresolve_form->rf_theirs->choices = list() )
   if(clear_ours   cgmergeresolve_form->rf_ours->choices =   list() )
   cgmergeresolve_form->rf_conflict->choices = gs->conflicted



)

procedure( CGstatusAllForm()

   importSkillVar(cdsGitAppName)

   formHeader = sprintf(nil "%s Workarea Repositories" cdsGitAppName)

   grid = Gridder()

   totalW = 6
   gridW = grid->width

   selectCB = "CGstatusAllCB()"
   refreshCB = "CGstatusAllRefreshCB()"

   
   reportHeader = list(
      list( "Path"   5*gridW 'left 'string t )
      list( "Status" 1*gridW 'left 'string t )
      )

   l_repos = hiCreateLabel( ?name 'l_repos ?labelText "Git Repositories")

   rf_repos = hiCreateReportField(
            ?name 'rf_repos
            ?headers reportHeader
            ?choices CGstatusAllGetStatus()
            ?selectMode 'single
            ?doubleClickCB selectCB
         )

   b_refresh = hiCreateButton(
      ?name 'b_refresh
      ?buttonText "Refresh"
      ?callback refreshCB
   )

   b_select_repo = hiCreateButton(
      ?name 'b_select_repo
      ?buttonText "Status"
      ?callback selectCB
   )


   NewField(grid ?field l_repos       ?x 1 ?y 1  ?w totalW ?h 1 ?prompt 10)
   NewField(grid ?field rf_repos      ?x 1 ?y 2  ?w totalW ?h 4 ?prompt 10)
   NewField(grid ?field b_refresh     ?x 1 ?y 6  ?w totalW ?h 1 ?prompt 10)
   NewField(grid ?field b_select_repo ?x 1 ?y 7  ?w totalW ?h 1 ?prompt 10)


   cgstatusall_form = hiCreateAppForm(
               ?name 'cgstatusall_form
               ?formTitle formHeader
               ?callback ""
               ?fields         grid->fields
               ?attachmentList grid->attachmentList
               ?initialSize    FormSize(grid)
               ?minSize        FormSize(grid)
               ?buttonLayout  'OKCancelDef
         )



   hiDisplayForm(cgstatusall_form)

)


procedure( CGstatusAllCB()
      fvalues  = cgstatusall_form->rf_repos->value
      fchoices = cgstatusall_form->rf_repos->choices

      if(fvalues then
         fvalue = car(fvalues)+1
         fchoice = car(nthelem(fvalue fchoices))

         gs = GitShell(?path fchoice)
         CGstatusForm(gs)
      )

)

procedure( CGstatusAllGetStatus()
   gitList = CGgitLibs()

   rootList = list()
   foreach( rootPath gitList
      if( !setof( strlist rootList car(strlist)==rootPath->str) then

         gs = GitShell(?path rootPath->str)
         Status(gs ?showInfo nil)

         statusStr = "modified"
         if( gs->clean then
            statusStr = "clean"
         )

         rootList = append(rootList list(list(rootPath->str statusStr)) )
      )
   )
   rootList
)

procedure( CGstatusAllRefreshCB()

   cgstatusall_form->rf_repos->choices=CGstatusAllGetStatus()
)



procedure( CGrevSelectForm(gs @key (formTitle "") (formCB "") (lcvSel t) ) 

   
   grid = Gridder(?verbose gs->verbose)
   gridW = grid->width
   revList = Log(gs)

   branchList = Branch(gs)



   
   s_lib  = hiCreateStringField( ?name 's_lib  ?prompt "Library" ?defValue gs->libName  ?editable nil)
   s_cell = hiCreateStringField( ?name 's_cell ?prompt "Cell"    ?defValue gs->cellName ?editable nil)
   s_view = hiCreateStringField( ?name 's_view ?prompt "View"    ?defValue gs->viewName ?editable nil)
   b_browse = hiCreateButton(
            ?name     'b_browse
            ?buttonText "Browse"
            ?callback  "CGrevSelectFormBrowseCB()"
            ) 


   c_branch = hiCreateCyclicField(
      ?name 'c_branch
      ?prompt "Branch"
      ?choices gs->branches
      ?value gs->branch
      ?callback "CGrevSelectFormRefersh()"
   ) 


   reportHeader = list(
      list( "SHA ID" 100 'left 'string t )
      list( "Author" 150 'left 'string t )
      list( "Date" 100 'left 'string t )
      list( "Log" 350 'left 'string t)
      )


   rf_revs = hiCreateReportField(
            ?name 'rf_revs
               ?title formTitle
               ?titleAlignment 'center
               ?headers reportHeader
               ?choices revList
               ?selectMode 'single
               ?doubleClickCB formCB
               ?callback ""
            )

   if( lcvSel then
      NewField(grid ?field s_lib     ?appendField t ?w 5 ?h 1 ?prompt gridW*1 )
      NewField(grid ?field s_cell    ?appendField t ?w 5 ?h 1 ?prompt gridW*1 )
      NewField(grid ?field s_view    ?appendField t ?w 5 ?h 1 ?prompt gridW*1 )
      NewField(grid ?field b_browse  ?appendField t ?w 5 ?h 1 ?prompt gridW*1 )
   )

   NewField(grid ?field c_branch  ?appendField t ?w 5 ?h 1 ?prompt gridW*1 )
   NewField(grid ?field rf_revs   ?appendField t ?w 5 ?h 4 ?prompt 10 )

   cgrevselect_form = hiCreateAppForm(
               ?name 'cgrevselect_form
               ?formTitle formTitle
               ?callback formCB
               ?fields         grid->fields
               ?attachmentList grid->attachmentList
               ?initialSize    FormSize(grid)
               ?minSize        FormSize(grid)
               ?buttonLayout  'OKCancelApply
               ?dontBlock     t
         )

   cgrevselect_form->gs = gs

   hiDisplayForm(cgrevselect_form)

)

procedure( CGrevSelectFormRefersh()
   gs = cgrevselect_form->gs
   bname = cgrevselect_form->c_branch->value
   cgrevselect_form->rf_revs->choices = Log(gs ?branchname bname)
)

procedure( CGrevSelectFormBrowseCB()

      CGlibSelectForm(cgrevselect_form 's_lib 's_cell 's_view )


      libName  = cgrevselect_form->s_lib->value
      cellName = cgrevselect_form->s_cell->value
      viewName = cgrevselect_form->s_view->value

      
      cgrevselect_form->c_branch->choices = list("")
      cgrevselect_form->c_branch->value   = ""
      cgrevselect_form->rf_revs->choices  = list()

      
      gs = CGMlmgrCB_gs(libName cellName viewName)
      cgrevselect_form->gs = gs

      if( gs->valid then
         
         branchList = Branch(gs)
         cgrevselect_form->c_branch->choices = gs->branches
         cgrevselect_form->c_branch->value   = gs->branch
         CGrevSelectFormRefersh()
      )

)



procedure( CGexportForm(gs)

   importSkillVar(cdsGitAppName)

   formTitle = sprintf(nil "%s Export Revision %s" cdsGitAppName gs->path)
   formCB = "CGexportFormCB()"

   CGrevSelectForm(gs ?formTitle formTitle ?formCB formCB)

)



procedure( CGexportFormCB()

   gs = cgrevselect_form->gs
   revSelected = CGgetRFchoices(cgrevselect_form->rf_revs)

   if( !gs->valid then
      ErrorCG(gs "Object is not in a valid git repository")
   )

   if(revSelected then

      gitSHA = nthelem(1 revSelected)

      if( isDir( strcat(gs->path "_" gitSHA)) then
         Info(gs "Export path already exists!")
      else
         Export(gs gitSHA)
      )


      
      

      
      

      ddUpdateLibList()

   else
      Info(gs "Please make a selection")
   )

)




procedure( CGcheckoutForm(gs)

   importSkillVar(cdsGitAppName)

   formTitle = sprintf(nil "%s Checkout Revision %s" cdsGitAppName gs->path)
   formCB = "CGcheckoutFormCB()"

   Status(gs ?showInfo nil)
   if( !gs->clean then
      ErrorCG(gs "Cannot Checkout, you have uncommited modifications\n")
   )

   CGrevSelectForm(gs ?formTitle formTitle ?formCB formCB)

)



procedure( CGcheckoutFormCB()

   revSelected = CGgetRFchoices(cgrevselect_form->rf_revs)
   gs = cgrevselect_form->gs

   if( !gs->valid then
      ErrorCG(gs "Object is not in a valid git repository")
   )

   if(revSelected then

      gitSHA = nthelem(1 revSelected)

      Status(gs ?showInfo nil)
      if( !gs->clean then
         ErrorCG(gs "Cannot Checkout, you have uncommited modifications\n")
      else
         Checkout(gs gitSHA)
         Reset(gs gs->path)
      )


      ddUpdateLibList()

   else
      Info(gs "Please make a selection")
   )

)



procedure( CGbranchSelectForm(gs @key (formTitle "") (formLabel "Select a Branch") (formCB "") (showCurrent t) (branch_args "") (grid nil) (locationChoices list("Local" "Remote")) )

   
   if( !grid then
      grid = Gridder(?verbose gs->verbose)
   )
   gridW = grid->width

   
   fr_formframe = hiCreateFrameField( ?name 'fr_formframe ?labelText formLabel)

   c_location = hiCreateRadioField(
      ?name 'c_location
      ?prompt ""
      ?choices locationChoices
      ?value "Local"
      ?callback list("CGbranchSelectFormRefersh()")
   )

   reportHeader = list(
      list( "Name" gridW   'left 'string t )
      
      
   )

   rf_branches = hiCreateReportField(
            ?name 'rf_branches
               ?title formTitle
               ?titleAlignment 'center
               ?headers reportHeader
               ?choices list()
               ?selectMode 'single
               ?callback ""
               ?doubleClickCB  formCB

            )

   NewField(grid ?field fr_formframe    ?x 1 ?y 1  ?w 5 ?h 5 ?prompt gridW*1 ?expand '(10 15 10 10))
   NewField(grid ?field c_location      ?x 1 ?y 1  ?w 5 ?h 1 ?prompt gridW*1 )
   NewField(grid ?field rf_branches     ?x 1 ?y 2  ?w 5 ?h 4 ?prompt 10 )

   cgbranchsel_form = hiCreateAppForm(
               ?name 'cgbranchsel_form
               ?formTitle formTitle
               ?callback formCB
               ?fields         grid->fields
               ?attachmentList grid->attachmentList
               ?initialSize    FormSize(grid)
               ?minSize        FormSize(grid)
               ?buttonLayout  'OKCancelApply
               ?dontBlock      t
         )

   cgbranchsel_form->gs = gs
   cgbranchsel_form->showCurrent = showCurrent
   cgbranchsel_form->branch_args = branch_args

   hiDisplayForm(cgbranchsel_form)

   CGbranchSelectFormRefersh()

)


procedure( CGbranchSelectFormRefersh()
   gs = cgbranchsel_form->gs
   showCurrent = cgbranchsel_form->showCurrent
   branch_args = cgbranchsel_form->branch_args

   args = ""
   case( cgbranchsel_form->c_location->value
      ("Local"   args = branch_args   )
      ("Remote"  args = strcat("-r " branch_args) )
   )

   Branch(gs ?args args ?showCurrent showCurrent)

   
   branch_list = list()
   foreach(branch gs->branches
      branch_list = append(branch_list list(list(branch)) )
   )
   cgbranchsel_form->rf_branches->choices = branch_list

)

procedure( CGBSmergeForm(gs)

   importSkillVar(cdsGitAppName)

   formTitle = sprintf(nil "%s Merge Branch %s" cdsGitAppName gs->root->str)
   formCB = "CGBSmergeFormCB()"

   CGbranchSelectForm(gs
      ?formTitle formTitle
      ?formLabel "Select a Branch to Merge"
      ?formCB formCB
      ?showCurrent nil
      ?branch_args "--no-merged"
   )

)

procedure( CGBSmergeFormCB()
   gs = cgbranchsel_form->gs


   rf_branches_value = CGgetRFchoices(cgbranchsel_form->rf_branches)

   if(rf_branches_value then
      src_branch = nthelem(1 rf_branches_value)
      if( gs->verbose printf("CGBSmergeFormCB: Attempting to merge %L",src_branch))
      result = MergeCG(gs src_branch)
      if( result == "warning" then
         response = Dialog(gs "Merge failed due to conflicts\nOpen the Merge confilt resolve form?")
         if(response then
            gs->path = gs->root->str
            CGmergeResolveForm(gs)
         else
            ErrorCG(gs "Merge failed due to unresolved conflicts")
         )
      )
   )

)

procedure( CGBSbranchopForm(gs branchop)

   case( branchop
      ("create"
         titleOp = "Create"
         formLabel = "Select Parent Branch"
         formCB = "CGBSbranchopCB(\"create\")"
         locationChoices = list("Local" "Remote")
      )
      ("delete"
         titleOp = "Delete"
         formLabel = "Select Branch to Delete"
         formCB = "CGBSbranchopCB(\"delete\")"
         locationChoices = list("Local")
      )
      ("rename"
         titleOp = "Rename"
         formLabel = "Select Branch to Rename"
         formCB = "CGBSbranchopCB(\"rename\")"
         locationChoices = list("Local")
      )
      ("checkout"
         titleOp = "Checkout"
         formLabel = "Select Branch to Checkout"
         formCB = "CGBSbranchopCB(\"checkout\")"
         locationChoices = list("Local")
      )
   )

   importSkillVar(cdsGitAppName)

   formTitle = sprintf(nil "%s %s Branch %s" cdsGitAppName titleOp gs->root->str)

   grid = Gridder(?verbose gs->verbose)

   fr_bnameframe = hiCreateFrameField( ?name 'fr_bnameframe ?labelText "New Branch Name")

   sf_bname = hiCreateStringField(
      ?name 'sf_bname
      ?prompt ""
      ?value ""
      ?defValue ""
      ?editable t
   )

   if( branchop == "create" || branchop == "rename" then
      NewField(grid ?field fr_bnameframe    ?x 1 ?y 7  ?w 5 ?h 1 ?prompt gridW*1 ?expand '(10 15 10 10))
      NewField(grid ?field sf_bname         ?x 1 ?y 7  ?w 5 ?h 1 ?prompt gridW*1 )
   )

   CGbranchSelectForm(gs
      ?formTitle ""
      ?formLabel formLabel
      ?formCB formCB
      ?showCurrent t
      ?grid grid
      ?locationChoices locationChoices
   )
)


procedure( CGBSbranchopCB(branchop)

   

   gs = cgbranchsel_form->gs

   rf_branches_value = CGgetRFchoices(cgbranchsel_form->rf_branches)
   parent_branch = nthelem(1 rf_branches_value)

   if( !rf_branches_value then
      ErrorCG(gs "You must select a Branch")
   )

   if( branchop == "create" || branchop == "rename" then
      sf_bname_value = cgbranchsel_form->sf_bname->value

      
      if( sf_bname_value == "" then
         ErrorCG(gs "You must enter a branch name")
      )

      CheckFormat(gs sf_bname_value)

   )

   case( branchop
      ("create"
         
         
         Checkout(gs "" ?args strcat("-b " sf_bname_value " " parent_branch ) )
         CGbranchSelectFormRefersh()
      )
      ("delete"
         Branch(gs ?args strcat("--delete " parent_branch) )
         CGbranchSelectFormRefersh()
      )
      ("rename"
         Branch(gs ?args strcat("-m " parent_branch " " sf_bname_value) )
         CGbranchSelectFormRefersh()
      )
      ("checkout"
         Checkout(gs "" ?args parent_branch)
         hiFormCancel(cgbranchsel_form)
      )
   )

)
procedure(CGcloneForm()

   importSkillVar(cdsGitAppName)
   formHeader = sprintf(nil "%s Clone Repository" cdsGitAppName)

   
   grid = Gridder()
   gridW = grid->width

   fr_url  = hiCreateFrameField( ?name 'fr_url ?labelText "Repository URL")

   s_url = hiCreateStringField( ?name 's_url ?value "" )

   fr_dirname  = hiCreateFrameField( ?name 'fr_dirname ?labelText "Destination")

   s_dirname = hiCreateStringField( ?name 's_dirname ?value pwd() )

   b_browse = hiCreateFormButton(
      ?name 'b_browse
      ?buttonText "Browse..."
      ?callback "ddsFileBrowseCB( hiGetCurrentForm() 's_dirname \"*\" 'directoryOnly)"
   )

   NewField(grid ?field fr_url      ?x 1 ?y 1 ?w 5 ?h 2 ?prompt 10 ?expand '(10 20 10 0))
   NewField(grid ?field s_url       ?x 1 ?y 1 ?w 5 ?h 1 ?prompt 10)
   NewField(grid ?field fr_dirname  ?x 1 ?y 3 ?w 5 ?h 2 ?prompt 10 ?expand '(10 20 10 0))
   NewField(grid ?field s_dirname   ?x 1 ?y 3 ?w 5 ?h 1 ?prompt 10)
   NewField(grid ?field b_browse    ?x 1 ?y 5 ?w 5 ?h 1 ?prompt 10)


   cgclone_form = hiCreateAppForm(
               ?name 'cgclone_form
               ?formTitle formHeader
               ?callback "CGcloneFormCB()"
               ?fields         grid->fields
               ?attachmentList grid->attachmentList
               ?initialSize    FormSize(grid)
               ?minSize        FormSize(grid)
               ?buttonLayout  'OKCancelApply
         )

   hiDisplayForm(cgclone_form)

)


procedure( CGcloneFormCB()

   giturl = cgclone_form->s_url->value
   gitdst = cgclone_form->s_dirname->value

   gs = GitShell(?path gitdst ?url giturl ?skipCheck t)

   if( gs->verbose printf("URL: %s DESTINIATION: %s" giturl gitdst) )

   CloneRepo(gs)

)
procedure( CGsetupSSHform()

   gs = GitShell(?path "" )

   

   sshKeyPath = strcat("~/.ssh/id_rsa")
   sshKeygenCmd = strcat("ssh-keygen -t rsa -N \"\" -f " sshKeyPath)

   if(!isFile(sshKeyPath) then

      promptStr = strcat("SSH key " sshKeyPath " does not exist, creating one for you in " sshKeyPath "\n Using command " sshKeygenCmd)

      response = Dialog( gs promptStr)

      if( response
         Cmd(gs strcat("dirname " sshKeyPath " | xargs mkdir -p"))
         Cmd(gs sshKeygenCmd)
      )

   )

   sshPubKeyPath = strcat(sshKeyPath ".pub")

   if( isFile(sshKeyPath) then

      fin = infile(sshPubKeyPath)
      gets(sshKeyStr fin)


      importSkillVar(cdsGitAppName)
      formHeader = sprintf(nil "%s SSH Key" cdsGitAppName)

      tf_ssh = hiCreateMLTextField(
            ?name 'tf_ssh
            ?value sshKeyStr
            ?editable t
            ?enableWordWrap t
            ?hasHorizontalScrollbar nil
            )

      
      l_form = hiCreateLabel(   ?name    'l_form
               ?labelText       strcat( "Path to SSH Key: " sshPubKeyPath "\nThe following is your SSH key:")
      )

      cgsetupssh_form = hiCreateAppForm(
         ?name    'cgsetupssh_form
         ?formTitle formHeader
         ?fields
            list(
               list( l_form 10:10   475:35 200 )
               list( tf_ssh  10:60  475:200 200 )
            )
            ?buttonLayout  'OKCancelDefApply
            ?initialSize   t
      )

      hiDisplayForm(cgsetupssh_form)

   else
      ErrorCG(gs strcat("Could not open %s" sshKeyPath) )
   )

)



procedure( CGpathBrowseForm(gs @key (grid nil) (formTitle "") (formLabel "Select a Path") (formCB "") (formMode "directoryOnly") )

   if( !grid then
      grid = Gridder()
   )

   sf_pathname = hiCreateStringField(
      ?name 'sf_pathname
      ?prompt ""
      ?value ""
      ?defValue ""
      ?editable t
   )

   b_browse = hiCreateFormButton(
      ?name       'myFileBrowseBtn
      ?buttonText "Browse"
      ?callback  sprintf(nil "CGpathBrowseFD(\"%s\")" formMode)
   )

   NewField(grid ?field sf_pathname ?appendField t ?w 5 ?h 1 ?frame t ?frameLabel formLabel ?frameName "fr_pathname" )
   NewField(grid ?field b_browse    ?appendField t ?w 5 ?h 1 )


   cgpathbrowseform = hiCreateAppForm(
               ?name 'cgpathbrowseform
               ?formTitle formTitle
               ?callback formCB
               ?fields         grid->fields
               ?attachmentList grid->attachmentList
               ?initialSize    FormSize(grid)
               ?minSize        FormSize(grid)
               ?buttonLayout  'OKCancelApply
         )
   hiDisplayForm(cgpathbrowseform)

)

procedure( CGpathBrowseFD(formMode)

   retval = hiDisplayFileDialog(
      ?dialogName 'myFileDialog
      ?caption "Select Existing Directory"
      
      ?mode evalstring(strcat("'" formMode))
      ?modal t
   )
   retval=buildString(retval)
   retval=simplifyFilename(retval)
   retval=StripCG(GSstr(retval))
   printf("%L\n" retval)
   cgpathbrowseform->sf_pathname->value = retval
)

procedure( CGPBinitForm()

   importSkillVar(cdsGitAppName)

   formTitle = sprintf(nil "%s Initialize a Repository" cdsGitAppName )
   formCB = "CGPBinitFormCB()"

   CGpathBrowseForm( nil ?formTitle formTitle ?formCB formCB ?formMode "directoryOnly")
)

procedure( CGPBinitFormCB()

   gsinit_path = StripCG(GSstr(cgpathbrowseform->sf_pathname->value))

   gs = GitShell( ?path gsinit_path ?skipCheck t)

   Init(gs)
   Check(gs)

   if( gs->valid then
      Info(gs sprintf(nil "Git Repository Initialized in %s" gsinit_path))
   else
      ErrorCG(gs sprintf(nil "Could not Initialize a Git Repository in %s\nCheck that you have permissions" gsinit_path))
   )

)



procedure( CGlibSelectForm( @optional
   (parentForm nil)
   (parentLibField nil) (parentCellField nil) (parentViewField nil)
   (formCB "CGlibSelectCB()") )

   formTitle = sprintf(nil "%s Library Browser" cdsGitAppName)

   
   grid = Gridder()
   grid->width = 80
   gridW = grid->width

   libList = ddGetLibList()~>name

   l_lib = hiCreateListBoxField(
      ?name 'l_lib
      ?prompt ""
      ?choices libList
      ?value list()
      ?defValue list()
      ?valueByPosition nil
      ?callback ""
      ?changeCB "CGlibSelectCBlib"
      ?multipleSelect nil
      ?doubleClickCB ""
      ?CBOnReselect ""
      ?keepHistory nil
      ?enabled t
      ?invisible nil
      ?help ""
   )

   l_cell = hiCreateListBoxField(
      ?name 'l_cell
      ?prompt ""
      ?choices list()
      ?value list()
      ?defValue list()
      ?valueByPosition nil
      ?callback ""
      ?changeCB "CGlibSelectCBcell"
      ?multipleSelect nil
      ?doubleClickCB ""
      ?CBOnReselect ""
      ?keepHistory t
      ?enabled t
      ?invisible nil
      ?help ""
   )

   l_view = hiCreateListBoxField(
      ?name 'l_view
      ?prompt ""
      ?choices list()
      ?value list()
      ?defValue list()
      ?valueByPosition nil
      ?callback ""
      ?changeCB "CGlibSelectCBview"
      ?multipleSelect nil
      ?doubleClickCB ""
      ?CBOnReselect ""
      ?keepHistory t
      ?enabled t
      ?invisible nil
      ?help ""
   )

   s_libfilter   = hiCreateStringField(  ?name    's_libfilter
            ?prompt     ""
            ?value      ""
            ?modifyCallback   "CGlibSelectCBfilter"
   )
   s_cellfilter   = hiCreateStringField(  ?name    's_cellfilter
            ?prompt     ""
            ?value      ""
            ?modifyCallback   "CGlibSelectCBfilter"
   )
   s_viewfilter   = hiCreateStringField(  ?name    's_viewfilter
            ?prompt     ""
            ?value      ""
            ?modifyCallback   "CGlibSelectCBfilter"
   )



   
   
   

   NewField(grid ?field l_lib  ?x 1 ?y 1 ?w 2 ?h 8 ?prompt 0 ?frame t ?frameLabel "Library" ?frameName "f_lib")
   NewField(grid ?field l_cell ?x 3 ?y 1 ?w 2 ?h 8 ?prompt 0 ?frame t ?frameLabel "Cell"    ?frameName "f_cell")
   NewField(grid ?field l_view ?x 5 ?y 1 ?w 2 ?h 8 ?prompt 0 ?frame t ?frameLabel "View"    ?frameName "f_view")

   NewField(grid ?field s_libfilter  ?x 1 ?y 9 ?w 2 ?h 1 ?prompt 0 )
   NewField(grid ?field s_cellfilter ?x 3 ?y 9 ?w 2 ?h 1 ?prompt 0 )
   NewField(grid ?field s_viewfilter ?x 5 ?y 9 ?w 2 ?h 1 ?prompt 0 )

   NewField(grid ?field nil ?x 1 ?y 9 ?w 6 ?h 1 ?frame t ?frameLabel "Filter" ?frameName "f_filter" ?frameExpand '(10 15 10 10) )

   cglibselect_form = hiCreateAppForm(
               ?name 'cglibselect_form
               ?formTitle formTitle
               ?callback  formCB
               ?fields         grid->fields
               ?attachmentList grid->attachmentList
               ?initialSize    FormSize(grid)
               ?minSize        FormSize(grid)
               ?buttonLayout  'OKCancelApply
               ?dontBlock     nil
         )

   
   cglibselect_form->storedLibs  = libList
   cglibselect_form->storedCells = list()
   cglibselect_form->storedViews = list()

   
   cglibselect_form->parentForm      = parentForm
   cglibselect_form->parentLibField  = parentLibField
   cglibselect_form->parentCellField = parentCellField
   cglibselect_form->parentViewField = parentViewField

   
   cglibselect_form->lib
   cglibselect_form->cell
   cglibselect_form->view


   hiDisplayForm(cglibselect_form)

)

procedure( CGlibSelectCB()

   
   parentForm = cglibselect_form->parentForm
   parentLibField  = cglibselect_form->parentLibField
   parentCellField = cglibselect_form->parentCellField
   parentViewField = cglibselect_form->parentViewField

   get(parentForm parentLibField)->value  = cglibselect_form->lib
   get(parentForm parentCellField)->value = cglibselect_form->cell
   get(parentForm parentViewField)->value = cglibselect_form->view

)

procedure( CGlibSelectCBlib()

   current_lib = car(cglibselect_form->l_lib->value)
   cglibselect_form->current_lib = current_lib

   if( current_lib then
      cellList = ddGetObj(current_lib)~>cells~>name
      cglibselect_form->l_cell->choices = cellList
      cglibselect_form->storedCells = cellList
      cglibselect_form->lib = current_lib
   else
      cglibselect_form->l_cell->choices = list()
      cglibselect_form->storedCells = list()
      cglibselect_form->lib = ""
   )
   CGlibSelectCBcell()

)

procedure( CGlibSelectCBcell()

   current_cell = car(cglibselect_form->l_cell->value)
   cglibselect_form->current_cell = current_cell

   if( current_cell then
      viewList = ddGetObj(cglibselect_form->current_lib current_cell)~>views~>name
      cglibselect_form->l_view->choices = viewList
      cglibselect_form->storedViews = viewList
      cglibselect_form->cell =  current_cell
   else
      cglibselect_form->l_view->choices = list()
      cglibselect_form->storedViews = list()
      cglibselect_form->cell = ""
   )
   CGlibSelectCBview()

)

procedure( CGlibSelectCBview()
   current_view = car(cglibselect_form->l_view->value)
   cglibselect_form->current_view = current_view

   if(current_view then
      cglibselect_form->view = current_view
   else
      cglibselect_form->view = ""
   )
)



procedure( CGlibSelectCBfilter(fieldName filterStr sourceOfChange)

   case( fieldName
      ('s_libfilter
         filterList = cglibselect_form->l_lib
         filterChoices = cglibselect_form->storedLibs
      )
      ('s_cellfilter
         filterList = cglibselect_form->l_cell
         filterChoices = cglibselect_form->storedCells
      )
      ('s_viewfilter
         filterList = cglibselect_form->l_view
         filterChoices = cglibselect_form->storedViews
      )

   )

   if( !filterStr || filterStr == "" then
      newChoices = filterChoices
   else
      newChoices = setof( str filterChoices rexMatchp( filterStr str ))
   )


   filterList->choices = newChoices


   cond(

      ( newChoices && length(newChoices) == 1
         filterList->value = newChoices
      )
      ( filterStr && filterStr != ""
         if( member(filterStr newChoices) then
            filterList->value = list(filterStr)
         )
      )
      (t
         filterList->value = list()
      )
   )

   t
)




git_merge_path = strcat(cdsgit_path "/cdsgit-merge")


GITmg_verbose = nil


procedure( GMergeGui( @key (cvid_A nil) (cvid_B nil))



form_title = sprintf(nil "%s Merge GUI" cdsGitAppName)


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



reportHeader = list(
    list( "Name" 150 'left 'string t )
    list( "Type" 80 'left 'string t )
    list( "Diff"   50  'left 'string t )
    )

rfield_choices = list( list("--" "--" "--" "--") )


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
) 
button_highlight = hiCreateButton(
   ?name     'button_highlight
   ?buttonText "Toggle Highlight"
   ?callback  "GMG_highlight()"
) 

toggle_editmode = hiCreateToggleField(
   ?name     'toggle_editmode
   ?prompt   "Edit Mode"
   ?choices   list( '(mode "") )
   ?value     list(GMG_cellEditMode())
   ?callback  list("GMG_editMode()")
) 
toggle_netdiff = hiCreateToggleField(
   ?name     'toggle_netdiff
   ?prompt   "Netist Diff"
   ?choices   list( '(val "") )
   ?value     list(t)
   ?callback  nil
) 
toggle_autoZoom = hiCreateToggleField(
   ?name     'toggle_autoZoom
   ?prompt   "Auto Zoom"
   ?choices   list( '(auto "") )
   ?value     list(t)
   ?callback  nil
) 

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


textLib_A  = hiCreateStringField( ?name 'textLib_A  ?prompt "Library"  ?defValue textLib_A_value  ?editable t)
textCell_A = hiCreateStringField( ?name 'textCell_A ?prompt "Cell"     ?defValue textCell_A_value ?editable t)
textView_A = hiCreateStringField( ?name 'textView_A ?prompt "View"     ?defValue textView_A_value ?editable t)
button_browse_A = hiCreateButton(
         ?name     'button_browse_A
         ?buttonText "CHANGE"
         ?callback  "GMG_button_change_CB(\"A\")"
         ) 
button_open_A = hiCreateButton(
         ?name     'button_open_A
         ?buttonText "OPEN"
         ?callback  "GMG_updateCellViews(?open \"A\")"
         ) 

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

textLib_B  = hiCreateStringField( ?name 'textLib_B  ?prompt "Library" ?defValue textLib_B_value  ?editable t)
textCell_B = hiCreateStringField( ?name 'textCell_B ?prompt "Cell"    ?defValue textCell_B_value ?editable t)
textView_B = hiCreateStringField( ?name 'textView_B ?prompt "View"    ?defValue textView_B_value ?editable t)
button_browse_B = hiCreateButton(
         ?name     'button_browse_B
         ?buttonText "CHANGE"
         ?callback  "GMG_button_change_CB(\"B\")"
         ) 
button_open_B = hiCreateButton(
         ?name     'button_open_B
         ?buttonText "OPEN"
         ?callback  "GMG_updateCellViews(?open \"B\")"
         ) 

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


g=Gridder()
g->width   = 140
g->height  = 30
g->spacing = 7
g->border  = 5


frameOffset = 15
frameHeight = reportRow + reportH-lRow+2
frameRow = 3
frameWidth = 2
frameExpand = 3
dframeHeight = 5

colA = 1
colM = 3
colB = 5

lRow = 4

lcvWidth = 2
lcvOffset = 60

reportRow = lRow+5
reportH = 8

moveRow = reportRow + reportH


NewField(g ?field frame_A  ?x colA ?y frameRow  ?w frameWidth   ?h frameHeight  ?prompt frameOffset ?expand frameExpand)
NewField(g ?field frame_M  ?x colM ?y frameRow  ?w frameWidth   ?h frameHeight  ?prompt frameOffset ?expand frameExpand)
NewField(g ?field frame_B  ?x colB ?y frameRow  ?w frameWidth   ?h frameHeight  ?prompt frameOffset ?expand frameExpand)
NewField(g ?field frame_D  ?x colA ?y moveRow+1 ?w frameWidth*3 ?h dframeHeight ?prompt frameOffset ?expand frameExpand)



NewField(g ?field cyclic_typeFilter  ?x colA   ?y 1 ?w 2 ?h 1 ?prompt 90 )
NewField(g ?field cyclic_diffFilter  ?x colA+1 ?y 1 ?w 1 ?h 1 ?prompt 40 )

NewField(g ?field radio_startPoint  ?x colA ?y frameWidth ?w 3 ?h 1 ?prompt 100 )

NewField(g ?field textLib_A  ?x colA ?y lRow   ?w frameWidth ?h 1 ?prompt lcvOffset )
NewField(g ?field textCell_A ?x colA ?y lRow+1 ?w frameWidth ?h 1 ?prompt lcvOffset )
NewField(g ?field textView_A ?x colA ?y lRow+2 ?w frameWidth ?h 1 ?prompt lcvOffset )

NewField(g ?field button_browse_A ?x colA ?y lRow+3 ?w frameWidth ?h 1 )
NewField(g ?field button_open_A   ?x colA ?y lRow+4 ?w frameWidth ?h 1 )


NewField(g ?field rfield_A   ?x colA ?y reportRow ?w frameWidth ?h reportH ?prompt lcvOffset )

NewField(g ?field button_move_A   ?x colA ?y moveRow ?w frameWidth ?h 1 )


NewField(g ?field button_recompute ?x colM ?y 1 ?w frameWidth ?h 1 )
NewField(g ?field button_highlight ?x colM ?y 2 ?w frameWidth ?h 1 )

NewField(g ?field rfield_M   ?x colM ?y lRow ?w frameWidth ?h reportH+(reportRow-lRow) ?prompt lcvOffset )

NewField(g ?field button_move_M   ?x colM ?y moveRow ?w frameWidth ?h 1 )



NewField(g ?field toggle_editmode  ?x colB   ?y 1 ?w 1 ?h 1 ?prompt 80 )
NewField(g ?field toggle_autoZoom  ?x colB+1 ?y 1 ?w 1 ?h 1 ?prompt 80 )
NewField(g ?field toggle_netdiff   ?x colB   ?y 2 ?w 1 ?h 1 ?prompt 80 )

NewField(g ?field textLib_B  ?x colB ?y lRow   ?w frameWidth ?h 1 ?prompt lcvOffset )
NewField(g ?field textCell_B ?x colB ?y lRow+1 ?w frameWidth ?h 1 ?prompt lcvOffset )
NewField(g ?field textView_B ?x colB ?y lRow+2 ?w frameWidth ?h 1 ?prompt lcvOffset )

NewField(g ?field button_browse_B ?x colB ?y lRow+3 ?w frameWidth ?h 1 )
NewField(g ?field button_open_B   ?x colB ?y lRow+4 ?w frameWidth ?h 1 )

NewField(g ?field rfield_B   ?x colB ?y reportRow ?w frameWidth ?h reportH ?prompt lcvOffset )

NewField(g ?field button_move_B   ?x colB ?y moveRow ?w frameWidth ?h 1 )


NewField(g ?field text_D ?x colA ?y moveRow+2 ?w frameWidth*3 ?h dframeHeight-1 )




hiCreateAppForm(
      ?name 'GMergeGui_form
      ?formTitle form_title

      ?fields g->fields
      ?attachmentList g->attachmentList

      ?buttonLayout 'OKCancelApply
      ?formType 'nonOptions
      ?unmapAfterCB t
      ?initialSize  FormSize(g)
      ?minSize      FormSize(g)
      ?callback nil
      )

hiDisplayForm(GMergeGui_form)

)




procedure( GMG_computeDiff( @key (showDialog t) )

   if( !boundp('GMG_verbose) GMG_verbose = nil)

   if( showDialog
      response = hiDisplayAppDBox(
         ?name 'updateDestinationWarn
         ?dboxBanner "Diff Recompute Warning"
         ?dboxText "Warning: The action you have selected will recompute the diff\nYou will not be able to undo current merged changes"
         ?buttonLayout 'OKCancel
      )
   )
   if( !showDialog || response then

      GMG_updateCellViews()

      if( GMG_validateCv() then

         
         destination = GMergeGui_form->radio_startPoint->value

         if(destination == "A" then
            srcCv = cvidB
            dstCv = cvidA
         else
            srcCv = cvidA
            dstCv = cvidB
         )

         netDiff = GMergeGui_form->toggle_netdiff->value

         GMrunDiff(?srcCv srcCv ?dstCv dstCv ?netDiff netDiff)
         GMG_setChoices()
         GMG_filterPopulate()
         GMergeGui_form->text_D->value = ""
      else
         GMdiffPairObj = nil
         GMG_setChoices()
         GMergeGui_form->text_D->value = "*** Cannot open current cell views for read ***"
      )
   )

)




procedure( GMG_updateSelected( values choices)

   foreach(value values
      selected = nthelem(1+value choices)
      diffObj = nthelem(4 selected)
      AddChange(GMdiffPairObj diffObj)
   )
   MakeChanges(GMdiffPairObj)
   HighlightDiffs(GMdiffPairObj)
)

procedure( GMG_updateCellViews( @key (open nil) )
let( (cv)
   cvidA = dbOpenCellViewByType(GMergeGui_form->textLib_A->value  GMergeGui_form->textCell_A->value GMergeGui_form->textView_A->value nil "r")
   cvidB = dbOpenCellViewByType(GMergeGui_form->textLib_B->value  GMergeGui_form->textCell_B->value GMergeGui_form->textView_B->value nil "r")

   case(open
      ("A" cv=cvidA)
      ("B" cv=cvidB)
      (t   open = nil)
   )
   if(open then
      wid = geGetCellViewWindow(cv)
      if( wid then
         hiRaiseWindow(wid)
      else
         deOpenCellView(cv->libName cv->cellName cv->viewName cv->cellViewType nil cv->mode)
      )
   )
)
)



procedure( GMG_rfield_CB(fieldName selectedItems "sl")

if(GMG_verbose printf( "Report field callback, fieldName = %L, selectedItems = %L\n"
                           fieldName selectedItems ))
if(selectedItems then

   case(fieldName
   ('rfield_A
      if(GMG_verbose printf("A\n"))
   )
   ('rfield_M
      if(GMG_verbose printf("M\n"))
   )
   ('rfield_B
      if(GMG_verbose printf("B\n"))
   )
   )

   selection = car(selectedItems)
   choices = evalstring(strcat("GMergeGui_form->" fieldName "->choices"))
   choice  = nthelem(selection+1 choices)
   diffObj = nthelem(4 choice)

   GMergeGui_form->text_D->value = Details(diffObj)
)


foreach(cv list(cvidA cvidB)
   wid = geGetCellViewWindow(cv)
   if(wid then geDeselectAll(wid) )
)

zoomBoth = nil
foreach(selection selectedItems
   choices = evalstring(strcat("GMergeGui_form->" fieldName "->choices"))
   choice  = nthelem(selection+1 choices)
   diffObj = nthelem(4 choice)
   if( diffObj->status == "partial" zoomBoth = t)
   GMG_selectInst(diffObj)
)
if( GMergeGui_form->toggle_autoZoom->auto->value then
   if(zoomBoth then
      GMG_zoomFit('rfield_A)
      GMG_zoomFit('rfield_B)
   else
      GMG_zoomFit(fieldName)
   )

)


)


procedure( GMG_clearForm()

   GMergeGui_form->text_D->value = ""

   GMergeGui_form -> rfield_A -> choices = list()
   GMergeGui_form -> rfield_M -> choices = list()
   GMergeGui_form -> rfield_B -> choices = list()

)


procedure( GMG_button_change_CB(fieldName)
   case(fieldName
   ("A"
      CGlibSelectForm(GMergeGui_form 'textLib_A 'textCell_A 'textView_A )
   )
   ("B"
      CGlibSelectForm(GMergeGui_form 'textLib_B 'textCell_B 'textView_B )
   )
   )

   
   Cleanup(GMdiffPairObj)
   GMG_clearForm()

)


procedure( GMG_mbutton_CB(fieldName)

   cellsEditable = GMG_checkEditMode()

   if(cellsEditable then
      choicesList = GMG_getChoices()

      case(fieldName
      ("A"
         values  = GMergeGui_form -> rfield_A -> value
         choices = nthelem(1 choicesList)
      )
      ("M"
         values  = GMergeGui_form -> rfield_M -> value
         choices = nthelem(2 choicesList)
      )
      ("B"
         values  = GMergeGui_form -> rfield_B -> value
         choices = nthelem(3 choicesList)
      )
      )

      choicesList = GMG_getChoices()
      choicesList = GMG_updateSelected(values choices)

      GMG_setChoices()
   )

   t
)

procedure( GMG_checkEditMode()

   if(!GMG_cellEditMode() then
      response = hiDisplayAppDBox(
         ?name 'editModeWarning
         ?dboxBanner "Edit Mode Warning"
         ?dboxText "Warning: The selected cells are not editable\nWould you like to open them for edit?"
         ?buttonLayout 'OKCancel
      )
      if(response then
            GMergeGui_form->toggle_editmode->mode->value = t
            GMG_editMode()
      )


      if(!GMG_cellEditMode() then
         error("Could not open cells for edit. Aborting")
      )
   )
   t
)

procedure( GMG_cellEditMode()
   if( GMG_validateCv() then
      editable = (cvidA->mode == "a" && cvidB->mode == "a")
   )
)


procedure( GMG_getChoices()

   choices_A = GMergeGui_form -> rfield_A -> choices
   choices_M = GMergeGui_form -> rfield_M -> choices
   choices_B = GMergeGui_form -> rfield_B -> choices

   list(choices_A choices_M choices_B)
)

procedure( GMG_validateCv()

   boundp('cvidA) && boundp('cvidB) && cvidA && cvidB

)


procedure( GMG_setChoices()
   if( GMdiffPairObj then
      diffList    = ToReport(GMdiffPairObj)

      GMergeGui_form -> rfield_A -> choices = nil
      GMergeGui_form -> rfield_M -> choices = nil
      GMergeGui_form -> rfield_B -> choices = nil

      foreach(diff diffList
         diffObj = nthelem(4 diff)
         diffState = diffObj->merged

         if(GMG_verbose Print(diffObj))

         if(diffObj->visible then
         case( diffState
            (nil
               if( diffObj->status == "partial" then obj = diffObj->refObj
               else                                  obj = diffObj->obj    )
               if( obj->cellView == cvidA then
                  GMergeGui_form -> rfield_A -> choices = cons( diff GMergeGui_form -> rfield_A -> choices)
               else
                  GMergeGui_form -> rfield_B -> choices = cons( diff GMergeGui_form -> rfield_B -> choices)
               )
            )
            (t
               GMergeGui_form -> rfield_M -> choices = cons( diff GMergeGui_form -> rfield_M -> choices)
            )

         )
         )
      )
   else
      GMergeGui_form -> rfield_A -> choices = list()
      GMergeGui_form -> rfield_M -> choices = list()
      GMergeGui_form -> rfield_B -> choices = list()
   )

)



procedure(GMG_filter()

tFilterValue = GMergeGui_form->cyclic_typeFilter->value
dFilterValue   = GMergeGui_form->cyclic_diffFilter->value

   GMdiffPairObj->diffList = foreach(diff GMdiffPairObj->diffList

      if(
         (tFilterValue == "All" || tFilterValue=="-----" || diff->type   == tFilterValue ) &&
         (dFilterValue == "All" || dFilterValue=="-----" || diff->status == dFilterValue )
      then
         diff->visible = t
      else
         diff->visible = nil
      )

   )
   GMG_setChoices()
)


procedure(GMG_filterPopulate()

   filterList = list( "-----" "None" "All")

   foreach(diff GMdiffPairObj->diffList
      if( !diff->type then
         error("No type for diff %d" diff->id)
      )
      if( diff->type && !member(diff->type filterList) then
         filterList = cons( sprintf(nil diff->type) filterList)
      )
   )

   GMergeGui_form->cyclic_typeFilter->choices = reverse(filterList)
   GMergeGui_form->cyclic_typeFilter->value = "All"

)


procedure( GMG_updateDestination()

if( !boundp('ignoreDialog) || !ignoreDialog then

   diffComputed = GMG_computeDiff(?showDialog t)

   if(!diffComputed then
      
      currentValue = GMergeGui_form->radio_startPoint->value
      if(currentValue == "A" then
         newValue = "B"
      else
         newValue = "A"
      )
      ignoreDialog = t
      GMergeGui_form->radio_startPoint->value = newValue

   )
else
   ignoreDialog = nil
)

)

procedure( GMG_editMode()
   if( GMG_validateCv() then
      if(GMergeGui_form->toggle_editmode->mode->value then
         dbReopen(cvidA "a")
         dbReopen(cvidB "a")
      else
         dbReopen(cvidA "r")
         dbReopen(cvidB "r")
      )
   )

)

procedure( GMG_highlight()
   if(!GMdiffPairObj->highlighted then
      HighlightDiffs(GMdiffPairObj)
   else
      DeleteHighlights(GMdiffPairObj)
   )
)

procedure( GMG_selectInst(diffObj)

   Select(diffObj)
   
)

procedure( GMG_zoomFit(fieldName)
case(fieldName
   ('rfield_A cvid = cvidA)
   ('rfield_B cvid = cvidB)
   (t cvid = nil)
)
   if(cvid then
      wid = geGetCellViewWindow(cvid)
      if(wid then
         printf("wid %L\n" wid)
         insts = geGetSelSet(wid)
         bbox = GMG_getBBox(insts)
         hiZoomIn(wid bbox)
      )
   )
)

procedure(GMG_getBBox(@optional objects "l")
  let( (lx rx ly uy)
    
    
    unless(objects && forall(obj objects dbobjectp(obj))
      
      objects = geGetSelectedSet()
    )
    
    
    when(objects
      lx = xCoord(lowerLeft(car(objects)~>bBox))
      rx = xCoord(upperRight(car(objects)~>bBox))
      ly = yCoord(lowerLeft(car(objects)~>bBox))
      uy = yCoord(upperRight(car(objects)~>bBox))
      
      
      
      foreach(obj objects
   lx = min(lx xCoord(lowerLeft(obj~>bBox)))
   ly = min(ly yCoord(lowerLeft(obj~>bBox)))
   uy = max(uy yCoord(upperRight(obj~>bBox)))
   rx = max(rx xCoord(upperRight(obj~>bBox)))
      )
      
      list(list(lx ly) list(rx uy))
    )
  )
)


procedure( GMG_get_diff(id)
   GetDiff( GMdiffPairObj id)
)

procedure( GMrunDiff( @key (srcCv nil) (dstCv nil) (netDiff nil) )
   GMrunSchDiff(?srcCv srcCv ?dstCv dstCv ?netDiff netDiff)
)


procedure( GMrunSchDiff( @key (srcCv nil) (dstCv nil) (netDiff nil) )

   if(!srcCv || !dstCv then error("GMrunDiff: both dstCv and srcCv must be valid cell views") )

   verbose = t

   
   GMdiffPairObj  = makeInstance( 'GMdiffPairs
                                    ?srcCv srcCv
                                    ?dstCv dstCv
                                    ?verbose verbose
                                    ?netDiff netDiff
                                    )
   Init(GMdiffPairObj)

   
   GMdiffPairObj = GMD_createInsts(GMdiffPairObj)
   GMdiffPairObj = GMD_createShapes(GMdiffPairObj)
   DiffPairs(GMdiffPairObj)
   GMdiffPairObj = GMD_createNets(GMdiffPairObj)
   DiffPairs(GMdiffPairObj)

   FindChildren(GMdiffPairObj)

   HighlightDiffs(GMdiffPairObj)

   diffList    = ToReport(GMdiffPairObj)

)




procedure( GITcreatePin(cvid refPin)

ip = dbOpenCellViewByType(  "basic" "ipin"  "symbol" "" "r")
op = dbOpenCellViewByType(  "basic" "opin"  "symbol" "" "r")
iop = dbOpenCellViewByType( "basic" "iopin" "symbol" "" "r")


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



schCreatePin(
   cvid
   dir
   refPin->name
   refPin->direction
   nil
   pLocation
   pOrientation
)

)





inSkill(
procedure( GMgenerateID()

   if(!boundp('GMuniqueID_cnt) then
      GMuniqueID_cnt = 0
   else
      GMuniqueID_cnt = GMuniqueID_cnt + 1
   )
   GMuniqueID_cnt
)
)





defclass( GMdiffPairs
   
   ()

   
   (
      (objsSrc     @initarg  objsSrc)
      (objsDst     @initarg  objsDst)
      (diffList    @initform list())
      (dstCv       @initarg  dstCv)
      (srcCv       @initarg  srcCv)
      (bckCv       @initarg  bckCv)
      (toChange    @initarg  toChange @initform nil)

      
      (highlighted @initform nil @initarg highlighted)
      (setLpps     @initform nil )
      (hiliteSrc   @initarg  hiliteSrc)
      (hiliteDst   @initarg  hiliteDst)

      
      (verbose @initform nil @initarg  verbose)
      (netDiff @initform nil @initarg  netDiff)

   )
)



defmethod( Init (( diffPairs GMdiffPairs ) )
   diffPairs->objsSrc = makeTable("diffObj" nil)
   diffPairs->objsDst = makeTable("diffObj" nil)

   
)

defmethod( Cleanup (( diffPairs GMdiffPairs ) )
   
)

defmethod( AddDiffObj (( diffPairs GMdiffPairs ) @key (obj nil) (key nil) (group nil))
   if(obj then
      if(!key then
         key = obj->name
      )

      objs = get(diffPairs group)

      
      
      
      while( objs[key]
         key = strcat( key "x")
         if(diffPairs->verbose warn("A key was appened %s " obj->name))
      )

      obj->key = key

      objs[key] = obj
   )
)


defmethod( FindByObj (( diffPairs GMdiffPairs ) @key (obj nil) (searchObjs nil))

   diff = setof(diffItem diffPairs->diffList eq(diffItem->obj obj) || eq(diffItem->refObj obj) )

   if( diff then
      diff = car(diff)
   )
)


defmethod( RemoveByObj (( diffPairs GMdiffPairs ) @key (objs nil))

   if( type(objs) != 'list then
      objs = list(objs)
   )

   foreach( obj objs
      diff = setof(diffItem diffPairs->diffList eq(diffItem->obj obj))
      if(diff then
         diff = car(diff)
         if( diffPairs->verbose printf("GMdiffPairs: Removing diff object %L %s\n" diff diff->name) )
         diffPairs->diffList = remove(diff diffPairs->diffList)
      )
   )
   diffPairs
)


defmethod( AddDiff (( diffPairs GMdiffPairs ) newDiff)
   diffPairs->diffList = cons(newDiff diffPairs->diffList)
)



defmethod( DiffPairs (( diffPairs GMdiffPairs ) )
   let( (
         ( objsSrc diffPairs->objsSrc )
         ( objsDst diffPairs->objsDst )
         ( verbose diffPairs->verbose )
         genNewDiff
      )

      
      foreach(objSrcKey objsSrc

         objSrc = objsSrc[objSrcKey]

         objDstKey = objSrcKey
         if(verbose printf("Searching for Exact Match for %s\n" Print(objSrc)) )
         matchStatus = nil

         while( objsDst[objDstKey] && !matchStatus
            objDst = objsDst[objDstKey]

            if( objDst then

                  matchStatus = Diff(objSrc objDst)

                  if(matchStatus == t then
                     if(verbose printf("Exact match %s\n" Print(objSrc)) )
                     remove(objSrcKey objsSrc)
                     remove(objDstKey objsDst)
                  )
            )
            objDstKey = strcat(objDstKey "x") 
         )

      )

      
      foreach(objSrcKey objsSrc

         

         objSrc = objsSrc[objSrcKey]
         objDst = objsDst[objSrcKey]

         if(verbose printf("Searching for Partial Match for %s\n" Print(objSrc)) )
         matchStatus = nil

         if( objDst then

               matchStatus = Diff(objSrc objDst)

               if(matchStatus != t && matchStatus != nil then
                  if(verbose printf("Partial match %s Result: %L \n" Print(objSrc) matchStatus) )

                  remove(objSrcKey objsSrc)
                  remove(objSrcKey objsDst)

                  
                  newDiff = NewDiff(objDst
                     ?refObj objSrc->obj
                     ?status "partial"
                     ?props matchStatus
                  )

                  AddDiff(diffPairs newDiff)


               )

         )

      )

      
      foreach(objTable list(objsSrc objsDst)
         foreach(key objTable
            newDiff = NewDiff( objTable[key]
               ?status "new"
                      )
            AddDiff(diffPairs newDiff)
            if(verbose printf("New Diff %s\n" Print(newDiff)) )
            remove(key objTable)
         )
      )

      diffPairs -> objsSrc = objsSrc
      diffPairs -> objsDst = objsDst
      diffPairs

   )
)





defmethod( FindChildren (( diffPairs GMdiffPairs ) @key (depth 0))

   diffList = diffPairs->diffList
   foreach(diff diffList
      FindChildren(diff)
   )

   
   foreach(diff diffList
      if(diff->isChild? then
         diffPairs->diffList = remove(diff diffPairs->diffList)
      )
   )
)

defmethod( FlattenChildren (( diffPairs GMdiffPairs ) )
   flatList = list()
   foreach(diff diffPairs->diffList
      flatList = append(flatList FlattenChildren(diff))
   )
   flatList
)




defmethod( AddChange (( diffPairs GMdiffPairs ) diffObj)
   diffPairs->toChange = cons( diffObj diffPairs->toChange )
)


defmethod( MakeChanges (( diffPairs GMdiffPairs ) )

   
   foreach(diff diffPairs->toChange
      ChangeState(diff)
   )

   
   UpdateDiffAttrs(diffPairs)

   
   diffPairs->toChange = nil

)



defmethod( UpdateDiffAttrs (( diffPairs GMdiffPairs ) )

   
   UpdateWireAttrs(diffPairs)

)



defmethod( ToReport (( diffPairs GMdiffPairs ) )

   diffList = list()

   appendList = lambda( (list item)
      list = cons( ToReport(item) list)
   )

   foreach( diffItem diffPairs->diffList
      diffList = appendList(diffList diffItem)
   )


   diffList
)

defmethod( PrintTables (( diffPairs GMdiffPairs ) )
   printf("Src: %L\nDst: %L\n" tableToList(diffPairs->objsSrc) tableToList(diffPairs->objsDst))
)




defmethod( HighlightDiffs (( diffPairs GMdiffPairs ) )
   diffList = diffPairs->diffList

   DeleteHighlights(diffPairs)

   
   

   hiliteSrc = makeTable("hliteTable" nil)
   hiliteDst = makeTable("hliteTable" nil)

   hiliteSrc["new"]     = geCreateHilightSet( diffPairs->srcCv list("annotate" "drawing7") )
   hiliteSrc["partial"] = geCreateHilightSet( diffPairs->srcCv list("annotate" "drawing4") )
   hiliteSrc["merged"]  = geCreateHilightSet( diffPairs->srcCv list("annotate" "drawing2") )

   hiliteDst["new"]     = geCreateHilightSet( diffPairs->dstCv list("annotate" "drawing7") )
   hiliteDst["partial"] = geCreateHilightSet( diffPairs->dstCv list("annotate" "drawing4") )
   hiliteDst["merged"]  = geCreateHilightSet( diffPairs->dstCv list("annotate" "drawing2") )

   diffPairs->hiliteSrc = hiliteSrc
   diffPairs->hiliteDst = hiliteDst

   foreach(diff diffList
      Highlight(diff)
   )
   diffPairs->highlighted = t
   diffPairs
)

defmethod( DeleteHighlights (( diffPairs GMdiffPairs ) )
   geDeleteAllHilightSet(diffPairs->srcCv)
   geDeleteAllHilightSet(diffPairs->dstCv)
   diffPairs->highlighted = nil
)

defmethod( GetWids (( diffPairs GMdiffPairs ) )
   diffPairs->widSrc = geGetCellViewWindow(diffPairs->srcCv)
   diffPairs->widDst = geGetCellViewWindow(diffPairs->dstCv)
)


defmethod( GetDiff (( diffPairs GMdiffPairs ) diffId)
   retDiff = nil
   foreach(diff diffPairs->diffList
      if( diff->id == diffId then retDiff = diff )
   )
   retDiff

)



defclass( GMdiff
   
   ()

   
   (
      ( id        @initarg  id  @initform GMgenerateID() )

      (diffPairs  @initarg  diffPairs)

      
      ( name      @initarg  name )                   
      ( key       @initarg  key )                    
      ( dispName  @initform "" @initarg  dispName )  
      ( type      @initarg  type)                    
      ( status    @initarg  status )                 
      ( props     @initarg  props )                  

      
      ( obj       @initarg  obj )                    
      ( refObj    @initarg  refObj )                 
      ( genObj    @initform nil @initarg  genObj  )  
      ( srcCv     @initarg  srcCv)                   
      ( dstCv     @initarg  dstCv)                   
      ( isDst?    @initarg  isDst?)                  
      ( genFail   @initform nil @initarg  genFail )  

      
      ( children   @initform list() @initarg children )      
      ( isChild?   @initform nil    @initarg isChild? )      
      ( parent     @initarg parent )                         

      
      ( merged    @initarg  merged   @initform nil)      
      ( visible   @initarg  visible @initform t)     

      
      ( verbose   @initform  nil @initarg verbose)
   )

)




defmethod( NewDiff (( diff GMdiff) @key
   (status nil)
   (refObj nil)
   (props nil)
   (parent nil)
)



   case( status
      ("new"      t )
      ("partial"  t
         if( !refObj then
            if( !diff->refObj then
               error("GMdiff: partial diffs must include refObj to link to")
            else
               refObj = diff->refObj
            )
         )
         if( !props    error("GMdiff: partial diffs must include match properties")   )
      )
      (t          error("GMdiff: Type must be 'new' or 'partial'") )
   )

   case(diff->type
      ("pin"  dispName = diff->obj->net->name)
      (t      dispName = diff->name)
   )

   
   if( strlen(dispName) > 20 then
      dispName = strncat("" dispName 20)
      dispName = strcat(dispName "...")
   )

   diff->dispName  = dispName
   diff->verbose   = diff->diffPairs->verbose
   diff->srcCv     = diff->diffPairs->srcCv
   diff->dstCv     = diff->diffPairs->dstCv
   diff->isDst?    = eq(diff->dstCv diff->obj->cellView) && status == "new"
   diff->status    = status
   diff->refObj    = refObj
   diff->props     = props
   diff->parent    = parent

   diff

)



defmethod( Print (( diff GMdiff ) )

str = sprintf(nil "ID: %d Name: %s DName: %L Type: %s  Merged %L\n" diff->id diff->name diff->dispName diff->type diff->merged)

)


defmethod( Details ((diff GMdiff ) )

   str = sprintf(nil "Name:%s   Type:%s   Diff Type:%s   ID:%d   " diff->name diff->type diff->status diff->id )

   if( !diff->merged then
      mergeStatus = "UNMERGED"
   else
      mergeStatus = "MERGED"
   )

   if(diff->verbose str = sprintf(nil "%sKey: %s\n" str diff->key) )

   if(diff->verbose && diff->children then str = sprintf(nil "%sChildren:\n%s" str PrintChildren(diff "")) )

   str = strcat(str sprintf(nil "MERGE STATUS: %s\n" mergeStatus))


)

defmethod( ToReport (( diff GMdiff ) @key (text "") )
   list( diff->dispName diff->type diff->status diff)
)



defmethod( ChangeState (( diff GMdiff ) )

   if( !diff->merged then
      
      if(diff->status == "partial" then
         UpdateAttr(diff)
         ChangeChildrenState(diff)
      else
         if( diff->isDst? then
            ChangeChildrenState(diff)
            DestroyCG(diff)
         else
            Create(diff)
            ChangeChildrenState(diff)
         )
      )
   else
      
      if(diff->status == "partial" then
         RestoreAttr(diff)
         ChangeChildrenState(diff)
      else
         if( diff->isDst? then
            Create(diff)
            ChangeChildrenState(diff)
         else
            ChangeChildrenState(diff)
            DestroyCG(diff)
         )
      )
   )

   ToggleState(diff)

)

defmethod( ToggleState (( diff GMdiff ) )
   diff->merged = !diff->merged
   if(diff->verbose printf("GMdiff Merged State %d Toggled to %L\n" diff->id diff->merged))
)

defmethod( ChangeChildrenState (( diff GMdiff ) )
   if(!diff->genFail then
      foreach(child diff->children
         ChangeState(child)
      )
   else
      warn("Child creation skipped, forcing toggle")
      ToggleChildrenState(diff)
      diff->genFail = nil
  )
)

defmethod( ToggleChildrenState (( diff GMdiff ) )
   ToggleState(diff)
   foreach(child diff->children
      ToggleChildrenState(child)
   )
)

defmethod( Highlight (( diff GMdiff ))
   error("GMdiff Highlight: Subclass should define this method")
)



defclass( GMobj
   
   (GMdiff)

   
   (
      (type         @initform "inst" @initarg type)
      (attrs        @initform GMD_instAttrs() )
      (attrsStored  @initform list() @initarg attrsStored)
      (propsStored  @initform list() @initarg propsStored)
      (hardAttrs    @initarg hardAttrs)
      (softAttrs    @initarg softAttrs)
      (propAttrs    @initarg propAttrs)
   )

)





defmethod( Details (( inst GMobj ) )

   str = callNextMethod(inst)

   if( inst->status=="new" then
      header = "New"
   else
      header = "Differences"
   )

   str = sprintf(nil "%s-------Instance %s %s ---\n" str inst->name header)

   if(inst->verbose str = sprintf(nil "%sProps:%L\n" str inst->props))

   if(inst->status=="partial" then
      attrList = append(inst->softAttrs inst->propAttrs)
      if( length(inst->props) != length(attrList) then error("GMobj Details: attr list should match property length\n") )
   else
      attrList = inst->attrs
   )
   for(i 1 length(attrList)
      currAttr = nthelem(i attrList)
      attrName = car(currAttr)
      if(inst->status=="partial" then
         attrDiff = nthelem(i inst->props)
      else
         attrDiff = nil
      )
      if( !attrDiff then
         str = sprintf(nil "%s%s: %L: \n" str attrName get(inst->obj attrName))
      )
   )
   str

)

defmethod( PrintChildren  (( inst GMobj) str @key (tab "\t"))
   foreach( child inst->children
      cellStr = child->obj->cellView->cellName
      if(!cellStr cellStr="**invalid cell**, object does not exist")
      str = sprintf(nil "%s%s%L %d %s from %s\n" str tab child child->id child->dispName cellStr)
      str = PrintChildren(child str ?tab strcat(tab "\t"))
   )
   str
)



defmethod( Diff   (( instX GMobj) instY )

   attrList  = instX->attrs
   hardAttrs = instX->hardAttrs
   softAttrs = instX->softAttrs
   propAttrs = instX->propAttrs

   
   newDiff = nil
   foreach(attr hardAttrs
      attrName = car(attr)
      diffResult = DiffAttr(instX instY attrName)
      if( !diffResult then
         newDiff = t
      )
   )

   if( !newDiff && propAttrs && (length(instX->propAttrs) != length(instY->propAttrs)) then
      warn("GMobj Diff: Attribute List's did not match on partiall matched instances\n
         You man need to run a callback and rerun the diff\nInstances:%s %s" instX->name instY->name)
      newDiff = t
   )

   
   if( !newDiff then
      statusList = nil
      foreach(attr softAttrs
         attrName = car(attr)
         diffResult = DiffAttr(instX instY attrName)
         statusList = cons( diffResult statusList)
      )
      
      if(propAttrs then
         instY->propAttrs = propAttrs
         foreach( attr propAttrs
            attrName = car(attr)
            diffResult = DiffAttr(instX instY attrName ?isProp t)
            statusList = cons( diffResult statusList)
         )
      )

      statusList = reverse(statusList)

      
      if( !member(nil statusList)  then
         matchStatus = t
      else
         matchStatus = statusList
      )
   else
      matchStatus = nil
   )
   matchStatus

)



defmethod( DiffAttr ((objX GMobj) objY attribute @key (isProp nil) )

   attrX = GetAttr( objX attribute ?isProp isProp)
   attrY = GetAttr( objY attribute ?isProp isProp)
   if(objX->verbose printf("%L %L %L\n" attrX attrY attrX==attrY))
   attrX == attrY

)

defmethod( GetAttr ((obj GMobj) attribute @key (source nil) (isProp nil))
   if( !source then
      source = obj->obj
   )
   if(isProp then
      val = car(setof(p source->prop p->name==attribute))->value
   else
      val = get(source attribute)
   )

)

defmethod( SetAttr ((obj GMobj) attribute value @key (target nil) )
   if( !target then
      target = obj->obj
   )
   dbSet( target value attribute )
)

defmethod( FilterAttr ((obj GMobj) )

   
   obj->hardAttrs = setof(a obj->attrs cadr(a)=="hard")
   obj->softAttrs = setof(a obj->attrs cadr(a)=="soft")
   obj->propAttrs = setof(a obj->attrs cadr(a)=="prop")
)

defmethod( StoreAttr (( inst GMobj) attribute @key (source nil))
   storeAttr = list(list(attribute GetAttr(inst attribute ?source source) ))
   inst->attrsStored = append( inst->attrsStored storeAttr)
)






defmethod( UpdateAttr (( inst GMobj ) @key (source nil) (target nil))

   if( !source then source = inst->refObj)
   if( !target then target = inst->obj)

   attrList = append(inst->softAttrs inst->propAttrs)

   
   for( i  1 length(attrList)
      currAttr = nthelem(i attrList)
      attrName = car(currAttr)
      newValue = GetAttr(inst attrName ?source source)
      if( !nthelem( i inst->props) then
         StoreAttr(inst attrName)
         SetAttr(inst attrName newValue ?target target)
      )
   )
)
defmethod( RestoreAttr (( inst GMobj ) @key (attrSet nil) (target nil))

   if( !attrSet attrSet=inst->attrsStored )

   foreach(attr attrSet
      attrName = car(attr)
      attrValue = cadr(attr)
      SetAttr(inst attrName attrValue ?target target)
   )
)
defmethod( RestoreProps (( inst GMobj ) @key (target nil))

   props = inst->propAttrs
   attrSet = list()
   foreach(attr inst->attrsStored
      if( setof(p props car(p)==car(attr) ) then
         attrSet = cons(attr attrSet)
      )
   )

   RestoreAttr(inst ?attrSet attrSet ?target target)
)

defmethod( StoreAttrs (( inst GMobj ) @key (source nil))

   attrList = append( inst->attrs inst->propAttrs)

   
   foreach( attr attrList
      attrName = car(attr)
      StoreAttr(inst attrName ?source source)
   )
)

defmethod( GetStoredAttrs (( inst GMobj ) )
   obj = ncons(nil)
   foreach( attr inst->attrsStored
      putprop(obj cadr(attr) car(attr))
   )
   obj
)



defmethod( Create (( inst GMobj ) )
   
   

)


defmethod( CreateFromObj (( obj GMobj ) dbObj)
   newObj = nil
   case(dbObj->objType
      
      
      
      ( list("line" "label" "textDisplay")
         newObj = GMD_createShape_func( dbObj obj->diffPairs )
      )
      
      ( list("marker")
         newObj = nil
      )
      (t
         error("GMobj CreateFromObj: Did not recognize dbObj->objType %s\n" dbObj->objType)
      )
   )
   newObj
)

defmethod( AddGenObj (( inst GMobj ) genObj)
   if( genObj then

      
      if( type(genObj) == 'list then
         if(length(genObj) > 1 then
            error("GMobj AddGenObj: Create returned more than one object!")
         )
         genObj = car(genObj)
      )
      
      if(inst->isDst? then
         inst->obj = genObj
      else
         inst->genObj = genObj
      )
   else
      str = sprintf(nil "GMobj %s AddGenObj: Creation of object %s failed. Is the destination cell writable?\n"
         className(classOf( inst )) inst->name )
      inst->genFail = t
      warn(str)
   )
)

defmethod( GetCreate  (( inst GMobj ) )
   if( inst->isDst? then
      refObj = GetStoredAttrs(inst)
   else
      refObj = inst->obj
   )
   if(!refObj error("GMobj GetCreate: No ref obj found!\n"))
   refObj
)

defmethod( GetParentObj (( inst GMobj) )

   if( inst->isDst? then
      parentObj = inst->parent->obj
   else
      parentObj = inst->parent->genObj
   )

   parentObj

)

defmethod( DestroyCG (( inst GMobj )  )

   if( inst->isDst? then
      StoreAttrs(inst)
      delObj = inst->obj
   else
      delObj = inst->genObj
   )

   if( type(delObj) == 'list then
      foreach(inst delObj
         dbDeleteObject(inst)
      )
   else
      dbDeleteObject(delObj)
   )

   if( inst->isDst? then
      inst->obj = nil
   else
      inst->genObj = nil
   )

)




defmethod( CreateParent (( inst GMobj ))
   error("GMobj CreateParent: This function should be defined by a sub-class")
)



defmethod( FindChildren (( obj GMobj ) @key (depth 1))

   foreach(child GetChildFromObj(obj)

      newObj = CreateFromObj(obj child)

      if( newObj then

         
         diff = car(setof(diff obj->diffPairs->diffList diff->obj == child))
         if(diff then
            diff->isChild? = t
         )

         
         newObj = NewDiff( newObj ?status "new" ?parent obj)

         if(obj->verbose printf("Parent: %L Child %L %d Name Class %s\n" obj newObj depth newObj->dispName classOf(newObj)) )


         
         newObj = FindChildren(newObj ?depth depth+1)

         
         obj->children = cons(newObj obj->children)

         printf("%L\n" obj->children)
      )

   )
   obj
)

defmethod( GetChildFromObj (( obj GMobj ) )

   children = obj->obj->children
   children
)


defmethod( FlattenChildren (( obj GMobj ) )
   flatList = list(obj)
   foreach( child obj->children
      flatList = append(flatList FlattenChildren(child))
   )
   flatList
)




defmethod( Highlight (( diff GMobj ))


   hiliteSrc = diff->diffPairs->hiliteSrc
   hiliteDst = diff->diffPairs->hiliteDst

   hiliteSet    = nil
   hiliteSetRef = nil
   hiliteSetGen = nil
   hiliteObj    = diff->obj
   hiliteObjRef = diff->refObj
   hiliteObjGen = diff->genObj

   if(diff->merged then
      key = "merged"
   else
      key = diff->status
   )

   diffCv = hiliteObj->cellView
   srcCv  = diff->diffPairs->srcCv
   dstCv  = diff->diffPairs->dstCv

   if( eq(diffCv srcCv) hiliteSet = hiliteSrc[key] )
   if( eq(diffCv dstCv) hiliteSet = hiliteDst[key] )

   
   if( hiliteObjRef then hiliteSetRef = hiliteSrc[key] )

   
   if( hiliteObjGen then hiliteSetGen = hiliteDst[key] )

   drawAll = t
   if(diff->type == "pin" then
      drawAll = nil
   )

   if( hiliteSet then
      hiliteSet->enable = t
      if(hiliteSet->cellView != hiliteObj->cellView  warn("Highlight cv did not match cell cv") )
      geAddHilightFig(hiliteSet hiliteObj drawAll)
   )
   if( hiliteSetRef then
      hiliteSetRef->enable = t
      if(hiliteSetRef->cellView != hiliteObjRef->cellView  warn("Highlight cv did not match cell cv") )
      geAddHilightFig(hiliteSetRef hiliteObjRef drawAll)
   )
   if( hiliteSetGen then
      hiliteSetGen->enable = t
      if(hiliteSetGen->cellView != hiliteObjGen->cellView  warn("Highlight cv did not match cell cv") )
      geAddHilightFig(hiliteSetGen hiliteObjGen drawAll)
   )

   foreach(child diff->children
      Highlight(child)
   )
)

defmethod( Select (( diff GMobj ) )

   if( diff->obj then
      wid = geGetCellViewWindow(diff->obj->cellView)
      if(wid then
         geSelectObject(diff->obj)
      )

      if( diff->refObj then
         wid = geGetCellViewWindow(diff->refObj->cellView)
         if(wid then
            geSelectObject(diff->refObj)
         )
      )
   )
   foreach(child diff->children
      Select(child)
   )
)





defclass( GMschInst
   
   (GMobj)

   
   (
      (type         @initform "inst" @initarg type)
      (attrs        @initform GMD_instAttrs() )
   )

)

procedure( GMD_instAttrs()





list(
   list("name"      "hard")
   list("libName"   "hard")
   list("cellName"  "hard")
   list("viewName"  "soft")
   list("objType"   "hard")
   list("orient"    "soft")
   list("xy"        "soft")
   list("numInst"   "soft")
)
)



procedure( GMD_createInsts(diffPairs)


   instsScr = diffPairs->srcCv->instances
   instsDst = diffPairs->dstCv->instances

   foreach(inst instsScr
      newInst = GMD_createInst_func(inst diffPairs)
      AddDiffObj(diffPairs ?obj newInst ?group 'objsSrc)
   )
   foreach(inst instsDst
      newInst = GMD_createInst_func(inst diffPairs)
      AddDiffObj(diffPairs ?obj newInst ?group 'objsDst)
   )

   diffPairs

)


procedure( GMD_createInst_func( inst diffPairs)

   if(inst->purpose == "pin" then
      newInst = makeInstance( 'GMschPin  ?obj inst ?name inst->net->name ?diffPairs diffPairs )
   else
      newInst = makeInstance( 'GMschInst ?obj inst ?name inst->name      ?diffPairs diffPairs )

      
      if(inst->prop then
         foreach(prop inst->prop
            newInst->attrs = append( newInst->attrs list(list(prop->name "prop")) )
         )
      )
   )
   FilterAttr(newInst)
   newInst
)



defmethod( Create (( inst GMschInst ) )




   refInst = GetCreate(inst)

   
   if( type(refInst->name) != 'string break())
   if(dbFindAnyInstByName(inst->dstCv refInst->name) then
      instName = nil
   else
      instName = refInst->name
   )
   genObj = dbCreateInstByMasterName(
      inst->dstCv
      refInst->libName
      refInst->cellName
      refInst->viewName
      instName
      refInst->xy
      refInst->orient
   )


   AddGenObj(inst genObj)


   
   if( inst->propAttrs then
      if( inst->isDst? then
         RestoreProps(inst ?target genObj)
      else
         dbCopyProp(refInst genObj)
      )
   )

   callNextMethod()

   inst
)



defclass( GMschPin
   
   (GMschInst)

   
   (
      (type         @initform "pin" @initarg type)
      (attrs        @initform GMD_pinAttrs() )
   )

)

procedure( GMD_pinAttrs()






attrs = GMD_instAttrs()
pinAttrs = list(
   list("net" "hard")
)
attrs = append( attrs pinAttrs)
)


defmethod( GetAttr ((obj GMschPin) attribute @key (source nil) (isProp nil))
   if( !source then
      source = obj->obj
   )
   case( attribute
      ("net" || "name"
         attr = source->net->name
      )
      (t
         attr = get(source attribute)
      )
   )
   attr
)

defmethod( StoreAttrs (( pin GMschPin ) @key (source nil))
   callNextMethod()

   storeAttr = list(list("direction" pin->obj->pin->term->direction))
   pin->attrsStored = append( pin->attrsStored storeAttr)

   storeAttr = list(list("master"    pin->obj->master))
   pin->attrsStored = append( pin->attrsStored storeAttr)

)

defmethod( Create (( pin GMschPin ))

   refPin = GetCreate(pin)

   if( pin->isDst? then
      pDirection   = refPin->direction
   else
      pDirection   = refPin->pin->term->direction
   )

   pName        = pin->dispName
   pMaster      = refPin->master
   pLocation    = refPin->xy
   pOrientation = refPin->orient




   genObj = schCreatePin(
      pin->dstCv
      pMaster
      pName
      pDirection
      nil
      pLocation
      pOrientation
   )

   AddGenObj(pin genObj)

   callNextMethod()

   pin

)





defclass( GMschShape
   
   (GMobj)

   
   (
      (type         @initform "shape" @initarg type)
      (attrs        @initform nil )
   )

)



procedure( GMD_createShapes(diffPairs)

   shapesSrc = diffPairs->srcCv->shapes
   shapesDst = diffPairs->dstCv->shapes

   foreach(shape shapesSrc
      newShape = GMD_createShape_func(shape diffPairs)
      AddDiffObj(diffPairs ?obj newShape ?group 'objsSrc)
   )
   foreach(shape shapesDst
      newShape = GMD_createShape_func(shape diffPairs)
      AddDiffObj(diffPairs ?obj newShape ?group 'objsDst)
   )

   diffPairs

)

procedure( GMD_createShape_func( shape diffPairs )

   name = ""
   classType = nil
   foundValidClass = t

   case(shape->objType
   ("line"
      classType = 'GMschWire
      netName = shape->net->name
      if(!netName netName = "")
      name = sprintf(nil "Line %s at %L" netName shape->points)
   )
   ("label"
      classType = 'GMschLabel
      name = sprintf(nil "Label %s at %L" shape->theLabel shape->xy)
   )
   (t
      foundValidClass = nil
   )
   )
   if( foundValidClass then
      newShape = makeInstance( classType ?obj shape ?name name ?diffPairs diffPairs )
      FilterAttr(newShape)
   else
      newShape = nil
   )
   newShape
)



defmethod( Print (( shape GMschShape ) )


str = sprintf(nil "Name:%s\n",shape->name)

)



defclass( GMschLabel
   
   (GMschShape)

   
   (
      (type         @initform "label" @initarg type)
      (attrs        @initform GMD_schLabelAttrs() )
   )

)

procedure( GMD_schLabelAttrs()





list(
   list("objType"      "hard")
   
   
   list("theLabel"     "hard")
   list("lpp"          "hard")
   list("nPoints"      "hard")
   list("xy"           "soft")
   list("orient"       "soft")
   list("font"         "soft")
   list("justify"      "soft")
   list("height"       "soft")
   list("isDrafted"    "soft")
   list("isOverbar"    "soft")
)
)






defmethod( Create (( inst GMschLabel ) )



   refInst = GetCreate(inst)

   parent = GetParentObj(inst)

   genObj = schCreateWireLabel(
      inst->dstCv
      parent
      refInst->xy
      refInst->theLabel
      refInst->justify
      refInst->orient
      refInst->font
      refInst->height
      nil
   )

   AddGenObj(inst genObj)

   callNextMethod()

   inst

)






defclass( GMschWire
   
   (GMschShape)

   
   (
      (type         @initform "wire" @initarg type)
      (attrs        @initform GMD_schWireAttrs() )
   )

)

procedure( GMD_schWireAttrs()





list(
   list("objType"      "hard")
   list("purpose"      "hard")
   list("lpp"          "hard")
   list("nPoints"      "hard")
   list("points"       "hard")
)
)




defmethod( UpdateWireAttrs (( diffPairs GMdiffPairs ) )

   

   
   flatDiffs = FlattenChildren(diffPairs)
   wireDiffsSrc = setof(diff flatDiffs diff->type == "wire" && diff->merged==t && !diff->isDst?)
   wireDiffsDst = setof(diff flatDiffs diff->type == "wire" && diff->merged==nil && diff->isDst?)

   wireDiffs = append(wireDiffsDst wireDiffsSrc)

   wireObjs = setof(obj diffPairs->dstCv->shapes obj->objType == "line")
   printf("called update wires\n")
   foreach(wireDiff wireDiffs
      if( wireDiff->isDst? then
         points  = GetStoredAttrs(wireDiff)->points
         
         if( !points then
            points = wireDiff->obj->points
         )
      else
         points = wireDiff->obj->points
      )
      matchingWire = setof(wire wireObjs wire->points == points )

      
      if( !matchingWire then
         matchingWire = CheckOverlap(wireDiff points)
      )

      if( length(matchingWire) > 1 error("How can I find more than 1 wire for a set of points?") )
      matchingWire = car(matchingWire)

      if( wireDiff->genObj != matchingWire then
         if(wireDiff->isDst? then
            wireDiff->obj = matchingWire
         else
            wireDiff->genObj = matchingWire
         )
      )

   )

)



defmethod( CheckOverlap (( inst GMschWire ) points)

   x1 = caar(points)
   x2 = caadr(points)
   y1 = cadar(points)
   y2 = cadadr(points)

   if( y1 == y2 then
      axisElem = 2
      axisVal = y1
      limElem = 1
      minLim = x1
      maxLim = x2
   else
      axisElem = 1
      axisVal = x1
      limElem = 2
      minLim = y1
      maxLim = y2
   )

   cvWires = setof(shape inst->dstCv->shapes shape->objType == "line" && shape->layerName=="wire")
   overlapWire = setof(wire cvWires
      nthelem( axisElem  car(wire->points)) == axisVal &&
      nthelem( axisElem cadr(wire->points)) == axisVal &&
      nthelem( limElem   car(wire->points)) <= minLim &&
      nthelem( limElem  cadr(wire->points)) >= maxLim
   )

   if(!overlapWire then
      break()
      error("GMschWire CheckOverlap: Could not find any existance of a wire!")
   )

   overlapWire
)


defmethod( Create (( inst GMschWire ) )

   refInst = GetCreate(inst)

   
   if(refInst->width then
      width = refInst->width
   else
      width = 0
   )

   genObj = schCreateWire(
      inst->dstCv
      "draw"
      ""
      refInst->points
      0
      0
      width
      
      
   )


   printf("Created %d line %L obj %L\n" inst->id refInst->points genObj)

   AddGenObj(inst genObj)

   callNextMethod()

   inst

)




defclass( GMnetGroup
   
   (GMobj)

   
   (
      (type         @initform "net" @initarg type)
      (attrs        @initform GMD_netGroupAttrs() )
   )

)

procedure( GMD_netGroupAttrs()





list(
   list("name"      "hard")
   list("diffFigs"  "soft") 
)
)


procedure( GMD_createNets(diffPairs)
   netsSrc = diffPairs->srcCv->signals
   netsDst = diffPairs->dstCv->signals

   
   
   

   
   
   


   
   netsSrc = setof( net netsSrc net->figs != nil)
   netsDst = setof( net netsDst net->figs != nil)

   foreach(net netsSrc
      newNet = GMD_createNet_func(net diffPairs)
      AddDiffObj(diffPairs ?obj newNet ?group 'objsSrc)
   )
   foreach(net netsDst
      newNet = GMD_createNet_func(net diffPairs)
      AddDiffObj(diffPairs ?obj newNet ?group 'objsDst)
   )
   diffPairs
)

procedure( GMD_createNet_func( net diffPairs )

   name = strcat("Net " net->name)
   newNet = makeInstance( 'GMnetGroup ?obj net ?name name ?diffPairs diffPairs )
   FilterAttr(newNet)
   newNet
)



defmethod( Diff (( net GMnetGroup ) netRef)

   
   instTerms = append(net->obj->instTerms netRef->obj->instTerms)
   termIndex = 1
   matched = t


   
   while( matched && termIndex < length(instTerms)+1
      term = nthelem(termIndex instTerms)
      name = term->name
      inst = term->inst

      instDiff = FindByObj(net->diffPairs ?obj inst)

      if( instDiff && instDiff->status=="new" then
         printf("\tInstance %s is a new instance, therefore the net %s is a diff\n" instDiff->name net->name)
         matched = list(t)
      )
      termIndex = termIndex + 1
   )

   matched

)

defmethod( RemoveDiffFigs (( net GMnetGroup ) )
   
   RemoveByObj(net->diffPairs ?objs net->obj->figs)
   RemoveByObj(net->diffPairs ?objs net->refObj->figs)
)


defmethod( GetChildFromObj (( net GMnetGroup ) )
   figs = net->obj->figs

   if(net->status == "partial" then
      figs = append(figs net->refObj->figs)
   )

   
   
   
   children = setof( fig figs fig->parent == nil)
)




defmethod( Create (( diff GMnetGroup ))
   t
)

defmethod( Delete (( diff GMnetGroup ))
   t
)

defmethod( UpdateAttr (( diff GMnetGroup ) @key (source nil) (target nil))
   t
)



defmethod( Print (( net GMnetGroup ) )


str = sprintf(nil "Name:%s\n",net->name)

)




defmethod( Highlight (( obj GMnetGroup ))
   foreach(child obj->children
      Highlight(child)
   )
)

defmethod( Select (( obj GMnetGroup ) )
   foreach(child obj->children
      Select(child)
   )
)




defmethod( CreateBackup (( diffPairs GMdiffPairs ) )

   dstCv = diffPairs->dstCv
   viewName = dstCv->viewName

   sysCommand = sprintf(nil "md5sum %s" dstCv->fileName)

   cid=ipcBeginProcess(sysCommand)
   ipcWait(cid)
   exitStatus = cid->exitStatus

   if(exitStatus != 0 then
      error("Failed to create backup cellView")
   )

   md5sum = ipcReadProcess(cid)
   md5sum = car(parseString(md5sum))

   bckViewName = sprintf(nil "%s%s" viewName md5sum)

   

   
   existcv = GMopenCellViewByType(
      dstCv->libName
      dstCv->cellName
      bckViewName
      nil
      "r"
   )
   if( existcv dbPurge(existcv) )

   bckCv = dbCopyCellView( dstCv
      dstCv->libName
      dstCv->cellName
      bckViewName
      nil
      ""
      t
   )

   if( !bckCv warn("\n\n**** Could not create backup cellview\nYou will not be able to delete objects in the destination cell\n****") )

   diffPairs->bckCv = bckCv
)

defmethod( DeleteBackup (( diffPairs GMdiffPairs ) )
   bckCv = diffPairs->bckCv
   if(bckCv then
      dd = ddGetObj(
         bckCv->libName
         bckCv->cellName
         bckCv->viewName
      )
      diffPairs->bckCv = nil
      dbPurge(bckCv)
      ddDeleteObj(dd)
   )
)


procedure(GMopenCellViewByType(@rest args)
  
  
  unless(boundp('GMnullPort) && openportp(GMnullPort)
    GMnullPort=outfile("/dev/null")
  ) 

  
  
  
  
  warn("")

  
  
  
  let((cv (woport GMnullPort))
    cv=apply('dbOpenCellViewByType args)
    getWarn()
    cv
  ) 
) 














procedure( createCdsGitSchMenu()
   hiCreatePulldownMenu(
      'CdsGitSchMenu
      "CdsGit"
      list(
         hiCreateMenuItem(?name 'item1 ?itemText "Git Gui"          ?callback "CGMlmgrCBcv( \"CGMgui\"      )" )
         hiCreateSeparatorMenuItem(?name 'itemd1)
         hiCreateMenuItem(?name 'item2 ?itemText "Add"              ?callback "CGMlmgrCBcv( \"CGMadd\"      )" )
         hiCreateMenuItem(?name 'item3 ?itemText "Reset"            ?callback "CGMlmgrCBcv( \"CGMreset\"    )" )
         hiCreateMenuItem(?name 'item4 ?itemText "Commit"           ?callback "CGMlmgrCBcv( \"CGMcommit\"   )" )
         hiCreateMenuItem(?name 'item5 ?itemText "Discard Unstaged" ?callback "CGMlmgrCBcv( \"CGMdiscard \" )" )
         hiCreateMenuItem(?name 'item6 ?itemText "Status"           ?callback "CGMlmgrCBcv( \"CGMstatus\"   )" )
         hiCreateMenuItem(?name 'item7 ?itemText "Diff"             ?callback "CGMlmgrCBcv( \"CGMdiff\"     )" )
         hiCreateMenuItem(?name 'item8 ?itemText "Checkout"         ?callback "CGMlmgrCBcv( \"CGMcheckout\" )" )
         hiCreateMenuItem(?name 'item9 ?itemText "Export"           ?callback "CGMlmgrCBcv( \"CGMexport\"   )" )
      )
   )
)





procedure( createCdsGitLayMenu()
   t

)

procedure( CdsGitSchMenuTrigger(args)
   
   unless(boundp('CdsGitSchMenu) && CdsGitSchMenu
      createCdsGitSchMenu()
   )

   
   createCdsGitSchMenu()

   list(CdsGitSchMenu)
) 
deRegUserTriggers("schematic"       nil 'CdsGitSchMenuTrigger nil)
deRegUserTriggers("schematicSymbol" nil 'CdsGitSchMenuTrigger nil)





deRegUserTriggers("maskLayout"       nil 'CdsGitSchMenuTrigger nil)
deRegUserTriggers("maskLayoutXL"     nil 'CdsGitSchMenuTrigger nil)



printf("********************************************************\n")
printf(strcat("Done Loading CdsGit SKILL\n"))
printf("********************************************************\n")

