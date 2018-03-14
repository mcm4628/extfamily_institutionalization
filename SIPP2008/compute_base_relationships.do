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
* It refuses to compute self-relationships.
capture program drop compute_relationships
program define compute_relationships
    args person1 person2 relationship_1_2 relationship_2_1 reason condition filename_1_2 filename_2_1

    preserve
    gen relfrom = `person1' if `condition'
    gen relto = `person2' if `condition'
    gen relationship_tc0 = "`relationship_1_2'":relationship if `condition'
    label values relationship_tc0 relationship
    gen reason_tc0 = "`reason'" if `condition'
    tab relationship_tc0 SWAVE
    keep SSUID SHHADID SWAVE relfrom relto relationship_tc0 reason_tc0
    drop if missing(relationship_tc0)
    drop if (relfrom == relto)
    save "$tempdir/`filename_1_2'", $replace
    restore

    preserve
    gen relfrom = `person2' if `condition'
    gen relto = `person1' if `condition'
    gen relationship_tc0 = "`relationship_2_1'":relationship if `condition'
    label values relationship_tc0 relationship
    gen reason_tc0 = "`reason'" if `condition'
    tab relationship_tc0 SWAVE
    keep SSUID SHHADID SWAVE relfrom relto relationship_tc0 reason_tc0
    drop if missing(relationship_tc0)
    drop if (relfrom == relto)
    save "$tempdir/`filename_2_1'", $replace
    restore
end



* This program fixes up conflicting relationship pairs,
* taking the first as preferable to the second.
capture program drop fixup_rel_pair
program define fixup_rel_pair
    args preferred_rel second_rel

    display "Preferring `preferred_rel' over `second_rel'"
    
    gen meets_condition = (((relationship_tc01 == "`preferred_rel'":relationship) & (relationship_tc02 == "`second_rel'":relationship)) | ((relationship_tc02 == "`preferred_rel'":relationship) & (relationship_tc01 == "`second_rel'":relationship)))
    gen needs_swap = ((relationship_tc02 == "`preferred_rel'":relationship) & (relationship_tc01 == "`second_rel'":relationship))

    replace numrels_tc0 = 1 if (meets_condition == 1)
    replace relationship_tc01 = "`preferred_rel'":relationship if ((meets_condition == 1) & (needs_swap == 1))
    replace relationship_tc02 = . if (meets_condition == 1)
    replace reason_tc01 = reason_tc02 if ((meets_condition == 1) & (needs_swap == 1))
    replace reason_tc02 = "" if (meets_condition == 1)

    drop meets_condition needs_swap
end


use "$tempdir/allwaves"

#delimit ;
label define relationship
    1 "BIOCHILD"
    2 "BIOMOM"
    3 "BIODAD"
    4 "STEPCHILD"
    5 "STEPMOM"
    6 "STEPDAD"
    7 "ADOPTCHILD"
    8 "ADOPTMOM"
    9 "ADOPTDAD"
    10 "CHILD"
    11 "MOM"
    12 "DAD"
    13 "SPOUSE"
    14 "GRANDCHILD"
    15 "GRANDPARENT"
    16 "SIBLING"
    17 "OTHER_REL"
    18 "PARTNER"
    19 "F_CHILD"
    20 "F_PARENT"
    21 "NOREL"
    ;
#delimit cr

* Compute parent/child relationships from EPNMOM and EPNDAD.
compute_relationships EPPPNUM EPNMOM BIOCHILD BIOMOM EPNMOM "((!missing(EPNMOM)) & (EPNMOM != 9999) & (ETYPMOM == 1))" biochild_of_mom biomom
compute_relationships EPPPNUM EPNDAD BIOCHILD BIODAD EPNDAD "((!missing(EPNDAD)) & (EPNDAD != 9999) & (ETYPDAD == 1))" biochild_of_dad biodad
compute_relationships EPPPNUM EPNMOM STEPCHILD STEPMOM EPNMOM "((!missing(EPNMOM)) & (EPNMOM != 9999) & (ETYPMOM == 2))" stepchild_of_mom stepmom
compute_relationships EPPPNUM EPNDAD STEPCHILD STEPDAD EPNDAD "((!missing(EPNDAD)) & (EPNDAD != 9999) & (ETYPDAD == 2))" stepchild_of_dad stepdad
compute_relationships EPPPNUM EPNMOM ADOPTCHILD ADOPTMOM EPNMOM "((!missing(EPNMOM)) & (EPNMOM != 9999) & (ETYPMOM == 3))" adoptchild_of_mom adoptmom
compute_relationships EPPPNUM EPNDAD ADOPTCHILD ADOPTDAD EPNDAD "((!missing(EPNDAD)) & (EPNDAD != 9999) & (ETYPDAD == 3))" adoptchild_of_dad adoptdad

* Merge in a variable indicating the reference person for the household.
merge m:1 SSUID SHHADID SWAVE using "$tempdir/ref_person_long"
assert missing(ref_person) if (_merge == 2)
drop if (_merge == 2)
assert (_merge == 3)
drop _merge

*** The 1 and 2 suffixes below are convenient but not very descriptive.
* 1 means the relationship as stated; 2 means the reverse.  E.g., errp_child_of_mom2 are moms of children identified by ERRP == 4.

* Spouse of reference person.
compute_relationships EPPPNUM ref_person SPOUSE SPOUSE ERRP_3 "(ERRP == 3)" errp_spouse1 errp_spouse2

* Child of reference person.  You'd expect EPNMOM/DAD to capture this, too.
compute_relationships EPPPNUM ref_person CHILD MOM ERRP_4 "((ERRP == 4) & (ref_person_sex == 2))" errp_child_of_mom1 errp_child_of_mom2
compute_relationships EPPPNUM ref_person CHILD DAD ERRP_4 "((ERRP == 4) & (ref_person_sex == 1))" errp_child_of_dad1 errp_child_of_dad2

* Grandchild of reference person.
compute_relationships EPPPNUM ref_person GRANDCHILD GRANDPARENT ERRP_5 "(ERRP == 5)" errp_grandchild1 errp_grandchild2

* Parent of reference person.
compute_relationships EPPPNUM ref_person MOM CHILD ERRP_6 "((ERRP == 6) & (ESEX == 2))" errp_mom1 errp_mom2
compute_relationships EPPPNUM ref_person DAD CHILD ERRP_6 "((ERRP == 6) & (ESEX == 1))" errp_dad1 errp_dad2

* Sibling of reference person.
compute_relationships EPPPNUM ref_person SIBLING SIBLING ERRP_7 "(ERRP == 7)" errp_sibling1 errp_sibling2

* Other relative.
compute_relationships EPPPNUM ref_person OTHER_REL OTHER_REL ERRP_8 "(ERRP == 8)" errp_otherrel1 errp_otherrel2

* Foster child.
compute_relationships EPPPNUM ref_person F_CHILD F_PARENT ERRP_9 "(ERRP == 9)" errp_fosterchild1 errp_fosterchild2

* Partner of reference person.
compute_relationships EPPPNUM ref_person PARTNER PARTNER ERRP_10 "(ERRP == 10)" errp_partner1 errp_partner2

* No relation.
compute_relationships EPPPNUM ref_person NOREL NOREL ERRP_GE_11 "((ERRP == 11) | (ERRP == 12) | (ERRP == 13))" errp_norelation1 errp_norelation2


* Spouse from EPNSPOUS
compute_relationships EPPPNUM EPNSPOUS SPOUSE SPOUSE EPNSPOUS "(EPNSPOUS != 9999)" epnspous1 epnspous2

* TODO -- Report on anomalies that cause trouble (now or later?) -- Compute parent/child relationships from EPNMOM and EPNDAD but ignore people who claim they are their own children.
*  compute_relationships EPPPNUM EPNMOM CHILD MOM "((!missing(EPNMOM)) & (EPNMOM != 9999))" "((EPNMOM == EPPPNUM) | (EPNDAD == EPPPNUM))" child_of_mom mom
* compute_relationships EPPPNUM EPNDAD CHILD PARENT "((!missing(EPNDAD)) & (EPNDAD != 9999))" "((EPNMOM == EPPPNUM) | (EPNDAD == EPPPNUM))" child_of_dad dad
* TODO -- Report on problem people -- Spouse of reference person.  Ignore people who also claim to be a child of the reference person.
* compute_relationships EPPPNUM ref_person SPOUSE SPOUSE "(ERRP == 3)" "((EPNMOM == ref_person) | (EPNDAD == ref_person))" errp_spouse1 errp_spouse2
* TODO - Check for conflict of parent type with ERRP_4.

clear

* Jam them all together
use "$tempdir/biochild_of_mom"
append using "$tempdir/biomom"
append using "$tempdir/biochild_of_dad"
append using "$tempdir/biodad"
append using "$tempdir/stepchild_of_mom"
append using "$tempdir/stepmom"
append using "$tempdir/stepchild_of_dad"
append using "$tempdir/stepdad"
append using "$tempdir/adoptchild_of_mom"
append using "$tempdir/adoptmom"
append using "$tempdir/adoptchild_of_dad"
append using "$tempdir/adoptdad"
append using "$tempdir/errp_spouse1"
append using "$tempdir/errp_spouse2"
append using "$tempdir/errp_child_of_mom1"
append using "$tempdir/errp_child_of_mom2"
append using "$tempdir/errp_child_of_dad1"
append using "$tempdir/errp_child_of_dad2"
append using "$tempdir/errp_grandchild1"
append using "$tempdir/errp_grandchild2"
append using "$tempdir/errp_mom1"
append using "$tempdir/errp_mom2"
append using "$tempdir/errp_dad1"
append using "$tempdir/errp_dad2"
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

* Now that we carry along reason for the relationship we need to force drop
* when we have more than one reason for the same relationship.  We won't worry
* about which reason we keep.
duplicates drop SSUID SHHADID SWAVE relfrom relto relationship_tc0, force

save "$tempdir/relationships_tc0_all", $replace


* Now deal with cases in which we derive more than one relationship
* between the same pair of people.
sort SSUID SHHADID SWAVE relfrom relto
by SSUID SHHADID SWAVE relfrom relto:  gen numrels_tc0 = _N
by SSUID SHHADID SWAVE relfrom relto:  gen relnum_tc0 = _n

assert (numrels_tc0 <= 2)

reshape wide relationship_tc0 reason_tc0, i(SSUID SHHADID SWAVE relfrom relto) j(relnum_tc0)

display "Number of relationships before any fix-ups"
tab numrels_tc0

fixup_rel_pair BIOMOM MOM
fixup_rel_pair BIODAD DAD
fixup_rel_pair BIOCHILD CHILD

display "Number of relationships after BIO fixes"
tab numrels_tc0

fixup_rel_pair STEPMOM MOM
fixup_rel_pair STEPDAD DAD
fixup_rel_pair STEPCHILD CHILD
fixup_rel_pair ADOPTMOM MOM
fixup_rel_pair ADOPTDAD DAD
fixup_rel_pair ADOPTCHILD CHILD

display "Number of relationships after STEP and ADOPT fixes"
tab numrels_tc0

tab relationship_tc01 relationship_tc02 if (numrels_tc0 > 1)

save "$tempdir/relationships_tc0_wide", $replace


* We also build a version with conflicts resolved.
* Since there are so few conflicts, for now we just drop them.

* To know what we have thrown away that we might care about,
* we keep a list of what we lost.
preserve
keep if (numrels_tc0 > 1)
save "$tempdir/relationships_tc0_lost", $replace


restore
drop if (numrels_tc0 > 1)
drop numrels_tc0

* And we drop the empty second relationship and reason.
drop relationship_tc02 reason_tc02

* And rename the first to have no suffix.
rename relationship_tc01 relationship
rename reason_tc01 reason

save "$tempdir/relationships_tc0_resolved", $replace


*** TODO:  We ideally want a single relationship.
* For starters, compute some stats on conflicts.



/*
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
*/

