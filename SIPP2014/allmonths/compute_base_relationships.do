//========================================================================================================//
//===== Children's Household Instability Project                                     
//===== Dataset: SIPP2014                                                           
//===== Purpose: Compute relationships of ego to other household members using EPNMOM, EPNDAD, EPNSPOUSE and ERELRP 
//========================================================================================================//

********************************************************************************
* Section: Start by creating programs to process data
********************************************************************************

** Program to create process data from all months and save a record for EGO and coresident (bio/step/adoptive mother/father) 
** Each relationship type is saved in a different file.
** The program also creates inverse relationships (i.e. relationships of other people to ego). 

capture program drop compute_relationships
program define compute_relationships
    args person1 person2 relationship_1_2 relationship_2_1 reason condition filename_1_2 filename_2_1 /* local macro */

    preserve
    gen relfrom = `person1' if `condition'
    gen relto = `person2' if `condition'
    gen relationship_tc0 = "`relationship_1_2'":relationship if `condition'
    label values relationship_tc0 relationship
    gen reason_tc0 = "`reason'" if `condition'
    tab relationship_tc0 panelmonth
    keep SSUID SHHADID panelmonth relfrom relto relationship_tc0 reason_tc0
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
    tab relationship_tc0 panelmonth
    keep SSUID SHHADID panelmonth relfrom relto relationship_tc0 reason_tc0
    drop if missing(relationship_tc0)
    drop if (relfrom == relto)
    save "$tempdir/`filename_2_1'", $replace
    restore
end

** Program to fix conflicting relationship pairs, taking the first as preferable to the second. Conflicting relationships are
** possible when relationship identified with the parent pointer is not the same as the relationship identified with the
** relationship to householder variable. 

capture program drop fixup_rel_pair
program define fixup_rel_pair
    args preferred_rel second_rel /*local macro, the first relationship is preferred */

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

********************************************************************************
* Read in and label data
use "$SIPP14keep/allmonths14"

do "$sipp2014_code/relationship_label"
********************************************************************************

* A small number of cases identified themselves as their own mother, father, or spouse
replace EPNPAR1=. if PNUM==EPNPAR1
replace EPNPAR2=. if PNUM==EPNPAR2
replace EPNSPOUSE=. if PNUM==EPNSPOUSE

********************************************************************************
** Section: Process parent/child relationships from EPNMOM, EPNDAD, and EPNSPOUS.
**
** Use Program: compute_relationships
**        args: person1 person2 relationship_1_2 relationship_2_1 reason condition filename_1_2 filename_2_1
********************************************************************************
compute_relationships PNUM EPNPAR1 BIOCHILD BIOMOM EPNPAR1 "((!missing(EPNPAR1)) & (EPNPAR1 != .) & (EPAR1TYP == 1))" biochild_of_mom biomom
compute_relationships PNUM EPNPAR2 BIOCHILD BIODAD EPNPAR2 "((!missing(EPNPAR2)) & (EPNPAR2 != .) & (EPAR2TYP == 1))" biochild_of_dad biodad
compute_relationships PNUM EPNPAR1 STEPCHILD STEPMOM EPNPAR1 "((!missing(EPNPAR1)) & (EPNPAR1 != .) & (EPAR1TYP == 2))" stepchild_of_mom stepmom
compute_relationships PNUM EPNPAR2 STEPCHILD STEPDAD EPNPAR2 "((!missing(EPNPAR2)) & (EPNPAR2 != .) & (EPAR2TYP == 2))" stepchild_of_dad stepdad
compute_relationships PNUM EPNPAR1 ADOPTCHILD ADOPTMOM EPNPAR1 "((!missing(EPNPAR1)) & (EPNPAR1 != .) & (EPAR1TYP == 3))" adoptchild_of_mom adoptmom
compute_relationships PNUM EPNPAR2 ADOPTCHILD ADOPTDAD EPNPAR1 "((!missing(EPNPAR2)) & (EPNPAR2 != .) & (EPAR2TYP == 3))" adoptchild_of_dad adoptdad
compute_relationships PNUM EPNSPOUSE SPOUSE SPOUSE EPNSPOUSE "((!missing(EPNSPOUSE)) & (EPNSPOUSE != .) & (ESEX == 1))" epnspous1 epnspous2 

********************************************************************************
** Section: Merge in ERELRP, a variable indicating the reference person for the household.
**          ref_person_long was created with make_auxiliary_datasets
********************************************************************************

merge m:1 SSUID SHHADID panelmonth using "$tempdir/ref_person_long"
assert missing(ref_person) if (_merge == 2)
drop if (_merge == 2)


** PS: assert finds 1 contradiction. Dropping this case
drop if _merge != 3
assert (_merge == 3)
drop _merge
********************************************************************************


********************************************************************************
** Section: Generate records for spouse, child, grandchild, parent, sibling, 
**          others, foster child, partener, no relation based ERELRP. 
** Note: The 1 and 2 suffixes below are convenient but not very descriptive.
**        1 means the relationship as stated; 2 means the reverse.  
**        E.g., ERELRP_child_of_mom2 are moms of children identified by ERELRP == 4.
**
** Use Program: compute_relationships
**        args: person1 person2 relationship_1_2 relationship_2_1 reason condition filename_1_2 filename_2_1
***********************************************************************************************************************

* Spouse of reference person.
compute_relationships PNUM ref_person SPOUSE SPOUSE ERELRP_3 "(ERELRP == 3)" ERELRP_spouse1 ERELRP_spouse2

* Child of reference person.  You'd expect EPNMOM/DAD to capture this, too.
compute_relationships PNUM ref_person CHILD MOM ERELRP_4 "((ERELRP == 4) & (ref_person_sex == 2))" ERELRP_child_of_mom1 ERELRP_child_of_mom2
compute_relationships PNUM ref_person CHILD DAD ERELRP_4 "((ERELRP == 4) & (ref_person_sex == 1))" ERELRP_child_of_dad1 ERELRP_child_of_dad2

* Grandchild of reference person.
compute_relationships PNUM ref_person GRANDCHILD GRANDPARENT ERELRP_5 "(ERELRP == 5)" ERELRP_grandchild1 ERELRP_grandchild2

* Parent of reference person.
compute_relationships PNUM ref_person MOM CHILD ERELRP_6 "((ERELRP == 6) & (ESEX == 2))" ERELRP_mom1 ERELRP_mom2
compute_relationships PNUM ref_person DAD CHILD ERELRP_6 "((ERELRP == 6) & (ESEX == 1))" ERELRP_dad1 ERELRP_dad2

* Sibling of reference person.
compute_relationships PNUM ref_person SIBLING SIBLING ERELRP_7 "(ERELRP == 7)" ERELRP_sibling1 ERELRP_sibling2

* Other relative.
compute_relationships PNUM ref_person OTHER_REL OTHER_REL ERELRP_8 "(ERELRP == 8)" ERELRP_otherrel1 ERELRP_otherrel2

* Foster child.
compute_relationships PNUM ref_person F_CHILD F_PARENT ERELRP_9 "(ERELRP == 9)" ERELRP_fosterchild1 ERELRP_fosterchild2

* Partner of reference person.
compute_relationships PNUM ref_person PARTNER PARTNER ERELRP_10 "(ERELRP == 10)" ERELRP_partner1 ERELRP_partner2

* No relation.
compute_relationships PNUM ref_person NOREL NOREL ERELRP_GE_11 "((ERELRP == 11) | (ERELRP == 12) | (ERELRP == 13))" ERELRP_norelation1 ERELRP_norelation2

clear

*******************************************************************************
** Section: Append all relationship data sets together.
*******************************************************************************
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
append using "$tempdir/ERELRP_spouse1"
append using "$tempdir/ERELRP_spouse2"
append using "$tempdir/ERELRP_child_of_mom1"
append using "$tempdir/ERELRP_child_of_mom2"
append using "$tempdir/ERELRP_child_of_dad1"
append using "$tempdir/ERELRP_child_of_dad2"
append using "$tempdir/ERELRP_grandchild1"
append using "$tempdir/ERELRP_grandchild2"
append using "$tempdir/ERELRP_mom1"
append using "$tempdir/ERELRP_mom2"
append using "$tempdir/ERELRP_dad1"
append using "$tempdir/ERELRP_dad2"
append using "$tempdir/ERELRP_sibling1"
append using "$tempdir/ERELRP_sibling2"
append using "$tempdir/ERELRP_otherrel1"
append using "$tempdir/ERELRP_otherrel2"
append using "$tempdir/ERELRP_fosterchild1"
append using "$tempdir/ERELRP_fosterchild2"
append using "$tempdir/ERELRP_partner1"
append using "$tempdir/ERELRP_partner2"
append using "$tempdir/ERELRP_norelation1"
append using "$tempdir/ERELRP_norelation2"
append using "$tempdir/epnspous1"
append using "$tempdir/epnspous2"


* Force drop when we have more than one reason for the SAME relationship 
duplicates drop SSUID SHHADID panelmonth relfrom relto relationship_tc0, force

save "$tempdir/relationships_tc0_all", $replace

********************************************************************************
** Section: Find pairs for which we have more than one relationship type in a single month.
**           Select the more specific one
********************************************************************************
sort SSUID SHHADID panelmonth relfrom relto
by SSUID SHHADID panelmonth relfrom relto:  gen numrels_tc0 = _N /* total number of relationships */
by SSUID SHHADID panelmonth relfrom relto:  gen relnum_tc0 = _n

assert (numrels_tc0 <= 2)

*reshape so that we can compare relationships for pairs (within month) with more than one relationship type
reshape wide relationship_tc0 reason_tc0, i(SSUID SHHADID panelmonth relfrom relto) j(relnum_tc0)

display "Number of relationships in a month before any fix-ups"
tab numrels_tc0

** Use program: fixup_rel_pair args: args preferred_rel second_rel
* start with biological parents
fixup_rel_pair BIOMOM MOM
fixup_rel_pair BIODAD DAD
fixup_rel_pair BIOCHILD CHILD

display "Number of relationships in a month after BIO fixes"
tab numrels_tc0

* Fix adopt and step. 
fixup_rel_pair STEPMOM MOM
fixup_rel_pair STEPDAD DAD
fixup_rel_pair STEPCHILD CHILD
fixup_rel_pair ADOPTMOM MOM
fixup_rel_pair ADOPTDAD DAD
fixup_rel_pair ADOPTCHILD CHILD

display "Number of relationships in a month after STEP and ADOPT fixes"
tab numrels_tc0

tab relationship_tc01 relationship_tc02 if (numrels_tc0 > 1)

* Save a data set with remaining conflicted relationships.
preserve
keep if (numrels_tc0 > 1)
save "$tempdir/relationships_tc0_lost", $replace 
restore

rename relationship_tc01 relationship
rename reason_tc01 reason

drop relationship_tc02 reason_tc02

replace relationship=. if numrels_tc0 > 1

*Despite the name, this file is still long. One record per pair per month.
save "$tempdir/relationships_tc0_wide", $replace



