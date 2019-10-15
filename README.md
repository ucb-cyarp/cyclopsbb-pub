# cyclopsbb
Cyclops Baseband used in xG and SC2 Projects

The baseband is a single carrier design capable of BPSK, QPSK, and 16 QAM modulation schemes.  It includes AGC, timing recovery, carrier recovery, Equilization, and packet parsing logic.

The radio baseband is primarily described in Mathworks Simulink with startup and helper scripts in Mathworks Matlab.

Note: A license to CommsToolbox is required to run this design.

The design is compatible with HDL Coder and has been deployed to 7 Series Xilinx FPGAs

## Opening the Design
1. Set the Matlab Path to the `baseband` directory
2. Run `rev0BB_startup.m`

## Changing Parameters
Parameters for the design are primarily set in `baseband/rev0BB_setup.m` with some simulation parameters set in `baseband/rev0BB_startup.m`.

## Editing the Design
1. Follow the directions in [Opening the Design](#opening-the-design)
2. Edit `rev0BB.slx`
