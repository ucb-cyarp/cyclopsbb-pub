# cyclopsbb
Zenodo Concept DOI: [![Concept DOI](https://zenodo.org/badge/DOI/10.5281/zenodo.6525769.svg)](https://doi.org/10.5281/zenodo.6525769)

Cyclops Baseband used in xG, SC2, and Christopher Yarp's Ph.D Thesis

The baseband is a single carrier design capable of BPSK, QPSK, 16 QAM, and 256 QAM modulation schemes.  It includes AGC, timing recovery, carrier recovery, Equilization, and packet parsing logic.

The radio baseband is primarily described in Mathworks Simulink with startup and helper scripts in Mathworks Matlab.

Note: A license to CommsToolbox is required to run this design.

## Opening the Design
1. Set the Matlab Path to the `baseband_rev1` directory
2. Run `rev1BB_startup.m`

## Changing Parameters
Parameters for the design are primarily set in `baseband/rev1BB_setup.m` with some simulation parameters set in `baseband/rev0BB_startup.m`.

## Editing the Design
1. Follow the directions in [Opening the Design](#opening-the-design)
2. Edit `rev1BB.slx`

## Citing This Software:
If you would like to reference this software, please cite Christopher Yarp's Ph.D. thesis.

*At the time of writing, the GitHub CFF parser does not properly generate thesis citations.  Please see the bibtex entry below.*

```bibtex
@phdthesis{yarp_phd_2022,
	title = {High Speed Software Radio on General Purpose CPUs},
	school = {University of California, Berkeley},
	author = {Yarp, Christopher},
	year = {2022},
}
```
