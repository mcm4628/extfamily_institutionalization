* Create measures of household change between wave 4 and wave 10

use "$SIPP08keep/HHchangeWithRelationships.dta", clear

keep if SWAVE==4|SWAVE==5|SWAVE==6|SWAVE==7|SWAVE==8|SWAVE==9
keep SSUID EPPPNUM SWAVE adj_age comp_change parent_change adult_arrive adult_leave ///
parent_arrive parent_leave otheradult30_arrive otheradult30_leave otheradult_arrive ///
otheradult_leave addr_change my_sex hh_change adult30_arrive adult30_leave ///
yadult_arrive yadult_leave otheryadult_arrive otheryadult_leave adultsib_arrive adultsib_leave

reshape wide adj_age comp_change parent_change adult_arrive adult_leave ///
parent_arrive parent_leave otheradult30_arrive otheradult30_leave otheradult_arrive ///
otheradult_leave addr_change adult30_arrive adult30_leave ///
yadult_arrive yadult_leave otheryadult_arrive otheryadult_leave  adultsib_arrive adultsib_leave ///
my_sex hh_change, i(SSUID EPPPNUM) j(SWAVE)

***calculate number of changes experienced between wave 4&10***
gen nmis_compchange410=0 
gen numchange410=0

forvalues i=4/9 {
	replace nmis_compchange410=nmis_compchange410+1 if missing(comp_change`i')
	replace numchange410=numchange410+1 if comp_change`i'==1
}


***drop cases that don't appear in the data between wave4&10***
drop if nmis_compchange410==6


***create indicators of whether experienced any specific type of change 
recode numchange410 (2/max=1), gen (anychange410)
recode nmis_compchange410 (2/max=1), gen (anymischange410)
egen parent_change=anymatch (parent_change*), v(1)
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
egen otheryadult_arrive=anymatch (otheryadult_arrive*), v(1)
egen otheryadult_leave=anymatch (otheryadult_leave*), v(1)
egen adultsib_arrive=anymatch (adultsib_arrive*), v(1)
egen adultsib_leave=anymatch (adultsib_leave*), v(1)
egen addr_change=anymatch (addr_change*), v(1)
egen hh_change=anymatch (hh_change*), v(1)

rename SSUID ssuid
rename EPPPNUM epppnum
keep ssuid epppnum adj_age4 my_sex6 anychange410 anymischange410 parent_change ///
adult_arrive adult_leave parent_arrive parent_leave otheradult30_arrive ///
otheradult30_leave otheradult_arrive otheradult_leave addr_change hh_change ///
adult30_arrive adult30_leave yadult_arrive yadult_leave otheryadult_arrive ///
otheryadult_leave adultsib_arrive adultsib_leave

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

keep if adj_age4<=16

save "$tempdir/cwb_hhchange410.dta", $replace

* # Merge with child well being files

merge 1:1 ssuid epppnum using "$tempdir/cwb4.dta", gen(merge4)
merge 1:1 ssuid epppnum using "$tempdir/cwb10.dta", gen(merge10)


