* Create a data file with one record for each coresident pair in each wave
* Merge onto the file the relationships data created by unify_relationships.


****************************************************************************
* create database with all pairs of coresident individuals in each wave
****************************************************************************
use "$tempdir/allmonths"

keep SSUID SHHADID EPPPNUM ERRP panelmonth

sort SSUID SHHADID panelmonth

by SSUID SHHADID  panelmonth:  gen HHmembers = _N  /* Number the people in the household in each wave. */

* merge in age of other person in the household to save as "to_age"
merge 1:1 SSUID EPPPNUM panelmonth using "$SIPP08keep/demo_long_interviews_am.dta", keepusing(adj_age my_sex)

assert _merge==3

drop _merge

rename EPPPNUM relto
rename ERRP ERRPto
rename adj_age to_age
rename my_sex to_sex

save "$tempdir/to", $replace

use "$tempdir/allmonths", clear

keep SSUID SHHADID EPPPNUM panelmonth ERRP

rename EPPPNUM relfrom
rename ERRP ERRPfrom

joinby SSUID SHHADID panelmonth using "$tempdir/to"  

* drop pairs of ego to self
drop if relto==relfrom

save "$tempdir/pairwise_bymonth", $replace

/*
********************************************************************************
* for the purpose of checking how many pairs of individuals are represented in 
* the unified relationships, create a pairwise database for all waves
********************************************************************************

duplicates drop SSUID relfrom relto, force

drop SWAVE

save "$tempdir/pairwise", $replace

*/

use "$tempdir/pairwise_bymonth", clear

merge m:1 SSUID relfrom relto panelmonth using "$SIPP08keep/relationship_pairs_bymonth"

replace relationship = .a if (_merge == 1) & (missing(relationship))
replace relationship = .m if (_merge == 3) & (missing(relationship))

drop if relationship == . // PS: 22 contradictins - dropping them 
assert (relationship != .)
drop _merge

tab relationship, m

rename relfrom EPPPNUM
rename relto to_EPPNUM

merge m:1 SSUID EPPPNUM panelmonth using "$SIPP08keep/demo_long_interviews_am.dta"

drop if _merge==2

drop _merge

tab relationship, m 

do "$sipp2008_code/simple_rel_label"

save "$SIPP08keep/HHComp_asis_am.dta", $replace

gen anyspouse=1 if relationship==12
gen anypartner=1 if relationship==18

collapse (count) anyspouse anypartner, by(SSUID EPPPNUM panelmonth)

save "$tempdir/comp.dta", replace

merge 1:1 SSUID EPPPNUM panelmonth using "$SIPP08keep/demo_long_interviews_am.dta"

gen marcohstat=2 if anypartner > 0
replace marcohstat=1 if anyspouse > 0
replace marcohstat=0 if missing(marcohstat)

* one record per person
save "$SIPP08keep/HHComp_pm.dta", $replace
