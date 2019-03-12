* For Table 1 of HHstability paper
* Run do_childrens_household_core (or at least project_macros) before executing.

use "$SIPP08keep/HHComp_asis", clear

keep if adj_age < $adult_age
keep if my_racealt==3

/* parents' duration on the US- year of the wave minus year of arrival.
The most recent arrival parent from latin america*/
g year=2008 if SWAVE==1
replace year=2009 if SWAVE>=2 & SWAVE<=4
replace year=2010 if SWAVE>=5 & SWAVE<=7
replace year=2011 if SWAVE>=8 & SWAVE<=10
replace year=2012 if SWAVE>=11 & SWAVE<=13
replace year=2013 if SWAVE>=14 & SWAVE<=16

foreach parent in mom dad{ 
g `parent'_arrival=2008 if `parent'_yrmigartion==22
replace `parent'_arrival=2007 if `parent'_yrmigartion==21
replace `parent'_arrival=2006 if `parent'_yrmigartion==20
replace `parent'_arrival=2005 if `parent'_yrmigartion==19
replace `parent'_arrival=2004 if `parent'_yrmigartion==18
replace `parent'_arrival=2002.5 if `parent'_yrmigartion==17
replace `parent'_arrival=2001 if `parent'_yrmigartion==16
replace `parent'_arrival=2000 if `parent'_yrmigartion==15
replace `parent'_arrival=1999 if `parent'_yrmigartion==14
replace `parent'_arrival=1997.5 if `parent'_yrmigartion==13
replace `parent'_arrival=1995.5 if `parent'_yrmigartion==12
replace `parent'_arrival=1993 if `parent'_yrmigartion>=1 & `parent'_yrmigartion<=11
}

g parent_duration= year-mom_arrival if mom_arrival!=. & mom_birthplace>=569 & mom_birthplace<=571
replace parent_duration= year-dad_arrival if ((dad_arrival>mom_arrival & dad_arrival!=.) | mom_arrival==.) & dad_birthplace>=569 & dad_birthplace<=571
replace parent_duration=dad_arrival if parent_duration==. & dad_birthplace>=569 & dad_birthplace<=571

* duration categorical variable:
g duration_cat=1 if parent_duration>=0 & parent_duration<=2
replace duration_cat=2 if parent_duration>2 & parent_duration<=5
replace duration_cat=3 if parent_duration>5 & parent_duration!=.
replace duration_cat=4 if mom_immigrant==0 & dad_immigrant==0

label define duration 1 "Up to 2 years" 2 "2 to 5 years" 3 "Above 5 years" 4 "3rd+ generation"
label values duration_cat duration

tab relationship [aweight=WPFINWGT]

gen bioparent=1 if relationship==1
gen otherparent=1 if inlist(relationship,4,7,19,21)
gen sibling=1 if inlist(relationship, 17)
gen grandparent=1 if inlist(relationship,13,14,27)
gen other_rel=1 if inlist(relationship,2,3,5,6,8,9,10,11,23,12,18,15,16,24,25,26,28,29,30,31,33,32,35,36) //not parents, siblings, children, spouses, or grandparents
gen nonrel=1 if inlist(relationship,20,22,34,37,38)
gen unknown=1 if relationship==40 | missing(relationship)
*gen nonnuke=1 if nonrel==1 | grandparent==1 | other_rel==1 | unknown==1 
*gen allelse=1 if inlist(relationship,2,3,5,6,8,9,10,11,23,12,18) // children, spouses
*gen extended_kin=1 if grandparent==1 | other_rel==1


local rellist "bioparent otherparent sibling nonrel grandparent other_rel unknown"

foreach var of varlist bioparent otherparent sibling grandparent other_rel nonrel unknown {
replace `var'=0 if `var'==.
}
collapse (sum)`rellist', by (SSUID EPPPNUM SWAVE duration_cat WPFINWGT) fast
tabstat bioparent otherparent sibling nonrel grandparent other_rel unknown [aweight=WPFINWGT], by(duration_cat) 
end



***********************************************************
*changes in household composition and address by duration:*
***********************************************************
use "$SIPP08keep/hh_change.dta", clear

keep if adj_age < $adult_age
keep if my_racealt==3

/* parents' duration on the US- year of the wave minus year of arrival.
The most recent arrival parent from latin america*/
g year=2008 if SWAVE==1
replace year=2009 if SWAVE>=2 & SWAVE<=4
replace year=2010 if SWAVE>=5 & SWAVE<=7
replace year=2011 if SWAVE>=8 & SWAVE<=10
replace year=2012 if SWAVE>=11 & SWAVE<=13
replace year=2013 if SWAVE>=14 & SWAVE<=16

foreach parent in mom dad{ 
g `parent'_arrival=2008 if `parent'_yrmigartion==22
replace `parent'_arrival=2007 if `parent'_yrmigartion==21
replace `parent'_arrival=2006 if `parent'_yrmigartion==20
replace `parent'_arrival=2005 if `parent'_yrmigartion==19
replace `parent'_arrival=2004 if `parent'_yrmigartion==18
replace `parent'_arrival=2002.5 if `parent'_yrmigartion==17
replace `parent'_arrival=2001 if `parent'_yrmigartion==16
replace `parent'_arrival=2000 if `parent'_yrmigartion==15
replace `parent'_arrival=1999 if `parent'_yrmigartion==14
replace `parent'_arrival=1997.5 if `parent'_yrmigartion==13
replace `parent'_arrival=1995.5 if `parent'_yrmigartion==12
replace `parent'_arrival=1993 if `parent'_yrmigartion>=1 & `parent'_yrmigartion<=11
}

g parent_duration= year-mom_arrival if mom_arrival!=. & mom_birthplace>=569 & mom_birthplace<=571
replace parent_duration= year-dad_arrival if ((dad_arrival>mom_arrival & dad_arrival!=.) | mom_arrival==.) & dad_birthplace>=569 & dad_birthplace<=571
replace parent_duration=dad_arrival if parent_duration==. & dad_birthplace>=569 & dad_birthplace<=571

* duration categorical variable:
g duration_cat=1 if parent_duration>=0 & parent_duration<=2
replace duration_cat=2 if parent_duration>2 & parent_duration<=5
replace duration_cat=3 if parent_duration>5 & parent_duration!=.
replace duration_cat=4 if mom_immigrant==0 & dad_immigrant==0

label define duration 1 "Up to 2 years" 2 "2 to 5 years" 3 "Above 5 years" 4 "3rd+ generation"
label values duration_cat duration


*generate comp change and address change:
g only_comp= (comp_change==1 & addr_change==0)
replace only_comp=. if comp_change==.
g only_addr= (comp_change==0 & addr_change==1)
replace only_addr=. if addr_change==.
g both_changes= (comp_change==1 & addr_change==1)
replace both_changes=. if comp_change==. | addr_change==.

tabstat only_comp [aweight=WPFINWGT], by(duration_cat)
tabstat only_addr [aweight=WPFINWGT], by(duration_cat)
tabstat both_change [aweight=WPFINWGT], by(duration_cat)
tabstat only_comp [aweight=WPFINWGT], by(parent_duration)
tabstat only_addr [aweight=WPFINWGT], by(parent_duration)
tabstat both_change [aweight=WPFINWGT], by(parent_duration)

















/*collapse (count) `rellist', by (SSUID EPPPNUM SWAVE) fast

merge 1:1 SSUID EPPPNUM SWAVE using "$tempdir/demo_long_interviews.dta", keepusing(WPFINWGT my_racealt adj_age my_sex biomom_ed_first par_ed_first ref_person_educ mom_measure)

keep if _merge==3

drop _merge

gen weight=int(WPFINWGT*10000)

tab adj_age par_ed_first

foreach v in `rellist'{
 tab `v' [fweight=weight]
 }
 
 recode nonnuke (0=0)(1/20=1), gen(anynonuke)
 recode nonrel (0=0)(1/20=1), gen(anynonrel)
 recode grandparent (0=0)(1/20=1), gen(anygp)
 recode other_rel (0=0)(1/20=1), gen(anyother)
 recode extended_kin (0=0)(1/20=1), gen(anyextended)
 recode unknown (0=0)(1/20=1), gen(anyunknown)

label variable anynonuke "non-nuclear kin or non-relative"
label variable anynonrel "non-relative"
label variable anygp "grandparent"
label variable anyother "non-nuclear non-grandparent kin"
label variable anyunknown "unknown relation"
label variable anyextended "any extended kin"

#delimit ;
label define yesno  0 "no"
                    1 "yes";
#delimit cr 

local anyrel "anynonuke anynonrel anygp anyother anyextended anyunknown"

label variable my_racealt "Race-Ethnicity"

foreach v in `anyrel'{
label values `v' yesno
tab `v' 
}

* Setup to put output in document

	putdocx begin
	
	// Create a paragraph
	putdocx paragraph
	putdocx text ("How often do children live with non-nuclear household members"), bold
	putdocx paragraph
	putdocx text ("We used measures of the relationship of each person in a ")
	putdocx text ("child's household to create indicators of whether anyone ")
	putdocx text ("was a non-nuclear member (i.e. not a parent or a sibling), ")
	putdocx text ("a non-relative, a grandparent other relative, or an unknown relation. ")
	putdocx text ("Note that any non-nuclear member includes non-relatives, ")
	putdocx text ("grandparents, other relatives, and unknown relations, ") 
	putdocx text ("but other relative does not include grandparent. ")
	putdocx text ("Table can be found in Table1b.csv")
	
	putdocx save "$results/Table1a.docx", replace

	*/
/*
tabout anynonuke anynonrel anygp anyother anyextended anyunknown my_racealt [aweight=WPFINWGT] using "$results/Table1b.csv", replace ///
cells(col) ///
clab(_ _ _) ///
layout(rb) ///
h1( | White | Black | Hispanic | Asian | Other | Total ) h2(nil) ///
style(csv)
	
tabout anynonuke anynonrel anygp anyother anyextended anyunknown par_ed_first [aweight=WPFINWGT] using "$results/Table1b.csv", append ///
cells(col) ///
clab(_ _ _) ///
layout(rb) ///
h1( | < HS | High School | Some College | College Grad | Total ) h2(nil) h3(nil) ///
style(csv)	
	

tab my_racealt, m
tab par_ed_first, m
tab mom_measure, m

duplicates drop SSUID EPPPNUM, force

tab my_racealt, m
tab par_ed_first, m
tab mom_measure, m



