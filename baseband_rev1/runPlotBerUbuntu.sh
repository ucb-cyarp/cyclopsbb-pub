#!/bin/bash

module load matlab

matlab -nodisplay -logfile `date +%a%d%b%Y_%H_%M_%S`_matlab.log -batch "plotBer;"
