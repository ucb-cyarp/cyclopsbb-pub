#!/bin/bash

#Collect repo information
timestamp=$(date +%a%d%b%Y_%H_%M_%S)

dstDir=$1

if [[ -z "${dstDir}" ]]; then
    echo "Please provide a destination directory"
    return 1
elif [[ -d "${dstDir}" ]]; then
    echo "Provided destination diretory already exists: ${dstDir}"
    return 1
else
    echo "Creating result directory: ${dstDir}"
    mkdir "${dstDir}"
fi

git log -1 > "${timestamp}_gitLastCommitDetailed.log"
git log -1 --format="%H"  > "${timestamp}_gitLastCommit.log"
git status -b > "${timestamp}_gitStatus.log"
git diff > "${timestamp}_gitDiff.patch"

#Run sweep
module load matlab

matlab -nodisplay -logfile "${timestamp}_matlab.log" -batch "plotBerParSim;"

#Move Results
#TODO: Specify exact results of matlab script to move rather than relying on wildcard
mv "${timestamp}_gitLastCommitDetailed.log" "${dstDir}/."
mv "${timestamp}_gitLastCommit.log" "${dstDir}/."
mv "${timestamp}_gitStatus.log" "${dstDir}/."
mv "${timestamp}_gitDiff.patch" "${dstDir}/."
mv "${timestamp}_matlab.log" "${dstDir}/."

mv BERvsEbN0_* "${dstDir}/."