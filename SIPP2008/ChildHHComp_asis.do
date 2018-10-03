* For Table 1 of HHstability paper
* Run do_childrens_household_core (or at least project_macros) before executing.

use "$tempdir/HHComp_asis", clear

keep if adj_age < $adult_age

tab relationship [aweight=WPFINWGT]

gen bioparent=1 if relationship==1
gen parent=1 if inlist(relationship,1,4,7,19,20,21,30,31,38)
gen sibling=1 if inlist(relationship, 17,33,34)
gen child=1 if inlist(relationship,2,3,5,6,8,9,10,11,22,23,25,26)
gen spartner=1 if inlist(relationship,12,18)
gen nonrel=1 if relationship==37
gen grandparent=1 if inlist(relationship,13,14,27)
gen other_rel=1 if inlist(relationship, 15,16,24,28,29,32,35)
gen unknown=1 if relationship==40 | missing(relationship)
gen nonnuke=1 if nonrel==1 | grandparent==1 | other_rel==1 | unknown==1 

local rellist "bioparent parent sibling  child spartner nonrel grandparent other_rel unknown nonnuke"

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
 recode unknown (0=0)(1/20=1), gen(anyunknown)
 
local anyrel "anynonuke anynonrel anygp anyother anyunknown"

foreach v in `anyrel'{
tab `v' my_race [aw=WPFINWGT], nofreq col
}

