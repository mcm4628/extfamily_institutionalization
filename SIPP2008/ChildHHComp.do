* For Table 1 of HHstability paper
* Run do_childrens_household_core (or at least project_macros) before executing.

use "$tempdir/HHComp", clear

keep if adj_age < $adult_age

tab unified_rel [aweight=WPFINWGT]

gen bioparent=1 if unified_rel==1
gen parent=1 if inlist(unified_rel,1,4,7,19,20,21,30,31,38)
gen parent2=1 if parent==1 | (rel_is_ever_child==1 & rel_is_confused==1)
gen sibling=1 if inlist(unified_rel, 17,33,34)
gen sibling2=1 if sibling==1 | (rel_is_ever_sibling & rel_is_confused==1 & parent2 !=1)
gen child=1 if inlist(unified_rel,2,3,5,6,8,9,10,11,22,23,25,26)
gen spartner=1 if inlist(unified_rel,12,18)
gen nonrel=1 if unified_rel==37
gen grandparent=1 if inlist(unified_rel,13,14,27)
gen other_rel=1 if inlist(unified_rel, 15,16,24,28,29,32,35)
gen confused=1 if unified_rel==39 
gen confused2=1 if confused==1 & parent2==0 & sibling2==0
gen unknown=1 if unified_rel==40
gen nonnuke=1 if nonrel==1 | grandparent==1 | other_rel==1 | confused2==1 | unknown==1

local rellist "bioparent parent parent2 sibling sibling2 child spartner nonrel grandparent other_rel confused confused2 unknown nonnuke"

collapse (count) `rellist', by (SSUID EPPPNUM SWAVE) fast

merge 1:1 SSUID EPPPNUM SWAVE using "$tempdir/demo_long_interviews.dta", keepusing(WPFINWGT my_race adj_age my_sex mom_educ)

gen weight=int(WPFINWGT*10000)

foreach v in `rellist'{
 tab `v' [fweight=weight]
 }
 
 recode nonnuke (0=0)(1/20=1), gen(anynonuke)
 recode nonrel (0=0)(1/20=1), gen(anynonrel)
 recode grandparent (0=0)(1/20=1), gen(anygp)
 recode other_rel (0=0)(1/20=1), gen(anyother)
 recode confused (0=0)(1/20=1), gen(anyconfused)
 
local anyrel "anynonuke anynonrel anygp anyother anyconfused"

foreach v in `anyrel'{
tab `v' my_race [aw=WPFINWGT], nofreq col
}
/*

* Use rel_is_confused, rel_is_ever_child, rel_is_ever_sibling to sort confused into sibling (17) and child (23).
* This makes estimate of percentage of "other" (i.e. non-parent, non-sibling) people in HH conservative.

gen diff_age=to_age-adj_age

replace simplified_rel=17 if rel_is_confused==1 & rel_is_ever_sibling==1 & abs(diff_age) < 20
replace simplified_rel=23 if rel_is_confused==1 & rel_is_ever_parent==1 & diff_age >= 12

*global results "$projdir/Results and Papers/Household Instability (PAA17)"

*putexcel set "$results/ChildHHComp.xlsx", sheet(2008) modify

tab simplified_rel [aweight=WPFINWGT], matcell(rels)

local rellables "GRANDCHILD GRANDCHILD_P GRANDPARENT SIBLING CHILD F_PARENT PARENT OTHER_REL OTHER_REL_P NOREL CONFUSED DONTKNOW"

*putexcel A1="Table 1. Relationships of Household members to Children"
*putexcel A2=("Relationship") B2=("Total") C2=("Race-Ethnicity") H2=("Mother's Education")
*putexcel B3="Percent"
*putexcel B4=matrix(100*rels/r(N))
*putexcel A16="Total"
*putexcel B16=formula(=SUM(B4:B15))

*forvalues r=1/11 {
*	local rw=`r'+3
*	putexcel A`rw'="`word(rellables,`rw')'"
*}

* By Race-ethnicity

local racegroups "NHWhite Black NHAsian NHOther Hispanic"

tab simplified_rel my_race [aweight=WPFINWGT], matcell(relrace)
*putexcel C3="`racegroups'"

*putexcel C4=matrix(relrace)

*putexcel C16= formula(=SUM(C4:C15)) ///
*		 D16= formula(=SUM(D4:D15)) ///
*		 E16= formula(=SUM(E4:E15)) ///
*		 F16= formula(=SUM(F4:F15)) ///
*		 G16= formula(=SUM(G4:G15))  

* By Maternal Education

local ceduc "<HS HS SomeCollege College+"

tab simplified_rel mom_educ [aweight=WPFINWGT], matcell(releduc)
*putexcel H3="`ceduc'"

*putexcel H4=matrix(releduc)

*putexcel H16= formula(=SUM(H4:H15)) ///
*		 I16= formula(=SUM(I4:I15)) ///
*		 J16= formula(=SUM(J4:J15)) ///
*		 K16= formula(=SUM(K4:K15))  
		 
sort SSUID EPPPNUM SWAVE

gen anyother=1 if inlist(ultra_simple_rel,3,4,5)
replace anyother=0 if missing(anyother)

preserve

collapse (max) anyother (median) momfirstced (median) first_raceth, by(SSUID EPPPNUM SWAVE)

tab anyother first_raceth, col
tab anyother momfirstced, col

duplicates drop SSUID EPPPNUM, force

tab momfirstced
tab first_raceth

restore

collapse (count) hhmem=ultra_simple_rel (median) momfirstced (median) first_raceth, by(SSUID EPPPNUM SWAVE)

sort first_raceth

by first_raceth: sum hhmem

sort momfirstced
by momfirstced: sum hhmem






		 


