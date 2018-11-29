//=========================================================================================//
//===== Children's experience in poverty               
//===== Dataset: SIPP2008                                      
//===== Purpose: This file creates a poverty measure for children's households by wave
//=========================================================================================//

use "$tempdir/person_wide_adjusted_ages", clear

keep SSUID EPPPNUM SHHADID* adj_age* 

reshape long SHHADID adj_age, i(SSUID EPPPNUM) j(SWAVE)

*********************************************************************************
**  Now merge with the base data to get the income variable 
********************************************************************************* 
merge 1:1 SWAVE SSUID EPPPNUM using "$tempdir/allwaves", keepusing(THTOTINC EHHNUMPP WPFINWGT RHCALYR) 
/* THTOTINC: total household income; EHHNUMPP: total number of persons in the household */
keep if _merge==3
drop _merge

*********************************************************************************
**  Keep the sample to children
********************************************************************************* 
keep if adj_age < 17

*********************************************************************************
**  write a program to generate a numeric variable representing the official U.S. poverty guideline
********************************************************************************* 
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

/*create a poverty indicator*/
gen annualinc= THTOTINC*12 /*convert monthly income to annual income*/

povertyguide, gen(povguide) famsize(EHHNUMPP) year(RHCALYR) /*generate poverty line*/
gen byte pov = annualinc < povguide if ~mi(povguide) & ~mi(annualinc) /*generate poverty indicator 1=in poverty*/

label variable pov "poverty indicator"
label define poverty 0 ">=100%FPL" 1 "<100%FPL"
tab pov [aw=WPFINWGT]

save "$tempdir/child_hhincome", $replace
