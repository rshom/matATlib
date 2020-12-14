# TODO #

  * [x] Classes
	* [x] AcousticEnvironment
	* [x] AcousticBoundary
	* [x] AcousticLayer
	* [x] AcousticSource
	* [x] AcousticReciever

  * [ ] run_at functions
	* [x] run_padepe.m
	* [x] run_kraken.m
	* [x] run_bellhop.m
	* [ ] run_bounce.m

  * [ ] write functions
	* [x] env (kraken/bellhop)
	* [ ] bty
	* [ ] ssp
	* [x] flp
	* [ ] brc
	* [ ] trc
	* [ ] irc
	
  * [x] read functions
	* [x] shd
	* [x] ray
	* [x] mod
	
  * [ ] Error checks and warnings
	
  * [x] Demos
	
  * [ ] Clean up
	* [ ] better name
	* [ ] remove run_padepe from toolbox

# MATLAB Acoustic Toolbox Library #
> MATLAB tools for running models through the Acoustic Toolbox

## Overview ##

The [Acoustic Toolbox](http://oalib.hlsresearch.com/AcousticsToolbox/)
is widely used to model underwater sound propagation.

## Documentation ##

<!-- TODO: autogenerate documentation -->

The scripts, classes, and functions in this toolbox are internally
documented. The documentation can be accessed using the `help` or
`doc` commands in MATLAB.

## Major Functionality ##

### Classes ###

  * `AcousticEnvironment`
	* `AcousticBoundary`
	* `AcousticLayer`
  * `AcousticSource`
  * `AcousticReciever`
  
### Environment Building ###

  * Layers
	* `gen_munk_lyr`
	* `gen_iso_lyr`
	* `get_lyr_from_posit`
	* `gen_mud_lyr`
	* `gen_sand_lyr`
	* `gen_silt_lyr`
  * Boundaries
	* `gen_vacuum_bdry`
	* `gen_halfspace_bdry`
	
### Sources/Receivers ###

  * Sources
  * Recievers
  
### Propagation Models ###

The propagtion models take the environment

  * `run_bounce`
  * `run_bellhop`
  * `run_kraken`
  * `run_padepe`
  
### Results Viewing ###

  * `plot_env`
  * `plot_shade`
  * `plot_rays`

## Demos ##

* [ ] Profile
  * [ ] Pull from netcdf
  * [ ] Pull from posit
* [ ] Bounce
  * [ ] Reproduce fig 1.23 in book using bounce
* [ ] Bellhop
  * [ ] Pull profile from posit high/low latitudes
  * [ ] Ray trace with source
  * [ ] Eigen ray trace
  * [ ] Eigen ray arrivals
* [ ] Advanced bellhop
  * [ ] Range dependent bathy (sea mount)
* [ ] Kraken
  * [ ] Shallow water Pekeris
	* [ ] plot modes
	* [ ] plot field
  * [ ] Deep water munk
	* [ ] plot modes
	* [ ] plot field
* [ ] PE
  * [ ] Pekeris shallow water
  * [ ] Shallow water wedge
  * [ ] deep water munk
* [ ] Broadband Kraken

## Contributors ##

  * [Russ Shomberg](rshomberg@uri.edu)
  
## License ##

This program is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

## References ##

  * http://oalib.hlsresearch.com/AcousticsToolbox/
