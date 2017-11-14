*** We are computing relationships we can deduce directly from
* EPNMOM, EPNDAD, and ERRP.

* We compute bidirectional relationships.  If A is related to B
* we will end up with two records, one A --> B and the other B --> A.

* To avoid problems with observations that can generate more than
* one relationship (e.g., the reference person is likely to be
* related to multiple people) we compute each realtionship into
* its own temporary dataset and append them all together.


use "$tempdir/allwaves"

* Record mom/child relationships.
* Ignore if they claim to be their own mom.
preserve
gen relfrom = EPPPNUM if ((!missing(EPNMOM)) & (EPNMOM != 9999))
gen relto = EPNMOM if ((!missing(EPNMOM)) & (EPNMOM != 9999))
gen relationship = "CHILD" if ((!missing(EPNMOM)) & (EPNMOM != 9999))
* Ignore people who report themselves as their own parent.
replace relationship = "" if ((EPNMOM == EPPPNUM) | (EPNDAD == EPPPNUM))
keep SSUID SHHADID SWAVE relfrom relto relationship
drop if missing(relationship)
tempfile child_of_mom
save `child_of_mom'

* The other half of mom/child relationships.
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

* Dad/child.
restore
preserve
gen relfrom = EPPPNUM if ((!missing(EPNDAD)) & (EPNDAD != 9999))
gen relto = EPNDAD if ((!missing(EPNDAD)) & (EPNDAD != 9999))
gen relationship = "CHILD" if ((!missing(EPNDAD)) & (EPNDAD != 9999))
replace relationship = "" if ((EPNMOM == EPPPNUM) | (EPNDAD == EPPPNUM))
keep SSUID SHHADID SWAVE relfrom relto relationship
drop if missing(relationship)
tempfile child_of_dad
save `child_of_dad'

* The other half of dad/child.
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

* Merge in a variable indicating the reference person for the household.
restore
merge m:1 SSUID SHHADID SWAVE using "$tempdir/ref_person_long"
assert missing(ref_person) if (_merge == 2)
drop if (_merge == 2)
assert (_merge == 3)
drop _merge

* Spouse of reference person.
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

* The other half of spouse.
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

* Child of reference person.  You'd expect EPNMOM/DAD to capture this, too.
restore
preserve
gen relfrom = EPPPNUM if (ERRP == 4)
gen relto = ref_person if (ERRP == 4)
gen relationship = "CHILD" if (ERRP == 4)
keep SSUID SHHADID SWAVE relfrom relto relationship
drop if missing(relationship)
tempfile errp_child1
save `errp_child1'

* The other half of child of reference.
restore
preserve
gen relfrom = ref_person if (ERRP == 4)
gen relto = EPPPNUM if (ERRP == 4)
gen relationship = "PARENT" if (ERRP == 4)
keep SSUID SHHADID SWAVE relfrom relto relationship
drop if missing(relationship)
tempfile errp_child2
save `errp_child2'

* Grandchild of reference person.
restore
preserve
gen relfrom = EPPPNUM if (ERRP == 5)
gen relto = ref_person if (ERRP == 5)
gen relationship = "GRANDCHILD" if (ERRP == 5)
keep SSUID SHHADID SWAVE relfrom relto relationship
drop if missing(relationship)
tempfile errp_grandchild1
save `errp_grandchild1'

* The other half of grandchild.
restore
preserve
gen relfrom = ref_person if (ERRP == 5)
gen relto = EPPPNUM if (ERRP == 5)
gen relationship = "GRANDPARENT" if (ERRP == 5)
keep SSUID SHHADID SWAVE relfrom relto relationship
drop if missing(relationship)
tempfile errp_grandchild2
save `errp_grandchild2'

* Parent of reference person.
restore
preserve
gen relfrom = EPPPNUM if (ERRP == 6)
gen relto = ref_person if (ERRP == 6)
gen relationship = "PARENT" if (ERRP == 6)
keep SSUID SHHADID SWAVE relfrom relto relationship
drop if missing(relationship)
tempfile errp_parent1
save `errp_parent1'

* The other half of parent of reference person.
restore
preserve
gen relfrom = ref_person if (ERRP == 6)
gen relto = EPPPNUM if (ERRP == 6)
gen relationship = "CHILD" if (ERRP == 6)
keep SSUID SHHADID SWAVE relfrom relto relationship
drop if missing(relationship)
tempfile errp_parent2
save `errp_parent2'

* Sibling of reference person.
restore
preserve
gen relfrom = EPPPNUM if (ERRP == 7)
gen relto = ref_person if (ERRP == 7)
gen relationship = "SIBLING" if (ERRP == 7)
keep SSUID SHHADID SWAVE relfrom relto relationship
drop if missing(relationship)
tempfile errp_sibling1
save `errp_sibling1'

* The other half of sibling.
restore
preserve
gen relfrom = ref_person if (ERRP == 7)
gen relto = EPPPNUM if (ERRP == 7)
gen relationship = "SIBLING" if (ERRP == 7)
keep SSUID SHHADID SWAVE relfrom relto relationship
drop if missing(relationship)
tempfile errp_sibling2
save `errp_sibling2'

* Other relative.
restore
preserve
gen relfrom = EPPPNUM if (ERRP == 8)
gen relto = ref_person if (ERRP == 8)
gen relationship = "OTHER_REL" if (ERRP == 8)
keep SSUID SHHADID SWAVE relfrom relto relationship
drop if missing(relationship)
tempfile errp_otherrel1
save `errp_otherrel1'

* Second half of other relative.
restore
preserve
gen relfrom = ref_person if (ERRP == 8)
gen relto = EPPPNUM if (ERRP == 8)
gen relationship = "OTHER_REL" if (ERRP == 8)
keep SSUID SHHADID SWAVE relfrom relto relationship
drop if missing(relationship)
tempfile errp_otherrel2
save `errp_otherrel2'

* Foster child.
restore
preserve
gen relfrom = EPPPNUM if (ERRP == 9)
gen relto = ref_person if (ERRP == 9)
gen relationship = "F_CHILD" if (ERRP == 9)
keep SSUID SHHADID SWAVE relfrom relto relationship
drop if missing(relationship)
tempfile errp_fosterchild1
save `errp_fosterchild1'

* Other half of foster child.
restore
preserve
gen relfrom = ref_person if (ERRP == 9)
gen relto = EPPPNUM if (ERRP == 9)
gen relationship = "F_PARENT" if (ERRP == 9)
keep SSUID SHHADID SWAVE relfrom relto relationship
drop if missing(relationship)
tempfile errp_fosterchild2
save `errp_fosterchild2'

* Partner of reference person.
restore
preserve
gen relfrom = EPPPNUM if (ERRP == 10)
gen relto = ref_person if (ERRP == 10)
gen relationship = "PARTNER" if (ERRP == 10)
keep SSUID SHHADID SWAVE relfrom relto relationship
drop if missing(relationship)
tempfile errp_partner1
save `errp_partner1'

* Other half of partner.
restore
preserve
gen relfrom = ref_person if (ERRP == 10)
gen relto = EPPPNUM if (ERRP == 10)
gen relationship = "PARTNER" if (ERRP == 10)
keep SSUID SHHADID SWAVE relfrom relto relationship
drop if missing(relationship)
tempfile errp_partner2
save `errp_partner2'

* No relation.
restore
preserve
gen relfrom = EPPPNUM if (ERRP == 11) | (ERRP == 12) | (ERRP == 13)
gen relto = ref_person if (ERRP == 11) | (ERRP == 12) | (ERRP == 13)
gen relationship = "NOREL" if (ERRP == 11) | (ERRP == 12) | (ERRP == 13)
keep SSUID SHHADID SWAVE relfrom relto relationship
drop if missing(relationship)
tempfile errp_norelation1
save `errp_norelation1'

* Second part of no relation.
restore
gen relfrom = ref_person if (ERRP == 11) | (ERRP == 12) | (ERRP == 13)
gen relto = EPPPNUM if (ERRP == 11) | (ERRP == 12) | (ERRP == 13)
gen relationship = "NOREL" if (ERRP == 11) | (ERRP == 12) | (ERRP == 13)
keep SSUID SHHADID SWAVE relfrom relto relationship
drop if missing(relationship)
tempfile errp_norelation2
save `errp_norelation2'


* Jam them all together
use `child_of_mom'
append using `mom'
append using `child_of_dad'
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

save "$tempdir/relationships_tc0", $replace


* Now deal with cases in which we derive more than one relationship
* between the same pair of people.
sort SSUID SHHADID SWAVE relfrom relto
by SSUID SHHADID SWAVE relfrom relto:  gen numrels = _N
tab numrels

* List those with more than one relationship.
keep if numrels > 1
list
preserve

* To get a better idea what's going on, merge in 
* EPNMOM, EPNDAD, and ERRP so we can list those for
* the problem cases.
keep SSUID SHHADID SWAVE
duplicates drop
merge 1:m SSUID SHHADID SWAVE using "$tempdir/allwaves"
assert _merge != 1
keep if _merge == 3
drop _merge
sort SSUID SHHADID SWAVE EPPPNUM EPNMOM EPNDAD ERRP
list SSUID SHHADID SWAVE EPPPNUM EPNMOM EPNDAD ERRP


* Now collapse the two observations with
* different relationships into a single observation that has both
* so we can produce a table (and list them).
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
use "$tempdir/relationships_tc0"
sort SSUID SHHADID SWAVE relfrom relto
by SSUID SHHADID SWAVE relfrom relto:  gen numrels = _N
tab numrels
drop if ((numrels > 1) & (relationship == "OTHER_REL"))
drop numrels

* Replacing because we're doing successive refinement, with tabs 
* and lists above to review the dropped data.
save, replace


* After that bit of cleanup let's see what's left,
* pretty much as we did before.
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
* We keep the spouse relationship and drop the other.
clear
use "$tempdir/relationships_tc0"

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

* Again, we're hard-coding replace because we are doing
* successive refinement.
save, replace


* Confirm we have no conflicting relationships remaining.
sort SSUID SHHADID SWAVE relfrom relto
by SSUID SHHADID SWAVE relfrom relto:  gen numrels = _N
tab numrels
summ numrels, detail
assert (`r(max)' == 1)
drop numrels

clear
