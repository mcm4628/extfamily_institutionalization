* For Table 1 of HHstability paper
* Run do_all (or at last project_macros) before executing.

use "$tempdir/examine_hh", clear

* Need to merge in file with demographic characteristics

global results "$projdir/Results and Papers/Household Instability (PAA17)"

putexcel set "$results/ChildHHComp.xlsx", sheet(2008) replace

drop if from_age < $adult_age)

tab simplified_rel, m sort, matcell(freq) matrow(names)

putexcel A1="Table 1. Relationships of Household members to Children", replace
putexcel A3=("Relationship") B3=("Freq.") C3=("Percent") using results, modify
putexcel A4=matrix(names) B2=matrix(freq) C2=matrix(100*freq/r(N)) using results, modify

tab simplified_rel raceth,matcell(relrace) 

svmat x

local column "C D E F G"
local racegroups " "
need to fill in race group names


forvalues racegroup=1/4 {
	putexcel word`racegroup' of `column'3
	forvalues reltype=4/15 {
		local x='reltype'-3
		local cases=relrace`racegroup' if _n=`reltype'
		putexcel C`reltype'=`cases'
	}
}

