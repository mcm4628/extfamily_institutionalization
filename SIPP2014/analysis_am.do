* Set where you want any output to go
global SIPP14results "$projdir/kraley/childhh/results/SIPP2014"

use "$SIPP14keep/HHchangeWithRelationships_am.dta", clear

keep if adj_age < 18

******************************************************************
* Section: Hand calculate numerators and denominators (unfinished because why?)
*****************************************************************
/*
forvalues a=0/17 {
	  gen rate_age1`a'=0
}

forvalues m=0/17 {
}
*/
drop if missing(ERESIDENCEID)

* first calculate transition rates by type by age by parent_ed in each month of the panel

gen swave=floor((panelmonth+11)/12)
gen month=12-(swave*12-panelmonth)

gen one=1

collapse (mean) hh_change comp_change parent_change sib_change other_change nonparent_change gp_change nonrel_change otherrel_change [aweight=WPFINWGT], by(adj_age panelmonth swave)

* Now I want to see annual measures of comp_change by child age to compare to SIPP 2008.

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


