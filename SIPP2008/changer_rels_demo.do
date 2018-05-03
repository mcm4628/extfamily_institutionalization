* changer_rels_demo.do
* merges data onto demographic data

use "$tempdir/simpler_leaver_and_arriver_rels", clear

keep if from_age < $adult_age

rename relfrom EPPPNUM

sort SSUID EPPPNUM SWAVE

merge m:1 SSUID EPPPNUM using "$tempdir/fixedracesex.dta"

keep if _merge==3

drop _merge

sort SSUID SHHADID SWAVE

merge m:1 SSUID SHHADID SWAVE using "$tempdir/demoHH08.dta"

keep if _merge==3

global results "$projdir/Results and Papers/Household Instability (PAA17)"

putexcel set "$results/ChangerRels.xlsx", sheet(2008) modify

tab ultra_simple_rel, matcell(rels)

putexcel A1="Table 3. Relationships of People entering/leaving child's household to Child"
putexcel A2=("Relationship") B2=("Total") C2=("By Race-Ethnicity") H2=("By Householder Education")
putexcel B3="Percent"
putexcel B4=matrix(100*rels/r(N))


tab ultra_simple_rel raceth, matcell(crelrace)
putexcel C3="`racegroups'"

putexcel C4=matrix(crelrace)


* By Householder Education

local ceduc "<HS HS SomeCollege College+"

tab ultra_simple_rel hheduc, matcell(creleduc)
putexcel H3="`ceduc'"

putexcel H4=matrix(creleduc)


