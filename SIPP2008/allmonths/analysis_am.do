use "$SIPP08keep/HHchangeWithRelationships_am.dta", clear
global SIPP08results "~/projects/childhh/results/2008"

drop if missing(SHHADID)

keep if adj_age < 18

collapse (mean) hh_change comp_change parent_change sib_change other_change nonparent_change gp_change nonrel_change otherrel_change [aweight=WPFINWGT], by(adj_age panelmonth)

gen wave=floor((panelmonth+3)/4)
gen month=4-(wave*4-panelmonth)

collapse (sum) hh_change comp_change parent_change sib_change other_change nonparent_change gp_change nonrel_change otherrel_change, by(adj_age wave)

replace hh_change=hh_change*3 // converting 4-month rate to an annual rate
replace comp_change=comp_change*3 
replace parent_change=parent_change*3 
replace sib_change=sib_change*3 
replace other_change=other_change*3 
replace nonparent_change=nonparent_change*3 
replace gp_change=gp_change*3 
replace nonrel_change=nonrel_change*3 
replace otherrel_change=otherrel_change*3 

preserve

collapse (mean) hh_change comp_change parent_change sib_change other_change nonparent_change gp_change nonrel_change otherrel_change, by(adj_age)

outsheet adj_age hh_change comp_change parent_change using "$SIPP08results/byage08.csv", comma $replace

restore

* Note that this is only an approximation of year since actual calendar month varies by rotation within wave
gen year=2008+floor((wave+2)/3)

tab year

sort year adj_age

outsheet adj_age year hh_change comp_change parent_change using "$SIPP08results/byagebyyear08.csv", comma $replace

end
// list adj_age hh_change

preserve


collapse (sum) hh_change comp_change parent_change sib_change other_change nonparent_change gp_change nonrel_change otherrel_change, by(par_ed_first)

tab par_ed_first parent_change
tab par_ed_first comp_change

restore

keep if adj_age < 5

collapse (sum) comp_change parent_change sib_change other_change nonparent_change gp_change nonrel_change otherrel_change, by(par_ed_first)

tab par_ed_first parent_change
tab par_ed_first comp_change


