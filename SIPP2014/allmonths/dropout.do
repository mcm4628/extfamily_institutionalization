//====================================================================//
//===== Children's Household Instability Project                    
//===== Dataset: SIPP2014                                          
//===== Purpose: This code append all waves of SIPP2014 original data into a long form dataset. 
//=====================================================================//

use "$SIPP14keep/allmonths14.dta", clear

gen summer=1 if inlist(MONTHCODE, 6, 7, 8)
replace summer=0 if inlist(MONTHCODE,1,2,3,4,5,9,10,11,12)

gen dropout=1 if RENROLL==2 & (EEDUC < 39 | TAGE < 15 ) & summer==0
replace dropout=0 if RENROLL==1 & (EEDUC < 39 | TAGE < 15)
replace dropout=2 if RENROLL==1 & (EEDUC < 39 | TAGE < 15) & summer==1
replace dropout=3 if EEDUC >= 39 & !missing(EEDUC)

merge 1:1 SSUID PNUM panelmonth using "$SIPP14keep/HHComp_pm.dta"
   
keep if adj_age >= 14 & adj_age <= 20

tab dropout

keep SSUID PNUM dropout adj_age my_race my_sex par_ed_first parcomp sibcomp extend swave MONTHCODE panelmonth

reshape wide dropout adj_age my_race my_sex par_ed_first parcomp sibcomp extend swave MONTHCODE, i(SSUID PNUM) j(panelmonth)

* an indicator for whether this person dropped out of high school in any non-summer month this year
* There are a few who drop out and then back in. We think that any droput might indicate a potential problem.
forvalues year=1/4{
    gen cdo`year'=.
    local ay=`year'-1
    forvalues m=1/12{
        local pm=`ay'*12+`m'
        replace cdo`year'=0 if !missing(dropout`pm') & cdo`year'==.
        replace cdo`year'=3 if dropout`pm'==3 & inlist(cdo`year',0,.)
        replace cdo`year'=1 if dropout`pm'==1 
    }
}

rename cdo1 cdo12
rename cdo2 cdo24
rename cdo3 cdo36    
rename cdo4 cdo48

foreach pm in 12 24 36{
    local z=`pm'+12
    gen dropoutny`pm'=dropout`z' 
    gen cdony`pm'=cdo`z'

}

reshape long dropout dropoutny cdo cdony adj_age my_race my_sex par_ed_first parcomp sibcomp extend swave MONTHCODE, i(SSUID PNUM) j(panelmonth)

keep if MONTHCODE==12

drop MONTHCODE

save "$SIPP14keep/HHcomp_dropout.dta", replace
