*Table 1- estimates of #transitions by race, education and sample restriction
*5 years all children:
use "$tempdir/nsfg_5years_all", clear
tabstat trans [aweight=WGTQ1Q16], by(age) 
tabstat trans [aweight=WGTQ1Q16] if race==1, by(age) 
tabstat trans [aweight=WGTQ1Q16] if race==2, by(age) 
tabstat trans [aweight=WGTQ1Q16] if race==3, by(age) 
tabstat trans [aweight=WGTQ1Q16] if race==4, by(age) 
tabstat trans [aweight=WGTQ1Q16] if educ==1, by(age) 
tabstat trans [aweight=WGTQ1Q16] if educ==2, by(age) 
tabstat trans [aweight=WGTQ1Q16] if educ==3, by(age) 
tabstat trans [aweight=WGTQ1Q16] if educ==4, by(age) 

/*total*/ di .0073806*144 
/*Hispanic*/ di .0065895*144
/*NH white*/ di .0066723*144
/*NH black*/ di .0115086*144
/*NH other*/ di .0068459*144
/*less than HS*/ di .0099717*144
/*HS*/ di .0095631*144
/*some college*/ di .0078116*144
/*bachelor+ */ di .0020085*144


*5 years mother gave birth under 30
use "$tempdir/nsfg_5years_mom30", clear
tabstat trans [aweight=WGTQ1Q16], by(age) 
tabstat trans [aweight=WGTQ1Q16] if race==1, by(age) 
tabstat trans [aweight=WGTQ1Q16] if race==2, by(age) 
tabstat trans [aweight=WGTQ1Q16] if race==3, by(age) 
tabstat trans [aweight=WGTQ1Q16] if race==4, by(age) 
tabstat trans [aweight=WGTQ1Q16] if educ==1, by(age) 
tabstat trans [aweight=WGTQ1Q16] if educ==2, by(age) 
tabstat trans [aweight=WGTQ1Q16] if educ==3, by(age) 
tabstat trans [aweight=WGTQ1Q16] if educ==4, by(age) 

/*total*/ di .009142*144 
/*Hispanic*/ di .0069212*144
/*NH white*/ di .0089175*144
/*NH black*/ di .0129527*144
/*NH other*/ di .0094353*144
/*less than HS*/ di .0110304*144
/*HS*/ di .0083373*144
/*some college*/ di .0070953*144
/*bachelor+ */ di .0019679*144







****************************************************************************************************
*Table 2- after removing transitions shorter than 5 month (all women)
use "$tempdir/nsfg_5years_all_t2",clear
tabstat trans [aweight=WGTQ1Q16], by(age) 
tabstat trans [aweight=WGTQ1Q16] if race==1, by(age) 
tabstat trans [aweight=WGTQ1Q16] if race==2, by(age) 
tabstat trans [aweight=WGTQ1Q16] if race==3, by(age) 
tabstat trans [aweight=WGTQ1Q16] if race==4, by(age) 
tabstat trans [aweight=WGTQ1Q16] if educ==1, by(age) 
tabstat trans [aweight=WGTQ1Q16] if educ==2, by(age) 
tabstat trans [aweight=WGTQ1Q16] if educ==3, by(age) 
tabstat trans [aweight=WGTQ1Q16] if educ==4, by(age) 

/*total*/ di .0065401*144 
/*Hispanic*/ di .0061654*144
/*NH white*/ di .0057056*144
/*NH black*/ di .0104207*144
/*NH other*/ di .0062536*144
/*less than HS*/ di .008568*144
/*HS*/ di .0083373*144
/*some college*/ di .0070953*144
/*bachelor+ */ di .0019679*144








****************************************************************************************************
*Table 3- marital status of mother in the sample
use "$tempdir/nsfg_5years_all", clear
duplicates drop CASEID, force
ta mstatus [aweight=WGTQ1Q16]







use "$projdir/data/ACS2008/acs08", clear
*marital status categories
/*married- if the person is married and live with the husband
cohabiting- if the person is living with someone who is not the husband
was married- seperated, widdow, divorce and married but live apart and not cohabiting
single- not cohabiting was never married*/
g mstatus=1 if marst==1
replace mstatus=2 if marst!=1 & sploc!=0
replace mstatus=3 if marst>=2 & marst<=5 & sploc==0
replace mstatus=4 if marst==6 & sploc==0

label define lmstatus 1 "Married" 2 "Cohabiting" 3 "Was married" 4 "Single"
label value mstatus lmstatus

*keep only women ages 15-44 with children under 12 in the hh:
keep if sex==2
keep if age>=15 & age<=44
keep if yngch<=12 /*keep if youngest own child in the hh is under/equal to 12*/

*marital status:
ta mstatus [aweight=perwt]






****************************************************************************************************
*Table 4- estimates of family instability by marital status
use "$tempdir/nsfg_5years_all", clear
tabstat trans [aweight=WGTQ1Q16] if mstatus==1, by(age) 
tabstat trans [aweight=WGTQ1Q16] if mstatus==2, by(age) 
tabstat trans [aweight=WGTQ1Q16] if mstatus==3, by(age) 
tabstat trans [aweight=WGTQ1Q16] if mstatus==4, by(age) 

/*Married*/ di .0017882*144
/*Cohabiting*/ di .0166847*144
/*Was married*/ di .0193696*144
/*Single*/ di .0153597*144
