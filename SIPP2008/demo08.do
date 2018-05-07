********************************************************************************************
* creates a basic file describing individuals' race-ethnicity and sex at first observation *
********************************************************************************************

use "$tempdir/allwaves", clear

keep SSUID EPPPNUM SWAVE EORIGIN ERACE ESEX 

gen raceth=ERACE
replace raceth=5 if inlist(ERACE,1,3,4) & EORIGIN==1

label define racethnic 1 "NHWhite" 2 "Black" 3 "NHAsian" 4 "NHOther" 5 "Hispanic"
label values raceth racethnic

sort SSUID EPPPNUM SWAVE

collapse (first) raceth ESEX, by (SSUID EPPPNUM)

rename raceth first_raceth
rename ESEX first_sex

save "$tempdir/fixedracesex", $replace

****************************************************************************
* creates a basic file describing individuals' demographic characteristics by WAVE *
****************************************************************************

use "$tempdir/allwaves", clear

keep SSUID EPPPNUM SHHADID SWAVE ERRP EORIGIN ERACE ESEX EEDUCATE TAGE EMS WPFINWGT

gen raceth=ERACE
replace raceth=5 if inlist(ERACE,1,3,4) & EORIGIN==1

label define racethnic 1 "NHWhite" 2 "Black" 3 "NHAsian" 4 "NHOther" 5 "Hispanic"
label values raceth racethnic

save "$tempdir/demoperson08.dta", replace

*generating some household demographics. 

gen hheduc=EEDUCATE if ERRP==1 | ERRP==2
gen hhage=TAGE if ERRP==1 | ERRP==2

sort SSUID SHHADID SWAVE

collapse (max) hheduc hhage, by(SSUID SHHADID SWAVE)

recode hheduc (1/38=1)(39=2)(40/43=3)(43/47=4)

recode hhage (0/25=1)(26/50=2)(51/99=3), gen(hhcage)

label define ceduc 1 "<HS" 2 "HS" 3 "Some College" 4 "BA+"
label values hheduc ceduc

label define cage 1 "0-25" 2 "26-50" 3 "51-99"
label values hhcage cage

save "$tempdir/demoHH08.dta", replace

tab hheduc

tab hhcage

sort hhcage

by hhcage: sum hheduc



****************************************************************************************
* Creating a file describing mother's characteristics for those with a coresident mom  *
*                                                                                      *
* First by wave and then first first observed wave                                     *
****************************************************************************************

*start by creating a data file for mother's characteristics
use "$tempdir/allwaves", clear

keep SSUID EPPPNUM SWAVE ERACE ESEX EEDUCATE TAGE EMS  

rename EPPPNUM EPNMOM
rename ERACE momrace
rename ESEX momsex
rename EEDUCATE momeducate
rename EMS momms
rename TAGE momage

sort SSUID EPNMOM SWAVE

save "$tempdir/mom1.dta", $replace

use "$tempdir/allwaves", clear

keep SSUID EPPPNUM SHHADID SWAVE ERRP EORIGIN ERACE ESEX EEDUCATE TAGE EMS WPFINWGT EPNMOM ETYPMOM 

drop if EPNMOM==9999
* dropping cases where mom isn't in ego's household

sort SSUID EPNMOM SWAVE

merge m:1 SSUID EPNMOM SWAVE using "$tempdir/mom1.dta"

keep if _merge==3
* dropping cases in "mom"file that were not matched in ego data

drop _merge

recode momeducate (1/38=1)(39=2)(40/43=3)(43/47=4), gen(momced)

label define ceduc 1 "<HS" 2 "HS" 3 "Some College" 4 "BA+"

label values momced ceduc

tab momced

tab momsex

save "$tempdir/mombywave.dta", $replace

*now collapsing to first observed momced for merging onto child file where mom-child aren't coresident

sort SSUID EPPPNUM SWAVE

collapse (firstnm) momced momrace momms momage ETYPMOM, by(SSUID EPPPNUM)

rename momced momfirstced
rename momrace momfirstrace
rename momms momfirstms
rename momage momfirstage
rename ETYPMOM firstmomtyp

label variable momfirstced "Mother's education at first observation of any mother in child's household"

label variable momfirstrace "Mother's race at first observation of any mother in child's household"

label variable momfirstms "Mother's marital status at first observation of any mother in child's housheold"

label variable firstmomtyp "Mother's relationship to child at first observation of any mother in child's household"

label values momfirstced ceduc

save "$tempdir/momfirst.dta", $replace

*********
* Finally, merging all the demographic info into one file
******

use "$tempdir/demoperson08.dta", clear

merge m:1 SSUID EPPPNUM using "$tempdir/fixedracesex"

drop _merge

merge m:1 SSUID SHHADID SWAVE using "$tempdir/demoHH08.dta" 

drop _merge

merge 1:1 SSUID EPPPNUM SWAVE using "$tempdir/mombywave.dta"

drop _merge

merge m:1 SSUID EPPPNUM using "$tempdir/momfirst.dta"

drop _merge

save "$tempdir/demo08.dta", $replace

