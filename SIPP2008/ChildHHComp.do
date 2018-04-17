* For Table 1 of HHstability paper
* Run do_all (or at last project_macros) before executing.

use "$tempdir/examine_hh", clear

* Need to merge in file with demographic characteristics
* in the meantime, to test code...
gen random=runiform()
gen raceth=1 if random < .6
replace raceth=2 if random >=.6
replace raceth=3 if random >=.75
replace raceth=4 if random >=.92 

global results "$projdir/Results and Papers/Household Instability (PAA17)"

putexcel set "$results/ChildHHComp.xlsx", sheet(2008) replace

keep if from_age < $adult_age

tab simplified_rel, matcell(rels)

local rellables "Grandparent Grandparent Grandchild Sibling Other_rel Other_rel_P Parent Non-Relative Child Confused DK"

putexcel A1="Table 1. Relationships of Household members to Children"
putexcel A2=("Relationship") B2=("Freq.") C2=("Percent")
putexcel B4=matrix(100*rels/r(N))

* The code below is not working right ************

forvalues r=1/11 {
	local rw=`r'+3
	putexcel A`rw'="`=word("`rellabels'",`r')'"
}
**************************************************

local racegroups "White Black Asian Hispanic"
*need to fill in real race group names

tab simplified_rel raceth, matcell(relrace)

putexcel C4=matrix(relrace)

putexcel C16= formula(=SUM(C4:C15)) ///
		 D16= formula(=SUM(D4:D15)) ///
		 E16= formula(=SUM(E4:E15)) ///
		 F16= formula(=SUM(F4:F15))  

/*

forvalues racegroup=1/4 {
	putexcel word`racegroup' of `column'3
	forvalues reltype=4/15 {
		local x='reltype'-3
		local cases=relrace`racegroup' if _n=`reltype'
		putexcel C`reltype'=`cases'
	}
}

