//========================================================================================================================//
//=========== Children's Household Instability Project                                               =====================//
//=========== Dataset: SIPP2008                                                                      =====================//
//=========== Purpose: This file describes individuals' and mother's demographic chcaracteristics    =====================//
//========================================================================================================================//

/******************* Creates a dataset with race-ethnicity and sex at first observation ***************/
** Import dataset allwaves
use "$tempdir/allwaves", clear

keep SSUID EPPPNUM SWAVE EORIGIN ERACE ESEX 

gen raceth=ERACE
** Function: Code Hispanics into Raceth
replace raceth=5 if inlist(ERACE,1,3,4) & EORIGIN==1
** Function: Label Racethnic
label define racethnic 1 "NHWhite" 2 "Black" 3 "NHAsian" 4 "NHOther" 5 "Hispanic"
label values raceth racethnic

sort SSUID EPPPNUM SWAVE
** Function: Use the first response of race and sex 
collapse (first) raceth ESEX, by (SSUID EPPPNUM)

rename raceth first_raceth
rename ESEX first_sex

** Output: fixedracesex
save "$tempdir/fixedracesex", $replace


/********************* Creates a basic file describing individuals' demographic characteristics by WAVE *****************/
** Import dataset allwaves
use "$tempdir/allwaves", clear

keep SSUID EPPPNUM SHHADID SWAVE ERRP EORIGIN ERACE ESEX EEDUCATE TAGE EMS WPFINWGT
** Function: Code Hispanic into Raceth
gen raceth=ERACE
replace raceth=5 if inlist(ERACE,1,3,4) & EORIGIN==1
** Function: Label Racethnic
label define racethnic 1 "NHWhite" 2 "Black" 3 "NHAsian" 4 "NHOther" 5 "Hispanic"
label values raceth racethnic
**Output: demoperson08
save "$tempdir/demoperson08.dta", replace

/**********************Creates a file generating some household demographics********************************/ 
* Reference person's education
gen hheduc=EEDUCATE if ERRP==1 | ERRP==2
* Reference person's age
gen hhage=TAGE if ERRP==1 | ERRP==2

** Function: use the highest education and age through waves
sort SSUID SHHADID SWAVE

collapse (max) hheduc hhage, by(SSUID SHHADID SWAVE)

** Function: Recode education into educational levels
recode hheduc (1/38=1)(39=2)(40/43=3)(43/47=4)

** Function: Recode age into categories
recode hhage (0/25=1)(26/50=2)(51/99=3), gen(hhcage)

** Function: label categoried education and categoried age 
label define ceduc 1 "<HS" 2 "HS" 3 "Some College" 4 "BA+"
label values hheduc ceduc

label define cage 1 "0-25" 2 "26-50" 3 "51-99"
label values hhcage cage

** Output: demoHH08
save "$tempdir/demoHH08.dta", replace

tab hheduc

tab hhcage

sort hhcage

by hhcage: sum hheduc



/****************** Creates a file describing mother's characteristics for those with a coresident mom *************/                                                                                      *
*Note: First by wave and then first first observed wave   
                            
* Import allwaves
use "$tempdir/allwaves", clear

keep SSUID EPPPNUM SWAVE ERACE ESEX EEDUCATE TAGE EMS  

* start by creating a data file for mother's characteristics
rename EPPPNUM EPNMOM
rename ERACE momrace
rename ESEX momsex
rename EEDUCATE momeducate
rename EMS momms
rename TAGE momage

sort SSUID EPNMOM SWAVE

** Output1: mom1
save "$tempdir/mom1.dta", $replace

** Import allwaves
use "$tempdir/allwaves", clear

keep SSUID EPPPNUM SHHADID SWAVE ERRP EORIGIN ERACE ESEX EEDUCATE TAGE EMS WPFINWGT EPNMOM ETYPMOM 

** Function: Drop cases where mom isn't in ego's household
drop if EPNMOM==9999

** Function: Merge dataset with mom's charactersitics
sort SSUID EPNMOM SWAVE
merge m:1 SSUID EPNMOM SWAVE using "$tempdir/mom1.dta"

keep if _merge==3 /* dropping cases in "mom" file that were not matched in ego data */

drop _merge

** Function: Recode mom's education into a categorical variable
recode momeducate (1/38=1)(39=2)(40/43=3)(43/47=4), gen(momced)
* Label mom's education
label define ceduc 1 "<HS" 2 "HS" 3 "Some College" 4 "BA+"
label values momced ceduc

tab momced
tab momsex

** Output2: mombywave
save "$tempdir/mombywave.dta", $replace

** Function: Collapse to first observed momced for merging onto child file where mom-child aren't coresident
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

** Output3: momfirst
save "$tempdir/momfirst.dta", $replace


/******************* Merge all the demographic info into one file *******************************/
** Import demoperson08
use "$tempdir/demoperson08.dta", clear

merge m:1 SSUID EPPPNUM using "$tempdir/fixedracesex"

drop _merge

merge m:1 SSUID SHHADID SWAVE using "$tempdir/demoHH08.dta" 

drop _merge

merge 1:1 SSUID EPPPNUM SWAVE using "$tempdir/mombywave.dta"

drop _merge

merge m:1 SSUID EPPPNUM using "$tempdir/momfirst.dta"

drop _merge

** Output: demo08
save "$tempdir/demo08.dta", $replace

