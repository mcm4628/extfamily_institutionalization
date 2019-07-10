* For Table 1 of HHstability paper
* Run do_childrens_household_core (or at least project_macros) before executing.

use "$SIPP08keep/HHComp_asis", clear
g panel=2008
save "$SIPP08keep/HHComp_asis", replace

use "$SIPP04keep/HHComp_asis", clear
g panel=2004
save "$SIPP04keep/HHComp_asis", replace

use "$SIPP04keep/HHComp_asis", clear
append using "$SIPP08keep/HHComp_asis"

keep if adj_age < 19
keep if my_racealt==3

/* parents' duration on the US- year of the wave minus year of arrival.
The most recent arrival parent from latin america*/
g year=2008 if SWAVE==1 & panel==2008
replace year=2009 if SWAVE>=2 & SWAVE<=4 & panel==2008
replace year=2010 if SWAVE>=5 & SWAVE<=7 & panel==2008
replace year=2011 if SWAVE>=8 & SWAVE<=10 & panel==2008
replace year=2012 if SWAVE>=11 & SWAVE<=13 & panel==2008 
replace year=2013 if SWAVE>=14 & SWAVE<=16 & panel==2008
replace year=2004 if SWAVE>=1 & SWAVE<=3 & panel==2004
replace year=2005 if SWAVE>=4 & SWAVE<=6 & panel==2004
replace year=2006 if SWAVE>=7 & SWAVE<=9 & panel==2004
replace year=2007 if SWAVE>=10 & SWAVE<=12 & panel==2004


foreach parent in mom dad{ 
g `parent'_arrival=2008 if `parent'_yrmigartion==22 & panel==2008
replace `parent'_arrival=2007 if `parent'_yrmigartion==21 & panel==2008
replace `parent'_arrival=2006 if `parent'_yrmigartion==20 & panel==2008
replace `parent'_arrival=2005 if `parent'_yrmigartion==19 & panel==2008
replace `parent'_arrival=2004 if `parent'_yrmigartion==18 & panel==2008
replace `parent'_arrival=2003 if `parent'_yrmigartion==20 & panel==2004
replace `parent'_arrival=2002.5 if `parent'_yrmigartion==17
replace `parent'_arrival=2001 if (`parent'_yrmigartion==16 & panel==2008) | (`parent'_yrmigartion==19 & panel==2004)
replace `parent'_arrival=2000 if (`parent'_yrmigartion==15 & panel==2008) | (`parent'_yrmigartion==18 & panel==2004)
replace `parent'_arrival=1999 if (`parent'_yrmigartion==14 & panel==2008) | (`parent'_yrmigartion==17 & panel==2004)
replace `parent'_arrival=1997.5 if (`parent'_yrmigartion==13 & panel==2008) | (`parent'_yrmigartion==16 & panel==2004)
replace `parent'_arrival=1995.5 if (`parent'_yrmigartion==12 & panel==2008) | (`parent'_yrmigartion==15 & panel==2004)
replace `parent'_arrival=1993.5 if (`parent'_yrmigartion==11 & panel==2008) | (`parent'_yrmigartion==14 & panel==2004)
replace `parent'_arrival=1991.5 if (`parent'_yrmigartion==10 & panel==2008) | (`parent'_yrmigartion==13 & panel==2004)
replace `parent'_arrival=1989.5 if (`parent'_yrmigartion==9 & panel==2008) | (`parent'_yrmigartion==12 & panel==2004)
replace `parent'_arrival=1987.5 if  (`parent'_yrmigartion==11 & panel==2004)
replace `parent'_arrival=1987 if (`parent'_yrmigartion<=8 & `parent'_yrmigartion>=1& panel==2008) 
replace `parent'_arrival=1985.5 if  (`parent'_yrmigartion==10 & panel==2004)
replace `parent'_arrival=1983.5 if  (`parent'_yrmigartion<=9 & `parent'_yrmigartion>=1 & panel==2004)
replace `parent'_arrival=. if (`parent'_yrmigartion==9999 | `parent'_yrmigartion==-1) 
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
collapse (sum)`rellist' [aweight=WPFINWGT], by (SSUID EPPPNUM SWAVE panel duration_cat) fast
tabstat bioparent otherparent sibling nonrel grandparent other_rel unknown, by(duration_cat) 

graph bar bioparent otherparent sibling grandparent other_rel nonrel, over(duration_cat) stack ///
bar(1, color(gs14)) bar(2, color(gs12)) bar(3, color(gs10)) bar(4, color(gs8)) bar(5, color(gs6)) bar(6, color(gs4)) ///
ylabel(0 (0.5) 4.5, val) subtitle(, fcolor(white) lcolor(white)) graphregion(fcolor(white)) note("") ///
ytitle("Number of household members") ///
legend(size(vsmall) label(1 "Biological parents") label(2 "Non-biological parents") label(3 "Siblings") label(4 "Grandparents") label(5 "Other relatives") label(6 "Non-relatives"))

end
/*With colors*/
graph bar bioparent otherparent sibling grandparent other_rel nonrel, over(duration_cat) stack ///
bar(1, color(ebblue)) bar(2, color(edkblue)) bar(3, color(eltgreen)) bar(4, color(erose)) bar(5, color(emidblue)) bar(6, color(gs4)) ///
ylabel(0 (0.5) 4.5, val) subtitle(, fcolor(white) lcolor(white)) graphregion(fcolor(white)) note("") ///
ytitle("Number of household members") ///
legend(size(vsmall) label(1 "Biological parents") label(2 "Non-biological parents") label(3 "Siblings") label(4 "Grandparents") label(5 "Other relatives") label(6 "Non-relatives"))



***********************************************************
*changes in household composition and address by duration:*
***********************************************************
/*
use "$SIPP08keep/hh_change.dta", clear
g panel=2008
save "$SIPP08keep/hh_change.dta", replace

use "$SIPP04keep/hh_change", clear
g panel=2004
save "$SIPP04keep/hh_change", replace


use "$SIPP04keep/hh_change", clear
append using "$SIPP08keep/hh_change.dta"
g size=1 
collapse (sum)size, by(SSUID SHHADID panel SWAVE)
save "$tempdir/hh_size", replace
*/
use "$SIPP04keep/hh_change", clear
append using "$SIPP08keep/hh_change.dta"
merge m:1 SSUID SHHADID panel SWAVE using "$tempdir/hh_size"
keep if adj_age < 19
keep if my_racealt==3

/* parents' duration on the US- year of the wave minus year of arrival.
The most recent arrival parent from latin america*/
g year=2008 if SWAVE==1 & panel==2008
replace year=2009 if SWAVE>=2 & SWAVE<=4 & panel==2008
replace year=2010 if SWAVE>=5 & SWAVE<=7 & panel==2008
replace year=2011 if SWAVE>=8 & SWAVE<=10 & panel==2008
replace year=2012 if SWAVE>=11 & SWAVE<=13 & panel==2008 
replace year=2013 if SWAVE>=14 & SWAVE<=16 & panel==2008
replace year=2004 if SWAVE>=1 & SWAVE<=3 & panel==2004
replace year=2005 if SWAVE>=4 & SWAVE<=6 & panel==2004
replace year=2006 if SWAVE>=7 & SWAVE<=9 & panel==2004
replace year=2007 if SWAVE>=10 & SWAVE<=12 & panel==2004

foreach parent in mom dad{ 
g `parent'_arrival=2008 if `parent'_yrmigartion==22 & panel==2008
replace `parent'_arrival=2007 if `parent'_yrmigartion==21 & panel==2008
replace `parent'_arrival=2006 if `parent'_yrmigartion==20 & panel==2008
replace `parent'_arrival=2005 if `parent'_yrmigartion==19 & panel==2008
replace `parent'_arrival=2004 if `parent'_yrmigartion==18 & panel==2008
replace `parent'_arrival=2003 if `parent'_yrmigartion==20 & panel==2004
replace `parent'_arrival=2002.5 if `parent'_yrmigartion==17
replace `parent'_arrival=2001 if (`parent'_yrmigartion==16 & panel==2008) | (`parent'_yrmigartion==19 & panel==2004)
replace `parent'_arrival=2000 if (`parent'_yrmigartion==15 & panel==2008) | (`parent'_yrmigartion==18 & panel==2004)
replace `parent'_arrival=1999 if (`parent'_yrmigartion==14 & panel==2008) | (`parent'_yrmigartion==17 & panel==2004)
replace `parent'_arrival=1997.5 if (`parent'_yrmigartion==13 & panel==2008) | (`parent'_yrmigartion==16 & panel==2004)
replace `parent'_arrival=1995.5 if (`parent'_yrmigartion==12 & panel==2008) | (`parent'_yrmigartion==15 & panel==2004)
replace `parent'_arrival=1993.5 if (`parent'_yrmigartion==11 & panel==2008) | (`parent'_yrmigartion==14 & panel==2004)
replace `parent'_arrival=1991.5 if (`parent'_yrmigartion==10 & panel==2008) | (`parent'_yrmigartion==13 & panel==2004)
replace `parent'_arrival=1989.5 if (`parent'_yrmigartion==9 & panel==2008) | (`parent'_yrmigartion==12 & panel==2004)
replace `parent'_arrival=1987.5 if  (`parent'_yrmigartion==11 & panel==2004)
replace `parent'_arrival=1987 if (`parent'_yrmigartion<=8 & `parent'_yrmigartion>=1& panel==2008) 
replace `parent'_arrival=1985.5 if  (`parent'_yrmigartion==10 & panel==2004)
replace `parent'_arrival=1983.5 if  (`parent'_yrmigartion<=9 & `parent'_yrmigartion>=1 & panel==2004)
replace `parent'_arrival=. if (`parent'_yrmigartion==9999 | `parent'_yrmigartion==-1) 
}

g parent_duration= year-mom_arrival if mom_arrival!=. & ((mom_birthplace>=569 & mom_birthplace<=571 & panel==2008)| (mom_birthplace>=310 & mom_birthplace<=389 & panel==2004))
replace parent_duration= year-dad_arrival if ((dad_arrival>mom_arrival & dad_arrival!=.) | mom_arrival==.) & ((dad_birthplace>=569 & dad_birthplace<=571 & panel==2008)| (dad_birthplace>=310 & dad_birthplace<=389 & panel==2004))
replace parent_duration=dad_arrival if parent_duration==. & ((dad_arrival>mom_arrival & dad_arrival!=.) | mom_arrival==.) & ((dad_birthplace>=569 & dad_birthplace<=571 & panel==2008)| (dad_birthplace>=310 & dad_birthplace<=389 & panel==2004))

*round and define upper border
replace parent_duration=round(parent_duration)
replace parent_duration=20 if parent_duration>20 & parent_duration!=.
replace parent_duration=21 if (mom_immigrant==0 & dad_immigrant==0) | (mom_immigrant==0 & dad_immigrant==.) | (mom_immigrant==. & dad_immigrant==0)
replace parent_duration=1 if parent_duration==0


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

keep if parent_duration<21
collapse (mean) only_comp only_addr both_changes [aweight=WPFINWGT], by(parent_duration)
g non_changes=1-both_changes-only_addr-only_comp 
g both_new= non_change+only_comp+only_addr+both_changes
g address_new=non_change+only_comp+only_addr
g comp_new= non_change+only_comp

twoway (area both_new parent_duration, color(gs4)) ///
	(area address_new parent_duration, color(gs7)) (area comp_new parent_duration, color(gs10)) ///
	(area non_changes parent_duration, color(gs13)), ///
	xlabel(1 (2) 19 20 21, valuelabel angle(50) ) ylabel(0.75 (0.05) 1, nogrid val) ///
	text(0.99 4.5 "{bf:Simultaneous changes}") text(0.96 9 "{bf:Only address change}") text(0.92 13.5 "{bf:Only composition change}") text(0.85 18 "{bf:No change}") /// 
	xtitle("Parental duration in the US") ytitle("Proportion of person waves") ///
	subtitle(, fcolor(white) lcolor(white)) legend(off) graphregion(fcolor(white)) note("")

*With colors	
twoway (area both_new parent_duration, color(emerald)) ///
	(area address_new parent_duration, color(maroon)) (area comp_new parent_duration, color(erose)) ///
	(area non_changes parent_duration, color(gs13)), ///
	xlabel(1 (2) 19 20 21, valuelabel angle(50) ) ylabel(0.75 (0.05) 1, nogrid val) ///
	text(0.99 4.5 "{bf:Simultaneous changes}") text(0.96 9 "{bf:Only address change}") text(0.92 13.5 "{bf:Only composition change}") text(0.85 18 "{bf:No change}") /// 
	xtitle("Parental duration in the US") ytitle("Proportion of person waves") ///
	subtitle(, fcolor(white) lcolor(white)) legend(off) graphregion(fcolor(white)) note("")

tabstat only_comp [aweight=WPFINWGT], by(duration_cat)
tabstat only_addr [aweight=WPFINWGT], by(duration_cat)
tabstat both_changes [aweight=WPFINWGT], by(duration_cat)
tabstat only_comp [aweight=WPFINWGT], by(parent_duration)
tabstat only_addr [aweight=WPFINWGT], by(parent_duration)
tabstat both_changes [aweight=WPFINWGT], by(parent_duration)

/* Second version-annual changes, instead of 4 months
keep if parent_duration<20
egen id=group(SSUID EPPPNUM panel)
collapse (max) only_comp only_addr both_changes [aweight=WPFINWGT], by(id parent_duration)
collapse (mean) only_comp only_addr both_changes, by(parent_duration)
g non_changes=1-both_changes-only_addr-only_comp 
g both_new= non_change+only_comp+only_addr+both_changes
g address_new=non_change+only_comp+only_addr
g comp_new= non_change+only_comp

twoway (area both_new parent_duration, color(gs4)) ///
	(area address_new parent_duration, color(gs7)) (area comp_new parent_duration, color(gs10)) ///
	(area non_changes parent_duration, color(gs13)), ///
	xlabel(1 (2) 19) ylabel(0.5 (0.1) 1, nogrid val) ///
	text(0.99 4 "{bf:Simultaneous changes}") text(0.9 9 "{bf:Only address change}") text(0.8 13.5 "{bf:Only composition change}") text(0.7 17 "{bf:No change}") /// 
	xtitle("Parental duration in the US") ytitle("Proportion of children") ///
	subtitle(, fcolor(white) lcolor(white)) legend(off) graphregion(fcolor(white)) note("")

*/




egen id=group(SSUID EPPPNUM panel)
logistic comp_change b4.duration_cat i.EBORNUS adj_age i.par_ed_first size i.my_sex ln_income, cluster(id)









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



