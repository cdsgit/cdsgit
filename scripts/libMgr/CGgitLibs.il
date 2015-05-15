
;Get all the git managed libraries
;Returns a list of libraries
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