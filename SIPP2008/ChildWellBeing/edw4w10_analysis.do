* Analysis of children's educational performance based on measures available in
* waves 4 and 10 of the SIPP 2008
*
* See cwb_analysis2 for a wider array of variables available in the SIPP Waves 4 and 10
* that are in the analysis data file, but not part of this analysis for PAA 2019.

set more off
capture log close
log using "cwb410.log",replace
use "$tempdir/cwb_hhchange410.dta", clear

keep if adj_age4 > 6 & adj_age4 < 16

tab inwave4 inwave10, m

* # Merge with child well being files

merge 1:1 ssuid epppnum using "$tempdir/cwb4.dta", gen(merge4)
keep if merge4==3

merge 1:1 ssuid epppnum using "$tempdir/cwb10.dta", gen(merge10)
keep if merge10==1 | merge10==3

local cwbw4 "erepgrad efarscho ethinksc ehighgra ecurrerl egrdeatt echgschl"

* measures of child well being. The health question was ask of all respondents and respondent's children.
* tvrules are asked for children age 2 to 17 in families with a designated parent or guardian with one or more children
* eeatbkf and eeatdinn, "In a typical week last month, how many days did designated parent eat breakfast/dinner with child. 
* meals questions are asked of all children age 0-17 in families with a designated parent or guardian.
* grade repeating is asked of children age 5-17.

local cwbw10 "erepgradw10 efarschow10 ethinkscw10 ehighgraw10 ecurrerlw10 egrdeattw10 echgschlw10"

foreach v in `cwbw4' {
replace `v'=. if `v' < 0
}

foreach v in `cwbw10' {
replace `v'=. if `v' < 0
}

drop swave

rename ssuid SSUID
rename epppnum EPPPNUM

merge 1:m SSUID EPPPNUM using "$tempdir/PovbyWave", keepusing(cpov rpov SWAVE)

keep if SWAVE==4

tab _merge

keep if _merge==3
drop _merge
drop SWAVE

rename cpov cpov4
rename rpov rpov4

merge 1:m SSUID EPPPNUM using "$tempdir/PovbyWave", keepusing(cpov rpov SWAVE)

keep if SWAVE==10

tab _merge

keep if _merge==3
drop _merge

rename cpov cpov10
rename rpov rpov10
rename  SSUID ssuid
rename  EPPPNUM epppnum 

*********************************************************************************
* Recode Child well being measures
*********************************************************************************

*code parental eductaional hopes outcome//1=wanting college or more
recode efarschow10 (1/3=0) (4/5=1), gen (eduhope10)
recode efarscho (1/3=0) (4/5=1), gen (eduhope4)

*code parental eductaional expectation outcome//1=thinks college or more
recode ethinkscw10 (1/3=0) (4/5=1), gen (eduexp10)
recode ethinksc (1/3=0) (4/5=1), gen (eduexp4)

*code interested in school 1=interested in school*****
recode eintschl (1/2=0) (3=1), gen (eintschlr)
recode eintschlw10 (1/2=0) (3=1), gen (eintschlw10r)

*code repreating grades 1=yes******
recode erepgradw10 2=0 
recode erepgrad 2=0

gen dcase=1 if erepgrad==1 & erepgradw10==0 //tag those who reported yes at wave4 but no at wave10

*********************************************************************************
* Recode measures of household change
*********************************************************************************

gen sibchange3=.
recode sibchange3 .=1 if sib_change==0 //no change
recode sibchange3 .=2 if infant_arrive==1 //infant born note 13 cases experienced both infant arrive and adult sibchange were coded into this category
recode sibchange3 .=3 if sib_change==1 & infant_arrive==0 // other sibling changes

* interaction between other change and address change
gen otheraddr=0 if other_change==0 & addr_change==0
replace otheraddr=1 if other_change==1 & addr_change==0
replace otheraddr=2 if other_change==0 & addr_change==1
replace otheraddr=3 if other_change==1 & addr_change==1

recode numobs410 (6=0)(1/5=1), gen(anymis410)
* did respondent miss any observations between wave 4 and 10?

*********************************************************************************
* Descriptive analysis
*********************************************************************************

* Are those who are in topical module 10 different from TM 4 sample?

sort merge10
by merge10: sum adj_age4

tab par_ed_first merge10, nofreq col
tab my_racealt merge10, nofreq col
tab my_sex4 merge10, nofreq col
tab parentsw10 merge10, nofreq col
tab anynnadultw10 merge10, nofreq col
tab num_childw10 merge10, nofreq col
tab cpov10 merge10, nofreq col
tab parent_change merge10, nofreq col
tab sibchange3 merge10, nofreq col
tab other_change merge10, nofreq col
tab addr_change merge10, nofreq col

keep if merge10==3

********************************************************************************
* Fix missing values
********************************************************************************

replace par_ed_first=5 if missing(par_ed_first)
replace parents=0 if missing(parents)
replace anynnadult=0 if missing(anynnadult)
replace num_child=1 if missing(num_child)
replace addr_change=2 if missing(addr_change)

********************************************************************************
* description of outcome variables
********************************************************************************

tab elikeschw10 
tab eintschlw10 
tab erepgradw10 

********************************************************************************
* Setting up for multi-variate models. 
*******************************************************************************

gen agesq=adj_age4*adj_age4
* agesq did not improve model fit

local ivs "adj_age4 i.par_ed_first i.my_racealt my_sex4 i.cpov10 b2.parentsw10 anynnadultw10 num_childw10 parent_change i.sibchange3 other_change addr_change"

local basevar "adj_age4 i.par_ed_first i.my_racealt my_sex4 b3.cpov4"
local compvar "b2.parents i.anynnadultw10 num_child b3.cpov10"
local changevar "parent_change i.sibchange3 other_change i.addr_change"

********************************************************************************
* Models
*******************************************************************************

*foreach var in `ivs' {
* ologit elikeschw10 `var' if !missing(elikeschw10), cluster(ssuid)
* ologit elikeschw10 elikesch `var' if !missing(elikeschw10), cluster(ssuid)
*}

eststo clear
eststo: quietly ologit elikeschw10 elikesch `basevar' `changevar', cluster(ssuid)
eststo: quietly ologit elikeschw10 elikesch `basevar' `compvar', cluster(ssuid)
eststo: quietly ologit elikeschw10 elikesch `basevar' `changevar' `compvar', cluster(ssuid)
esttab using "$cwb_results/like.csv", $replace

*foreach var in `ivs' {
* ologit eintschlw10 `var' if eintschlw10 > 0 & adj_age > 6, cluster(ssuid)
* ologit eintschlw10 eintschl `var' if eintschlw10 > 0 & adj_age > 6, cluster(ssuid)
*}

eststo clear
eststo: quietly ologit eintschlw10 eintschl `basevar' `changevar', cluster(ssuid)
eststo: quietly ologit eintschlw10 eintschl `basevar' `compvar', cluster(ssuid)
eststo: quietly ologit eintschlw10 eintschl `basevar' `changevar' `compvar', cluster(ssuid)
esttab using "$cwb_results/interested.csv", $replace

*foreach var in `ivs' {
* logistic erepgradw10 `var' if  adj_age4 > 6, cluster(ssuid)
* logistic erepgradw10 erepgrad `var' if  adj_age4 > 6, cluster(ssuid)
*}

eststo clear
eststo: quietly logit erepgradw10 erepgrad `basevar' `changevar', cluster(ssuid)
eststo: quietly logit erepgradw10 erepgrad `basevar' `compvar', cluster(ssuid)
eststo: quietly logit erepgradw10 erepgrad `basevar' `changevar' `compvar', cluster(ssuid)
esttab using "$cwb_results/repgrade.csv", $replace

/*
