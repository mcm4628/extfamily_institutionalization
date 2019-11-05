* Create a data file with one record for each coresident pair in each wave
* Merge onto the file the relationships data created by unify_relationships.


****************************************************************************
* create database with all pairs of coresident individuals in each wave
****************************************************************************
use "$tempdir/allwaves"

keep SSUID SHHADID PNUM SWAVE ERELRP

sort SSUID SHHADID SWAVE

by SSUID SHHADID SWAVE:  gen HHmembers = _N  /* Number the people in the household in each wave. */

* merge in age of other person in the household to save as "to_age"
merge 1:1 SSUID PNUM SWAVE using "$tempdir/demo_long_interviews.dta", keepusing(adj_age my_sex)

assert _merge==3

drop _merge

rename PNUM relto
rename ERRP ERRPto
rename adj_age to_age
rename my_sex to_sex

save "$tempdir/to", $replace

use "$tempdir/allwaves", clear

keep SSUID SHHADID PNUM SWAVE ERELRP

rename PNUM relfrom
rename ERELRP ERRPfrom

joinby SSUID SHHADID SWAVE using "$tempdir/to"  

* drop pairs of ego to self
drop if relto==relfrom

save "$tempdir/pairwise_bywave", $replace

/*
********************************************************************************
* for the purpose of checking how many pairs of individuals are represented in 
* the unified relationships, create a pairwise database for all waves
********************************************************************************

duplicates drop SSUID relfrom relto, force

drop SWAVE

save "$tempdir/pairwise", $replace

*/

use "$tempdir/pairwise_bywave", clear

merge m:1 SSUID relfrom relto SWAVE using "$tempdir/relationship_pairs_bywave"

replace relationship = .a if (_merge == 1) & (missing(relationship))
replace relationship = .m if (_merge == 3) & (missing(relationship))

assert (relationship != .)
drop _merge

tab relationship, m

rename relfrom PNUM
rename relto to_PNUM

merge m:1 SSUID PNUM SWAVE using "$tempdir/demo_long_interviews.dta"

drop if _merge==2

drop _merge

tab relationship, m 

do "$sipp2014_code/simple_rel_label"

save "$SIPP14keep/HHComp_asis.dta", $replace





