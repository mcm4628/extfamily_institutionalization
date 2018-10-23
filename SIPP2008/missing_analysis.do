//==============================================================================
//===== Children's Household Instability Project                                                    
//===== Dataset: SIPP2008                                                                               
//===== Purpose: Evaluate how much missing data might bias our analyses
//==============================================================================

* Setup to put output in document

	putdocx begin
	
	// Create a paragraph
	putdocx paragraph

* Read in data
use "$tempdir\hh_change.dta", clear

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
	putdocx text ("In wave 1, the data have `ninwave1' original sample members. ")
	putdocx text ("The maximum possible number of observed intervals for original sample members is ")
	putdocx text ("`possible_original_obs' (`ninwave1' times 14). ")

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

	putdocx text ("The number of observed or inferred comp_change intervals original sample members is ")
	putdocx text ("`number_original_nmc' (`prop_nmc'%). So inferring composition change ")
	putdocx text ("reduced missing data by (`prop_nmc' - `prop_fully_observed') percentage points." )

*******************************************************************************
* Section: Do we observe children < 15 transitioning alone?
*******************************************************************************	
	// New paragraph
	putdocx paragraph	

use "$tempdir/changebytype.dta", clear

	putdocx text ("The SIPP does not follow original sample members < 15 years old when they ") 
	putdocx text ("leave the household with no original sample member >=15 years old. ")
	putdocx text ("We are interested to know how often this happens. In our code this would ")
	putdocx text ("be where a person is < 15 and not observed in the next wave ")

* keep observations < 15 years old and who were not observed in the next wave
keep if adj_age < 15 & innext==0

local cases=_N

	putdocx text ("(N=`cases'). ")
	
	putdocx paragraph
	putdocx text ("If we have a value on comp_change, then someone in the child's household ")
	putdocx text ("must be observed in some future wave. If everyone the child was living with ")
	putdocx text ("never appears in the data when the child is missing and is with the child at ")
	putdocx text ("the child's next appearance, then comp_change will equal zero. ")
	putdocx text ("If someone living with the child is observed living apart from the child before or ")
	putdocx text ("when the child reappears, then comp_change==1. ")

* if comp_change=1 then we know that some people in child's household are observed in the next wave

	putdocxfreqtable comp_change, nocum 

* if adult_leave=1 then we know that an adult in child's household is observed in next wave

	// New paragraph
	putdocx paragraph
	
	putdocx text ("If the other person is an adult, then adult_leave should ==1. ")
	
	putdocxfreqtable adult_leave, nocum

use "$tempdir/changebytype.dta", clear

	// New paragraph
	putdocx paragraph
	putdocx text ("In a population representative sample, children <15 exiting households alone ")
	putdocx text ("[i.e. exiting the data with a comp_change==1] should be matched by ")
	putdocx text ("children entering households alone. These children would not be ")
	putdocx text ("observed in the current wave and appear in the next wave. ")

keep if adj_age < 15 & inwave==0	

	putdocx text ("They should all experience a composition change, but we aren't ") 
	putdocx text ("well set-up to determine whether they entered the houeshold alone. ")
	putdocxfreqtable comp_change, nocum
	
********************************************************************************
* section: What proportion of original household members have complete data?
********************************************************************************

use "$tempdir\comp_change.dta", clear

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
	putdocx text ("Do those with some missing data tend to have more unstable households during the observed periods? ")
	putdocx text ("We find that the average proportion experiencing a composition change between waves is `propchange_nomiss', among those with no missing data, and ")
	putdocx text ("`propchange_somemiss' among those with some missing data. ")


putdocx save "$logdir/missingreport.docx", $replace

