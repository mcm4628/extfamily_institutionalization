set more off
use "$projdir/data/NSFG/2006_2010_FemResp_original.dta", clear

*installing relevant packages:
ssc d rowsort
ssc install rowsort


*keep relevant variables:
keep CASEID WGTQ1Q16 CMINTVW AGE_R CMBIRTH MARSTAT  EVRMARRY HISP RACE HISPRACE MANREL TIMESMAR ///
	CMMARRHX* CMPMCOHX* CMHSBDIEX* CMSTPHSBX* CMMARRCH  CMSTRTHP CMCOHSTX* ///
	CMSTPCOHX* DATEND* OUTCOM* HAVEDEG HIEDUC EDUCAT DIPGED LVTOGHX* AGEPRG* CMSTRTCP

foreach var of varlist CMMARRHX CMPMCOHX LVTOGHX CMCOHSTX CMHSBDIEX CMSTPHSBX CMSTPCOHX {
rename `var' `var'1 
}

*race and ethnicty - HISPRACE
rename HISPRACE race

*Mother's eductaion:
*correction for highest education: https://www.cdc.gov/nchs/data/nsfg/HIEDUC_correction_2006_2010.pdf:
g HIEDUC2=HIEDUC
replace HIEDUC2=9 if (HAVEDEG==. | HAVEDEG==5) & DIPGED==2 & 9<=EDUCAT<=12 & HIEDUC!=10

g educ=1 if HIEDUC2<9
replace educ=2 if HIEDUC2==9
replace educ=3 if HIEDUC2==10 | HIEDUC2==11
replace educ=4 if HIEDUC2>=12
label define leduc 1 "Less than HS" 2 "HS" 3 "Some college" 4 "Bachelor+"
label value educ leduc

*marital status:
g mstatus=1 if MARSTAT==1
replace mstatus=2 if MARSTAT==2
replace mstatus=3 if MARSTAT>=3 & MARSTAT<=5
replace mstatus=4 if MARSTAT==6
label define lmstatus 1 "Married" 2 "Cohabiting" 3 "Was married" 4 "Single"
label value mstatus lmstatus

*Previous partenrs- start date:
/* the date is the move in together date- in case of marriage it is the marriage 
date or the date before that, when the couple moved in together as cohabitors). 
*/
forvalue h=1/6{
g partner_start`h'= CMPMCOHX`h' if (CMPMCOHX`h'<9998) 
replace partner_start`h'=CMMARRHX`h' if (partner_start`h'>9997) & (CMMARRHX`h'<9998)
}
forvalue c=1/4{
local p=`c'+6
g partner_start`p'= CMCOHSTX`c' if CMCOHSTX`c'<9998
}

*current partner (non-husband)- start date:
g partner_start11= CMSTRTCP if CMSTRTHP<9998



*Previous partenrs- end date:
/*for marriages it can end by the death of the husband or by stop livig together*/
forvalue h=1/6{
g partner_end`h'=CMHSBDIEX`h'
replace partner_end`h'= CMSTPHSBX`h' if CMSTPHSBX`h'<9998
}

forvalue c=1/4{
local p=`c'+6
g partner_end`p'=CMSTPCOHX`c' if CMSTPCOHX`c'<9998
}

*sorting the dates a woman started and ended living with a partner- husband or not:
rowsort partner_start* partner_end*, gen (transition1-transition21)



* Date of birth of children-"cm" (only if the pregnancy ended in a living birth):
forvalue c=1/9 {
g child`c'= DATEND0`c' if OUTCOM0`c'==1
}
forvalue c=10/19 {
g child`c'= DATEND`c' if OUTCOM`c'==1
}

*children instability-change to long version when each child is a row and each month is a variable with the number of transitions:
keep child* transition* WGTQ1Q16 CASEID educ race CMINTVW CMBIRTH mstatus 
save "$tempdir/nsfg_wide", replace
keep child* CASEID 
forvalue c=1/19{
capture rename child`c' child_cm`c'
}
reshape long child_cm, i(CASEID) j(child_id)
drop if child_cm==. 
merge m:1 CASEID using "$tempdir/nsfg_wide"
keep if _merge==3

keep CASEID CMINTVW child_id child_cm WGTQ1Q16 race educ transition* CMBIRTH mstatus


*create for each month in the last 5 years before the survey a flag variable to mark transitions:
forvalue m=1218/1326 {
g trans`m'= (transition1==`m')
}
forvalue m=1218/1326 {
forvalue t=2/21 {
capture replace trans`m'=trans`m'+1 if transition`t'==`m'
}
}
drop transition* 

*keep transitions that occur 5 years before the survey:
forvalue t=1218/1326{
replace trans`t'=. if (CMINTVW-`t')>60
replace trans`t'=. if (CMINTVW-`t')<0
}

*children age in each month:
forvalue m=1218/1326 {
g age`m'= (`m'-child_cm)
replace age`m'=. if age`m'<1 | age`m'>144 /*keep only children less than 12*/
}

reshape long trans age, i (CASEID child_id) j(month)

save "$tempdir/nsfg_5years_all", replace


*keep only children who were born to mothers less than 30:
drop if (child_cm-CMBIRTH)/12>30
save "$tempdir/nsfg_5years_mom30", replace









*creating a dataset for table 2- dropping transitions that occur within less than 4 months
*the same as before:
use "$tempdir/nsfg_wide", clear
keep child* CASEID 
forvalue c=1/19{
capture rename child`c' child_cm`c'
}
reshape long child_cm, i(CASEID) j(child_id)
drop if child_cm==. 
merge m:1 CASEID using "$tempdir/nsfg_wide"
keep if _merge==3

keep CASEID CMINTVW child_id child_cm WGTQ1Q16 race educ transition* CMBIRTH mstatus

**************************************************************
*replace gaps that are smaller than 5 months to missing:
forvalue t=21(-1)2{
local x=`t'-1
replace transition`t'=. if (transition`t'-transition`x')<5
}
**************************************************************

*the same as before:
forvalue m=1218/1326 {
g trans`m'= (transition1==`m')
}
forvalue m=1218/1326 {
forvalue t=2/21 {
capture replace trans`m'=trans`m'+1 if transition`t'==`m'
}
}
drop transition* 
forvalue t=1218/1326{
replace trans`t'=. if (CMINTVW-`t')>60
replace trans`t'=. if (CMINTVW-`t')<0
}
forvalue m=1218/1326 {
g age`m'= (`m'-child_cm)
replace age`m'=. if age`m'<1 | age`m'>144 /*keep only children less than 12*/
}
reshape long trans age, i (CASEID child_id) j(month)

save "$tempdir/nsfg_5years_all_t2", replace




























end

/*

****problems to fix:
* Women who were married but we don't know when they lived with their husbands:
forvalue h=1/6{
count if TIMESMAR!=. & TIMESMAR>=`h' & CMPMCOHX`h'>9997 & CMMARRHX`h'>9997
}
/*1st marriage- 19
  2nd marriage- 1
  3rd marriage- 2
  4th marriage- 2
  5th marriage- 1
  6th marriage- 1
	*/

*when premarital cohabiting with the married partner starts after marriage: 
forvalue h=1/6{
count if (CMPMCOHX`h'>CMMARRHX`h' & CMPMCOHX`h'!=9999 & CMPMCOHX`h'!=9998 & CMMARRHX`h'!=9999 & CMMARRHX`h'!=9998 & CMMARRHX`h'!=. & CMPMCOHX`h'!=.)
}
/*1st marriage- 6
  2nd marriage- 2
  3rd marriage- 1
	*/

*women who cohabited with their husband before marriage, but we don't know when (we do know when they got married):
forvalue h=1/6 {
count if LVTOGHX`h'==1 & CMPMCOHX`h'>9997 & CMMARRHX`h'<9998
}
/*1st marriage- 11
  2nd marriage- 3
	*/

*women in cohabitation that we don't know when it started:
forvalue h=1/4 {
count if CMCOHSTX`h'>9997 & CMCOHSTX`h'!=.
}
count if CMSTRTHP>9997 & CMSTRTHP!=.
/*1st relationship- 22
  2nd relationship- 10
  3rd relationship- 1  
  4th relationship- 2
  current relationship- 12
  */

*Missing date of end of living together and in how many cases a new relationship started after  
forvalue h=1/6{
count if CMSTPHSBX`h'==9998| CMSTPHSBX`h'==9999
count if (CMSTPHSBX`h'==9998| CMSTPHSBX`h'==9999) & (partner_start1>partner_start`h'| ///
	partner_start2>partner_start`h' | partner_start3>partner_start`h' | partner_start4>partner_start`h' | ///
	partner_start5>partner_start`h' | partner_start6>partner_start`h' | partner_start7>partner_start`h' | ///
	partner_start8>partner_start`h' | partner_start9>partner_start`h' | partner_start10>partner_start`h' | ///
	partner_start11>partner_start`h')
	}
forvalue c=1/4 {
local p=`c'+6
count if CMSTPCOHX`c'==9998| CMSTPCOHX`c'==9999
count if (CMSTPCOHX`c'==9998| CMSTPCOHX`c'==9999) & (partner_start1>partner_start`p'| ///
	partner_start2>partner_start`p' | partner_start3>partner_start`p' | partner_start4>partner_start`p' | ///
	partner_start5>partner_start`p' | partner_start6>partner_start`p' | partner_start7>partner_start`p' | ///
	partner_start8>partner_start`p' | partner_start9>partner_start`p' | partner_start10>partner_start`p' | ///
	partner_start11>partner_start`p')
	}

/* 1st marriage- 23 missing ends (17 new relationships after)
	2nd marriage- 8 missing ends (6 new relationships after)
	3rd marriage- 4 missing ends (2 new relationships after)
	4th marriage- 2 missing ends (0 new relationships after)
	5th marriage- 2 missing ends (1 new relationships after)
	6th marriage- 1 missing ends (0 new relationships after)
	1st cohabitation- 33 missing ends (24 new relationships after)
	2nd cohabitation- 16 missing ends (7 new relationships after)
	3rd cohabitation- 5 missing ends (4 new relationships after)
	4th cohabitation- 4 missing ends (2 new relationships after)
	*/
	


