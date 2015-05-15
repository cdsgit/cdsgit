
procedure( GMrunDiff( @key (srcCv nil) (dstCv nil) (netDiff nil) )
   GMrunSchDiff(?srcCv srcCv ?dstCv dstCv ?netDiff netDiff)
)


procedure( GMrunSchDiff( @key (srcCv nil) (dstCv nil) (netDiff nil) )

   if(!srcCv || !dstCv then error("GMrunDiff: both dstCv and srcCv must be valid cell views") )

   verbose = t

   ;At some point make this a method to validate inputs
   GMdiffPairObj  = makeInstance( 'GMdiffPairs
                                    ?srcCv srcCv
                                    ?dstCv dstCv
                                    ?verbose verbose
                                    ?netDiff netDiff
                                    )
   Init(GMdiffPairObj)

   ;Diff the pins
   GMdiffPairObj = GMD_createInsts(GMdiffPairObj)
   GMdiffPairObj = GMD_createShapes(GMdiffPairObj)
   DiffPairs(GMdiffPairObj)
   GMdiffPairObj = GMD_createNets(GMdiffPairObj)
   DiffPairs(GMdiffPairObj)

   FindChildren(GMdiffPairObj)

   HighlightDiffs(GMdiffPairObj); Highlight the diff objects

   diffList    = ToReport(GMdiffPairObj)

)
