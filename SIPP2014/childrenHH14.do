* This program identifies whether an individual is living with his or her biological mother in each of the reference 
* months. Checking EPNPAR1, EPNPAR2, EPAR1TYP, and EPAR2TYP gets biological mothers living with the respondent
* at the time of the SIPP 2014 Survey (i.e. type 1 household members). People in the household during the reference period 
* but not at time of [Wave 1] interview are called "type 2." Their person numbers are < 100. 
* Variables identifying their age and sex are TT2_AGE* and ET2_SEX* respectively.
* ET2_RELX describes in rough terms the relationship to type 2 person X and ET2_LNOX is the person-number of type 2 person X
*

* This program has three sections. In section 1 some preparatory variables are created 
* In section 2, variables indicating whether there is a type 1 biological mother in the household are created.
* In section 3, I read in some type 2 biomom and biodad variables and then do a little cleaning because of 
* inconsistencies in the data. 

**
*******************************************************************************
*******************************************************************************
**    Section 1 -- creating preparatory variables like parpresent and hasHHsp
*******************************************************************************
*******************************************************************************
**

* Read in an extract from the SIPP 2014
use "$SIPP2014data/selected.dta", clear

* Create some simple dummies for whether a person's parent is present. There are two types of measures.
* parpresent, which includes parents or guaridans and parX which only include biological, step, or adoptive parents.
* Note that parpresent includes parents or guardians 
gen parpresent=1 if erefpar >= 101 & erefpar <= 499
replace parpresent=1 if epnpar2 >=101 & epnpar2 <= 499
replace parpresent=1 if epnpar1 >=101 & epnpar1 <= 499
replace parpresent=0 if missing(parpresent)

*par1 and par2present include only type 1 biological, step, or adoptive parents

gen par1present=1 if epnpar1 >= 101 & epnpar1 <= 499
replace par1present=0 if missing(par1present)

gen par2present=1 if epnpar2 >= 101 & epnpar2 <= 499
replace par2present=0 if missing(par2present)

*This variable was created to identify whether a biological parent has a spouse or partner at the time of interview, but the logic 
* is different from bioparent because it is an attribute of the parent, not of the child.
gen hasHHsp=1 if epnspouse >=101 & epnspouse <=499
replace hasHHsp=2 if epncohab >=101 & epncohab <=499
replace hasHHsp=0 if missing(hasHHsp)

gen pnumsp=epnspouse if epnspouse >=101 & epnspouse <=499
replace pnumsp=epncohab if epncohab >=101 & epncohab <=499
replace pnumsp=-99 if missing(pnumsp)

gen ageint=tage

sort ssuid epnpar1 monthcode

save "$tempdir/allmon.dta", replace

**
******************************************************
******************************************************
**  Section 2 -- Type 1 biological parents
******************************************************
******************************************************
**

* The first step is to create a small file with a few variables describing individuals' characteristics. Think of this as 
* a file of variables which will be used to describe parents.  pnum is renamed to epnpar1 and we will merge it back onto
* the "child" file using EPNPARX to attach parent characteristics to children.

*create file with sex and partner status where pnum is changed to epnpar1 to match to individuals with a par1present in long file
keep ssuid pnum monthcode esex hasHHsp tage eresidenceid pnumsp eeduc

rename pnum epnpar1
rename esex par1sex
rename hasHHsp par1HHsp
rename pnumsp par1_pnumsp
rename tage par1tage
rename eeduc par1educ
rename eresidenceid par1eresid

sort ssuid epnpar1 monthcode

* This is the type 1 "parent" 1 file.
save "$tempdir/par1sexsp_allmon.dta", replace


* Now call back the "child file". Note that this file includes everyone.
use "$tempdir/allmon.dta", clear

* And merge onto the child file the parent file (i.e. the file with variables describing characteristics of parents)
merge m:1 ssuid epnpar1 monthcode using "$tempdir/par1sexsp_allmon.dta"

* drop [710,050] cases of the "parent" file not matched to the "child" file.
drop if _merge==2

* 283,001 individual-months are matched to a parent
* 1,297,401 individual-months are not matched to parent

gen notyp1par1=1 if _merge==1 

drop _merge

save "$tempdir/par1added.dta", replace

* Repeat for second parent.
use "$tempdir/allmon.dta", clear

keep ssuid pnum monthcode esex hasHHsp tage eresidenceid pnumsp eeduc

rename pnum epnpar2
rename esex par2sex
rename hasHHsp par2HHsp
rename pnumsp par2_pnumsp
rename tage par2tage
rename eeduc par2educ
rename eresidenceid par2eresid

sort ssuid epnpar2 monthcode

save "$tempdir/par2sexsp_allmon.dta", replace

* Calling back the "child" file with the parent 1 variables already attached.
use "$tempdir/par1added.dta", replace

merge m:1 ssuid epnpar2 monthcode using "$tempdir/par2sexsp_allmon.dta"

* drop [776,525] cases of the "parent" file not matched to the "child" file.
drop if _merge==2

* 175,916 individual-months are matched to a second parent
* 1,470,961 individual-months are not matched to a second parent

gen notyp1par2=1 if _merge==1 

drop _merge

gen biomom=1 if par1sex==2 & epar1typ==1 & eresidenceid==par1eresid
gen biomom_pnum=epnpar1 if par1sex==2 & epar1typ==1
gen biomomage=par1tage if par1sex==2 & epar1typ==1
gen biomomeduc=par1educ if par1sex==2 & epar1typ==1
replace biomom=2 if par2sex==2 & epar2typ==1 & eresidenceid==par2eresid
replace biomom_pnum=epnpar2 if par2sex==2 & epar2typ==1 
replace biomomage=par2tage if par2sex==2 & epar2typ==1
replace biomomeduc=par2educ if par2sex==2 & epar2typ==1

gen biodad=1 if par1sex==1 & epar1typ==1 & eresidenceid==par1eresid
gen biodad_pnum=epnpar1 if par1sex==1 & epar1typ==1 
replace biodad=1 if par2sex==1 & epar2typ==1 & eresidenceid==par2eresid
replace biodad_pnum=epnpar2 if par2sex==1 & epar2typ==1 

replace biomom=0 if missing(biomom)
replace biodad=0 if missing(biodad)

* setting the person number of mom's partner at the time of interview *

gen momsp_pnum=par1_pnumsp if biomom==1
replace momsp_pnum=par2_pnumsp if biomom==2

* Now recoding biomom to a 0/1 variable 

replace biomom=1 if biomom==2

tab biomom biodad

sort ssuid pnum monthcode

save "$tempdir/typ1par_allmon.dta", replace


**
******************************************************
******************************************************
**  Section 3 -- Type 2 biological parents
******************************************************
******************************************************
**

merge m:1 ssuid pnum using "$tempdir/t2biomom.dta"

**************
* Checks and saves
**************

tab biomom t2biomom

tab biomom_pnum t2biomom_pnum

*how is it possible to have both a t2biomom and a t1biomom?
*preserve
*
*keep if biomom==1 & t2biomom==1
*
*keep ssuid 
*
*save "$SIPPshared/badcases.dta"
*
*restore

tab biodad t2biodad

replace biomom_pnum=t2biomom_pnum if biomom==0 & t2biomom==1
replace biomomage=t2biomom_age if biomom==0 & t2biomom==1

replace biomom=1 if t2biomom==1
replace biodad=1 if t2biodad==1

tab biomom 
tab biodad 

gen biomomcage=1 if biomomage > 1 & biomomage-ageint < 18
replace biomomcage=2 if biomomage > 1 & biomomage-ageint >= 18 & biomomage-ageint <= 21
replace biomomcage=3 if biomomage > 1 & biomomage-ageint >= 22 & biomomage-ageint <= 25
replace biomomcage=4 if biomomage > 1 & biomomage-ageint >= 26 & biomomage-ageint < 30
replace biomomcage=5 if biomomage > 1 & biomomage-ageint >= 30

gen biomomage_birth=biomomage-ageint

keep if tage_ehc < 18

tab biomom biodad 
tab biomomcage
tab biomomage_birth

keep ssuid pnum biomom_pnum monthcode biomom biodad biomomage biomomeduc erace tage_ehc esex wpfinwgt biomomcage biomomage_birth

save "$tempdir/longbiomom.dta", replace

reshape wide biomom biodad biomomage biomomeduc tage_ehc wpfinwgt, i(ssuid pnum) j(monthcode)

tab biomomcage

tab biomom_pnum

keep if biomom_pnum !=.

sort ssuid biomom_pnum

save "$tempdir/widebiomom.dta", replace

merge m:1 ssuid biomom_pnum using "$tempdir/idpartner.dta"

keep if _merge==3

tab partner_change14
tab partner_change48
tab partner_change812

keep ssuid pnum biomom* partner_change14 partner_change48 partner_change812

sort ssuid pnum

save "$tempdir/partner_change.dta", replace



