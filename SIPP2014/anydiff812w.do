* prep.do prepares the data files for this program 

* This program searches the string of HH members in month 12 (stored as allHH12) for each pnum in month 8 (stored as sm8rrel_pnumX where X=1 to 30)
* and the string of HH members in month 8 (stored as allHH8) for each pnum in month 12 (stored as sm12rrel_pnumX)

use "$SIPP2014data/ChildWellBeingw1.dta", clear

keep if monthcode==12

save "$tempdir/cwb.dta", replace

use "$tempdir/babyin12.dta", clear
* Note that babyin is a residence level variables (ssuid eresidence id)

merge 1:m ssuid eresidenceid12 using "$tempdir/SIPP14_8to12.dta"

drop _merge 

merge 1:1 ssuid pnum using "$tempdir/cwb.dta"

drop _merge

merge 1:1 ssuid eresidenceid12 pnum using "$tempdir/agerrelm12.dta"

drop _merge

sort ssuid eresidenceid8

merge 1:1 ssuid eresidenceid8 pnum using "$tempdir/agerrelm8.dta"

drop _merge

*checking to see if anyone moved out 
*Are all the people in at month 8 in the string allHH12?
* !!!! Variable name is counterintuitive. HHout=1 if noone moved out 

gen nrelout=0

forvalues i=1/30 {
gen relout`i'=0
gen pnumout`i'="999"
gen agerelout`i'=97
gen HHout`i'=strpos(allHH12, sm8rrel_pnum`i')
replace HHout`i'=1 if HHout`i' !=0
replace HHout`i'=1 if HHout`i'==0 & sm8rrel_pnum`i'=="999"
replace relout`i'=rrel`i'_m8 if HHout`i'==0 /* relationship of person who moved out */
replace agerelout`i'=agerrelm8_`i' if HHout`i'==0 /* age of person who moved out */
replace pnumout`i'=sm8rrel_pnum`i' if HHout`i'==0 /* person number of person who moved out */
replace nrelout=nrelout+1 if HHout`i'==0 
}

forvalues t=1/27{
	gen typrelout`t'=0
	forvalues i=1/30{
		replace relout`i'=20 if relout`i'==5 & agerelout`i' < 3 /* biological child (rare)*/
		replace relout`i'=25 if relout`i' >= 9 & relout`i' <=13 
		replace relout`i'=21 if relout`i'==25 & agerelout`i'==0 /* sibling AGE 0 */
		replace relout`i'=22 if relout`i'==25 & agerelout`i'==1 /* sibling age 1-17 */
		replace relout`i'=23 if relout`i'==25 & agerelout`i'==2 /* sibling age 18-29 */
		replace relout`i'=24 if relout`i'==25 & agerelout`i' >= 3 & agerelout`i' <=4  /* sibling age > 30 */
		replace relout`i'=26 if relout`i'==19 & agerelout`i' < 2 /* non-relative child */
		replace relout`i'=27 if relout`i'==19 & agerelout`i' >=2 & agerelout`i' <=4 /* non-relative adult */
		replace typrelout`t'=typrelout`t'+1 if relout`i'==`t'
	}
}

gen nrelin=0

forvalues i=1/30 {
gen relin`i'=0
gen sHHin`i'=strpos(allHH8, sm12rrel_pnum`i')
gen HHin`i'=sHHin`i'
gen agerelin`i'=97
replace HHin`i'=1 if HHin`i' !=0
replace HHin`i'=1 if HHin`i'==0 & sm12rrel_pnum`i'=="999"
replace relin`i'=rrel`i'_m12 if HHin`i'==0
replace agerelin`i'=agerrelm12_`i' if HHin`i'==0
replace nrelin=nrelin+1 if HHin`i'==0
}

forvalues t=1/27{
	gen typrelin`t'=0
	forvalues i=1/30{
		replace relin`i'=20 if relin`i'==5 & agerelin`i' < 3 /* biological child (rare)*/
    	replace relin`i'=25 if relin`i' >= 9 & relin`i' <=13 
		replace relin`i'=21 if relin`i'==25 & agerelin`i'==0 /* sibling AGE 0 */
		replace relin`i'=22 if relin`i'==25 & agerelin`i'==1 /* sibling age 1-17 */
		replace relin`i'=23 if relin`i'==25 & agerelin`i'==2 /* sibling age 18-29 */
		replace relin`i'=24 if relin`i'==25 & agerelin`i' >=3 & agerelin`i' <=4  /* sibling age > 30 */
		replace relin`i'=26 if relin`i'==19 & agerelin`i' < 2 /* non-relative child */
		replace relin`i'=27 if relin`i'==19 & agerelin`i' >=2 & agerelin`i' <=4 /* non-relative adult */
		replace typrelin`t'=typrelin`t'+1 if relin`i'==`t'
	}
}

gen anydiff812=0
forvalues i=1/30 {
replace anydiff812=1 if HHout`i'==0 | HHin`i'==0
}

gen Compchange=0
replace Compchange=1 if anydiff812==1

gen moved812=1 if eresidenceid8 != eresidenceid12
replace moved812=0 if missing(moved812)

replace anydiff812=1 if in12not8==1 
replace anydiff812=1 if eresidenceid8 !=eresidenceid12

gen born812=1 if in12not8==1 & tage12==0
replace born812=0 if missing(born812)

replace moved812=0 if born812==1

tab born812

forvalues t=1/27 {
 replace typrelin`t'=0 if born812==1
}

replace anydiff812=0 if born812==1
replace nrelin=0 if born812==1
replace nrelout=0 if born812==1

tab anydiff812

keep ssuid pnum anydiff812 in12not8 moved812 born812 tage8 anybabyin relout* ///
relin* nrelin nrelout typrelout* typrelin* Compchange rcares rworks rgetby ///
agerelin* agerelout* 

gen nhhchange=nrelin+nrelout

gen anyparent=0
replace anyparent=1 if typrelout5+typrelout6+typrelout7+typrelin5+typrelin6+typrelin7 > 0
replace anyparent=0 if born812==1

gen anysib=0
replace anysib=1 if typrelout9+typrelout10+typrelout11+typrelout12+typrelout13+typrelin9+typrelin10+typrelin11+typrelin12+typrelin13 > 0
replace anysib=0 if born812==1

gen anyrel=0
replace anyrel=1 if typrelout14+typrelout15+typrelout16+typrelout17+typrelin14+typrelin15+typrelin16+typrelin17 > 0
replace anyrel=0 if born812==1

gen anygp=0
replace anygp=1 if typrelin8+typrelout8 > 0 
replace anygp=0 if born812==1

gen anynr=0
replace anynr=1 if typrelout19+typrelin19 > 0
replace anynr=0 if born812==1

gen anychild=0
replace anychild=1 if typrelout20==1
replace anychild=0 if born812==1

save "$tempdir/anydiff812.dta", replace

drop if tage8 > 16

tab typrelout1
tab typrelout2
tab typrelout3
tab typrelout4
tab typrelout5
tab typrelout6
tab typrelout7
tab typrelout8
tab typrelout9
tab typrelout10
tab typrelout11
tab typrelout12
tab typrelout13
tab typrelout14
tab typrelout15
tab typrelout16
tab typrelout17
tab typrelout18
tab typrelout19
tab typrelout20
tab typrelout21
tab typrelout22
tab typrelout23
tab typrelout24
tab typrelout25

tab typrelin1
tab typrelin2
tab typrelin3
tab typrelin4
tab typrelin5
tab typrelin6
tab typrelin7
tab typrelin8
tab typrelin9
tab typrelin10
tab typrelin11
tab typrelin12
tab typrelin13
tab typrelin14
tab typrelin15
tab typrelin16
tab typrelin17
tab typrelin18
tab typrelin19
tab typrelin20
tab typrelin21
tab typrelin22
tab typrelin23
tab typrelin24
tab typrelin25

/*


tab agerelout1
tab agerelout2
tab agerelout3
tab agerelout4
tab agerelout5
tab agerelout6
tab agerelout7
tab agerelout8
tab agerelout9
tab agerelout10
tab agerelout11
tab agerelout12
tab agerelout13
tab agerelout14
tab agerelout15
tab agerelout16
tab agerelout17
tab agerelout18
tab agerelout19




/*
tab nhhchange
tab rcares
tab rworks
tab rgetby


ologit rcares anyparent anysib anyrel anygp anynr moved812
ologit rworks anyparent anysib anyrel anygp anynr moved812
ologit rgetby anyparent anysib anyrel anygp anynr moved812



/*


