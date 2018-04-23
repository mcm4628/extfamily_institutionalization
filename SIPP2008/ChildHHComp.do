* For Table 1 of HHstability paper
* Run do_all (or at last project_macros) before executing.

use "$tempdir/examine_hh", clear


keep if from_age < $adult_age

rename relfrom EPPPNUM

sort SSUID EPPPNUM SWAVE

merge m:1 SSUID EPPPNUM SWAVE using "$tempdir/demoperson08.dta"

tab TAGE _merge

keep if _merge==3

drop _merge

sort SSUID SHHADID SWAVE

merge m:1 SSUID SHHADID SWAVE using "$tempdir/demoHH08.dta"

keep if _merge==3

* Use rel_is_confused, rel_is_ever_child, rel_is_ever_sibling to sort confused into sibling (17) and child (23).
* This makes estimate of percentage of "other" (i.e. non-parent, non-sibling) people in HH conservative.

gen diff_age=to_age-from_age

replace simplified_rel=17 if rel_is_confused==1 & rel_is_ever_sibling==1 & abs(diff_age) < 20
replace simplified_rel=23 if rel_is_confused==1 & rel_is_ever_parent==1 & diff_age >= 12


global results "$projdir/Results and Papers/Household Instability (PAA17)"

putexcel set "$results/ChildHHComp.xlsx", sheet(2008) modify

tab simplified_rel [aweight=WPFINWGT], matcell(rels)

local rellables "Grandparent Grandparent Grandchild Sibling Other_rel Other_rel_P Parent Non-Relative Child Confused DK"

putexcel A1="Table 1. Relationships of Household members to Children"
putexcel A2=("Relationship") B2=("Total") C2=("By Race-Ethnicity") H2=("By Householder Education")
putexcel B3="Percent"
putexcel B4=matrix(100*rels/r(N))
putexcel A16="Total"
putexcel B16=formula(=SUM(B4:B15))

forvalues r=1/11 {
	local rw=`r'+3
	putexcel A`rw'="`word(rellables,`rw')'"
}

* By Race-ethnicity

local racegroups "NHWhite Black NHAsian NHOther Hispanic"

tab simplified_rel raceth [aweight=WPFINWGT], matcell(relrace)
putexcel C3="`racegroups'"

putexcel C4=matrix(relrace)

putexcel C16= formula(=SUM(C4:C15)) ///
		 D16= formula(=SUM(D4:D15)) ///
		 E16= formula(=SUM(E4:E15)) ///
		 F16= formula(=SUM(F4:F15)) ///
		 G16= formula(=SUM(G4:G15))  

* By Householder Education

local ceduc "<HS HS SomeCollege College+"

tab simplified_rel hheduc [aweight=WPFINWGT], matcell(releduc)
putexcel H3="`ceduc'"

putexcel H4=matrix(releduc)

putexcel H16= formula(=SUM(H4:H15)) ///
		 I16= formula(=SUM(I4:I15)) ///
		 J16= formula(=SUM(J4:J15)) ///
		 K16= formula(=SUM(K4:K15))  
		 
sort SSUID EPPPNUM SWAVE

gen anyother=1 if inlist(ultra_simple_rel,3,4,5)
replace anyother=0 if missing(anyother)

preserve

collapse (max) anyother (median) hheduc (median) raceth, by(SSUID EPPPNUM SWAVE)

tab anyother raceth, col
tab anyother raceth, col

duplicates drop SSUID EPPPNUM, force

tab hheduc
tab raceth

restore

collapse (count) hhmem=ultra_simple_rel (median) hheduc (median) raceth, by(SSUID EPPPNUM SWAVE)

sort raceth

by raceth: sum hhmem

sort hheduc
by hheduc: sum hhmem






		 


