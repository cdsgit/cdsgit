;test GitShell Cmd


procedure( TST_GScmd()


dd=  ddGetObj("LCBUmodels" nil nil nil nil "r")

ddPath = dd->readPath
ddName = dd->name

gs = GitShell( ?path ddPath ?dd dd ?name ddName)


)