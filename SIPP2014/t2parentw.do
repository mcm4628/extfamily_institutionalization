*
* Creates variables identifying whether there is a type-2 biological mother in the household each month.
*
* First restrict the sample to individuals with any type 2 people in a reference month.
* and calculate the number of individuals who were biologically related to ego as parent or child. 
* Note that numpc could include type 1 and type 2 individuals. Separate code deals with type 1 biological mothers.
*
* Finally, use et2_ sequence of variables to identify biological mothers (who are female, have rel==5, and are older than ego

*but there is a problem with the et2_ variables, they often are inconsistent with the rrel variables

use "$SIPP2014data/selected.dta", clear

*checking ET2 variables for any type 2 person
*gen ntyp2=0
*forvalues i=1/10{
*replace ntyp2=ntyp2+1 if et2_rel`i' !=.
*}

gen nt2=0
forvalues p=1/30{
replace nt2=nt2+1 if rrel_pnum`p' >= 60 & rrel_pnum`p' <=99
}

*tab ntyp2 nt2
* more type 2 people found by looking at rrel variables than ET2 variables

* focus on those individuals with at least one type 2 person in the household (rrel)
keep if nt2 > 0

gen numpc=0

* Count the number of people in the household who are a child or parent of ego
forvalues p=1/30{
replace numpc=numpc+1 if rrel`p'==5
}

*max is 9

tab numpc

gen t2biopc=0

forvalues i=1/5{
 gen t2biopc`i'_pnum=999
}

forvalues p=1/30{
 replace t2biopc=t2biopc+1 if rrel`p'==5 & rrel_pnum`p' >= 60 & rrel_pnum`p' <=99
 replace t2biopc1_pnum=rrel_pnum`p' if rrel`p'==5 & rrel_pnum`p' >= 60 & rrel_pnum`p' <=99 & t2biopc==1
 replace t2biopc2_pnum=rrel_pnum`p' if rrel`p'==5 & rrel_pnum`p' >= 60 & rrel_pnum`p' <=99 & t2biopc==2
 replace t2biopc3_pnum=rrel_pnum`p' if rrel`p'==5 & rrel_pnum`p' >= 60 & rrel_pnum`p' <=99 & t2biopc==3
 replace t2biopc4_pnum=rrel_pnum`p' if rrel`p'==5 & rrel_pnum`p' >= 60 & rrel_pnum`p' <=99 & t2biopc==4
 replace t2biopc5_pnum=rrel_pnum`p' if rrel`p'==5 & rrel_pnum`p' >= 60 & rrel_pnum`p' <=99 & t2biopc==5
}

sort ssuid t2biopc1_pnum

drop et2_* tt2_*

save "$tempdir/t2biopc.dta", replace

*********************************************************************************************************
* merging each of the biopc only the type 2 person file to get each person's age and sex
*********************************************************************************************************
use "$SIPP2014data/t2persons.dta", clear

rename pnum t2biopc1_pnum

merge ssuid t2biopc1_pnum using "$tempdir/t2biopc.dta"

rename tt2_age t2bpc1_age 
rename et2_sex t2bpc1_sex 

sort ssuid t2biopc2_pnum

drop _merge

save "$tempdir/t2biopc1.dta", replace

use "$SIPP2014data/t2persons.dta", clear

rename pnum t2biopc2_pnum

merge ssuid t2biopc2_pnum using "$tempdir/t2biopc1.dta"

rename tt2_age t2bpc2_age 
rename et2_sex t2bpc2_sex 

sort ssuid t2biopc3_pnum

drop _merge
save "$tempdir/t2biopc2.dta", replace

use "$SIPP2014data/t2persons.dta", clear

rename pnum t2biopc3_pnum

merge ssuid t2biopc3_pnum using "$tempdir/t2biopc2.dta"

rename tt2_age t2bpc3_age 
rename et2_sex t2bpc3_sex 

sort ssuid t2biopc4_pnum
drop _merge
save "$tempdir/t2biopc3.dta", replace

use "$SIPP2014data/t2persons.dta", clear

rename pnum t2biopc4_pnum

merge ssuid t2biopc4_pnum using "$tempdir/t2biopc3.dta"

rename tt2_age t2bpc4_age 
rename et2_sex t2bpc4_sex 

sort ssuid t2biopc5_pnum
drop _merge
save "$tempdir/t2biopc4.dta", replace

use "$SIPP2014data/t2persons.dta", clear

rename pnum t2biopc5_pnum

merge ssuid t2biopc5_pnum using "$tempdir/t2biopc4.dta"

rename tt2_age t2bpc5_age 
rename et2_sex t2bpc5_sex 

drop _merge
save "$tempdir/t2biopc5.dta", replace

*********************************************************************************************************
* checking each person...are you my mommy?
*********************************************************************************************************

gen t2biomom=0
gen t2biomom_pnum=999
gen t2biodad=0
gen t2biodad_pnum=999


forvalues p=1/5{
replace t2biomom=1 if t2bpc`p'_age > tage & t2bpc`p'_sex==2
replace t2biomom_pnum=t2biopc`p'_pnum if t2bpc`p'_age > tage & t2bpc`p'_sex==2
replace t2biodad=1 if t2bpc`p'_age > tage & t2bpc`p'_sex==1
replace t2biodad_pnum=t2biopc`p'_pnum if t2bpc`p'_age > tage & t2bpc`p'_sex==1
}

tab t2biomom t2biodad

keep ssuid pnum monthcode t2biomom t2biodad t2biomom_pnum t2biodad_pnum

sort ssuid pnum monthcode 

save "$tempdir/t2parent.dta", replace

*
* Written for the ET2 variables, but they don't appear to be working as expected
*
*forvalues m=1/12{
*  forvalues a=1/10{
*    replace t2biomom=1 if monthcode==`m' & et2_sex`a'==2 & et2_rel`a'==5 & tt2_age`a' > tage & et2_mth`m'_`a'==1
*	replace t2biomom_pnum=et2_lno`a' if monthcode==`m' & et2_sex`a'==2 & et2_rel`a'==5 & tt2_age`a' > tage & et2_mth`m'_`a'==1
*	replace t2biodad=1 if monthcode==`m' & et2_sex`a'==1 & et2_rel`a'==5 & tt2_age`a' > tage & et2_mth`m'_`a'==1
*	replace t2biodad_pnum=et2_lno`a' if monthcode==`m' & et2_sex`a'==1 & et2_rel`a'==5 & tt2_age`a' > tage & et2_mth`m'_`a'==1
*}
*}


/*

