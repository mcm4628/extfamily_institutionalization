set more off
capture log close
log using "cwb410.log",replace
use "$tempdir/cwb_hhchange410.dta", clear
* # Merge with child well being files
merge 1:1 ssuid epppnum using "$tempdir/cwb4.dta", gen(merge4)
merge 1:1 ssuid epppnum using "$tempdir/cwb10.dta", gen(merge10)

local cwbw4 "ehltstat erepgrad efarscho ethinksc etvrules etimestv ehoustv ehardcar ebother egivuplf eangrycl efuntime epraise eeatbkf eeatdinn eouting eparread elivapat ecounton etrustpe estrtage ehighgra ecurrerl egrdeatt echgschl etimchan"

* measures of child well being. The health question was ask of all respondents and respondent's children.
* tvrules are asked for children age 2 to 17 in families with a designated parent or guardian with one or more children
* eeatbkf and eeatdinn, "In a typical week last month, how many days did designated parent eat breakfast/dinner with child. 
* meals questions are asked of all children age 0-17 in families with a designated parent or guardian.
* grade repeating is asked of children age 5-17.


local cwbw10 "ehltstatw10 erepgradw10 efarschow10 ethinkscw10 etvrulesw10 etimestvw10 ehoustvw10 ehardcarw10 ebotherw10 egivuplfw10 eangryclw10 efuntimew10 epraisew10 eeatbkfw10 eeatdinnw10 eoutingw10 eparreadw10 elivapatw10 ecountonw10 etrustpew10 estrtagew10 ehighgraw10 ecurrerlw10 egrdeattw10 echgschlw10 etimchanw10"


foreach v in `cwbw4' {
replace `v'=. if `v' < 0
}

foreach v in `cwbw10' {
replace `v'=. if `v' < 0
tab `v'
}

********create poverty status***********
capture program drop povertyguide
program def povertyguide

syntax , gen(string) famsize(string) year(string)


capture confirm new var `gen'
if _rc~=0 {
  disp as err "gen must be new var"
  exit 198
}


tempname povtable

#delimit ;
matrix input `povtable' = (
/*       base  incr */
/*2008*/ 10400, 3600 \
/*2009*/ 10830, 3740 \
/*2010*/ 10830, 3740 \
/*2011*/ 10890, 3820 \
/*2012*/ 11170, 3960 \
/*2013*/ 11490, 4020 \
/*2014*/ 11670, 4060 \
/*2015*/ 11770, 4160 
);
#delimit cr


local yearlo "2008"
local yearhi "2015"



tempvar year1
capture gen int `year1' = (`year')
if _rc ~=0 {
    disp in red "invalid expression for year: `year'"
    exit 198
}

capture assert (`year1' >= `yearlo' & `year1' <= `yearhi') | mi(`year1')
if _rc ~=0 {
    disp as error  "Warning: year expression has out-of-bounds values"
    /* But do not exit; just let out-of-bounds values yield missing. */
}

capture assert ~mi(`year1')
if _rc ~=0 {
    disp as error  "Warning: year expression yields some missing values"
    /* But do not exit. */
}

tempvar index1 /* index for year */

gen int `index1' = (`year1' - `yearlo') + 1



tempvar base incr
gen int `base' = `povtable'[`index1', 1]
gen int `incr' = `povtable'[`index1', 2]



tempvar famsiz1
capture gen int `famsiz1' = (`famsize')
/* Note that that is loaded into an int; will be truncated if non-integer.*/
if _rc ~=0 {
    disp in red "invalid expression for famsize: `famsize'"
    exit 198
}

capture assert `famsiz1' >= 1
if _rc ~=0 {
    disp as error  "Warning: famsize expression has out-of-bounds values (<1)"
    /* But do not exit; just let out-of-bounds values yield missing. */
}

capture assert ~mi(`famsiz1')
if _rc ~=0 {
    disp as error  "Warning: famsize expression yields some missing values"
    /* But do not exit. */
}

/* bottom-code  famsiz1 at 1. */
quietly replace `famsiz1' = 1 if `famsiz1' < 1

gen long `gen' = `base' + (`famsiz1' - 1)* `incr'
quietly compress `gen'
end

povertyguide, gen(povguide4) famsize(EHHNUMPP4) year(2009) /*generate poverty line for wave4: year 2009*/
povertyguide, gen(povguide10) famsize(EHHNUMPP10) year(2011) /*generate poverty line for wave10: year 2011*/
gen annualinc4= THTOTINC4*12 
gen annualinc10= THTOTINC10*12 
gen byte pov4 = annualinc4 < povguide4 if ~mi(povguide4) & ~mi(annualinc10) /*generate poverty indicator 1=in poverty*/
gen byte pov10 = annualinc10 < povguide10 if ~mi(povguide4) & ~mi(annualinc10) /*generate poverty indicator 1=in poverty*/


****tv rules index-combine 3 measures:1=having certain rules****
recode etvrules 2=0
recode etimestv 2=0
recode ehoustv 2=0
egen tvrules= rowtotal(etvrules etimestv ehoustv),missing

recode etvrulesw10 2=0
recode etimestvw10 2=0
recode ehoustvw10 2=0
egen tvrulesw10= rowtotal(etvrulesw10 etimestvw10 ehoustvw10),missing

****code sibling change into 4 types*******
gen sibchange4=.
recode sibchange4 .=1 if sib_change==0 //no change
recode sibchange4 .=2 if infant_arrive==1 & adultsib_leave==0 //infant born
recode sibchange4 .=3 if adultsib_leave==1 //adult sibling leaving- note 13 cases experienced both infant arrive and adult sibchange were coded into this category
recode sibchange4 .=4 if sib_change==1 & infant_arrive==0 & adultsib_leave==0 //other sib change

*code parental eductaional expectation outcome//1=wanting college or more
recode efarschow10 (1/3=0) (4/5=1), gen (eduexp10)
recode efarscho (1/3=0) (4/5=1), gen (eduexp4)

*code health into a binary outcome 1=good*
recode ehltstatw10 (2/3=1) (4/5=0), gen(health10)
recode ehltstat (2/3=1) (4/5=0), gen(health4)

*code interested in school 1=interested in school*****
recode eintschl (-1=.) (1/2=0) (3=1), gen (eintschlr)
recode eintschlw10 (-1=.) (1/2=0) (3=1), gen (eintschlw10r)

*code repreating grades 1=yes******
recode erepgradw10 2=0 
recode erepgrad 2=0
tab erepgrad erepgradw10
gen dcase=1 if erepgrad==1 & erepgradw10==0 //tag those who reported yes at wave4 but no at wave10
global model adj_age4 i.par_ed_first i.my_racealt my_sex4 


***build models****
eststo clear
eststo: quietly logit eduexp10 eduexp4 $model, cluster(ssuid)
eststo: quietly logit eduexp10 eduexp4 $model pov10 b2.parentsw10 anyotheradultsw10 num_childw10, cluster(ssuid) // household structure //
eststo: quietly logit eduexp10 eduexp4 $model parent_change other_change i.sibchange4 addr_change pov10 b2.parentsw10 anyotheradultsw10, cluster(ssuid) // household change 
eststo: quietly logit eduexp10 eduexp4 $model parent_change other_change i.sibchange4 addr_change pov10 b2.parentsw10 anyotheradultsw10 num_childw10, cluster(ssuid) // 
esttab


eststo clear
eststo: quietly logit eintschlw10r eintschlr $model, cluster(ssuid)
eststo: quietly logit eintschlw10r eintschlr $model pov10 b2.parentsw10 anyotheradultsw10 num_childw10, cluster(ssuid) // household structure 
eststo: quietly logit eintschlw10r eintschlr $model parent_change other_change i.sibchange4 addr_change pov10 b2.parentsw10 anyotheradultsw10 num_childw10, cluster(ssuid) // household change 
eststo: quietly logit eintschlw10r eintschlr $model parent_change other_change i.sibchange4 addr_change pov10 b2.parentsw10 anyotheradultsw10 num_childw10 tvrulesw10, cluster(ssuid) // household change 
esttab


eststo clear
eststo: quietly logit erepgradw10 erepgrad $model if dcase !=1, cluster(ssuid) 
eststo: quietly logit erepgradw10 erepgrad $model pov10 b2.parentsw10 anyotheradultsw10 num_childw10 if dcase !=1, cluster(ssuid) // household structure 
eststo: quietly logit erepgradw10 erepgrad $model parent_change other_change addr_change pov10 b2.parentsw10 anyotheradultsw10 num_childw10 if dcase !=1, cluster(ssuid) // household change 
eststo: quietly logit erepgradw10 erepgrad $model parent_change other_change addr_change pov10 b2.parentsw10 anyotheradultsw10 num_childw10 tvrulesw10 if dcase !=1, cluster(ssuid)  
esttab


****************MAKING TABLES***************************************************
********************************************************************************
logit eduexp10 eduexp4 $model, cluster(ssuid)
outreg2 using eduexp, dec(2) stats (coef se pval) alpha(0.001, 0.01, 0.05) replace side noparen noobs excel ctitle(coef)
logit eduexp10 eduexp4 $model pov10 b2.parentsw10 anyotheradultsw10 num_childw10, cluster(ssuid) // household structure 
outreg2 using eduexp, dec(2) stats (coef se pval) alpha(0.001, 0.01, 0.05) append side noparen noobs excel ctitle(coef)
logit eduexp10 eduexp4 $model parent_change other_change i.sibchange4 addr_change pov10 b2.parentsw10 anyotheradultsw10, cluster(ssuid) // household change 
outreg2 using eduexp, dec(2) stats (coef se pval) alpha(0.001, 0.01, 0.05) append side noparen noobs excel ctitle(coef)
logit eduexp10 eduexp4 $model parent_change other_change i.sibchange4 addr_change pov10 b2.parentsw10 anyotheradultsw10 num_childw10, cluster(ssuid)  
outreg2 using eduexp, dec(2) stats (coef se pval) alpha(0.001, 0.01, 0.05) append side noparen noobs excel ctitle(coef)


logit eintschlw10r eintschlr $model, cluster(ssuid)
outreg2 using sinterest, dec(2) stats (coef se pval) alpha(0.001, 0.01, 0.05) replace side noparen noobs excel ctitle(coef)
logit eintschlw10r eintschlr $model pov10 b2.parentsw10 anyotheradultsw10 num_childw10, cluster(ssuid) // household structure 
outreg2 using sinterest, dec(2) stats (coef se pval) alpha(0.001, 0.01, 0.05) append side noparen noobs excel ctitle(coef)
logit eintschlw10r eintschlr $model parent_change other_change i.sibchange4 addr_change pov10 b2.parentsw10 anyotheradultsw10 num_childw10, cluster(ssuid) // household change 
outreg2 using sinterest, dec(2) stats (coef se pval) alpha(0.001, 0.01, 0.05) append side noparen noobs excel ctitle(coef)
logit eintschlw10r eintschlr $model parent_change other_change i.sibchange4 addr_change pov10 b2.parentsw10 anyotheradultsw10 tvrulesw10, cluster(ssuid)  
outreg2 using sinterest, dec(2) stats (coef se pval) alpha(0.001, 0.01, 0.05) append side noparen noobs excel ctitle(coef)


logit erepgradw10 erepgrad $model if dcase !=1, cluster(ssuid)
outreg2 using grepeating, dec(2) stats (coef se pval) alpha(0.001, 0.01, 0.05) replace side noparen noobs excel ctitle(coef)
logit erepgradw10 erepgrad $model pov10 b2.parentsw10 anyotheradultsw10 num_childw10 if dcase !=1, cluster(ssuid) // household structure 
outreg2 using grepeating, dec(2) stats (coef se pval) alpha(0.001, 0.01, 0.05) append side noparen noobs excel ctitle(coef)
logit erepgradw10 erepgrad $model parent_change other_change sib_change addr_change pov10 b2.parentsw10 anyotheradultsw10 num_childw10 if dcase !=1, cluster(ssuid) // household change 
outreg2 using grepeating, dec(2) stats (coef se pval) alpha(0.001, 0.01, 0.05) append side noparen noobs excel ctitle(coef)
logit erepgradw10 erepgrad $model parent_change other_change sib_change addr_change pov10 b2.parentsw10 anyotheradultsw10 num_childw10 tvrulesw10 if dcase !=1, cluster(ssuid) 
outreg2 using grepeating, dec(2) stats (coef se pval) alpha(0.001, 0.01, 0.05) append side noparen noobs excel ctitle(coef)
******erepgrad was dropped because erepgrad != 0 predicts success perfectly
********************************************************************************



/****robustness check---instability in past year (wave 7-10)
gen sibchange4t=.
recode sibchange4t .=1 if sib_changet==0 //no change
recode sibchange4t .=2 if infant_arrivet==1 & adultsib_leave==0 //infant born
recode sibchange4t .=3 if adultsib_leave==1 //adult leaving
recode sibchange4t .=4 if sib_changet==1 & infant_arrivet==0 & adultsib_leavet==0 //other sib change


eststo clear
eststo: quietly logit eduexp10 eduexp4 $model, cluster(ssuid)
eststo: quietly logit eduexp10 eduexp4 $model pov10 b2.parentsw10 anyotheradultsw10 num_childw10, cluster(ssuid) // household structure //
eststo: quietly logit eduexp10 eduexp4 $model parent_changet other_changet i.sibchange4t addr_changet pov10 b2.parentsw10 anyotheradultsw10, cluster(ssuid) // household change 
eststo: quietly logit eduexp10 eduexp4 $model parent_changet other_changet i.sibchange4t addr_changet pov10 b2.parentsw10 anyotheradultsw10 num_childw10, cluster(ssuid) // 
esttab
***infant arriving not significant

eststo clear
eststo: quietly logit eintschlw10r eintschlr $model, cluster(ssuid)
eststo: quietly logit eintschlw10r eintschlr $model pov10 b2.parentsw10 anyotheradultsw10 num_childw10, cluster(ssuid) // household structure 
eststo: quietly logit eintschlw10r eintschlr $model parent_changet other_changet i.sibchange4t addr_changet pov10 b2.parentsw10 anyotheradultsw10 num_childw10, cluster(ssuid) // household change 
eststo: quietly logit eintschlw10r eintschlr $model parent_changet other_changet i.sibchange4t addr_changet pov10 b2.parentsw10 anyotheradultsw10 num_childw10 tvrulesw10, cluster(ssuid) // household change 
esttab
***adult sib leaving still significant

eststo clear
eststo: quietly reg erepgradw10 erepgrad $model if dcase !=1, cluster(ssuid)
eststo: quietly reg erepgradw10 erepgrad $model pov10 b2.parentsw10 anyotheradultsw10 num_childw10 if dcase !=1, cluster(ssuid) // household structure 
eststo: quietly reg erepgradw10 erepgrad $model parent_changet other_changet sib_changet addr_changet pov10 b2.parentsw10 anyotheradultsw10 num_childw10 if dcase !=1, cluster(ssuid) // household change 
eststo: quietly reg erepgradw10 erepgrad $model parent_changet other_changet sib_changet addr_changet pov10 b2.parentsw10 anyotheradultsw10 num_childw10 tvrulesw10 if dcase !=1, cluster(ssuid) // household change 
esttab
***address change no more significant but parent change appear to be significant





/*4 types of changes:parent and non parent non sibling change*
gen change_4type1=.
recode change_4type1 .=1 if parent_change==0 & other_change==0 //no change
recode change_4type1 .=2 if parent_change==1 & other_change==0 //only parent change
recode change_4type1 .=3 if parent_change==0 & other_change==1 //only other change
recode change_4type1 .=4 if parent_change==1 & other_change==1 //joint change

*8 indicators-adding address change
gen change_8type1=.
recode change_8type1 .=1 if change_4type1==1 & addr_change==0 //no compchange and no addr change
recode change_8type1 .=2 if change_4type1==2 & addr_change==0 //only parent change 
recode change_8type1 .=3 if change_4type1==3 & addr_change==0 //only other change
recode change_8type1 .=4 if change_4type1==4 & addr_change==0 //joint change
recode change_8type1 .=5 if change_4type1==1 & addr_change==1 //no compychange with addr change
recode change_8type1 .=6 if change_4type1==2 & addr_change==1 //only parent change with addr change
recode change_8type1 .=7 if change_4type1==3 & addr_change==1 //only other change with addr change
recode change_8type1 .=8 if change_4type1==4 & addr_change==1 //joint change with addr change

*8 indicators-adding sibling change
gen change_8type2=.
recode change_8type2 .=1 if change_4type1==1 & sib_change==0 //no compchange
recode change_8type2 .=2 if change_4type1==2 & sib_change==0 //only parent change 
recode change_8type2 .=3 if change_4type1==3 & sib_change==0 //only other change
recode change_8type2 .=4 if change_4type1==4 & sib_change==0 //parent and nonparent change
recode change_8type2 .=5 if change_4type1==1 & sib_change==1 //only sibchange
recode change_8type2 .=6 if change_4type1==2 & sib_change==1 //parent change with sib change
recode change_8type2 .=7 if change_4type1==3 & sib_change==1 //other change with sib change
recode change_8type2 .=8 if change_4type1==4 & sib_change==1 //3 changes

*4 types of changes:parent and non parent change-including sibling change*
gen change_4type2=.
recode change_4type2 .=1 if parent_change==0 & nonparent_change==0 //no change
recode change_4type2 .=2 if parent_change==1 & nonparent_change==0 //only parent change
recode change_4type2 .=3 if parent_change==0 & nonparent_change==1 //only other change
recode change_4type2 .=4 if parent_change==1 & nonparent_change==1 //joint change

*4 types of changes:parent and non parent adult change-including adult sibling change*
gen change_4type3=.
recode change_4type3 .=1 if parent_change==0 & otheradult_change==0 //no change
recode change_4type3 .=2 if parent_change==1 & otheradult_change==0 //only parent change
recode change_4type3 .=3 if parent_change==0 & otheradult_change==1 //only other change
recode change_4type3 .=4 if parent_change==1 & otheradult_change==1 //joint change

*4 types of changes:parent and non parent adult change- not including sibling change*
gen change_4type4=.
recode change_4type4 .=1 if parent_change==0 & otheradult2_change==0 //no change
recode change_4type4 .=2 if parent_change==1 & otheradult2_change==0 //only parent change
recode change_4type4 .=3 if parent_change==0 & otheradult2_change==1 //only other change
recode change_4type4 .=4 if parent_change==1 & otheradult2_change==1 //joint change

*health as outcome:best fit with parent change and all other nonparent change
eststo clear
eststo: quietly logit health10 health4 $model, cluster(ssuid)
eststo: quietly logit health10 health4 $model b2.parentsw10 anyotheradultsw10 , cluster(ssuid) // household structure //
eststo: quietly logit health10 health4 $model ib1.change_4type2, cluster(ssuid) // household change //
eststo: quietly logit health10 health4 $model b2.parentsw10 anyotheradultsw10 ib1.change_4type2, cluster(ssuid) // 
esttab

eststo clear
eststo: quietly logit erepgradw10 erepgrad $model, cluster(ssuid)
eststo: quietly logit erepgradw10 erepgrad $model b2.parentsw10 anyotheradultsw10 , cluster(ssuid) // household structure //
eststo: quietly logit erepgradw10 erepgrad $model ib1.change_8type2, cluster(ssuid) // household change //
eststo: quietly logit erepgradw10 erepgrad $model b2.parentsw10 anyotheradultsw10 ib1.change_8type1, cluster(ssuid) // 
esttab

*education expectation as outcome-sib change is significant (pure sibling change)

eststo clear
eststo: quietly logit eduexp10 eduexp4 $model, cluster(ssuid)
eststo: quietly logit eduexp10 eduexp4 $model b2.parentsw10 anyotheradultsw10 , cluster(ssuid) // household structure //
eststo: quietly logit eduexp10 eduexp4 $model ib1.change_8type2, cluster(ssuid) // household change //
eststo: quietly logit eduexp10 eduexp4 $model b2.parentsw10 anyotheradultsw10 parent_change other_change sib_change, cluster(ssuid) // 
esttab

*eating breakfast together as outcome-other change significant (may need to deal with extreme values)
eststo clear
eststo: quietly regress eeatbkfw10 eeatbkf $model, cluster(ssuid)
eststo: quietly regress eeatbkfw10 eeatbkf $model b2.parentsw10 anyotheradultsw10 , cluster(ssuid) // household structure //
eststo: quietly regress eeatbkfw10 eeatbkf $model parent_change otheradult_change, cluster(ssuid) // household change //
eststo: quietly regress eeatbkfw10 eeatbkf $model b2.parentsw10 anyotheradultsw10 parent_change other_change sib_change addr_change, cluster(ssuid) // 
esttab

/*doesn't work for eating dinner
eststo clear
eststo: quietly regress eeatdinnw10 eeatdinn $model, cluster(ssuid)
eststo: quietly regress eeatdinnw10 eeatdinn $model b2.parentsw10 anyotheradultsw10 , cluster(ssuid) // household structure //
eststo: quietly regress eeatdinnw10 eeatdinn $model parent_change otheradult_change, cluster(ssuid) // household change //
eststo: quietly regress eeatdinnw10 eeatdinn $model b2.parentsw10 anyotheradultsw10 ib1.change_8type2, cluster(ssuid) // 
esttab 


eststo clear
eststo: quietly regress eoutingw10 eouting $model, cluster(ssuid)
eststo: quietly regress eoutingw10 eouting $model b2.parentsw10 anyotheradultsw10 , cluster(ssuid) // household structure //
eststo: quietly regress eoutingw10 eouting $model parent_change otheradult_change, cluster(ssuid) // household change //
eststo: quietly regress eoutingw10 eouting $model b2.parentsw10 anyotheradultsw10 ib1.change_8type2, cluster(ssuid) // 
esttab


eststo clear
eststo: quietly regress eparreadw10 eparread $model, cluster(ssuid)
eststo: quietly regress eparreadw10 eparread $model b2.parentsw10 anyotheradultsw10 , cluster(ssuid) // household structure //
eststo: quietly regress eparreadw10 eparread $model parent_change otheradult_change, cluster(ssuid) // household change //
eststo: quietly regress eparreadw10 eparread $model b2.parentsw10 anyotheradultsw10 ib1.change_8type2, cluster(ssuid) // 
esttab */

*tv rules as outcome-sib change is significant (pure sibling change)
recode tvrulesw10 (1/2=0) (3=1), gen (tvrules10)
recode tvrules (1/2=0) (3=1), gen (tvrules4)
eststo clear
eststo: quietly regress tvrulesw10 tvrules $model, cluster(ssuid)
eststo: quietly regress tvrulesw10 tvrules $model b2.parentsw10 anyotheradultsw10 , cluster(ssuid) // household structure //
eststo: quietly regress tvrulesw10 tvrules $model parent_change otheradult_change, cluster(ssuid) // household change //
eststo: quietly regress tvrulesw10 tvrules $model b2.parentsw10 anyotheradultsw10 ib1.change_8type2, cluster(ssuid) // 
esttab

eststo clear
eststo: quietly logit eintschlw10r eintschlr $model, cluster(ssuid)
eststo: quietly logit eintschlw10r eintschlr $model b2.parentsw10 anyotheradultsw10 , cluster(ssuid) // household structure //
eststo: quietly logit eintschlw10r eintschlr $model , cluster(ssuid) // household change //
eststo: quietly logit eintschlw10r eintschlr $model b2.parentsw10 anyotheradultsw10 parent_change other_change sib_change addr_change, cluster(ssuid) // 
esttab



eststo clear
eststo: quietly logit health10 health4 $model b2.parentsw10 anyotheradultsw10 ib1.change_8type1, cluster(ssuid) 
eststo: quietly logit erepgradw10 erepgrad $model b2.parentsw10 anyotheradultsw10 ib1.change_8type1, cluster(ssuid)
eststo: quietly logit eduexp10 eduexp4 $model b2.parentsw10 anyotheradultsw10 ib1.change_8type1, cluster(ssuid)
eststo: quietly regress eeatbkfw10 eeatbkf $model b2.parentsw10 anyotheradultsw10 ib1.change_8type1, cluster(ssuid) 
eststo: quietly regress tvrulesw10 tvrules $model b2.parentsw10 anyotheradultsw10 ib1.change_8type1, cluster(ssuid)
esttab

eststo clear
eststo: quietly logit health10 health4 $model b2.parentsw10 anyotheradultsw10 ib1.change_8type2, cluster(ssuid) 
eststo: quietly logit erepgradw10 erepgrad $model b2.parentsw10 anyotheradultsw10 ib1.change_8type2, cluster(ssuid)
eststo: quietly logit eduexp10 eduexp4 $model b2.parentsw10 anyotheradultsw10 ib1.change_8type2, cluster(ssuid)
eststo: quietly regress eeatbkfw10 eeatbkf $model b2.parentsw10 anyotheradultsw10 ib1.change_8type2, cluster(ssuid) 
eststo: quietly regress tvrulesw10 tvrules $model b2.parentsw10 anyotheradultsw10 ib1.change_8type2, cluster(ssuid)
esttab

eststo clear
eststo: quietly logit health10 health4 $model b2.parentsw10 anyotheradultsw10 parent_change other_change sib_change addr_change, cluster(ssuid) 
eststo: quietly logit erepgradw10 erepgrad $model b2.parentsw10 anyotheradultsw10 parent_change other_change sib_change addr_change, cluster(ssuid)
eststo: quietly logit eduexp10 eduexp4 $model b2.parentsw10 anyotheradultsw10 parent_change other_change sib_change addr_change, cluster(ssuid)
eststo: quietly regress eeatbkfw10 eeatbkf $model b2.parentsw10 anyotheradultsw10 parent_change other_change sib_change addr_change, cluster(ssuid) 
eststo: quietly regress tvrulesw10 tvrules $model b2.parentsw10 anyotheradultsw10 parent_change other_change sib_change addr_change, cluster(ssuid)
esttab

log close

eststo clear
eststo: quietly logit health10 health4 adj_age4 i.par_ed_first i.my_racealt my_sex4 pov4 parent_change other_change sib_change addr_change, cluster(ssuid) 
eststo: quietly logit erepgradw10 erepgrad adj_age4 i.par_ed_first i.my_racealt my_sex4 pov4 parent_change other_change sib_change addr_change, cluster(ssuid)
eststo: quietly logit eduexp10 eduexp4 adj_age4 i.par_ed_first i.my_racealt my_sex4 pov4 parent_change other_change sib_change addr_change, cluster(ssuid)
eststo: quietly regress eeatbkfw10 eeatbkf adj_age4 i.par_ed_first i.my_racealt my_sex4 pov4 parent_change other_change sib_change addr_change, cluster(ssuid) 
eststo: quietly regress tvrulesw10 tvrules adj_age4 i.par_ed_first i.my_racealt my_sex4 pov4 parent_change other_change sib_change addr_change, cluster(ssuid)
esttab

eststo clear
eststo: quietly logit health10 health4 adj_age4 i.par_ed_first i.my_racealt my_sex4 pov4 parent_change, cluster(ssuid) 
eststo: quietly logit erepgradw10 erepgrad adj_age4 i.par_ed_first i.my_racealt my_sex4 pov4 parent_change, cluster(ssuid)
eststo: quietly logit eduexp10 eduexp4 adj_age4 i.par_ed_first i.my_racealt my_sex4 pov4 parent_change, cluster(ssuid)
eststo: quietly regress eeatbkfw10 eeatbkf adj_age4 i.par_ed_first i.my_racealt my_sex4 pov4 parent_change, cluster(ssuid) 
eststo: quietly regress tvrulesw10 tvrules adj_age4 i.par_ed_first i.my_racealt my_sex4 pov4 parent_change, cluster(ssuid)
esttab

eststo clear
eststo: quietly logit health10 health4 adj_age4 i.par_ed_first i.my_racealt my_sex4 parent_change, cluster(ssuid) 
eststo: quietly logit erepgradw10 erepgrad adj_age4 i.par_ed_first i.my_racealt my_sex4 parent_change, cluster(ssuid)
eststo: quietly logit eduexp10 eduexp4 adj_age4 i.par_ed_first i.my_racealt my_sex4 parent_change, cluster(ssuid)
eststo: quietly regress eeatbkfw10 eeatbkf adj_age4 i.par_ed_first i.my_racealt my_sex4 parent_change, cluster(ssuid) 
eststo: quietly regress tvrulesw10 tvrules adj_age4 i.par_ed_first i.my_racealt my_sex4 parent_change, cluster(ssuid)
esttab


eststo clear
eststo: quietly logit health10 health4 adj_age4 i.par_ed_first i.my_racealt my_sex4 pov4 parent_change nonparent_change addr_change, cluster(ssuid) 
eststo: quietly logit erepgradw10 erepgrad adj_age4 i.par_ed_first i.my_racealt my_sex4 pov4 parent_change nonparent_change addr_change, cluster(ssuid)
eststo: quietly logit eduexp10 eduexp4 adj_age4 i.par_ed_first i.my_racealt my_sex4 pov4 parent_change nonparent_change addr_change, cluster(ssuid)
eststo: quietly regress eeatbkfw10 eeatbkf adj_age4 i.par_ed_first i.my_racealt my_sex4 pov4 parent_change nonparent_change addr_change, cluster(ssuid) 
eststo: quietly regress tvrulesw10 tvrules adj_age4 i.par_ed_first i.my_racealt my_sex4 pov4 parent_change nonparent_change addr_change, cluster(ssuid)
eststo: quietly logit eintschlw10r eintschlr $model b2.parentsw10 anyotheradultsw10 parent_change nonparent_change addr_change, cluster(ssuid)
esttab






