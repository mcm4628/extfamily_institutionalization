//==============================================================================
//===== Children's Household Instability Project
//===== Dataset: SIPP2008
//===== Purpose:  Identify whether every person (adult) in ego's household in this wave
//=====           is observed in the data the next wave.
//==============================================================================

*******************************************************************************
* Section: Create a file with an observation for every person observed in the 
*          data the next wave to be merged onto this wave.
*******************************************************************************
use "$tempdir/person_wide_adjusted_ages"

keep SSUID EPPPNUM SHHADID* ERRP* adj_age* shhadid_members*

reshape long SHHADID adj_age shhadid_members, i(SSUID EPPPNUM) j(SWAVE)

keep if !missing(SHHADID)

drop SHHADID

replace SWAVE=SWAVE-1

keep if SWAVE > 0

rename EPPPNUM relto
rename adj_age to_age

save "$tempdir/everyoneobservednextwave", $replace

*******************************************************************************
* Section: readin file with one observation for each person in ego's (relto) 
*          household
*******************************************************************************

* Add to_age to pairs data 
use "$tempdir/relationship_pairs_bywave", clear
rename relto EPPPNUM
merge m:1 SSUID EPPPNUM SWAVE using "$SIPP08keep/demo_long_all", keepusing(adj_age)

keep if _merge==3

drop _merge

* renameing to "other_age" instead of "to_age" just to avoid conflict later.
rename adj_age other_age
rename EPPPNUM relto

gen other_oldenough=1 if other_age > 15

* count number of household members and 
egen hhmem=count(SHHADID), by(SSUID relfrom SWAVE)
egen oldhhmem=count(other_oldenough), by(SSUID relfrom SWAVE)

*look for everyone in my household this wave in the next wave

merge m:1 SSUID relto SWAVE using "$tempdir/everyoneobservednextwave"

* don't care about observations that are just in next wave
drop if _merge==2


gen toinnext=1 if _merge==3

gen toinnext_oldenough=1 if _merge==3 & other_age > 15

*******************************************************************************
* Section: Collapse to on record per person with indicators for number 
*******************************************************************************

collapse (first) hhmem oldhhmem (count) hhmem_innext=toinnext num_old_innext=toinnext_oldenough, by(SSUID relfrom SWAVE)

tab hhmem_innext hhmem

gen all_other_observed=1 if hhmem_innext==hhmem

label variable all_other_observed "Every other person in ego's household is observed in next wave"

gen no_other_observed=1 if hhmem_innext==0

label variable no_other_observed "No other person in ego's household is observed in next wave"

gen all_other_old_observed=1 if oldhhmem==num_old_innext

label variable all_other_old_observed "Every other person age 15+ in ego's household is observed in next wave"

gen no_other_old_observed=1 if num_old_innext==0

label variable no_other_old_observed "No other person age 15+ in ego's household is observed in next wave"

rename relfrom EPPPNUM

*******************************************************************************
* Section: merge onto hh_change to see how often comp_change
*          happens when all_other_observed=1 (disappear alone)
*******************************************************************************

merge 1:1 SSUID EPPPNUM SWAVE using "$tempdir/hh_change.dta"

keep if _merge==3

gen gone_missing_alone=1 if innext==0 & all_other_observed==1
gen gone_missing_withoutadult=1 if innext==0 & all_other_old_observed==1

save "$tempdir/nextwave.dta", $replace

tab comp_change gone_missing_alone, m

tab comp_change gone_missing_withoutadult, m

keep if adj_age < 15

tab comp_change gone_missing_alone, m

tab comp_change gone_missing_withoutadult, m

drop _merge

tab comp_change

tab comp_change all_other_observed, m

tab comp_change no_other_observed, m

tab comp_change all_other_old_observed, m
