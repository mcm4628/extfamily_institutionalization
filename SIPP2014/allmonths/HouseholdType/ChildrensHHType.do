* This file has one record per coresident other per person per month
* One needs to collapse by SSUID EPPPNUM panelmonth to get to person-months

* Run do_all_months (or at least project_macros) before executing this file

use "$SIPP14keep/HHComp_asis", clear

keep if adj_age < 18

tab relationship

* Create simplified/aggregated indicators for comparison to Pilkauskas & Cross

Note that this code is not correct. Unlike earlier waves of SIPP, we did not need to create relationship variables, they
were already available in the RREL variables on the file. This code uses the relationship codes we created for earlier versions of the SIPP, but
they do not apply to SIPP 2014. Do a fre on relationship to see what codes correspond to bioparent (3) etc. 

gen bioparent=1 if relationship==1
gen parent=1 if inlist(relationship,1,4,7,19,21)
gen sibling=1 if inlist(relationship, 17)
gen child=1 if inlist(relationship,2,3,5,6,8,9,10,11,22,23)
gen spartner=1 if inlist(relationship,12,18)
gen nonrel=1 if inlist(relationship,20,22,34,37,38,40)
gen grandparent=1 if inlist(relationship,13,14,27)
gen auntuncle=1 if inlist(relationship,29,30)
gen other_rel=1 if inlist(relationship, 15,16,24,25,26,28,31,33,32,35,36) //not parents, siblings, children, spouses, aunt/uncle, or grandparents
gen unknown=1 if relationship==40 | missing(relationship)
gen nonnuke=1 if nonrel==1 | grandparent==1 | other_rel==1 | unknown==1 
gen allelse=1 if inlist(relationship,2,3,5,6,8,9,10,11,23,12,18) // children, spouses
gen allrel=1 if !missing(relationship)
gen all=1

gen extended_kin=1 if grandparent==1 | other_rel==1

local rellist "bioparent parent sibling  child spartner nonrel grandparent auntuncle other_rel extended_kin unknown nonnuke allrel all"

*rename from_num PNUM
*rename to_num relto

// convert the file to individuals from coresident others

collapse (count) `rellist' (max) to_age, by (SSUID PNUM panelmonth) fast

rename to_age hhmaxage

recode hhmaxage (14/17=1)(18/49=2)(5/64=3)(65/74=4)(75/90=5), gen(chhmaxage)
if hhmaxage < 14 then chhmaxage==2

merge 1:1 SSUID PNUM panelmonth using "$SIPP14keep/demo_long_interviews_am.dta", ///
keepusing(WPFINWGT my_racealt adj_age my_sex biomom_ed_first par_ed_first ///
mom_measure mom_age)

keep if _merge==3

drop _merge

gen weight=int(WPFINWGT*10000)

recode nonnuke (0=0)(1/20=1), gen(anynonuke)
recode nonrel (0=0)(1/20=1), gen(anynonrel)
recode grandparent (0=0)(1/20=1), gen(anygp)
recode auntuncle (0=0)(1/20=1), gen(anyauntuncle)
recode other_rel (0=0)(1/20=1), gen(anyother)
recode extended_kin (0=0)(1/20=1), gen(anyextended)
recode unknown (0=0)(1/20=1), gen(anyunknown)

label variable anynonuke "non-nuclear kin or non-relative"
label variable anynonrel "non-relative"
label variable anygp "grandparent"
label variable anyauntuncle "aunt/uncle"
label variable anyother "non-nuclear non-grandparent non-aunt/uncle kin"
label variable anyunknown "unknown relation"
label variable anyextended "any extended kin"

rename all hhsize
rename nonnuke nnsize

label variable hhsize "number of people in the household"
label variable nnsize "number of nonnuclear people in household"

#delimit ;
label define yesno  0 "no"
                    1 "yes";
#delimit cr 

local anyrel "anygp anyauntuncle anyother anynonrel"

label variable my_racealt "Race-Ethnicity"

foreach v in `anyrel'{
	label values `v' yesno
}

local t2rel "anyt2gp anyt2au anyt2or anyt2nr"

foreach v in `t2rel'{
	label values `v' yesno
}

save "$tempdir/relationships14.dta", replace
