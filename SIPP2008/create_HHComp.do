* Create a data file with one record for each coresident pair in each wave
* Merge onto the file the relationships data created by unify_relationships.


****************************************************************************
* create database with all pairs of coresident individuals in each wave
****************************************************************************
use "$tempdir/allwaves"

keep SSUID SHHADID EPPPNUM SWAVE ERRP

sort SSUID SHHADID SWAVE

by SSUID SHHADID SWAVE:  gen HHmembers = _N  /* Number the people in the household in each wave. */

* merge in age of other person in the household to save as "to_age"
merge 1:1 SSUID EPPPNUM SWAVE using "$tempdir/demo_long.dta", keepusing(adj_age)

assert _merge==3

drop _merge

rename EPPPNUM relto
rename ERRP ERRPto
rename adj_age to_age

save "$tempdir/to", $replace

use "$tempdir/allwaves", clear

keep SSUID SHHADID EPPPNUM SWAVE ERRP

rename EPPPNUM relfrom
rename ERRP ERRPfrom

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

merge m:1 SSUID relfrom relto using "$tempdir/unified_rel"

replace unified_rel = .a if (_merge == 1) & (missing(unified_rel))
replace unified_rel = .m if (_merge == 3) & (missing(unified_rel))

assert (unified_rel != .)
drop _merge

tab unified_rel, m

rename relfrom EPPPNUM
rename relto to_EPPNUM

merge m:1 SSUID EPPPNUM SWAVE using "$tempdir/demo_long.dta"

drop if _merge==2

drop _merge

tab unified_rel, m 

do "$sipp2008_code/simple_rel_label"

******************************************************************
** Function: This calls a program "simplify_relationship" defined in "project_macros". 
******************************************************************
simplify_relationships unified_rel simplified_rel ultra_simple_rel

display "Unhandled relationships"
tab unified_rel if missing(simplified_rel), m sort
display "Unhandled child relationships"
tab unified_rel if (missing(simplified_rel) & (adj_age < $adult_age)), m sort

******************************************************************
** Function: Tabulate relationships and child relationships. 
******************************************************************
tab simplified_rel, m sort
tab simplified_rel if (adj_age < $adult_age), m sort

tab ultra_simple_rel, m sort
tab ultra_simple_rel if (adj_age < $adult_age), m sort

* data file with one record per pair of coresident individuals per wave
* in many cases you'll collapse by hh (SSUID SHHADID SWAVE) to identify HH composition
* for example, collapse to see if ego is grandchild to anyone in the household

save "$tempdir/HHComp.dta", $replace






