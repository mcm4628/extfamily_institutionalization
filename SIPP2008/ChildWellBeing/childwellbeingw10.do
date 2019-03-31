use "$SIPP2008/FullFile/sippp08putm10.dta", clear
destring epppnum, replace

keep ssuid swave shhadid epppnum /// 
 ehltstat erepgrad ///health status and repeating grades
 efarscho edadfar ethinksc ///parent expectations
 etvrules etimestv ehoustv ///parent control-tv rules
 ehardcar ebother egivuplf eangrycl ///parenting emotions
 efuntime edadfun epraise edadprai ///emotional support-praise & fun times
 eeatbkf edadbrkf eeatdinn edaddinn ///parent-child activities undertaken
 eouting etotread eparread edadread ///parent-child activities undertaken
 elivapat ecounton etrustpe ///
 elikesch eintschl /// interest in school
 estrtage ehighgra ecurrerl egrdeatt echgschl etimchan ///grades related
 egrdrpt1 egrdrpt2 egrdrpt3 egrdrpt4 egrdrpt5 //grades repeated

rename ehltstat ehltstatw10
rename erepgrad erepgradw10
rename efarscho efarschow10
rename edadfar edadfarw10
rename ethinksc ethinkscw10
rename etvrules etvrulesw10
rename etimestv etimestvw10
rename ehoustv ehoustvw10
rename ehardcar ehardcarw10
rename ebother ebotherw10
rename egivuplf egivuplfw10
rename eangrycl eangryclw10
rename efuntime efuntimew10
rename edadfun edadfunw10
rename epraise epraisew10
rename edadprai edadpraiw10
rename eeatbkf eeatbkfw10
rename eeatdinn eeatdinnw10
rename edadbrkf edadbrkfw10
rename edaddinn edaddinnw10
rename eouting eoutingw10
rename etotread etotreadw10
rename eparread eparreadw10
rename edadread edadreadw10
rename elivapat elivapatw10
rename ecounton ecountonw10
rename etrustpe etrustpew10
rename elikesch elikeschw10
rename eintschl eintschlw10

foreach v in estrtage ehighgra ecurrerl egrdeatt echgschl etimchan egrdrpt1 egrdrpt2 egrdrpt3 egrdrpt4 egrdrpt5 {
rename `v' `v'w10
}

save "$SIPP2008/FullFile/TM10/childwellbeing.dta", replace


***create hhtype*********
use "$SIPP08keep/HHComp_asis.dta", clear
* Note that this file has one record per person in indivdual's household.


**keep sample to wave10
keep if SWAVE==10
keep if adj_age<=17

keep SSUID EPPPNUM SHHADID relationship adj_age to_age to_sex
sort SSUID EPPPNUM
by SSUID EPPPNUM: gen n=_n

****give the relationship backwards to children***
gen parent=1 if inlist(relationship,1,4,7,19,21)
gen grandparent=1 if inlist(relationship,13,14,27)
gen grandmother=1 if inlist(relationship,13,14,27) & to_sex==2
gen other_rel=1 if inlist(relationship, 15,16,24,25,26,28,29,30,31,33,32,35,36) 
gen other_femrel=1 if inlist(relationship, 15,16,24,25,26,28,29,30,31,33,32,35,36) & to_sex==2 
gen unknown=1 if relationship==40 | missing(relationship)

gen otheradult30=. 
recode otheradult30 .=1 if parent==.  & to_age>30
gen otherfemadult30=1 if otheradult30==1 & to_sex==2
gen othermaladult30=1 if otheradult30==1 & to_sex==1

gen otheradult=.
recode otheradult .=1 if parent==.  & to_age>=18
gen otherfemadult =1 if otheradult==1 & to_sex==2
gen othermaladult =1 if otheradult==1 & to_sex==1
gen child=1 if to_age<=16

reshape wide to_age to_sex relationship parent grandparent grandmother other_rel other_femrel child otheradult30 otherfemadult30 othermaladult30 otheradult otherfemadult othermaladult unknown, i(SSUID EPPPNUM) j(n)

sum adj_age

****count number of each type of people in hh****
egen parentsw10=anycount(parent*), v(1)
egen otheradults30w10=anycount(otheradult30*), v(1)
egen otherfemadult30w10=anycount(otherfemadult30*), v(1)
egen othermaladult30w10=anycount(othermaladult30*), v(1)
egen grandmotherw10=anycount(grandmother*), v(1)
egen otheradultsw10=anycount(otheradult*), v(1)
egen otherfemadultsw10=anycount(otherfemadult*), v(1)
egen othermaladultsw10=anycount(othermaladult*), v(1)
egen childrenw10=anycount(child*), v(1)
gen num_childw10=childrenw10+1
recode otheradults30w10 (2/max=1), gen (anyotheradults30w10)
recode otheradultsw10 (2/max=1), gen (anyotheradultsw10)

tab parentsw10
recode parentsw10 3=2

recode otherfemadult30w10 (0=0)(1/3=1), gen(anyofem30w10)
recode othermaladult30w10 (0=0)(1/3=1), gen(anyomal30w10)
recode otherfemadultsw10 (0=0)(1/9=1), gen(anyofem18w10)
recode othermaladultsw10 (0=0)(1/9=1), gen(anyomal18w10)

merge 1:1 SSUID EPPPNUM using "$tempdir/person_wide.dta", keepusing (par_ed_first my_racealt THTOTINC10 EHHNUMPP10)

keep if _merge==3

drop _merge

rename SSUID ssuid
rename EPPPNUM epppnum 

merge 1:1 ssuid epppnum using "$SIPP2008/FullFile/TM10/childwellbeing.dta"
keep if _merge==3
drop _merge

save "$tempdir/cwb10.dta", $replace

