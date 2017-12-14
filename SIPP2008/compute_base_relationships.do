*** We are computing relationships we can deduce directly from
* EPNMOM, EPNDAD, and ERRP.

* We compute bidirectional relationships.  If A is related to B
* we will end up with two records, one A --> B and the other B --> A.

* To avoid problems with observations that can generate more than
* one relationship (e.g., the reference person is likely to be
* related to multiple people) we compute each relationship into
* its own temporary dataset and append them all together.


* This program is an attempt to encapsulate computation of relationships
* because too much code was being repeated.
* It assumes that there is a single condition defining the relationship,
* and that the relationship is bidirectional (e.g., if A-->B is MOM then
* B-->A is always CHILD.
* It assumes there is at most one other condition that invalidates the
* relationship.  Just pass a 0 for this condition if there are no such
* invalid conditions.
capture program drop compute_relationships
program define compute_relationships
    args person1 person2 relationship_1_2 relationship_2_1 condition false_condition filename_1_2 filename_2_1

    preserve
    gen relfrom = `person1' if `condition'
    gen relto = `person2' if `condition'
    gen relationship = "`relationship_1_2'" if `condition'
    replace relationship = "" if `false_condition'
    tab relationship SWAVE
    keep SSUID SHHADID SWAVE relfrom relto relationship
    drop if missing(relationship)
    save "$tempdir/`filename_1_2'", $replace
    restore

    preserve
    gen relfrom = `person2' if `condition'
    gen relto = `person1' if `condition'
    gen relationship = "`relationship_2_1'" if `condition'
    replace relationship = "" if `false_condition'
    tab relationship SWAVE
    keep SSUID SHHADID SWAVE relfrom relto relationship
    drop if missing(relationship)
    save "$tempdir/`filename_2_1'", $replace
    restore
end


use "$tempdir/allwaves"

* Compute parent/child relationships from EPNMOM and EPNDAD but ignore people who claim they are their own children.
compute_relationships EPPPNUM EPNMOM CHILD PARENT "((!missing(EPNMOM)) & (EPNMOM != 9999))" "((EPNMOM == EPPPNUM) | (EPNDAD == EPPPNUM))" child_of_mom mom
compute_relationships EPPPNUM EPNDAD CHILD PARENT "((!missing(EPNDAD)) & (EPNDAD != 9999))" "((EPNMOM == EPPPNUM) | (EPNDAD == EPPPNUM))" child_of_dad dad

* Merge in a variable indicating the reference person for the household.
merge m:1 SSUID SHHADID SWAVE using "$tempdir/ref_person_long"
assert missing(ref_person) if (_merge == 2)
drop if (_merge == 2)
assert (_merge == 3)
drop _merge

* Spouse of reference person.  Ignore people who also claim to be a child of the reference person.
compute_relationships EPPPNUM ref_person SPOUSE SPOUSE "(ERRP == 3)" "((EPNMOM == ref_person) | (EPNDAD == ref_person))" errp_spouse1 errp_spouse2

* Child of reference person.  You'd expect EPNMOM/DAD to capture this, too.
compute_relationships EPPPNUM ref_person CHILD PARENT "(ERRP == 4)" 0 errp_child1 errp_child2

* Grandchild of reference person.
compute_relationships EPPPNUM ref_person GRANDCHILD GRANDPARENT "(ERRP == 5)" 0 errp_grandchild1 errp_grandchild2

* Parent of reference person.
compute_relationships EPPPNUM ref_person PARENT CHILD "(ERRP == 6)" 0 errp_parent1 errp_parent2

* Sibling of reference person.
compute_relationships EPPPNUM ref_person SIBLING SIBLING "(ERRP == 7)" 0 errp_sibling1 errp_sibling2

* Other relative.
compute_relationships EPPPNUM ref_person OTHER_REL OTHER_REL "(ERRP == 8)" 0 errp_otherrel1 errp_otherrel2

* Foster child.
compute_relationships EPPPNUM ref_person F_CHILD F_PARENT "(ERRP == 9)" 0 errp_fosterchild1 errp_fosterchild2

* Partner of reference person.
compute_relationships EPPPNUM ref_person PARTNER PARTNER "(ERRP == 10)" 0 errp_partner1 errp_partner2

* No relation.
compute_relationships EPPPNUM ref_person NOREL NOREL "((ERRP == 11) | (ERRP == 12) | (ERRP == 13))" 0 errp_norelation1 errp_norelation2


* Spouse from EPNSPOUS
compute_relationships EPPPNUM EPNSPOUS SPOUSE SPOUSE "(EPNSPOUS != 9999)" 0 epnspous1 epnspous2


clear

* Jam them all together
use "$tempdir/child_of_mom"
append using "$tempdir/mom"
append using "$tempdir/child_of_dad"
append using "$tempdir/dad"
append using "$tempdir/errp_spouse1"
append using "$tempdir/errp_spouse2"
append using "$tempdir/errp_child1"
append using "$tempdir/errp_child2"
append using "$tempdir/errp_grandchild1"
append using "$tempdir/errp_grandchild2"
append using "$tempdir/errp_parent1"
append using "$tempdir/errp_parent2"
append using "$tempdir/errp_sibling1"
append using "$tempdir/errp_sibling2"
append using "$tempdir/errp_otherrel1"
append using "$tempdir/errp_otherrel2"
append using "$tempdir/errp_fosterchild1"
append using "$tempdir/errp_fosterchild2"
append using "$tempdir/errp_partner1"
append using "$tempdir/errp_partner2"
append using "$tempdir/errp_norelation1"
append using "$tempdir/errp_norelation2"
append using "$tempdir/epnspous1"
append using "$tempdir/epnspous2"

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
assert n <= 2
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
gen relationship_source = 0
save, replace


* Confirm we have no conflicting relationships remaining.
sort SSUID SHHADID SWAVE relfrom relto
by SSUID SHHADID SWAVE relfrom relto:  gen numrels = _N
tab numrels
summ numrels, detail
assert (`r(max)' == 1)
drop numrels

clear
