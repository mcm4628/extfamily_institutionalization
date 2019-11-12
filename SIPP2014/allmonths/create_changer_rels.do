//==============================================================================
//===== Children's Household Instability Project
//===== Dataset: SIPP2014
//===== Purpose:  Link individuals identified as entering, leaving, or staying in
//===== a person's (ego's) household to their relationship to ego.
//==============================================================================

use "$SIPP14keep/comp_change_am.dta", clear

keep SSUID PNUM ERESIDENCEID* arrivers* leavers* stayers* comp_change* comp_change_reason* adj_age* 

reshape long ERESIDENCEID adj_age arrivers leavers stayers comp_change comp_change_reason, i(SSUID PNUM) j(panelmonth)

gen have_arrivers = (indexnot(arrivers, " ") != 0)
gen have_leavers = (indexnot(leavers, " ") != 0)

gen have_changers = (have_arrivers | have_leavers)

tab comp_change have_changers

assert (have_changers == 0) if (comp_change == 0)
assert (have_changers == 0) if missing(comp_change)

drop if missing(comp_change)
drop if (comp_change == 0)

gen err=0
replace err=1 if have_changers == 0 & comp_change == 1
egen error=mean(err)

* we will tolerate less than .5% without changers identified on either have_arrivers or have_leavers
assert error < .005  

save "$tempdir/comp_change_onlychangers", $replace

********************************************************************************
* Section: create long file where each record is a person who started or stopped
*          living with ego (and stayed living with ego).
********************************************************************************

foreach changer in leaver arriver stayer {
    clear

    use "$tempdir/comp_change_onlychangers"

    * Compute max number of leavers/arrivers.
    gen n_`changer's = wordcount(`changer's)
    egen max_`changer's = max(n_`changer's)

    forvalues my_`changer'_num = 1/`=max_`changer's' {
        gen `changer'`my_`changer'_num' = word(`changer's, `my_`changer'_num')
    }
    drop `changer's max_`changer's

    keep SSUID PNUM ERESIDENCEID panelmonth adj_age comp_change_reason n_`changer's `changer'* 

    reshape long `changer', i(SSUID PNUM panelmonth) j(`changer'_num)

    drop if missing(`changer')

    save "$tempdir/hh_`changer's", $replace
}

********************************************************************************
* Section: Linking those who leave to relationships in that month
********************************************************************************

use "$tempdir/hh_leavers", clear
drop if missing(leaver)
gen from_num = PNUM
destring leaver, gen(to_num)
merge 1:1 SSUID from_num to_num panelmonth using "$tempdir/relationship_pairs_bymonth", keepusing(relationship)
	
display "deleting relationships to self"
assert from_num!=to_num

replace relationship=40 if _merge==1

drop if _merge == 2
drop _merge

display "Relationships for leavers"
tab relationship, m sort
save "$tempdir/leaver_rels", $replace

********************************************************************************
* Section: Linking those who arrive to relationships
*          We have to link in month+n because they aren't with ego in the current 
*          month else they wouldn't be arrivers 
********************************************************************************

use "$tempdir/hh_arrivers", clear

* We link to relationship in next month, since they aren't together in this month
replace panelmonth=panelmonth+1
drop if missing(arriver)
gen from_num = PNUM
destring arriver, gen(to_num)
merge 1:1 SSUID from_num to_num panelmonth using "$tempdir/relationship_pairs_bymonth", keepusing(relationship to_age from_age)

* return panelmonth to its original value. (Yiwen, this is the silly error I made 
* that broke the code. I forgot to put panelmonth back to its original value). 	
replace panelmonth=panelmonth-1

replace relationship=40 if _merge==1

drop if _merge == 2
drop _merge

display "Relationships for arrivers"
tab relationship, m sort
save "$tempdir/arriver_rels", $replace


gen change_type=1

append using "$tempdir/leaver_rels"
replace change_type=2 if missing(change_type)

label variable change_type "Indicator for whether this person arrive in or left from ego's household"
label define change_type 1 "arriver" 2 "leaver" 

label values change_type change_type 

gen bioparent=1 if relationship==3
gen parent=1 if inlist(relationship,3,5,7)
gen sibling=1 if inrange(relationship,11,15)
gen biosib=1 if relationship==11
gen halfsib=1 if relationship==12
gen stepsib=1 if relationship==13
gen child=1 if inlist(relationship,4,6,8)
gen spartner=1 if inlist(relationship,1,2)
gen spouse=1 if relationship==1
gen nonrel=1 if inlist(relationship,19,20)
gen foster=1 if relationship==19
gen grandparent=1 if relationship==9
gen other_rel=1 if inrange(relationship,16,18) //not parents, siblings, children, spouses, or grandparents
gen unknown=1 if relationship==40 | missing(relationship)
gen nonnuke=1 if nonrel==1 | grandparent==1 | other_rel==1 | unknown==1
gen allelse=1 if inrange(relationship,1,8) // children, spouses

gen adult_arrive=1 if change_type==1 & to_age >= 18
gen adult_leave=1 if change_type==2 & to_age >= 18

gen yadult_arrive=1 if change_type==1 & to_age >= 18 & to_age < 30
gen yadult_leave=1 if change_type==2 & to_age >= 18 & to_age < 30

gen adult30_arrive=1 if change_type==1 & to_age >= 30
gen adult30_leave=1 if change_type==2 & to_age >= 30

*create variables for parent_arrive and parent_leave
gen parent_arrive=1 if change_type==1 & parent==1
gen parent_leave=1 if change_type==2 & parent==1

*create variables for otheradult30_arrive and otheradult30_leave
gen otheradult30_arrive=1 if change_type==1 & parent !=1 & to_age >30
gen otheradult30_leave=1 if change_type==2 & parent !=1 & to_age >30

*create variables for otheradult_arrive and otheradult_leave
gen otheradult_arrive=1 if change_type==1 & parent !=1 & to_age >=18
gen otheradult_leave=1 if change_type==2 & parent !=1 & to_age >=18

*create variable for non-parent young adult 
gen otheryadult_arrive=1 if change_type==1 & parent !=1 & to_age >= 18 & to_age < 30
gen otheryadult_leave=1 if change_type==2 & parent !=1 & to_age >= 18 & to_age < 30

gen adultsib_arrive=1 if change_type==1 & sibling==1 & to_age >= 18
gen adultsib_leave=1 if change_type==2 & sibling==1 & to_age >= 18

*create variable for non-parent non sibling adult
gen otheradult2_arrive=1 if change_type==1 & parent !=1 & sibling !=1 & to_age >=18
gen otheradult2_leave=1 if change_type==2 & parent !=1 & sibling !=1 & to_age >=18

*create variable for infant born
gen infant_arrive=1 if change_type==1 & sibling==1 & to_age <=0

save "$tempdir/changer_rels", $replace



