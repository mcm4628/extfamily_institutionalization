********************************************************************************
********create poverty status***********
********************************************************************************
capture program drop povertyguide
program def povertyguide

syntax , gen(string) famsize(string) year(string)


capture confirm new var `gen'
if _rc~=0 {
  disp as err "gen must be new var"
  exit 198
}


tempname povtable

#delimit ;
matrix input `povtable' = (
/*       base  incr */
/*2008*/ 10400, 3600 \
/*2009*/ 10830, 3740 \
/*2010*/ 10830, 3740 \
/*2011*/ 10890, 3820 \
/*2012*/ 11170, 3960 \
/*2013*/ 11490, 4020 \
/*2014*/ 11670, 4060 \
/*2015*/ 11770, 4160 
);
#delimit cr


local yearlo "2008"
local yearhi "2015"



tempvar year1
capture gen int `year1' = (`year')
if _rc ~=0 {
    disp in red "invalid expression for year: `year'"
    exit 198
}

capture assert (`year1' >= `yearlo' & `year1' <= `yearhi') | mi(`year1')
if _rc ~=0 {
    disp as error  "Warning: year expression has out-of-bounds values"
    /* But do not exit; just let out-of-bounds values yield missing. */
}

capture assert ~mi(`year1')
if _rc ~=0 {
    disp as error  "Warning: year expression yields some missing values"
    /* But do not exit. */
}

tempvar index1 /* index for year */

gen int `index1' = (`year1' - `yearlo') + 1



tempvar base incr
gen int `base' = `povtable'[`index1', 1]
gen int `incr' = `povtable'[`index1', 2]



tempvar famsiz1
capture gen int `famsiz1' = (`famsize')
/* Note that that is loaded into an int; will be truncated if non-integer.*/
if _rc ~=0 {
    disp in red "invalid expression for famsize: `famsize'"
    exit 198
}

capture assert `famsiz1' >= 1
if _rc ~=0 {
    disp as error  "Warning: famsize expression has out-of-bounds values (<1)"
    /* But do not exit; just let out-of-bounds values yield missing. */
}

capture assert ~mi(`famsiz1')
if _rc ~=0 {
    disp as error  "Warning: famsize expression yields some missing values"
    /* But do not exit. */
}

/* bottom-code  famsiz1 at 1. */
quietly replace `famsiz1' = 1 if `famsiz1' < 1

gen long `gen' = `base' + (`famsiz1' - 1)* `incr'
quietly compress `gen'
end

use "$SIPP08keep/HHCompbyWave", clear

local ivars "SSUID EPPPNUM"
local jvars "SWAVE"
local ovars "THTOTINC EHHNUMPP"

keep `ivars' `jvars' `ovars'

reshape wide `ovars', i(`ivars') j(`jvars')  

povertyguide, gen(povguide1) famsize(EHHNUMPP1) year(2008) /*generate poverty line for wave4: year 2009*/
forvalues wave=2/4 {
povertyguide, gen(povguide`wave') famsize(EHHNUMPP`wave') year(2009) 
}
forvalues wave=5/7 {
povertyguide, gen(povguide`wave') famsize(EHHNUMPP`wave') year(2010) 
}
forvalues wave=8/10 {
povertyguide, gen(povguide`wave') famsize(EHHNUMPP`wave') year(2011) 
}
forvalues wave=11/13 {
povertyguide, gen(povguide`wave') famsize(EHHNUMPP`wave') year(2012) 
}
forvalues wave=14/15 {
povertyguide, gen(povguide`wave') famsize(EHHNUMPP`wave') year(2013) 
}

forvalues wave=1/15 {
	gen annualinc`wave'= THTOTINC`wave'*12 
	gen byte pov`wave' = annualinc`wave' < povguide`wave' if ~mi(povguide`wave') /*generate poverty indicator 1=in poverty*/
	gen rpov`wave'=annualinc`wave'/povguide`wave'
	gen cpov`wave'=0 if rpov`wave' <= .5
	replace cpov`wave'=1 if rpov`wave' > .5 & rpov`wave' <= 1
	replace cpov`wave'=2 if rpov`wave' > 1 & rpov`wave' <= 2
	replace cpov`wave'=3 if rpov`wave' > 2
}

reshape long `ovars' annualinc pov rpov cpov, i(`ivars') j(`jvars')  

save "$tempdir/PovbyWave", $replace
