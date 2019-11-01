* Set where you want any output to go
global SIPP14results "~/projects/childhh/results/2014"

use "$SIPP14keep/HHchangeWithRelationships_am.dta", clear

drop if missing(SHHADID)

* first calculate transition rates by type by age by parent_ed in each month of the panel

collapse (mean) hh_change comp_change parent_change sib_change other_change nonparent_change gp_change nonrel_change otherrel_change, by(adj_age par_ed_first panelmonth)

gen swave=floor((panelmonth+11)/12)
gen month=12-(swave*12-panelmonth)

* Now I want to see annual measures of comp_change by child age to compare to SIPP 2008.

keep if adj_age < 18

collapse (sum) hh_change comp_change parent_change, by(adj_age swave)

sort swave adj_age
gen year=2012+swave

outsheet adj_age year hh_change comp_change parent_change using "$SIPP14results/agebyyear14.csv" , comma $replace 

end


collapse (sum) hh_change comp_change parent_change sib_change other_change nonparent_change gp_change nonrel_change otherrel_change, by(adj_age par_ed_first)

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


