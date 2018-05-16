* changer_rels_demo.do
* merges data onto demographic data

use "$tempdir/simpler_leaver_and_arriver_rels", clear

keep if from_age < $adult_age

rename relfrom EPPPNUM

sort SSUID EPPPNUM SWAVE

merge m:1 SSUID EPPPNUM SWAVE using "$tempdir/demo08.dta"

keep if _merge==3

gen diff_age=to_age-from_age

replace simplified_rel=17 if rel_is_confused==1 & rel_is_ever_sibling==1 & abs(diff_age) < 20
replace simplified_rel=23 if rel_is_confused==1 & rel_is_ever_parent==1 & diff_age >= 12

global results "$projdir/Results and Papers/Household Instability (PAA17)"

putexcel set "$results/ChangerRels.xlsx", sheet(2008) modify

tab ultra_simple_rel, matcell(rels)

putexcel A1="Table 3. Relationships of People entering/leaving child's household to Child"
putexcel A2=("Relationship") B2=("Total") C2=("By Race-Ethnicity") H2=("By Maternal Education")
putexcel B3="Percent"
putexcel B4=matrix(100*rels/r(N))


tab ultra_simple_rel first_raceth, matcell(crelrace)
putexcel C3="`racegroups'"

putexcel C4=matrix(crelrace)


* By Maternal Education

local ceduc "<HS HS SomeCollege College+"

tab ultra_simple_rel momfirstced, matcell(creleduc)
putexcel H3="`ceduc'"

putexcel H4=matrix(creleduc)


