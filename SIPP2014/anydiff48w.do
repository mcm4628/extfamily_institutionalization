* prep.do prepares the data files for this step 

* This program searches the string of HH members in month 8 (stored as allHH8) for each pnum in month 4 (stored as sm4rrel_pnumX where X=1 to 30)
* and the string of HH members in month 4 (stored as allHH4) for each pnum in month 8 (stored as sm8rrel_pnumX)

use "$tempdir/babyin8.dta", clear

merge 1:m ssuid eresidenceid8 using "$tempdir/SIPP14_4to8.dta"

drop _merge

merge 1:1 ssuid eresidenceid8 pnum using "$tempdir/agerrelm8.dta"

drop _merge

sort ssuid eresidenceid4

merge 1:1 ssuid eresidenceid4 pnum using "$tempdir/agerrelm4.dta"

drop _merge

*checking to see if anyone moved out 
*Are all the people in at month 4 in the string allHH8?
* !!!! Variable name is counterintuitive. HHout=1 if noone moved out 

gen nrelout=0
forvalues i=1/30 {
gen relout`i'=0
gen pnumout`i'="999"
gen agerelout`i'=97
gen HHout`i'=strpos(allHH8, sm4rrel_pnum`i')
replace HHout`i'=1 if HHout`i' !=0
replace HHout`i'=1 if HHout`i'==0 & sm4rrel_pnum`i'=="999"
replace relout`i'=rrel`i'_m4 if HHout`i'==0 /* relationship of person who moved out */
replace agerelout`i'=agerrelm4_`i' if HHout`i'==0 /* age of person who moved out */
replace pnumout`i'=sm4rrel_pnum`i' if HHout`i'==0 /* person number of person who moved out */
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

*checking to see if anyone moved in 
*Are all the people in at month 8 in the string allHH4?
gen nrelin=0
forvalues i=1/30 {
gen relin`i'=0
gen sHHin`i'=strpos(allHH4, sm8rrel_pnum`i')
gen HHin`i'=sHHin`i'
gen agerelin`i'=97
replace HHin`i'=1 if HHin`i' !=0
replace HHin`i'=1 if HHin`i'==0 & sm8rrel_pnum`i'=="999"
replace relin`i'=rrel`i'_m8 if HHin`i'==0
replace agerelin`i'=agerrelm8_`i' if HHin`i'==0
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

gen anydiff48=0
forvalues i=1/30 {
replace anydiff48=1 if HHout`i'==0 | HHin`i'==0
}

gen Compchange=0
replace Compchange=1 if anydiff48==1

replace anydiff48=1 if in8not4==1 & tage8 != 0

gen moved48=1 if eresidenceid4 != eresidenceid8
replace moved48=0 if missing(moved48)

replace anydiff48=1 if eresidenceid4 !=eresidenceid8

gen born48=1 if in8not4==1 & tage8==0
replace born48=0 if missing(born48)

replace anydiff48=0 if born48==1
replace moved48=0 if born48==1

forvalues t=1/27 {
 replace typrelin`t'=0 if born48==1
}


tab anydiff48

keep ssuid pnum anydiff48 in8not4 moved48 born48 tage4 anybabyin relout* ///
relin* nrelin nrelout typrelout* typrelin* Compchange agerelin* agerelout*

save "$tempdir/anydiff48.dta", replace

drop if tage4 > 16

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
