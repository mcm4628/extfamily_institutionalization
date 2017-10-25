*
* Creates variables identifying whether there is a type-2 biological mother in the household each month.
*
* First restrict the sample to individuals with any type 2 people in a reference month.
* and calculate the number of individuals who were biologically related to ego as parent or child. 
* Note that numpc could include type 1 and type 2 individuals. Separate code deals with type 1 biological mothers.
*
* Finally, use et2_ sequence of variables to identify biological mothers (who are female, have rel==5, and are older than ego

but there is a problem with the et2_ variables, they often are inconsistent with the rrel variables

use "$SIPP2014data/selected.dta", clear

gen ntyp2=0
forvalues i=1/10{
replace ntyp2=ntyp2+1 if et2_rel`i' !=.
}

tab ntyp2

* focus on those individuals with at least one type 2 person in the household
keep if ntyp2 > 0

gen numpc=0

* Count the number of people in the household who are a child or parent of ego
forvalues i=1/30{
replace numpc=numpc+1 if rrel`i'==5
}

*max is 9

tab numpc

gen t2biomom=0
gen t2biomom_pnum=999
gen t2biodad=0
gen t2biodad_pnum=999

forvalues m=1/12{
  forvalues a=1/10{
    replace t2biomom=1 if monthcode==`m' & et2_sex`a'==2 & et2_rel`a'==5 & tt2_age`a' > tage & et2_mth`m'_`a'==1
	replace t2biomom_pnum=et2_lno`a' if monthcode==`m' & et2_sex`a'==2 & et2_rel`a'==5 & tt2_age`a' > tage & et2_mth`m'_`a'==1
	replace t2biodad=1 if monthcode==`m' & et2_sex`a'==1 & et2_rel`a'==5 & tt2_age`a' > tage & et2_mth`m'_`a'==1
	replace t2biodad_pnum=et2_lno`a' if monthcode==`m' & et2_sex`a'==1 & et2_rel`a'==5 & tt2_age`a' > tage & et2_mth`m'_`a'==1
}
}

replace t2biomom=0 if missing(t2biomom)
replace t2biodad=0 if missing(t2biodad)

sort ssuid pnum monthcode 

save "$tempdir/t2parent.dta", replace

tab t2biomom
tab t2biodad
tab t2biomom_pnum
tab t2biodad_pnum

tab numpc

tab numpc t2biomom
