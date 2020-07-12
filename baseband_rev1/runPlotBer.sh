#!/bin/bash
# run by piping script to bsub and not passing the script name to bsub

#BSUB -n 4
#BSUB -q normal
#BSUB -R "span[hosts=1]"
#BSUB -o ./%J_stdout.log
#BSUB -e ./%J_stderr.log
#BSUB -N

source ~/matlabR2020asetup.csh
source scl_source enable devtoolset-8 #From https://serverfault.com/questions/751155/permanently-enable-a-scl

matlab -nodisplay -logfile ${LSB_JOBID}_matlab.log -batch "maxNumCompThreads(4); plotBer;"
#matlab -nodisplay -nosplash -logfile ${LSB_JOBID}_matlab.log -r "maxNumCompThreads(4); plotBer;"
