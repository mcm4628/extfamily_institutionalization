//==============================================================================
//===== Children's Household Instability Project                                                    
//===== Dataset: SIPP2008                                                                               
//===== Purpose: Evaluate how much missing data might bias our analyses
//==============================================================================
use "$tempdir\hh_change.dta", clear

********************************************************************************
* Section: Does recovering comp_change by looking for other household members in
*          the gap make much difference to our estimates?
*
* Logic: Create an alternative measure of comp_change that is missing if 
*        comp_change_reason != 0|1. Compare instability rates for two measures
********************************************************************************

gen comp_change_nm=comp_change if inlist(comp_change_reason,0,1)
replace comp_change_nm=. if innext==0


* "interval" is a fully-observe interval
gen interval=1 if inwave==1 & innext==1
replace interval=0 if inwave==0 | innext==0

tab SWAVE interval

* we have more observations of comp_change than we have full intervals because
* we use information on other household members to code ego as experiencing
* a composition change even if ego is missing.
tab SWAVE comp_change 



********************************************************************************
* section: What proportion of original household members have complete data?
********************************************************************************

use "$tempdir\comp_change.dta", clear

drop _*

* original respondents have same value for SHHADID1
keep if SHHADID1==11

gen nummissing=0
gen ncompchange=0
gen nummisscc=0
gen age=adj_age1

label variable nummissing "Number of waves without an interview"
label variable nummisscc "Number of waves where we do not know comp change"

forvalues a=1/15 {
replace nummissing=nummissing+1 if missing(SHHADID`a')
}

forvalues a=1/14 {
replace ncompchange=ncompchange+1 if comp_change`a'==1
replace nummisscc=nummisscc+1 if missing(comp_change`a')
}

tab nummissing
tab nummisscc

gen nobs=15-nummissing
gen nobscc=15-nummisscc

tab nobs
tab nobscc

keep SSUID EPPPNUM comp_change* comp_change_reason* SHHADID*

reshape long comp_change comp_change_reason SHHADID, i(SSUID EPPPNUM) j(SWAVE)

tab comp_change

/*

recode age (0=0)(1/14=1)(15/24=2)(25/99=3), gen(cage)
recode nummissing (0=0)(1/14=1), gen(anymissing)
recode nummisscc (0=0)(1/14=1), gen(anyccmissing)

tab anymissing anyccmissing, m

keep if nobs > 0

gen perchange=100*nobscc/nobs

tab anymissing cage, col

sort anymissing
by anymissing: sum perchange

sum perchange



