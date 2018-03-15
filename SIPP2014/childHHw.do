* Read in an extract from the SIPP 2014
use "$SIPP2014/selected.dta", clear

keep ssuid pnum monthcode wpfinwgt tage_ehc erace eorigin eeduc rrel* erefpar erelrp erelrpe tage

keep if monthcode==12 
* 72919 individuals

drop monthcode

sort ssuid

save "$tempdir/hhcomp", replace

* Identify which SSUIDs have a household member less than 18

collapse (min) youngest=tage, by(ssuid)
* 29685 households 

keep if youngest < 18
* 9223 households with an individual < 18

save "$tempdir/youngest", replace

* Merge this flag so that we can restrict sample to people living in households with some members <= 17

merge 1:m ssuid using "$tempdir/hhcomp"

keep if _merge==3
* 37251 individuals in households with at least one person < 18

drop _merge

sort ssuid

by ssuid: gen hhmem=_N

tab hhmem
sum hhmem

* Make this file wide

keep ssuid pnum erelrp erelrpe tage hhmem

rename erelrp othererelrp
rename erelrpe othererelrpe
rename tage othertage

reshape wide othererelrp othererelrpe othertage, i(ssuid) j(pnum)

save "$tempdir/widechildhh14", replace
* 9223 households 


* Make a data file with one record for each child

use "$tempdir/hhcomp", clear

keep if tage < 18
* 17584 individuals age < 18

merge m:1 ssuid using "$tempdir/widechildhh14"
assert _merge==3

drop _merge

rename erelrp childerelrp
rename erelrpe childerelrpe
rename pnum childpnum

* Make the data file long so that each person in the child's household is a record

reshape long othererelrp othererelrpe othertage, i(ssuid childpnum) j(otherpnum)

drop if missing(othererelrp)

gen selftoself=0
replace selftoself=1 if childpnum==otherpnum

drop if selftoself==1

tab childerelrp othererelrp
*17584 records dropped because they represent self to self

save $tempdir/baserel_14, replace

gen baserel="PARENT" if inlist(othererelrp,1,3,4) & childerelrp==5
replace baserel="SIB" if othererelrp==5 & childerelrp==5
replace baserel="GRANDPARENT" if othererelrp==6 & childerelrp==5
replace baserel="PARENT/AUNT" if othererelrp==7 & childerelrp==5
replace baserel="AUNT/UNCLE" if othererelrp==8 & childerelrp==5
replace baserel="RELATIVE" if othererelrp==9 & childerelrp==5
replace baserel="NONREL" if inrange(othererelrp,10,13) & childerelrp==5
replace baserel="SPOUSE/PARTNER" if inlist(othererelrp,1,2) & inlist(childerelrp,3,4)
replace baserel="CHILD" if othererelrp==5 & childerelrp==4
replace baserel="GRANDPARENT" if inlist(othererelrp,1,3,4) & childerelrp==6
replace baserel="PARENT/AUNT" if othererelrp==5 & childerelrp==6
replace baserel="RELATIVE" if othererelrp==6 & childerelrp==6
replace baserel="SIB/COUSIN" if othererelrp==7 & childerelrp==6
replace baserel="RELATIVE" if inrange(othererelrp,8,9) & childerelrp==6
replace baserel="NONREL" if inrange(othererelrp,10,13) & childerelrp==6
replace baserel="SIB" if othererelrp==1 & childerelrp==8
replace baserel="RELATIVE" if inlist(othererelrp,3,5,6,7,9) & childerelrp==8
replace baserel="NONREL" if inlist(othererelrp,4,10,11,12,13) & childerelrp==8
replace baserel="RELATIVE" if inlist(othererelrp,1,3,5,6,7,8,9) & childerelrp==9
replace baserel="NONREL" if inlist(othererelrp,4,10,11,12,13) & childerelrp==9
replace baserel="NONREL" if inrange(othererelrp,1,9) & inrange(childerelrp,10,13)
replace baserel="DK" if inrange(othererelrp,10,13) & inrange(childerelrp,10,13)
replace baserel="GRANDCHILD" if othererelrp==7 & childerelrp==1
replace baserel="SIB" if othererelrp==8 & childerelrp==1
replace baserel="RELATIVE" if othererelrp==9 & childerelrp==1
replace baserel="NONREL" if inrange(othererelrp,10,13) & inrange(childerelrp,1,2)


gen otheradult=0
replace otheradult=1 if othertage > 17

tab baserel otheradult

save $tempdir/baserel_14, replace

/* 
tage_ehc < 16

save "$tempdir/childHH.dta", replace

gen anygrandp=0
gen anyhalfsib=0
gen anystepsib=0
gen anyaunn=0
gen anysibil=0
gen anyorel=0
gen anyfoster=0
gen anynonrel=0

forvalues i=1/30{
replace anygrandp=1 if rrel`i'==8
replace anyhalfsib=1 if rrel`i'==10
replace anystepsib=1 if rrel`i'==11
replace anyaunn=1 if rrel`i'==16
replace anysibil=1 if rrel`i'==15
replace anyorel=1 if rrel`i'==17
replace anyfoster=1 if rrel`i'==18
replace anynonrel=1 if rrel`i'==19
}

tab anygrandp [aweight=wpfinwgt]
tab anyhalfsib [aweight=wpfinwgt]
tab anystepsib [aweight=wpfinwgt]
tab anyaunn [aweight=wpfinwgt]
tab anysibil [aweight=wpfinwgt]
tab anyorel [aweight=wpfinwgt]
tab anyfoster [aweight=wpfinwgt]
tab anynonrel

/*


reshape long rrel rrel_pnum, i(ssuid pnum) j(relno)

tab rrel

tab rrel [aweight=wpfinwgt]
