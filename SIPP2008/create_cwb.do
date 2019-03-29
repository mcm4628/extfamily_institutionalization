* Create measures of household change between wave 4 and wave 10

use "$SIPP08keep/HHchangeWithRelationships.dta", clear

keep if SWAVE==4|SWAVE==5|SWAVE==6|SWAVE==7|SWAVE==8|SWAVE==9
keep SSUID EPPPNUM SWAVE adj_age comp_change parent_change sib_change other_change nonparent_change adult_arrive adult_leave ///
parent_arrive parent_leave otheradult30_arrive otheradult30_leave otheradult_arrive ///
otheradult_leave addr_change my_sex hh_change adult30_arrive adult30_leave ///
yadult_arrive yadult_leave otheryadult_arrive otheryadult_leave adultsib_arrive adultsib_leave otheradult2_arrive otheradult2_leave infant_arrive

reshape wide adj_age comp_change parent_change sib_change other_change nonparent_change adult_arrive adult_leave ///
parent_arrive parent_leave otheradult30_arrive otheradult30_leave otheradult_arrive ///
otheradult_leave addr_change adult30_arrive adult30_leave ///
yadult_arrive yadult_leave otheryadult_arrive otheryadult_leave adultsib_arrive adultsib_leave otheradult2_arrive otheradult2_leave infant_arrive ///
my_sex hh_change, i(SSUID EPPPNUM) j(SWAVE)

***calculate number of changes experienced between wave 4&10***
gen nmis_compchange410=0 
gen numchange410=0

forvalues i=4/9 {
	replace nmis_compchange410=nmis_compchange410+1 if missing(comp_change`i')
	replace numchange410=numchange410+1 if comp_change`i'==1
}


gen nmis_compchange710=0 
gen numchange710=0

forvalues i=7/9 {
	replace nmis_compchange710=nmis_compchange710+1 if missing(comp_change`i')
	replace numchange710=numchange710+1 if comp_change`i'==1
}


***create indicators of whether experienced any specific type of change 
recode numchange410 (2/max=1), gen (anychange410)
recode nmis_compchange410 (2/max=1), gen (anymischange410)
egen parent_change=anymatch (parent_change*), v(1)
egen sib_change=anymatch (sib_change*), v(1)
egen nonparent_change=anymatch (nonparent_change*), v(1)
egen other_change=anymatch (other_change*), v(1)
egen adult_arrive=anymatch (adult_arrive*), v(1)
egen adult_leave=anymatch (adult_leave*), v(1)
egen yadult_leave=anymatch (yadult_leave*), v(1)
egen yadult_arrive=anymatch (yadult_arrive*), v(1)
egen adult30_arrive=anymatch (adult30_arrive*), v(1)
egen adult30_leave=anymatch (adult30_leave*), v(1)
egen parent_arrive=anymatch (parent_arrive*), v(1)
egen parent_leave=anymatch (parent_leave*), v(1)
egen otheradult30_arrive=anymatch (otheradult30_arrive*), v(1)
egen otheradult30_leave=anymatch (otheradult30_leave*), v(1)
egen otheradult_arrive=anymatch (otheradult_arrive*), v(1)
egen otheradult_leave=anymatch (otheradult_leave*), v(1)
egen otheradult2_arrive=anymatch (otheradult_arrive*), v(1)
egen otheradult2_leave=anymatch (otheradult_leave*), v(1)
egen otheryadult_arrive=anymatch (otheryadult_arrive*), v(1)
egen otheryadult_leave=anymatch (otheryadult_leave*), v(1)
egen adultsib_arrive=anymatch (adultsib_arrive*), v(1)
egen adultsib_leave=anymatch (adultsib_leave*), v(1)
egen addr_change=anymatch (addr_change*), v(1)
egen hh_change=anymatch (hh_change*), v(1)
egen infant_arrive=anymatch(infant_arrive*), v(1)

***create indicators of whether experienced any specific type of change for wave 7-9 (robustness check)
recode numchange710 (2/max=1), gen (anychange710)
recode nmis_compchange710 (2/max=1), gen (anymischange710)
egen parent_changet=anymatch (parent_change7 parent_change8 parent_change9), v(1)
egen sib_changet=anymatch (sib_change7 sib_change8 sib_change9), v(1)
egen nonparent_changet=anymatch (nonparent_change7 nonparent_change8 nonparent_change9), v(1)
egen other_changet=anymatch (other_change7 other_change8 other_change9), v(1)
egen adult_arrivet=anymatch (adult_arrive7 adult_arrive8 adult_arrive9), v(1)
egen adult_leavet=anymatch (adult_leave7 adult_leave8 adult_leave9), v(1)
egen yadult_leavet=anymatch (yadult_leave7 yadult_leave8 yadult_leave9), v(1)
egen yadult_arrivet=anymatch (yadult_arrive7 yadult_arrive8 yadult_arrive9), v(1)
egen adult30_arrivet=anymatch (adult30_arrive7 adult30_arrive8 adult30_arrive9), v(1)
egen adult30_leavet=anymatch (adult30_leave7 adult30_leave8 adult30_leave9), v(1)
egen parent_arrivet=anymatch (parent_arrive7 parent_arrive8 parent_arrive9), v(1)
egen parent_leavet=anymatch (parent_leave7 parent_leave8 parent_leave9), v(1)
egen otheradult30_arrivet=anymatch (otheradult30_arrive7 otheradult30_arrive8 otheradult30_arrive9), v(1)
egen otheradult30_leavet=anymatch (otheradult30_leave7 otheradult30_leave8 otheradult30_leave9), v(1)
egen otheradult_arrivet=anymatch (otheradult_arrive7 otheradult_arrive8 otheradult_arrive9), v(1)
egen otheradult_leavet=anymatch (otheradult_leave7 otheradult_leave8 otheradult_leave9), v(1)
egen otheradult2_arrivet=anymatch (otheradult_arrive7 otheradult_arrive8 otheradult_arrive9), v(1)
egen otheradult2_leavet=anymatch (otheradult_leave7 otheradult_leave8 otheradult_leave9), v(1)
egen otheryadult_arrivet=anymatch (otheryadult_arrive7 otheryadult_arrive8 otheryadult_arrive9), v(1)
egen otheryadult_leavet=anymatch (otheryadult_leave7 otheryadult_leave8 otheryadult_leave9), v(1)
egen adultsib_arrivet=anymatch (adultsib_arrive7 adultsib_arrive8 adultsib_arrive9), v(1)
egen adultsib_leavet=anymatch (adultsib_leave7 adultsib_leave8 adultsib_leave9), v(1)
egen addr_changet=anymatch (addr_change7 addr_change8 addr_change9), v(1)
egen hh_changet=anymatch (hh_change7 hh_change8 hh_change9), v(1)
egen infant_arrivet=anymatch(infant_arrive7 infant_arrive8 infant_arrive9), v(1)

rename SSUID ssuid
rename EPPPNUM epppnum
keep ssuid epppnum adj_age4 my_sex4 anychange410 anymischange410 parent_change sib_change other_change nonparent_change ///
adult_arrive adult_leave parent_arrive parent_leave otheradult30_arrive ///
otheradult30_leave otheradult_arrive otheradult_leave otheradult2_arrive otheradult2_leave addr_change hh_change ///
adult30_arrive adult30_leave yadult_arrive yadult_leave otheryadult_arrive ///
otheryadult_leave adultsib_arrive adultsib_leave otheradult2_arrive otheradult2_leave infant_arrive ///
anychange710 anymischange710 parent_changet sib_changet other_changet nonparent_changet ///
adult_arrivet adult_leavet parent_arrivet parent_leavet otheradult30_arrivet ///
otheradult30_leavet otheradult_arrivet otheradult_leavet otheradult2_arrivet otheradult2_leavet addr_changet hh_changet ///
adult30_arrivet adult30_leavet yadult_arrivet yadult_leavet otheryadult_arrivet ///
otheryadult_leavet adultsib_arrivet adultsib_leavet otheradult2_arrivet otheradult2_leavet infant_arrivet

gen adult_change=1 if adult_arrive==1 | adult_leave==1
replace adult_change=0 if missing(adult_change)

gen yadult_change=1 if yadult_arrive==1 | yadult_leave==1
replace yadult_change=0 if missing(yadult_change)

gen adult30_change=1 if adult30_arrive==1 | adult30_leave==1
replace adult30_change=0 if missing(adult30_change)

gen otheradult_change=1 if otheradult_arrive==1 | otheradult_leave==1
replace otheradult_change=0 if missing(otheradult_change)

gen otheryadult_change=1 if otheryadult_arrive==1 | otheryadult_leave==1
replace otheryadult_change=0 if missing(otheryadult_change)

gen otheradult30_change=1 if otheradult30_arrive==1 | otheradult30_leave==1
replace otheradult30_change=0 if missing(otheradult30_change)

gen adultsib_change=1 if adultsib_arrive==1 | adultsib_leave==1
replace adultsib_change=0 if missing(adultsib_change)

gen otheradult2_change=1 if otheradult2_arrive==1 | otheradult2_leave==1
replace otheradult2_change=0 if missing(otheradult2_change)

keep if adj_age4<=14

save "$tempdir/cwb_hhchange410.dta", $replace

* # Merge with child well being files

merge 1:1 ssuid epppnum using "$tempdir/cwb4.dta", gen(merge4)
merge 1:1 ssuid epppnum using "$tempdir/cwb10.dta", gen(merge10)


