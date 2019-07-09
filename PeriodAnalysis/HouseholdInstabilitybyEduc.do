
* Any change 

* SIPP 2001
clear
use "C:\Users\Carolina Aragao\Box\sipp files\WorkingFiles2001\hh_change.dta" 

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
use "C:\Users\Carolina Aragao\Box\sipp files\WorkingFiles2004\hh_change.dta" 

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
use "C:\Users\Carolina Aragao\Box\sipp files\WorkingFiles2008\hh_change.dta" 

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
use "C:\Users\Carolina Aragao\Box\sipp files\WorkingFiles2001\HHchangeWithRelationships.dta"
gen year=2001
append using "C:\Users\Carolina Aragao\Box\sipp files\WorkingFiles2004\HHchangeWithRelationships.dta"
replace year=2004 if year==.
append using "C:\Users\Carolina Aragao\Box\sipp files\WorkingFiles2008\HHchangeWithRelationships.dta"
replace year=2008 if year==.


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


* Recode
tab mom_educ, nol
recode mom_educ -1=.

gen mom_educ2=.
replace mom_educ2=1 if mom_educ==1|mom_educ==2
replace mom_educ2=2 if mom_educ==3
replace mom_educ2=3 if mom_educ==4

label def mom_educ2 1 "hsol" 2 "ltcol" 3 "coll" 


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
quietly anova parent_change wave##mom_educ2
quietly margins wave##mom_educ2
marginsplot, noci ytitle(Parent Change)

*Sibling
quietly anova sib_change wave##mom_educ2
quietly margins wave##mom_educ2
marginsplot, noci ytitle(Sibling Change)

*Grandparents
quietly anova gp_change wave##mom_educ2
quietly margins wave##mom_educ2
marginsplot, noci ytitle(Mean Change)

*Other relative
quietly anova otherrel_change wave##mom_educ2
quietly margins wave##mom_educ2
marginsplot, noci ytitle(Mean Change)

* Non-relative
quietly anova nonrel_change wave##mom_educ2
quietly margins wave##mom_educ2
marginsplot, noci ytitle(Mean Change)

clear
