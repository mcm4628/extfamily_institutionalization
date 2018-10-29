//==============================================================================
//===== Children's Household Instability Project                                                    
//===== Dataset: SIPP2008                                                                               
//===== Purpose: Evaluate how much missing data might bias our analyses
//==============================================================================

* Setup to put output in document

	putdocx begin
	
	// Create a paragraph
	putdocx paragraph
	putdocx text ("How much data are missing because of missed interviews?"), bold

* Read in data
use "$tempdir/hh_change.dta", clear

********************************************************************************
* Section: Does recovering comp_change by looking for other household members in
*          the gap make much difference to our estimates?
*
* Logic: Create an indicator of whether person is observed both in this wave and
*        in the next, a fully-observed interval. Compare to the number of 
*	     intervals that would have existed if ego had been in all 15 waves 
*        (i.e. _N in wave 1 (105633) times 14 (1478862). 
********************************************************************************

* Get _N in Wave 1
sort inwave SWAVE
by inwave SWAVE: gen ninwave=_n  // Number the people in household in each wave. 
egen ninwave1=max(ninwave) // works because wave 1 has the largest sample. 

* calculate the number of possible observations
local inwave1 = `=ninwave1' 
local possible_original_obs=`inwave1'*14

	putdocx paragraph
	putdocx text ("This analysis evaluates how much missing data are in the SIPP 2008 panel and ")
	putdocx text ("how much missing data is recovered by our inference of comp change as ")
	putdocx text ("described below. Missing intervals sometimes happen because a ")
	putdocx text ("person (ego) moved out of a household and could not be located ")
	putdocx text ("or interviewed at their new address. In this situation, ")
	putdocx text ("we know that ego experienced a household composition change if someone ")
	putdocx text ("in ego’s household at last observation appears in ego’s missing wave(s). ")
	putdocx text ("Thus, we code this as a composition change even though ego is ")
	putdocx text ("missing in the next wave and the interval is not fully-observed. ")
	putdocx text ("Analogously, we code a composition change if someone in ego’s ")
	putdocx text ("household just after ego’s gap in data appears during the gap. ")
	putdocx text ("Also, if everyone in a household is missing in next wave, ")
	putdocx text ("we compare each person’s household composition at their last ")
	putdocx text ("appearance before the gap in data to their first appearance after the gap. ")
	putdocx text ("If the households are different, all the individuals are coded as having a ")
	putdocx text ("composition change at the time of the last observation before the gap; ")
	putdocx text ("if they are the same, all are coded as not experiencing a composition change. ")
	
	putdocx paragraph
	putdocx text ("In wave 1, the data have `inwave1' original sample members. ")
	putdocx text ("The maximum possible number of observed intervals for original sample members is ")
	putdocx text ("`possible_original_obs' (`inwave1' times 14). ")

* Calculate number of fully-observed intervals
gen interval=1 if inwave==1 & innext==1
replace interval=0 if inwave==0 | innext==0

*group observations by whether they are an original sample member and fully-observed interval
sort original interval                  
by original interval: gen norigint=_n // original ==1 and interval ==1 will be the largest group
egen numorigint=max(norigint)
local number_original_intervals = `=numorigint'
local prop_fully_observed=int(100*`number_original_intervals'/`possible_original_obs')


	putdocx text ("The number of fully-observed intervals for original sample members is ")
	putdocx text ("`number_original_intervals' (`prop_fully_observed'%). ")
	
* Calculate number and proportion of observations fully_observed or inferred
* We have more observations of comp_change than we have full intervals because
* we use information on other household members to code ego as experiencing
* a composition change even if ego is missing.

gen nmcomp= !missing(comp_change)   // not missing comp_change

sort original nmcomp 
by original nmcomp: gen norignmc=_n // original ==1 and nmcomp ==1 will be the largest group
egen numorignmc=max(norignmc)
local number_original_nmc = `=numorignmc'
local prop_nmc = int(100*`number_original_nmc'/`possible_original_obs')

	putdocx text ("The number of observed or inferred comp_change intervals for ")
	putdocx text ("original sample members is ")
	putdocx text ("`number_original_nmc' (`prop_nmc'%). So inferring composition change ")
local prop_diff = `prop_nmc' - `prop_fully_observed'
	putdocx text ("reduced missing data by `prop_diff' percentage points." )

*******************************************************************************
* Section: Do we observe children < 15 transitioning alone or without adults?
*******************************************************************************	

	// New paragraph
	putdocx paragraph	
	putdocx text ("Do we observe children < 15 transitioning alone or without adults? "), bold

	putdocx paragraph
	putdocx text ("By design, when children leave a sample household without an adult, ")
	putdocx text ("they are not followed. Assuming the household continues to be ") 
	putdocx text ("observed, these children will be coded as having a composition ")
	putdocx text ("change. In a population-representative sample, children ")
	putdocx text ("exiting without adults should be matched (and represented) by ")
	putdocx text ("children entering sample households unaccompanied by adults. These ")
	putdocx text ("children would also be coded as having a composition change. ")
	putdocx text ("Thus we double count these transitions and this might be a source ")
	putdocx text ("of over-estimation of children’s household instability. ")
	putdocx text ("So, our goal is to determine what proportion of comp_changes ")
	putdocx text ("involve children disappearing alone/with no adults. ")

********************************************************************	
* Create a file with an observation for every person observed in the 
* data the next wave to be merged onto this wave.
use "$tempdir/person_wide_adjusted_ages", clear

keep SSUID EPPPNUM SHHADID* ERRP* adj_age* shhadid_members*

reshape long SHHADID adj_age shhadid_members, i(SSUID EPPPNUM) j(SWAVE)

keep if !missing(SHHADID)

drop SHHADID

replace SWAVE=SWAVE-1

keep if SWAVE > 0

rename EPPPNUM relto
rename adj_age to_age

save "$tempdir/everyoneobservednextwave", $replace

********************************************************************
* Read in file with one observation for each person in ego's (relto) 
* household

* Add to_age to pairs data 
use "$tempdir/relationship_pairs_bywave", clear
rename relto EPPPNUM
merge m:1 SSUID EPPPNUM SWAVE using "$tempdir/demo_long_all", keepusing(adj_age)

keep if _merge==3

drop _merge

* renameing to "other_age" instead of "to_age" to avoid conflict with to_age (next wave)
rename adj_age other_age
rename EPPPNUM relto

gen other_oldenough=1 if other_age > 15

********************************************************************
* count number of household members in this wave 
egen hhmem=count(SHHADID), by(SSUID relfrom SWAVE)
egen oldhhmem=count(other_oldenough), by(SSUID relfrom SWAVE)

********************************************************************
*look for everyone in my household this wave in the next wave

merge m:1 SSUID relto SWAVE using "$tempdir/everyoneobservednextwave"

* drop observations that are just in next wave
drop if _merge==2

gen toinnext=1 if _merge==3

gen toinnext_oldenough=1 if _merge==3 & other_age > 15

********************************************************************
* Collapse to one record per person with indicators for number 

collapse (first) hhmem oldhhmem (count) hhmem_innext=toinnext num_old_innext=toinnext_oldenough, by(SSUID relfrom SWAVE)

gen all_other_observed=1 if hhmem_innext==hhmem

label variable all_other_observed "Every other person in ego's household is observed in next wave"

gen no_other_observed=1 if hhmem_innext==0

label variable no_other_observed "No other person in ego's household is observed in next wave"

gen all_other_old_observed=1 if oldhhmem==num_old_innext

label variable all_other_old_observed "Every other person age 15+ in ego's household is observed in next wave"

gen no_other_old_observed=1 if num_old_innext==0

label variable no_other_old_observed "No other person age 15+ in ego's household is observed in next wave"

rename relfrom EPPPNUM

********************************************************************
* Merge onto hh_change to see how often comp_change happens when all_other_observed=1 (disappear alone)

merge 1:1 SSUID EPPPNUM SWAVE using "$tempdir/hh_change.dta"

keep if _merge==3

gen gone_missing_alone=0 if !missing(comp_change)
replace gone_missing_alone=1 if innext==0 & all_other_observed==1

gen gone_missing_withoutadult=0 if !missing(comp_change)
replace gone_missing_withoutadult=1 if innext==0 & all_other_old_observed==1

save "$tempdir/nextwave.dta", $replace

tab comp_change gone_missing_alone, m

keep if adj_age < 15

tab comp_change gone_missing_alone, m

tab comp_change gone_missing_withoutadult, m

* ssc install putdocxcrosstab
putdocxcrosstab comp_change gone_missing_withoutadult



egen num_compchange=sum(comp_change)
local compchanges=num_compchange

egen num_gone_missing_withoutadult=sum(gone_missing_withoutadult)
local gonemissingbydesign=num_gone_missing_withoutadult
local percentbydesign=int(100*`gonemissingbydesign'/`compchanges')
local impact=`percentbydesign'/2 

	putdocx paragraph
	putdocx text ("Of the `compchanges' intervals where a person < 15 ")
	putdocx text ("is coded as having a composition change, only `gonemissingbydesign' ")
	putdocx text (" (`percentbydesign' percent) of the composition changes involve ")
	putdocx text ("a child leaving without an adult. ")

	
********************************************************************************
* section: What proportion of original household members have complete data?
********************************************************************************

use "$tempdir/comp_change.dta", clear

	putdocx paragraph
	putdocx text ("What proportion of original household members have complete data?"), bold

* original respondents have same value for SHHADID1
gen original=1 if !missing(SHHADID1)

gen nummissing=0
gen ncompchange=0
gen age=adj_age1

label variable nummissing "Number of waves without an interview"

forvalues a=1/15 {
replace nummissing=nummissing+1 if missing(SHHADID`a')
}

gen nobs=15-nummissing
label variable nobs "Number of observed waves"

recode nummissing (0=0)(1/14=1), gen(anymissing)

* What proportion of original sample members are observed 15 waves?
egen propincomplete=mean(anymissing)
local incomplete=int(100*propincomplete)

	// New paragraph
	putdocx paragraph
	putdocx text ("Shifting from intervals to observations, we see that `incomplete' % individuals have some missing observations. ")

*******************************************************************************
* Section: Do those with missing observations have more instability than those 
*          that don't?
*******************************************************************************
	putdocx paragraph
	putdocx text ("Do those with missing observations have more instability than those that don't?"), bold
keep SSUID EPPPNUM SHHADID* nobs anymissing comp_change* comp_change_reason* adj_age*

reshape long comp_change comp_change_reason adj_age SHHADID, i(SSUID EPPPNUM) j(SWAVE)

sort anymissing
by anymissing: sum comp_change

gen anymiss0_compchange=comp_change if anymissing==0
gen anymiss1_compchange=comp_change if anymissing==1

* Is perchange greater for those with anymissing?
egen propchange_anymiss0=mean(anymiss0_compchange)
local propchange_nomiss=round(propchange_anymiss0, .001)

egen propchange_anymiss1=mean(anymiss1_compchange)
local propchange_somemiss=round(propchange_anymiss1, .001)


	// New paragraph
	putdocx paragraph
	putdocx text ("We find that the average proportion experiencing a composition change between waves is `propchange_nomiss', among those with no missing data, and ")
	putdocx text ("`propchange_somemiss' among those with some missing data. ")


putdocx save "$logdir/missingreport.docx", $replace

