use "$SIPP08keep/HHchangeWithRelationships_am.dta", clear

gen wave=floor((panelmonth+3)/4)
gen month=4-(wave*4-panelmonth)

tab month parent_change, nofreq row

drop if missing(SHHADID)

collapse (mean) hh_change comp_change parent_change sib_change other_change nonparent_change gp_change nonrel_change otherrel_change, by(adj_age par_ed_first month)
collapse (sum) hh_change comp_change parent_change sib_change other_change nonparent_change gp_change nonrel_change otherrel_change, by(adj_age par_ed_first)

replace hh_change=hh_change*3 // converting 4-month rate to an annual rate
replace comp_change=comp_change*3 
replace parent_change=parent_change*3 
replace sib_change=sib_change*3 
replace other_change=other_change*3 
replace nonparent_change=nonparent_change*3 
replace gp_change=gp_change*3 
replace nonrel_change=nonrel_change*3 
replace otherrel_change=otherrel_change*3 

// list adj_age hh_change

preserve

keep if adj_age < 18

collapse (sum) hh_change comp_change parent_change sib_change other_change nonparent_change gp_change nonrel_change otherrel_change, by(par_ed_first)

tab par_ed_first parent_change
tab par_ed_first comp_change

restore

keep if adj_age < 5

collapse (sum) comp_change parent_change sib_change other_change nonparent_change gp_change nonrel_change otherrel_change, by(par_ed_first)

tab par_ed_first parent_change
tab par_ed_first comp_change


