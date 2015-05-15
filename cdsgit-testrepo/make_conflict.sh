#!/bin/bash

### Create a merge conflict

txt_file="conflict.txt"
bin_file="conflict.bin"


## TEXT FILE
git checkout testbranch
echo `date` >> $txt_file
echo "testbranch" >> $txt_file
git add $txt_file
git commit -m "creating txt conflict testbranch"


git checkout master
echo `date` >> $txt_file
echo "master" >> $txt_file
git add $txt_file
git commit -m "creating txt conflict testbranch"


## BIN FILE
git checkout testbranch
dd if=/dev/urandom of=$bin_file bs=1 count=1024
git add $bin_file
git commit -m "creating bin conflict testbranch"

git checkout master
dd if=/dev/urandom of=$bin_file bs=1 count=1024
git add $bin_file
git commit -m "creating bin conflict testbranch"


#git merge testbranch
