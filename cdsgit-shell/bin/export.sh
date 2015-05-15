#/bin/bash


gitName=$1
gitPath=$2
gitSHA=$3

cd $gitPath/..
gitDest="${PWD}/${gitName}_${gitSHA}"

#echo $PWD

tempDir=`mktemp -d`

git archive $gitSHA ./$gitName | tar -x -C $tempDir

#echo $tempDir

echo $gitDest

if [ ! -f $gitDest ]; then
   mv $tempDir/$gitName $gitDest
fi
