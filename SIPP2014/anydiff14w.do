* prep.do prepares the data files for this step 

* This program searches the string of HH members in month 4 (stored as allHH4) for each pnum in month 1 (stored as sm1rrel_pnumX where X=1 to 30)
* and the string of HH members in month 1 (stored as allHH1) for each pnum in month 4 (stored as sm4rrel_pnumX)

use "$tempdir/babyin4.dta", clear

merge 1:m ssuid eresidenceid4 using "$tempdir/SIPP14_1to4.dta"

drop _merge

*checking to see if anyone moved out 
*Are all the people in at month 1 in the string allHH4?
* !!!! Variable name is counterintuitive. HHout=1 if noone moved out 

gen relout=0
forvalues i=1/30 {
gen HHout`i'=strpos(allHH4, sm1rrel_pnum`i')
replace HHout`i'=1 if HHout`i' !=0
replace HHout`i'=1 if HHout`i'==0 & sm1rrel_pnum`i'=="999"
replace relout=rrel`i'_m1 if HHout`i'==0 & relout==0 /* relationship of person who moved out */
}

*checking to see if anyone moved in 
*Are all the people in at month 4 in the string allHH1?
gen relin=0
forvalues i=1/30 {
gen HHin`i'=strpos(allHH1, sm4rrel_pnum`i')
replace HHin`i'=1 if HHin`i' !=0
replace HHin`i'=1 if HHin`i'==0 & sm4rrel_pnum`i'=="999"
replace relin=rrel`i'_m4 if HHin`i'==0
}


gen anydiff14=0
forvalues i=1/30 {
replace anydiff14=1 if HHout`i'==0 | HHin`i'==0
}

gen Compchange=0
replace Compchange=1 if anydiff14==1

replace anydiff14=1 if in4not1==1 & tage4 != 0

gen moved14=1 if eresidenceid1 != eresidenceid4
replace moved14=0 if missing(moved14)

replace anydiff14=1 if eresidenceid1 !=eresidenceid4

gen born14=1 if in4not1==1 & tage4==0

replace anydiff14=0 if born14==1

tab anydiff14

keep ssuid pnum anydiff14 in4not1 moved14 born14 tage1 anybabyin relout relin Compchange

save "$tempdir/anydiff14.dta", replace
