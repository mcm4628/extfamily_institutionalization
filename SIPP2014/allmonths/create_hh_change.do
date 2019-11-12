//==============================================================================
//===== Children's Household Instability Project                                                    
//===== Dataset: SIPP2014                                                                              
//===== Purpose: Create a database with comp_change, addr_change, and sociodemographic characteristics
//===== One record per person per month.
//===== create_comp_change generates the variable comp_change. This file adds addr_change
//===== and reshapes the data to long form.
//===== Note: this code depends on macros set in project_macros and create_comp_change
//==============================================================================

use "$SIPP14keep/comp_change_am.dta", clear

#delimit ; 
label define addr_change          0 "No move"
                                  1 "Move";	 
#delimit cr

********************************************************************************
* Section Propagate residence_members forward into prev_ERESIDENCEID for missing months.
********************************************************************************

gen prev_ERESIDENCEID$first_month = .
forvalues month = $second_month/$final_month {
    local prev_month = `month' - 1
	gen prev_ERESIDENCEID`month' = ERESIDENCEID`prev_month' if (missing(ERESIDENCEID`month') & missing(prev_ERESIDENCEID`prev_month'))
	replace prev_ERESIDENCEID`month' = prev_ERESIDENCEID`prev_month' if (missing(ERESIDENCEID`month') & (!missing(prev_ERESIDENCEID`prev_month')))
}

********************************************************************************
** Section:  Propagate residence_members backward into future_hh_members for missing months.  
********************************************************************************

gen future_ERESIDENCEID$final_month = .
forvalues month = $penultimate_month (-1) $first_month {
    local next_month = `month' + 1
    gen future_ERESIDENCEID`month' = ERESIDENCEID`next_month' if (missing(ERESIDENCEID`month') & missing(future_ERESIDENCEID`next_month'))
	replace future_ERESIDENCEID`month' = future_ERESIDENCEID`next_month' if (missing(ERESIDENCEID`month') & (!missing(future_ERESIDENCEID`next_month')))
}

********************************************************************************
** Section: walk backward through the months and for each month in which ego is missing  compare prev_ERESIDENCEID to see if we find anyone
********************************************************************************

gen found_prev_ERESID$first_month = .
forvalues month = $final_month (-1) $second_month {
	gen found_prev_ERESID`month'= 0 if (missing(ERESIDENCEID`month'))
	gen found_prev_ERESID_in_gap`month'=0 if (missing(ERESIDENCEID`month'))
	replace found_prev_ERESID`month' = 1 if ((missing(ERESIDENCEID`month')) & (strpos(ssuid_residence`month', " " + string(prev_ERESIDENCEID`month') + " ") != 0))
	replace found_prev_ERESID_in_gap`month' = 1 if ((missing(ERESIDENCEID`month')) & (strpos(ssuid_residence`month', " " + string(prev_ERESIDENCEID`month') + " ") !=0))
	if (`month' < $final_month) {
		local next_month = `month' + 1
		replace found_prev_ERESID_in_gap`month' = 1 if ((missing(ERESIDENCEID`month')) & (found_prev_ERESID_in_gap`next_month' == 1))
	}
}

********************************************************************************
** Section: walk forward through the months 
********************************************************************************

gen found_future_ERESID$final_month = .
forvalues month = $first_month/$penultimate_month {
	gen found_future_ERESID`month'= 0 if (missing(ERESIDENCEID`month'))
	gen found_future_ERESID_in_gap`month'=0 if (missing(ERESIDENCEID`month'))
	replace found_future_ERESID`month' = 1 if ((missing(ERESIDENCEID`month')) & (strpos(ssuid_residence`month', " " + string(prev_ERESIDENCEID`month') + " ") != 0))
	replace found_future_ERESID_in_gap`month' = 1 if ((missing(ERESIDENCEID`month')) & (strpos(ssuid_residence`month', " " + string(prev_ERESIDENCEID`month') + " ") !=0))
	if (`month' > $final_month) {
		local prev_month = `month' - 1
		replace found_future_ERESID_in_gap`month' = 1 if ((missing(ERESIDENCEID`month')) & (found_future_ERESID_in_gap`prev_month' == 1))
	}
}

*******************************************************************************
** Section: Compute address change.
*******************************************************************************

forvalues month = $first_month/$penultimate_month {
    local next_month = `month' + 1

    * Start by assuming this month is not interesting.
    gen addr_change`month' = .

    * If we have data in both months, just compare HH members.
    replace addr_change`month' = (ERESIDENCEID`month' != ERESIDENCEID`next_month') if ((!missing(ERESIDENCEID`month')) & (!missing(ERESIDENCEID`next_month')))

    * If we are moving from a month in which ego is missing to one in which ego is present
    * there is an address change if we have seen the future ERESIDENCEID in the gap during which ego was missing
    * UNLESS this is ego's birth.
    * We also need to populate age and weight from the next month since ego has no data in this month.
    replace addr_change`month' = 1 if ((missing(ERESIDENCEID`month')) & (!missing(ERESIDENCEID`next_month')) & (found_future_ERESID_in_gap`month' == 1))
    replace adj_age`month' = adj_age`next_month' if ((missing(ERESIDENCEID`month')) & (!missing(ERESIDENCEID`next_month')) & (found_future_ERESID_in_gap`month' == 1))
    replace WPFINWGT`month' = WPFINWGT`next_month' if ((missing(ERESIDENCEID`month')) & (!missing(ERESIDENCEID`next_month')) & (found_future_ERESID_in_gap`month' == 1))
    * Undo those changes if this is birth.
    replace addr_change`month' = . if ((`next_month' == my_first_month) & (adj_age`next_month' == 0))
    replace adj_age`month' = . if ((`next_month' == my_first_month) & (adj_age`next_month' == 0))
    replace WPFINWGT`month' = . if ((`next_month' == my_first_month) & (adj_age`next_month' == 0))

    * If we are moving from a month in which ego is present to one in which ego is missing
    * there is an address change if we have seen the current ERESIDENCEID in the gap 
    * during which ego is missing as we look forward.
    replace addr_change`month' = 1 if ((!missing(ERESIDENCEID`month')) & (missing(ERESIDENCEID`next_month')) & (found_prev_ERESID_in_gap`next_month' == 1))

    * If we are moving from a month in which ego is present to one in which ego is missing
    * and we do not see the current ERESIDENCEID in the gap looking forward,
    * we compare the current ERESIDENCEID to the future ERESIDENCEID as if we move into the
    * future household in the first missing month, unless there is no future ERESIDENCEID
    * (ego's last appearance).
    replace addr_change`month' = (ERESIDENCEID`month' != future_ERESIDENCEID`next_month') if ((!missing(ERESIDENCEID`month')) & (missing(ERESIDENCEID`next_month')) & (!missing(future_ERESIDENCEID`next_month')) & (found_prev_ERESID_in_gap`next_month' != 1))


    * Tab "original" addr_change and comp_change variables.
    tab addr_change`month' comp_change`month', m

    * We once forced them up to have the same denominator by setting to zero if missing and the other variable is not missing.
	* but this is not appropriate. Sometimes we can know if there was an address change even if we don't know household composition
	* Keeping this here to document.
*    replace addr_change`month' = 0 if (missing(addr_change`month') & (!missing(comp_change`month')))
*    replace comp_change`month' = 0 if (missing(comp_change`month') & (!missing(addr_change`month')))

*    tab addr_change`month' comp_change`month', m
}

gen original=1 if !missing(TAGE4)
gen agemonth1=adj_age1 if original==1

keep SSUID PNUM ERESIDENCEID* adj_age* comp_change* addr_change* comp_change_reason* original agemonth1

reshape long ERESIDENCEID adj_age comp_change addr_change comp_change_reason, i(SSUID PNUM) j(panelmonth)

merge 1:1 SSUID PNUM panelmonth using "$SIPP14keep/demo_long_all_am.dta"

* these cases were create for a loop in normalize_ages 
drop if panelmonth==49


assert _merge==3

drop _merge

gen hh_change=comp_change
replace hh_change=1 if addr_change==1

gen inmonth = !missing(ERESIDENCEID)

gen insample=0
* Keep if in this month and next
replace insample=1 if inmonth==1 & innext==1
* also keep if hh_change is not missing. This would be (for example) if not in current month, 
* but in next one and people you live with in next month appear while ego is missing.
* hh_change also ==1 if in current month and not in next, but some of the people 
* you are living with now appear in "next" month while ego is missing.
* hh_change can =0 if not in next month but in a subsequent one and everyone ego 
* is with in this month is in the household in the next appearence
replace insample=2 if insample==0 & !missing(comp_change)
replace insample=3 if insample==0 & !missing(hh_change)

	label var comp_change_reason "Codes for whether comp_change is observed in adjascent months or inferred"
    label values comp_change_reason comp_change_reason
	
	label var comp_change "Indicator for whether a composition change is observed or inferred"
	label values comp_change comp_change
	
	label var addr_change "Indicator for whether individual moved"
	label values addr_change addr_change

save "$SIPP14keep/hh_change_am.dta", $replace
