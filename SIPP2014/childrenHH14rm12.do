use "$SIPP2014/selected.dta", clear

drop if monthcode !=12

drop if tage > 17

forvalues t=1/19{
  gen typrel`t'=0
}
forvalues r=1/30{
  forvalues t=1/19 {
  replace typrel`t'=typrel`t'+1 if rrel`r'==`t'
}
}

forvalues t=1/19{
 tab typrel`t'
}

* Note that parpresent includes parents or guardians 
gen parpresent=1 if erefpar >= 101 & erefpar <= 499
replace parpresent=1 if epnpar2 >=101 & epnpar2 <= 499
replace parpresent=1 if epnpar1 >=101 & epnpar1 <= 499
replace parpresent=0 if missing(parpresent)

*par1 and par2present include only biological, step, or adoptive parents

gen par1present=1 if epnpar1 >= 101 & epnpar1 <= 499
replace par1present=0 if missing(par1present)

gen par2present=1 if epnpar2 >= 101 & epnpar2 <= 499
replace par2present=0 if missing(par2present)

gen hasHHsp=1 if epnspouse >=101 & epnspouse <=499
replace hasHHsp=2 if epncohab >=101 & epncohab <=499
replace hasHHsp=0 if missing(hasHHsp)

save "$tempdir/refmon12.dta", replace

*create file with sex and partner status where pnum is changed to epnpar1 to match to individuals with a par1present in long file
keep ssuid pnum esex hasHHsp

rename pnum epnpar1
rename esex par1sex
rename hasHHsp par1HHsp

sort ssuid epnpar1

save ""$tempdir\par1sexsp.dta", replace

use ""$tempdir\refmon12.dta", clear

sort ssuid epnpar1

merge m:1 ssuid epnpar1 using "$tempdir/par1sexsp.dta"

replace par1sex=0 if missing(par1sex)
replace par1HHsp=0 if missing(par1HHsp)

* drop cases of the wide file not matched to the long file
drop if _merge==2

drop _merge

save "$tempdir/par1added.dta", replace

use "$tempdir/refmon12.dta", clear

keep ssuid pnum esex hasHHsp

rename pnum epnpar2
rename esex par2sex
rename hasHHsp par2HHsp

sort ssuid epnpar2

save "$tempdir/par2sexsp.dta", replace

use "$tempdir/par1added.dta", replace

merge m:1 ssuid epnpar2 using "$tempdir/par2sexsp.dta"

replace par2sex=0 if missing(par2sex)
replace par2HHsp=0 if missing(par2HHsp)

keep if tage < 18

save "$tempdir/childrenHH14.dta", replace

tab par1sex par2sex [aweight=wpfinwgt]

* The question is, what percentage of children living with a single parent are living with a single father
* There are a couple of ways to define single parent. One is to flag children with only one parent present.
* A second is to determine whether par1HHsp is 1 or 2.

gen singpar1=1 if par1present==1 & par2present==0
replace singpar1=0 if par1present==1 & par2present==1

gen singpar2=1 if par1present==1 & par1HHsp==0
replace singpar2=0 if par1HHsp==1 | par1HHsp==2

gen unmarriedpar=1 if par1present==1 & par1HHsp==0
replace unmarriedpar=1 if parpresent==1 & par1HHsp==2
replace unmarriedpar=0 if par1HHsp==1

tab unmarriedpar par1sex 

tab singpar1 singpar2
