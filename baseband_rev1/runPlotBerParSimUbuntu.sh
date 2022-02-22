#!/bin/bash

#Collect repo information
timestamp=$(date +%a%d%b%Y_%H_%M_%S)

git log -1 > "${timestamp}_gitLastCommitDetailed.log"
git log -1 --format="%H"  > "${timestamp}_gitLastCommit.log"
git status -b > "${timestamp}_gitStatus.log"
git diff > "${timestamp}_gitDiff.patch"

#Run sweep
module load matlab

matlab -nodisplay -logfile "${timestamp}_matlab.log" -batch "plotBerParSim;"
