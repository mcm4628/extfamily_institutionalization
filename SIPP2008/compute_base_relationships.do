*** TODO:  Document what we're doing here.


use "$tempdir/allwaves"

preserve
gen relfrom = EPPPNUM if ((!missing(EPNMOM)) & (EPNMOM != 9999))
gen relto = EPNMOM if ((!missing(EPNMOM)) & (EPNMOM != 9999))
gen relationship = "CHILD" if ((!missing(EPNMOM)) & (EPNMOM != 9999))
* Ignore people who report themselves as their own parent.
replace relationship = "" if ((EPNMOM == EPPPNUM) | (EPNDAD == EPPPNUM))
keep SSUID SHHADID SWAVE relfrom relto relationship
drop if missing(relationship)
tempfile momchild
save `momchild'

restore
preserve
gen relfrom = EPNMOM if ((!missing(EPNMOM)) & (EPNMOM != 9999))
gen relto = EPPPNUM if ((!missing(EPNMOM)) & (EPNMOM != 9999))
gen relationship = "PARENT" if ((!missing(EPNMOM)) & (EPNMOM != 9999))
replace relationship = "" if ((EPNMOM == EPPPNUM) | (EPNDAD == EPPPNUM))
keep SSUID SHHADID SWAVE relfrom relto relationship
drop if missing(relationship)
tempfile mom
save `mom'

restore
preserve
gen relfrom = EPPPNUM if ((!missing(EPNDAD)) & (EPNDAD != 9999))
gen relto = EPNDAD if ((!missing(EPNDAD)) & (EPNDAD != 9999))
gen relationship = "CHILD" if ((!missing(EPNDAD)) & (EPNDAD != 9999))
replace relationship = "" if ((EPNMOM == EPPPNUM) | (EPNDAD == EPPPNUM))
keep SSUID SHHADID SWAVE relfrom relto relationship
drop if missing(relationship)
tempfile dadchild
save `dadchild'

restore
preserve
gen relfrom = EPNDAD if ((!missing(EPNDAD)) & (EPNDAD != 9999))
gen relto = EPPPNUM if ((!missing(EPNDAD)) & (EPNDAD != 9999))
gen relationship = "PARENT" if ((!missing(EPNDAD)) & (EPNDAD != 9999))
replace relationship = "" if ((EPNMOM == EPPPNUM) | (EPNDAD == EPPPNUM))
keep SSUID SHHADID SWAVE relfrom relto relationship
drop if missing(relationship)
tempfile dad
save `dad'

restore
merge m:1 SSUID SHHADID SWAVE using "$tempdir/ref_person_long"
assert missing(ref_person) if (_merge == 2)
drop if (_merge == 2)
assert (_merge == 3)
drop _merge

preserve
gen relfrom = EPPPNUM if (ERRP == 3)
gen relto = ref_person if (ERRP == 3)
gen relationship = "SPOUSE" if (ERRP == 3)
* Ignore the spouse claim of people who claim to be a spouse and a child of the ref person.
replace relationship = "" if ((EPNMOM == ref_person) | (EPNDAD == ref_person))
keep SSUID SHHADID SWAVE relfrom relto relationship
drop if missing(relationship)
tempfile errp_spouse1
save `errp_spouse1'

restore
preserve
gen relfrom = ref_person if (ERRP == 3)
gen relto = EPPPNUM if (ERRP == 3)
gen relationship = "SPOUSE" if (ERRP == 3)
* Ignore the spouse claim of people who claim to be a spouse and a child of the ref person.
replace relationship = "" if ((EPNMOM == ref_person) | (EPNDAD == ref_person))
keep SSUID SHHADID SWAVE relfrom relto relationship
drop if missing(relationship)
tempfile errp_spouse2
save `errp_spouse2'

restore
preserve
gen relfrom = EPPPNUM if (ERRP == 4)
gen relto = ref_person if (ERRP == 4)
gen relationship = "CHILD" if (ERRP == 4)
keep SSUID SHHADID SWAVE relfrom relto relationship
drop if missing(relationship)
tempfile errp_child1
save `errp_child1'

restore
preserve
gen relfrom = ref_person if (ERRP == 4)
gen relto = EPPPNUM if (ERRP == 4)
gen relationship = "PARENT" if (ERRP == 4)
keep SSUID SHHADID SWAVE relfrom relto relationship
drop if missing(relationship)
tempfile errp_child2
save `errp_child2'

restore
preserve
gen relfrom = EPPPNUM if (ERRP == 5)
gen relto = ref_person if (ERRP == 5)
gen relationship = "GRANDCHILD" if (ERRP == 5)
keep SSUID SHHADID SWAVE relfrom relto relationship
drop if missing(relationship)
tempfile errp_grandchild1
save `errp_grandchild1'

restore
preserve
gen relfrom = ref_person if (ERRP == 5)
gen relto = EPPPNUM if (ERRP == 5)
gen relationship = "GRANDPARENT" if (ERRP == 5)
keep SSUID SHHADID SWAVE relfrom relto relationship
drop if missing(relationship)
tempfile errp_grandchild2
save `errp_grandchild2'

restore
preserve
gen relfrom = EPPPNUM if (ERRP == 6)
gen relto = ref_person if (ERRP == 6)
gen relationship = "PARENT" if (ERRP == 6)
keep SSUID SHHADID SWAVE relfrom relto relationship
drop if missing(relationship)
tempfile errp_parent1
save `errp_parent1'

restore
preserve
gen relfrom = ref_person if (ERRP == 6)
gen relto = EPPPNUM if (ERRP == 6)
gen relationship = "CHILD" if (ERRP == 6)
keep SSUID SHHADID SWAVE relfrom relto relationship
drop if missing(relationship)
tempfile errp_parent2
save `errp_parent2'

restore
preserve
gen relfrom = EPPPNUM if (ERRP == 7)
gen relto = ref_person if (ERRP == 7)
gen relationship = "SIBLING" if (ERRP == 7)
keep SSUID SHHADID SWAVE relfrom relto relationship
drop if missing(relationship)
tempfile errp_sibling1
save `errp_sibling1'

restore
preserve
gen relfrom = ref_person if (ERRP == 7)
gen relto = EPPPNUM if (ERRP == 7)
gen relationship = "SIBLING" if (ERRP == 7)
keep SSUID SHHADID SWAVE relfrom relto relationship
drop if missing(relationship)
tempfile errp_sibling2
save `errp_sibling2'

restore
preserve
gen relfrom = EPPPNUM if (ERRP == 8)
gen relto = ref_person if (ERRP == 8)
gen relationship = "OTHER_REL" if (ERRP == 8)
keep SSUID SHHADID SWAVE relfrom relto relationship
drop if missing(relationship)
tempfile errp_otherrel1
save `errp_otherrel1'

restore
preserve
gen relfrom = ref_person if (ERRP == 8)
gen relto = EPPPNUM if (ERRP == 8)
gen relationship = "OTHER_REL" if (ERRP == 8)
keep SSUID SHHADID SWAVE relfrom relto relationship
drop if missing(relationship)
tempfile errp_otherrel2
save `errp_otherrel2'

restore
preserve
gen relfrom = EPPPNUM if (ERRP == 9)
gen relto = ref_person if (ERRP == 9)
gen relationship = "F_CHILD" if (ERRP == 9)
keep SSUID SHHADID SWAVE relfrom relto relationship
drop if missing(relationship)
tempfile errp_fosterchild1
save `errp_fosterchild1'

restore
preserve
gen relfrom = ref_person if (ERRP == 9)
gen relto = EPPPNUM if (ERRP == 9)
gen relationship = "F_PARENT" if (ERRP == 9)
keep SSUID SHHADID SWAVE relfrom relto relationship
drop if missing(relationship)
tempfile errp_fosterchild2
save `errp_fosterchild2'

restore
preserve
gen relfrom = EPPPNUM if (ERRP == 10)
gen relto = ref_person if (ERRP == 10)
gen relationship = "PARTNER" if (ERRP == 10)
keep SSUID SHHADID SWAVE relfrom relto relationship
drop if missing(relationship)
tempfile errp_partner1
save `errp_partner1'

restore
preserve
gen relfrom = ref_person if (ERRP == 10)
gen relto = EPPPNUM if (ERRP == 10)
gen relationship = "PARTNER" if (ERRP == 10)
keep SSUID SHHADID SWAVE relfrom relto relationship
drop if missing(relationship)
tempfile errp_partner2
save `errp_partner2'

restore
preserve
gen relfrom = EPPPNUM if (ERRP == 11) | (ERRP == 12) | (ERRP == 13)
gen relto = ref_person if (ERRP == 11) | (ERRP == 12) | (ERRP == 13)
gen relationship = "NOREL" if (ERRP == 11) | (ERRP == 12) | (ERRP == 13)
keep SSUID SHHADID SWAVE relfrom relto relationship
drop if missing(relationship)
tempfile errp_norelation1
save `errp_norelation1'

restore
gen relfrom = ref_person if (ERRP == 11) | (ERRP == 12) | (ERRP == 13)
gen relto = EPPPNUM if (ERRP == 11) | (ERRP == 12) | (ERRP == 13)
gen relationship = "NOREL" if (ERRP == 11) | (ERRP == 12) | (ERRP == 13)
keep SSUID SHHADID SWAVE relfrom relto relationship
drop if missing(relationship)
tempfile errp_norelation2
save `errp_norelation2'

use `momchild'
append using `mom'
append using `dadchild'
append using `dad'
append using `errp_spouse1'
append using `errp_spouse2'
append using `errp_child1'
append using `errp_child2'
append using `errp_grandchild1'
append using `errp_grandchild2'
append using `errp_parent1'
append using `errp_parent2'
append using `errp_sibling1'
append using `errp_sibling2'
append using `errp_otherrel1'
append using `errp_otherrel2'
append using `errp_fosterchild1'
append using `errp_fosterchild2'
append using `errp_partner1'
append using `errp_partner2'
append using `errp_norelation1'
append using `errp_norelation2'

duplicates drop

save "$tempdir/base_relationships", $replace

sort SSUID SHHADID SWAVE relfrom relto
by SSUID SHHADID SWAVE relfrom relto:  gen numrels = _N
tab numrels

keep if numrels > 1
list
preserve

keep SSUID SHHADID SWAVE
duplicates drop
merge 1:m SSUID SHHADID SWAVE using "$tempdir/allwaves"
assert _merge != 1
keep if _merge == 3
drop _merge
sort SSUID SHHADID SWAVE EPPPNUM EPNMOM EPNDAD ERRP
list SSUID SHHADID SWAVE EPPPNUM EPNMOM EPNDAD ERRP

restore
by SSUID SHHADID SWAVE relfrom relto:  gen n = _n
gen rel1 = relationship if n == 1
gen rel2 = relationship if n == 2
collapse (firstnm) rel1 rel2, by(SSUID SHHADID SWAVE relfrom relto)
tab rel1 rel2
list


* We'll just drop "other relative" when we have two different relationships,
* believing that the other report is more likely accurate.
clear
use "$tempdir/base_relationships"
sort SSUID SHHADID SWAVE relfrom relto
by SSUID SHHADID SWAVE relfrom relto:  gen numrels = _N
tab numrels
drop if ((numrels > 1) & (relationship == "OTHER_REL"))
drop numrels
* Replacing because we're doing successive refinement, with tabs 
* and lists above to review the dropped data.
save, replace

sort SSUID SHHADID SWAVE relfrom relto
by SSUID SHHADID SWAVE relfrom relto:  gen numrels = _N
tab numrels

keep if numrels > 1
list
preserve

keep SSUID SHHADID SWAVE
duplicates drop
merge 1:m SSUID SHHADID SWAVE using "$tempdir/allwaves"
assert _merge != 1
keep if _merge == 3
drop _merge
sort SSUID SHHADID SWAVE EPPPNUM EPNMOM EPNDAD ERRP
list SSUID SHHADID SWAVE EPPPNUM EPNMOM EPNDAD ERRP

restore
by SSUID SHHADID SWAVE relfrom relto:  gen n = _n
gen rel1 = relationship if n == 1
gen rel2 = relationship if n == 2
collapse (firstnm) rel1 rel2, by(SSUID SHHADID SWAVE relfrom relto)
tab rel1 rel2
list


* This is nasty.  It looks like the remaining crap is spouses
* who claim one of their parents is someone who is actually one of
* their children.
clear
use "$tempdir/base_relationships"

sort SSUID SHHADID SWAVE relfrom relto
by SSUID SHHADID SWAVE relfrom relto:  gen numrels = _N
tab numrels

gen EPPPNUM = relfrom
merge m:1 SSUID SWAVE EPPPNUM using "$tempdir/allwaves", keepusing(ERRP)
assert _merge != 1
drop if _merge == 2
drop _merge
drop EPPPNUM
drop if ((numrels > 1) & (ERRP == 3) & (relationship == "CHILD"))
drop if ((numrels > 1) & (ERRP != 3) & (relationship == "PARENT"))
drop numrels
drop ERRP
save, replace

sort SSUID SHHADID SWAVE relfrom relto
by SSUID SHHADID SWAVE relfrom relto:  gen numrels = _N
tab numrels
summ numrels, detail
assert (`r(max)' == 1)
drop numrels

clear
