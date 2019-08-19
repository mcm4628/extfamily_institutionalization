
* Any change 

* SIPP 2001
clear
use "$SIPP01keep\hh_change.dta" 

* Sample
keep if age<=18

tab SWAVE mom_educ [aw=WPFINWGT], sum(comp_change) 
tab SWAVE mom_educ  [aw=WPFINWGT], sum(addr_change)

 

tab SWAVE my_race [aw=WPFINWGT], sum(comp_change) 
tab SWAVE my_race [aw=WPFINWGT], sum(addr_change) 


* By race and education
bys my_race: tab SWAVE mom_educ [aw=WPFINWGT], sum(comp_change) 
bys my_race: tab SWAVE mom_educ [aw=WPFINWGT], sum(addr_change) 




* SIPP 2004
clear
use "$SIPP04keep\hh_change.dta"

* Sample
keep if age<=18

tab mom_educ, nol
recode mom_educ -1=.


tab SWAVE mom_educ [aw=WPFINWGT], sum(comp_change) 
tab SWAVE mom_educ  [aw=WPFINWGT], sum(addr_change) 

tab SWAVE my_race [aw=WPFINWGT], sum(comp_change) 
tab SWAVE my_race [aw=WPFINWGT], sum(addr_change) 


* By race and education
bys my_race: tab SWAVE mom_educ [aw=WPFINWGT], sum(comp_change) 
bys my_race: tab SWAVE mom_educ [aw=WPFINWGT], sum(addr_change) 



* SIPP 2008
clear
use "$SIPP08keep\hh_change.dta"

* Sample
keep if age<=18

tab SWAVE mom_educ [aw=WPFINWGT], sum(comp_change) 
tab SWAVE mom_educ  [aw=WPFINWGT], sum(addr_change)

 

tab SWAVE my_race [aw=WPFINWGT], sum(comp_change) 
tab SWAVE my_race [aw=WPFINWGT], sum(addr_change) 


* By race and education
bys my_race: tab SWAVE mom_educ [aw=WPFINWGT], sum(comp_change) 
bys my_race: tab SWAVE mom_educ [aw=WPFINWGT], sum(addr_change) 



******************************* By type of change*********************************
clear
use "$SIPP14keep\HHchangeWithRelationships.dta"
gen year=2014
rename PNUM EPPPNUM 
append using "$SIPP04keep\HHchangeWithRelationships.dta"
replace year=2004 if year==.
append using "$SIPP08keep\HHchangeWithRelationships.dta"
replace year=2008 if year==2008
append using "$SIPP01keep\HHchangeWithRelationships.dta"
replace year=2001 if year==.


*Rename waves
gen wave=.
replace wave=1 if SWAVE==1 & year==2001
replace wave=2 if SWAVE==2 & year==2001
replace wave=3 if SWAVE==3 & year==2001
replace wave=4 if SWAVE==4 & year==2001
replace wave=5 if SWAVE==5 & year==2001
replace wave=6 if SWAVE==6 & year==2001
replace wave=7 if SWAVE==7 & year==2001
replace wave=8 if SWAVE==8 & year==2001

replace wave=9 if SWAVE==1 & year==2004
replace wave=10 if SWAVE==2 & year==2004
replace wave=11 if SWAVE==3 & year==2004
replace wave=12 if SWAVE==4 & year==2004
replace wave=13 if SWAVE==5 & year==2004
replace wave=14 if SWAVE==6 & year==2004
replace wave=15 if SWAVE==7 & year==2004
replace wave=16 if SWAVE==8 & year==2004
replace wave=17 if SWAVE==9 & year==2004
replace wave=18 if SWAVE==10 & year==2004
replace wave=19 if SWAVE==11 & year==2004

replace wave=20 if SWAVE==1 & year==2008
replace wave=21 if SWAVE==2 & year==2008
replace wave=22 if SWAVE==3 & year==2008
replace wave=23 if SWAVE==4 & year==2008
replace wave=24 if SWAVE==5 & year==2008
replace wave=25 if SWAVE==6 & year==2008
replace wave=26 if SWAVE==7 & year==2008
replace wave=27 if SWAVE==8 & year==2008
replace wave=28 if SWAVE==9 & year==2008
replace wave=29 if SWAVE==10 & year==2008
replace wave=30 if SWAVE==11 & year==2008
replace wave=31 if SWAVE==12 & year==2008
replace wave=32 if SWAVE==13 & year==2008
replace wave=33 if SWAVE==14 & year==2008
replace wave=34 if SWAVE==1 & year==2014
replace wave=35 if SWAVE==2 & year==2014
replace wave=36 if SWAVE==3 & year==2014


* Recode
tab mom_educ, nol
recode mom_educ -1=.

gen mom_educ2=.
replace mom_educ2=1 if mom_educ==1|mom_educ==2
replace mom_educ2=2 if mom_educ==3
replace mom_educ2=3 if mom_educ==4

label def mom_educ2 1 "hsol" 2 "ltcol" 3 "coll" 

* Creating moving avareges
egen id= group(SSUID EPPPNUM)
tsset id swave

tssmooth ma parent = parent_change, window(2 1 2) 
tssmooth ma sib = sib_change, window(2 1 2) 
tssmooth ma gp = gp_change, window(2 1 2) 
tssmooth ma otherrel = otherrel_change, window(2 1 2) 
tssmooth ma nonrel = nonrel_change, window(2 1 2) 


* Sample
keep if TAGE<=18 


* Tabs
tab SWAVE mom_educ  [aw=WPFINWGT], sum(parent_change) means
tab SWAVE mom_educ  [aw=WPFINWGT], sum(sib_change) means
tab SWAVE mom_educ  [aw=WPFINWGT], sum(gp_change) means
tab SWAVE mom_educ  [aw=WPFINWGT], sum(otherrel_change) means
tab SWAVE mom_educ  [aw=WPFINWGT], sum(nonrel_change) means

* Graphs

* Parent Channge
quietly anova parent wave##mom_educ2
quietly margins wave##mom_educ2
marginsplot, noci ytitle(Parent Change)

*Sibling
quietly anova sib wave##mom_educ2
quietly margins wave##mom_educ2
marginsplot, noci ytitle(Sibling Change)

*Grandparents
quietly anova gp wave##mom_educ2
quietly margins wave##mom_educ2
marginsplot, noci ytitle(Mean Change)

*Other relative
quietly anova otherrel wave##mom_educ2
quietly margins wave##mom_educ2
marginsplot, noci ytitle(Mean Change)

* Non-relative
quietly anova nonrel wave##mom_educ2
quietly margins wave##mom_educ2
marginsplot, noci ytitle(Mean Change)


* Moving Averages 2
local i_vars "SSUID EPPPNUM"
local j_vars "wave"
local wide_vars "SSUID EPPPNUM wave TAGE WPFINWGT mom_educ2 parent_change sib_change other_change nonparent_change gp_change nonrel_change otherrel_change"

keep SSUID EPPPNUM wave TAGE WPFINWGT mom_educ2 parent_change sib_change other_change nonparent_change gp_change nonrel_change otherrel_change

reshape wide TAGE WPFINWGT mom_educ2 parent_change sib_change other_change nonparent_change gp_change nonrel_change otherrel_change, i(`i_vars') j(`j_vars')


* Moving Avarages

* Parent change
forvalues n =1/35 {
    gen parent_changem`n' = (parent_change`n-1' + parent_change`n' + parent_change`n+1')/3
    
}

*Sibling change
forvalues n =1/35 {
    gen sib_changem`n' = (sib_change`n-1' + sib_change`n' + sib_change`n+1')/3
    
}

*Grandparents change
forvalues n =1/35 {
    gen gp_changem`n' = (gp_change`n-1' + gp_change`n' + gp_change`n+1')/3
    
}

*Other relative change
forvalues n =1/35 {
    gen otherrel_changem`n' = (otherrel_change`n-1' + otherrel_change`n' + otherrel_change`n+1')/3
    
}

*Non-relative change
forvalues n =1/35 {
    gen nonrel_changem`n' = (nonrel_change`n-1' + nonrel_change`n' + nonrel_change`n+1')/3
    
}

reshape long TAGE WPFINWGT mom_educ2 parent_change sib_change other_change nonparent_change gp_change nonrel_change otherrel_change parent_changem sib_changem other_changem nonparent_changem gp_changem nonrel_changem otherrel_changem, i(SSUID EPPPNUM) j(wave)


* Parent Channge
quietly anova parent_changem wave##mom_educ2
quietly margins wave##mom_educ2
marginsplot, noci ytitle(Parent Change)

*Sibling
quietly anova sib_changem wave##mom_educ2
quietly margins wave##mom_educ2
marginsplot, noci ytitle(Sibling Change)

*Grandparents
quietly anova gp_changem wave##mom_educ2
quietly margins wave##mom_educ2
marginsplot, noci ytitle(Granparent Change)

*Other relative
quietly anova otherrel_changem wave##mom_educ2
quietly margins wave##mom_educ2
marginsplot, noci ytitle(Other Relative Change)

* Non-relative
quietly anova nonrel_changem wave##mom_educ2
quietly margins wave##mom_educ2
marginsplot, noci ytitle(Non-relative Change)
