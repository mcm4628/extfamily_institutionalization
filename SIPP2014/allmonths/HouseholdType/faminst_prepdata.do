* famiinst_prepdata.do
*
*  Merge together files desccribing household composition in December of each year
*  to predict a composition change over the subsequent year.

*******************************************************
* bring in comp_change and create annual measure of composition change
********************************************************
*

// a wide file
use "$SIPP14keep/comp_change_am.dta", clear

gen comp_change0=.
gen leavers0=" "

forvalues y=1/4 {
	gen obsyear`y'=0 // dummy indicator for whether there were  observations in this year
	forvalues m=0/11 {
		local pm=((`y'-1)*12)+`m'
		replace obsyear`y'=obsyear`y'+1 if !missing(comp_change`pm')
	}
}

forvalues y=1/4 {
	gen comp_changey`y'= 0 if obsyear`y' > 0
	gen hhsplity`y'=0 if obsyear`y' > 0
	forvalues m=0/11 {
		local pm=((`y'-1)*12)+`m'
		replace comp_changey`y'=1 if comp_change`pm'==1
		replace hhsplity`y'=1 if leavers`pm' != " " & !missing(leavers`pm')
	}
	tab comp_changey`y' hhsplity`y', m
}


keep SSUID PNUM comp_changey? hhsplity? obsyear?

reshape long comp_changey hhsplity obsyear, i(SSUID PNUM) j(year)

tab comp_changey hhsplity, m

replace year=year-1 // lag the dv

save "$tempdir/compchangey14", replace

use  "$tempdir/relationships14.dta", replace

keep if inlist(panelmonth, 12, 24, 36, 48)

gen year=1 if panelmonth==12
replace year=2 if panelmonth==24
replace year=3 if panelmonth==36
replace year=4 if panelmonth==48 

merge 1:1 SSUID PNUM year using "$tempdir/compchangey14"

keep if _merge == 3

keep if adj_age < 18

gen parentcomp=1 if bioparent==2
replace parentcomp=2 if bioparent==1 & parent==1
replace parentcomp=3 if parent > bioparent
replace parentcomp=4 if parent==0

label define parentcomp 1 "two bio parent" 2 "single bioparent" 3 "stepparent" 4 "noparent"

* mean-center mom_age
mean mom_age
replace mom_age=mom_age-37 
replace mom_age=0 if missing(mom_age)

gen mom_age2=mom_age*mom_age

* dummy indicators for demographics
gen black= my_racealt==2
gen nhwhite= my_racealt==1
gen hispanic= my_racealt==3
gen asian= my_racealt==4
gen otherr=my_racealt==5

gen plths=par_ed_first==1
gen phs=par_ed_first==2
gen pscol=par_ed_first==3
gen pcolg=par_ed_first==4
gen pedmiss= missing(par_ed_first)

gen twobio=parentcomp==1
gen singlebio=parentcomp==2
gen stepparent=parentcomp==3
gen noparent=parentcomp==4

save "$SIPP14keep/faminst_analysis.dta", replace


 
