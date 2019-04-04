*cd /Users/yiwen/Documents/GitHub/childHH
*do setup_yiwen
*do setup_childhh_environment

capture log close
set more off
set linesize 80
clear all

//========================================================================================================//
//===== Household Instability and Child Food Insecurity Project                               
//===== Dataset: SIPP2008                                                     
//===== Purpose: Creates an analysis file 
//===== Author: Yiwen Wang\ 2018-11-29
//========================================================================================================//

//#1 construct data file for wave 6 
//***extract food security variables from source data wave6-topical module***//

use "$SIPP2008/food insecurity data/sippp08putm6.dta", clear

recode eafbaln (2=1) (3=0), gen (eafbalnr)
recode eaflast (2=1) (3=0), gen (eaflastr)

****generate food insecurity variable****
****coded 1 if number of total affirmative responses to food insecurity questions is greater than 1****

egen fcount=anycount(eafbalnr eaflastr eafless eafskip eafday),v(1)
recode fcount (1=0) (2/5=1), gen (foodins6)
label values foodins6 foodinsl
label define foodinsl 0 "food secure" 1 "food insecure"

rename wpfinwgt wpfinwgt6
keep ssuid epppnum wpfinwgt6 foodins6 
destring epppnum,replace
recast float epppnum
save "$tempdir/food6.dta", $replace

//***extract household size and income info from source data wave6-core***//
use "$SIPP2008/wave6_extract.dta", clear
keep if SREFMON==1
rename THTOTINC thtotinc6
rename SSUID ssuid
rename EPPPNUM epppnum
rename SHHADID shhadid
egen hhsize6=count(epppnum), by(ssuid shhadid)

merge 1:1 ssuid epppnum using "$tempdir/food6.dta", gen(merge1)
keep ssuid epppnum wpfinwgt6 thtotinc6 foodins6 hhsize6 merge1
save "$tempdir/food6.dta", $replace 
//***not matched=2340(from master=1163;from using=1177)matched=86987***//



//#2 construct data file for wave 9 and merge with wave 6
//***extract food security variables from source data wave9-topical module***//

use "$SIPP2008/food insecurity data/sippp08putm9.dta", clear

recode eafbaln (2=1) (3=0), gen (eafbalnr)
recode eaflast (2=1) (3=0), gen (eaflastr)

****generate food insecurity variable****
****coded 1 if number of total affirmative responses to food insecurity questions is greater than 1****

egen fcount=anycount(eafbalnr eaflastr eafless eafskip eafday),v(1)
recode fcount (1=0) (2/5=1), generate (foodins9)
label values foodins9 foodinsl
label define foodinsl 0 "food secure" 1 "food insecure"

rename wpfinwgt wpfinwgt9
keep ssuid epppnum wpfinwgt9 foodins9 
destring epppnum,replace
recast float epppnum
save "$tempdir/food9.dta", $replace

//***extract household size and income info from source data wave6-core***//
use "$SIPP2008/wave9_extract.dta", clear
keep if SREFMON==1
rename THTOTINC thtotinc9
rename SSUID ssuid
rename EPPPNUM epppnum
rename SHHADID shhadid
egen hhsize9=count(epppnum), by(ssuid shhadid)

merge 1:1 ssuid epppnum using "$tempdir/food9.dta", gen(merge2)
keep ssuid epppnum wpfinwgt9 hhsize9 thtotinc9 foodins9 merge2 

//***not matched=2040;from master=1093;from using=947;matched=81313***//

***merge with food6.dta***

merge 1:1 ssuid epppnum using "$tempdir/food6.dta", gen (merge3)
save "$tempdir/food69.dta", $replace 
//***not matched=26428(from master=10227;from using=16201);matched=73126***//



//#3 create variables measuring household instability between wave 6 and 9
//***extract and compute household instability variables for wave6-9 from hhchange.dta***//

use "$SIPP08keep/HHchangeWithRelationships.dta", clear
keep if SWAVE==6|SWAVE==7|SWAVE==8
keep SSUID EPPPNUM SWAVE adj_age comp_change parent_change adult_arrive adult_leave ///
parent_arrive parent_leave otheradult30_arrive otheradult30_leave otheradult_arrive ///
otheradult_leave addr_change my_sex hh_change adult30_arrive adult30_leave ///
yadult_arrive yadult_leave otheryadult_arrive otheryadult_leave adultsib_arrive adultsib_leave

reshape wide adj_age comp_change parent_change adult_arrive adult_leave ///
parent_arrive parent_leave otheradult30_arrive otheradult30_leave otheradult_arrive ///
otheradult_leave addr_change adult30_arrive adult30_leave ///
yadult_arrive yadult_leave otheryadult_arrive otheryadult_leave  adultsib_arrive adultsib_leave ///
my_sex hh_change, i(SSUID EPPPNUM) j(SWAVE)

***calculate number of changes experienced between wave 6&9***
gen nmis_compchange69=0 
gen numchange69=0

forvalues i=6/8 {
	replace nmis_compchange69=nmis_compchange69+1 if missing(comp_change`i')
	replace numchange69=numchange69+1 if comp_change`i'==1
}


***drop cases that don't appear in the data between wave6&9***
drop if nmis_compchange69==3


***create indicators of whether experienced any specific type of change 
recode numchange69 (2/max=1), gen (anychange69)
recode nmis_compchange69 (2/max=1), gen (anymischange69)
egen parent_change=anymatch (parent_change*), v(1)
egen adult_arrive=anymatch (adult_arrive*), v(1)
egen adult_leave=anymatch (adult_leave*), v(1)
egen yadult_leave=anymatch (yadult_leave*), v(1)
egen yadult_arrive=anymatch (yadult_arrive*), v(1)
egen adult30_arrive=anymatch (adult30_arrive*), v(1)
egen adult30_leave=anymatch (adult30_leave*), v(1)
egen parent_arrive=anymatch (parent_arrive*), v(1)
egen parent_leave=anymatch (parent_leave*), v(1)
egen otheradult30_arrive=anymatch (otheradult30_arrive*), v(1)
egen otheradult30_leave=anymatch (otheradult30_leave*), v(1)
egen otheradult_arrive=anymatch (otheradult_arrive*), v(1)
egen otheradult_leave=anymatch (otheradult_leave*), v(1)
egen otheryadult_arrive=anymatch (otheryadult_arrive*), v(1)
egen otheryadult_leave=anymatch (otheryadult_leave*), v(1)
egen adultsib_arrive=anymatch (adultsib_arrive*), v(1)
egen adultsib_leave=anymatch (adultsib_leave*), v(1)
egen addr_change=anymatch (addr_change*), v(1)
egen hh_change=anymatch (hh_change*), v(1)


rename SSUID ssuid
rename EPPPNUM epppnum
keep ssuid epppnum adj_age6 my_sex6 anychange69 anymischange69 parent_change ///
adult_arrive adult_leave parent_arrive parent_leave otheradult30_arrive ///
otheradult30_leave otheradult_arrive otheradult_leave addr_change hh_change ///
adult30_arrive adult30_leave yadult_arrive yadult_leave otheryadult_arrive ///
otheryadult_leave adultsib_arrive adultsib_leave

gen adult_change=1 if adult_arrive==1 | adult_leave==1
replace adult_change=0 if missing(adult_change)

gen yadult_change=1 if yadult_arrive==1 | yadult_leave==1
replace yadult_change=0 if missing(yadult_change)

gen adult30_change=1 if adult30_arrive==1 | adult30_leave==1
replace adult30_change=0 if missing(adult30_change)

gen otheradult_change=1 if otheradult_arrive==1 | otheradult_leave==1
replace otheradult_change=0 if missing(otheradult_change)

gen otheryadult_change=1 if otheryadult_arrive==1 | otheryadult_leave==1
replace otheryadult_change=0 if missing(otheryadult_change)

gen otheradult30_change=1 if otheradult30_arrive==1 | otheradult30_leave==1
replace otheradult30_change=0 if missing(otheradult30_change)

gen adultsib_change=1 if adultsib_arrive==1 | adultsib_leave==1
replace adultsib_change=0 if missing(adultsib_change)

***merge with food69.dta***
merge 1:1 ssuid epppnum using "$tempdir/food69.dta", gen(merge4)
//***not matched=7254(from master=2161;from using=5093);matched=94461***//

keep if adj_age6<=15
//****sample size 18971***//
save "$tempdir/food_hhchange69.dta", $replace



//#4 create household type for wave 6
***create hhtype*********
use "$SIPP08keep/HHComp_asis.dta", clear

**keep sample to wave6
keep if SWAVE==6
keep if adj_age<=15
****sample size 19153***//

keep SSUID EPPPNUM SHHADID relationship adj_age to_age to_sex
sort SSUID EPPPNUM
by SSUID EPPPNUM: gen n=_n

****give the relationship backwards to children***
gen parent=1 if inlist(relationship,1,4,7,19,21)
gen grandparent=1 if inlist(relationship,13,14,27)
gen grandmother=1 if inlist(relationship,13,14,27) & to_sex==2
gen other_rel=1 if inlist(relationship, 15,16,24,25,26,28,29,30,31,33,32,35,36) 
gen other_femrel=1 if inlist(relationship, 15,16,24,25,26,28,29,30,31,33,32,35,36) & to_sex==2 
gen unknown=1 if relationship==40 | missing(relationship)

gen otheradult30=. 
recode otheradult30 .=1 if parent==.  & to_age>30
gen otherfemadult30=1 if otheradult30==1 & to_sex==2
gen othermaladult30=1 if otheradult30==1 & to_sex==1

gen otheradult=.
recode otheradult .=1 if parent==.  & to_age>=18
gen otherfemadult =1 if otheradult==1 & to_sex==2
gen othermaladult =1 if otheradult==1 & to_sex==1
gen child=1 if to_age<=16

reshape wide to_age to_sex relationship parent grandparent grandmother other_rel other_femrel child otheradult30 otherfemadult30 othermaladult30 otheradult otherfemadult othermaladult unknown, i(SSUID EPPPNUM) j(n)

****count number of each type of people in hh****
egen parents=anycount(parent*), v(1)
egen otheradults30=anycount(otheradult30*), v(1)
egen otherfemadult30=anycount(otherfemadult30*), v(1)
egen othermaladult30=anycount(othermaladult30*), v(1)
egen grandmother=anycount(grandmother*), v(1)
egen otheradults=anycount(otheradult*), v(1)
egen otherfemadults=anycount(otherfemadult*), v(1)
egen othermaladults=anycount(othermaladult*), v(1)
egen children=anycount(child*), v(1)
gen num_child=children+1
recode otheradults30 (2/max=1), gen (anyotheradults30)
recode otheradults (2/max=1), gen (anyotheradults)
tab parents
recode parents 3=2
rename SSUID ssuid
rename EPPPNUM epppnum 

recode otherfemadult30 (0=0)(1/3=1), gen(anyofem30)
recode othermaladult30 (0=0)(1/3=1), gen(anyomal30)
recode otherfemadults (0=0)(1/9=1), gen(anyofem18)
recode othermaladults (0=0)(1/9=1), gen(anyomal18)

save "$tempdir/hhtype6.dta", $replace

//#5 create household type for wave 9
***create hhtype*********
use "$SIPP08keep/HHComp_asis.dta", clear

//keep sample to wave6
keep if SWAVE==9
keep if adj_age<=15
//****sample size 19153***//

keep SSUID EPPPNUM SHHADID relationship adj_age to_age
sort SSUID EPPPNUM
by SSUID EPPPNUM: gen n=_n

//****give the relationship backwards to children***//
gen parent=1 if inlist(relationship,1,4,7,19,21)
gen otheradult30=. 
recode otheradult30 .=1 if parent==.  & to_age>30
gen otheradult=.
recode otheradult .=1 if parent==.  & to_age>=18
gen child=1 if to_age<=16
reshape wide to_age relationship parent child otheradult30 otheradult, i(SSUID EPPPNUM) j(n)

//****count number of each type of people in hh****//
egen parentsw9=anycount(parent*), v(1)
egen otheradults30w9=anycount(otheradult30*), v(1)
egen otheradultsw9=anycount(otheradult*), v(1)
egen childrenw9=anycount(child*), v(1)
gen num_childw9=childrenw9+1
recode otheradults30w9 (2/max=1), gen (anyotheradults30w9)
recode otheradultsw9 (2/max=1), gen (anyotheradultsw9)
tab parentsw9
recode parentsw9 3=2
rename SSUID ssuid
rename EPPPNUM epppnum 

save "$tempdir/hhtype9.dta", $replace

*merge hhtype with food_hhchange69*
use "$tempdir/food_hhchange69.dta", clear
merge 1:1 ssuid epppnum using "$tempdir/hhtype6.dta", keepusing (parents anyotheradults30 anyotheradults num_child) gen(merge5)
//***not matched=938(from master=378;from using=560);matched=18593***//
merge 1:1 ssuid epppnum using "$tempdir/hhtype9.dta", keepusing (parentsw9 anyotheradults30w9 anyotheradultsw9 num_childw9) gen(merge6)

save "$tempdir/foodinsecurity.dta", $replace


*extract parental education and race*
use "$tempdir/person_wide.dta", clear
keep SSUID EPPPNUM par_ed_first my_racealt
rename SSUID ssuid
rename EPPPNUM epppnum 
merge 1:1 ssuid epppnum using "$tempdir/foodinsecurity.dta"
keep if _merge==3
drop _merge



*use povertyguide program to generate FPL for 2009 and 2010*
*********************************************************************************
**  write a program to generate a numeric variable representing the official U.S. poverty guideline
********************************************************************************* 

capture drop povertyguide

program def povertyguide

syntax , gen(string) famsize(string) year(string)


capture confirm new var `gen'
if _rc~=0 {
  disp as err "gen must be new var"
  exit 198
}


tempname povtable

#delimit ;
matrix input `povtable' = (
/*       base  incr */
/*2008*/ 10400, 3600 \
/*2009*/ 10830, 3740 \
/*2010*/ 10830, 3740 \
/*2011*/ 10890, 3820 \
/*2012*/ 11170, 3960 \
/*2013*/ 11490, 4020 \
/*2014*/ 11670, 4060 \
/*2015*/ 11770, 4160 
);
#delimit cr


local yearlo "2008"
local yearhi "2015"



tempvar year1
capture gen int `year1' = (`year')
if _rc ~=0 {
    disp in red "invalid expression for year: `year'"
    exit 198
}

capture assert (`year1' >= `yearlo' & `year1' <= `yearhi') | mi(`year1')
if _rc ~=0 {
    disp as error  "Warning: year expression has out-of-bounds values"
    /* But do not exit; just let out-of-bounds values yield missing. */
}

capture assert ~mi(`year1')
if _rc ~=0 {
    disp as error  "Warning: year expression yields some missing values"
    /* But do not exit. */
}

tempvar index1 /* index for year */

gen int `index1' = (`year1' - `yearlo') + 1



tempvar base incr
gen int `base' = `povtable'[`index1', 1]
gen int `incr' = `povtable'[`index1', 2]



tempvar famsiz1
capture gen int `famsiz1' = (`famsize')
/* Note that that is loaded into an int; will be truncated if non-integer.*/
if _rc ~=0 {
    disp in red "invalid expression for famsize: `famsize'"
    exit 198
}

capture assert `famsiz1' >= 1
if _rc ~=0 {
    disp as error  "Warning: famsize expression has out-of-bounds values (<1)"
    /* But do not exit; just let out-of-bounds values yield missing. */
}

capture assert ~mi(`famsiz1')
if _rc ~=0 {
    disp as error  "Warning: famsize expression yields some missing values"
    /* But do not exit. */
}

/* bottom-code  famsiz1 at 1. */
quietly replace `famsiz1' = 1 if `famsiz1' < 1

gen long `gen' = `base' + (`famsiz1' - 1)* `incr'
quietly compress `gen'
end

povertyguide, gen(povguide6) famsize(hhsize6) year(2010) /*generate poverty line for wave6: year 2010*/
povertyguide, gen(povguide9) famsize(hhsize9) year(2011) /*generate poverty line for wave9: year 2011*/
gen annualinc6= thtotinc6*12 
gen annualinc9= thtotinc9*12 
gen byte pov6 = annualinc6 < povguide6 if ~mi(povguide6) & ~mi(annualinc6) /*generate poverty indicator 1=in poverty*/
gen byte pov9 = annualinc9 < povguide9 if ~mi(povguide9) & ~mi(annualinc9) /*generate poverty indicator 1=in poverty*/

gen byte nearpov6 = annualinc6 < 1.5*povguide6 if ~mi(povguide6) & ~mi(annualinc6) /*generate poverty indicator 1= below 1.5 times poverty line */
gen byte nearpov9 = annualinc9 < 1.5*povguide9 if ~mi(povguide9) & ~mi(annualinc9) /*generate poverty indicator 1= below 1.5 times poverty line */

keep if foodins6 !=. & foodins9 !=.

***label variables***
la var par_ed_first "Parental education"
la def edu  1 "Less than high school" 2 "High school" 3 "Some college" 4"College grad", modify
la val par_ed_first edu

la var foodins9 "Food insecurity at wave 9"
la var foodins6 "Food insecurity at wave 6"
la def foodins 0 "Food secure" 1 "Food insecure"
la val foodins9 foodins
la val foodins6 foodins

la var my_racealt "Race"
la def racer 1 "White" 2 "Black" 3 "Hispanic" 4 "Asian" 5 "Other"
la val my_racealt racer

la var num_child "Number of children in household"
la var parents "Number of parents in household"

la var anyotheradults "Any other adult in household at wave 6"
la def ny 0 "No" 1 "Yes"
la val anyotheradults ny

la var otheradult_leave "Any other adult left household between wave 6-9"
la val otheradult_leave ny

la var parent_leave "Any parent left household between wave 6-9"
la val parent_leave ny

la var otheradult30_leave "Any other adult older than 30 left household"
la val otheradult30_leave ny

la var hhsize6 "Number of people in household at wave 6"
la var hhsize9 "Number of people in household at wave 9"

la var thtotinc6 "Household income at wave 6"
la var thtotinc9 "Household income at wave 9"
 
la var pov6 "Poverty status at wave 6"
la var pov9 "Poverty status at wave 9"
la def pov 0 ">=100% FPL" 1 "<100% FPL"
la val pov6 pov
la val pov9 pov
la def nearpov 0 ">=150% FPL" 1 "<150% FPL"
la val nearpov6 nearpov
la val nearpov9 nearpov

save "$tempdir/foodinsecurity.dta", $replace








