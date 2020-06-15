********************************************************************************
* Comparison of household composition, our measures versus Pilkauskas and Cross
********************************************************************************

use "$tempdir/relationships.dta", clear

local t2rel "anyt2gp anyt2au anyt2or anyt2nr"
local anyrel "anygp anyauntuncle anyother anynonrel"

********************************************************************************
* Analysis
********************************************************************************

putexcel set "$results/compare08.xlsx", sheet(individuals) modify  

putexcel A1 = "Household Composition by various measurement strategies"
putexcel B2:E2 = "2008", merge
putexcel B3:C3 = "All months", merge
putexcel B4 = ("Transitively measured") C4 = ("Directly Measured") D4 = ("Transitively measured") E4 = ("Directly Measured")
putexcel A4 = "HH contains:"

local row = 4
local count = 0 



foreach v in `anyrel' {
	local row = `row' + 1
	local count = `count' + 1
	
	local reltype : word  `count' of `anyrel'
	display "Reltype `reltype' count `count' row `row'"
	putexcel A`row'="`reltype'"
	
	mean `v' [fweight=weight] if allrel > 0
	matrix rel`v' = e(b)*100
	putexcel B`row' = matrix(rel`v'), nformat(###.#)
}

local t2rel "anyt2gp anyt2au anyt2or anyt2nr"

local row = 4
local count = 0 

foreach v in `t2rel'{
	local row = `row' + 1
	
	mean `v' [fweight=weight] if t2allrel > 0
	matrix rel`v' = e(b)*100
	putexcel C`row' = matrix(rel`v'), nformat(###.#)
}

* Transitive by t2 measure
tab anygp anyt2gp if allrel > 0, cell
tab anyauntuncle anyt2au if allrel > 0, cell
tab anyother anyt2or if allrel > 0, cell
tab anynonrel anyt2nr if allrel > 0, cell

/* restrict to Wave 2 observations */
keep if panelmonth==8

putexcel D3:E3 = "Wave 2", merge
 
local row = 4
local count = 0
 
foreach v in `anyrel'{
	local row = `row' + 1
	mean `v' [fweight=weight] if allrel > 0
	matrix rel`v'm2 = e(b)*100
	putexcel D`row' = matrix(rel`v'm2), nformat(###.#)
 }
 
local row = 4
local count = 0

foreach v in `t2rel'{
	local row = `row' + 1
	mean `v' [fweight=weight] if t2allrel > 0
	matrix rel`v'm2 = e(b)*100
	putexcel E`row' = matrix(rel`v'm2), nformat(###.#)
}

tab anygp anyt2gp
tab anyauntuncle anyt2au
tab anyother anyt2or
tab anynonrel anyt2nr
