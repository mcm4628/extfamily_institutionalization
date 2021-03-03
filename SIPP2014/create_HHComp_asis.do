* Create a data file with one record for each coresident pair in each wave
* Merge onto the file the relationships data created by unify_relationships.


****************************************************************************
* create database with all pairs of coresident individuals in each wave
****************************************************************************
use "$SIPP14keep/allmonths14"

keep SSUID ERESIDENCEID PNUM panelmonth ERELRP

sort SSUID ERESIDENCEID panelmonth

by SSUID ERESIDENCEID panelmonth:  gen HHmembers = _N  /* Number the people in the household in each wave. */

* merge in age of other person in the household to save as "to_age"
merge 1:1 SSUID PNUM panelmonth using "$SIPP14keep/demo_long_interviews_am.dta", keepusing(adj_age my_sex)

assert _merge==3

drop _merge

rename PNUM to_num
rename ERELRP ERRPto
rename adj_age to_age
rename my_sex to_sex

save "$tempdir/to", $replace

use "$SIPP14keep/allmonths14"

keep SSUID ERESIDENCEID PNUM panelmonth ERELRP

sort SSUID ERESIDENCEID panelmonth

by SSUID ERESIDENCEID panelmonth:  gen HHmembers = _N  /* Number the people in the household in each wave. */

* merge in age of other person in the household to save as "to_age"
merge 1:1 SSUID PNUM panelmonth using "$SIPP14keep/demo_long_interviews_am.dta", keepusing(adj_age my_sex)

assert _merge==3

drop _merge

rename PNUM to_num
rename ERELRP ERRPto
rename adj_age to_age
rename my_sex to_sex

save "$tempdir/to", $replace

use "$SIPP14keep/allmonths14", clear

keep SSUID ERESIDENCEID PNUM panelmonth ERELRP

rename PNUM from_num
rename ERELRP ERRPfrom

joinby SSUID ERESIDENCEID panelmonth using "$tempdir/to"  

* drop pairs of ego to self
drop if to_num==from_num

save "$SIPP14keep/pairwise_bymonth", $replace

* relationship pairs bymonth is created by compute_relationships.do
merge m:1 SSUID from_num to_num panelmonth using "$SIPP14keep/relationship_pairs_bymonth"

replace relationship = .a if (_merge == 1) & (missing(relationship))
replace relationship = .m if (_merge == 3) & (missing(relationship))

gen err=1 if relationship==.
egen errors=count(err)

assert (errors < 100)
drop _merge err errors

tab relationship, m

rename from_num PNUM
rename to_num to_PNUM

merge m:1 SSUID PNUM panelmonth using "$SIPP14keep/demo_long_interviews_am.dta"

drop if _merge==2

drop _merge

tab relationship, m 

do "$sipp2014_code/simple_rel_label"

save "$SIPP14keep/HHComp_asis_am.dta", $replace

gen bioparent=1 if relationship==3
gen parent=1 if inlist(relationship, 3, 5, 7)
gen stepparent=1 if relationship==5

gen sibling=1 if inlist(relationship, 11,12,13,14,15)
gen stphlfsib=1 if inlist(relationship, 12, 13)
gen adpothsib=1 if inlist(relationship,14,15)

gen anyext=1 if inlist(relationship, 9, 10, 16, 17, 18, 20)
gen ngpext=1 if inlist(relationship, 16, 17, 18, 20)

gen foster=1 if relationship==19

gen anyspouse=1 if relationship==1
gen anypartner=1 if relationship==2

collapse (count) bioparent parent stepparent sibling stphlfsib adpothsib anyext ngpext foster anyspouse anypartner, by(SSUID PNUM panelmonth)

save "$tempdir/comp.dta", replace

merge 1:1 SSUID PNUM panelmonth using "$SIPP14keep/demo_long_interviews_am.dta"

assert _merge !=1
* Note that people who are living alone are not in master datafile

drop _merge

gen parcomp=1 if bioparent==2
replace parcomp=2 if parent==1
replace parcomp=3 if stepparent > 0
replace parcomp=4 if parent==0

gen sibcomp=0 if sibling==0
replace sibcomp=1 if sibling > 0 & stphlfsib==0
replace sibcomp=2 if stphlfsib > 0

gen extend=0 if anyext==0
replace extend=1 if anyext > 0 & ngpext==0
replace extend=2 if ngpext > 0

label define parcomp 1 "2 bioparents" 2 "single parent" 3 "step parent" 4 "no parent"
label define sibcomp 0 "no siblings" 1 "only biosibs" 2 "step/half sibs"
label define extend 0 "nuclear" 1 "grandparent" 2 "horizontal extension"

label values parcomp parcomp
label values sibcomp sibcomp
label values extend extend

gen marcohstat=2 if anypartner > 0
replace marcohstat=1 if anyspouse > 0
replace marcohstat=0 if missing(marcohstat)

* one record per person
save "$SIPP14keep/HHComp_pm.dta", $replace


