*Stack two intervals to see "Who Moved"
* but so far, only one wave...

* first stage is to read in data files with information basic demographics and partnerchange

use "$tempdir/demo.dta", clear


merge 1:1 ssuid pnum using "$tempdir/partner_change.dta"
* Note that partner_change.dta has variables describing biological mothers partnership changes
* but only for individuals less than age 18. Created with childrenHH14.do
* Also, partner changes are available only for type 1 biomoms. 

keep if _merge==3

tab biomom8 biomom12

drop _merge

merge 1:1 ssuid pnum using "$tempdir/anydiff812.dta"

keep if _merge==3

drop _merge

gen interval=2

save "$tempdir/whomoved812.dta", replace

use "$tempdir/demo.dta", clear

keep ssuid pnum wpfinwgt

merge 1:1 ssuid pnum using "$tempdir/partner_change.dta"

keep if _merge==3

tab biomom4 biomom8

drop _merge

merge 1:1 ssuid pnum using "$tempdir/anydiff48.dta"

keep if _merge==3

drop _merge

gen interval=1

append using "$tempdir/whomoved812.dta"
tab interval

*gen mom_educ=biomomeduc12
*recode mom_educ (31/38=1)(39=2)(40/43=3)(44/47=4), gen (momced)
* this variable is on longbiomom, but now I'm troubleshooting and don't care

gen raceth=4
replace raceth=1 if erace==1 & eorigin==2
replace raceth=2 if erace==2
replace raceth=3 if erace !=2 & eorigin==1
replace raceth=4 if erace==3 

*recode biomomeduc (31/38=1)(39=2)(40/42=3)(43/46=4)

**********************************************************
* creating variables not interval-specific
**********************************************************

generate anydiff=anydiff812
replace anydiff=anydiff48 if anydiff==.

generate moved=moved812
replace moved=moved48 if moved812==.

generate partner_change=partner_change812
replace partner_change=partner_change48 if partner_change==.

*******************************************************************
* calculating number in and out of each relative type
*******************************************************************

sort interval 

tab anydiff [aweight=wpfinwgt]
tab moved[aweight=wpfinwgt]

tab Compchange [aweight=wpfinwgt]
tab partner_change [aweight=wpfinwgt]

tab typrelout1 [aweight=wpfinwgt]
tab typrelout2 [aweight=wpfinwgt]
tab typrelout3 [aweight=wpfinwgt]
tab typrelout4 [aweight=wpfinwgt]
tab typrelout5 [aweight=wpfinwgt]

/*
sum typrelout5 [aweight=wpfinwgt]

/*

tab typrelout6 [aweight=wpfinwgt]
tab typrelout7 [aweight=wpfinwgt]
tab typrelout8 [aweight=wpfinwgt]
tab typrelout9 [aweight=wpfinwgt]
tab typrelout10 [aweight=wpfinwgt]
tab typrelout11 [aweight=wpfinwgt]
tab typrelout12 [aweight=wpfinwgt]
tab typrelout13 [aweight=wpfinwgt]
tab typrelout14 [aweight=wpfinwgt]
tab typrelout15 [aweight=wpfinwgt]
tab typrelout16 [aweight=wpfinwgt]
tab typrelout17 [aweight=wpfinwgt]
tab typrelout18 [aweight=wpfinwgt]
tab typrelout19 [aweight=wpfinwgt]
tab typrelout20 [aweight=wpfinwgt]
tab typrelout21 [aweight=wpfinwgt]
tab typrelout22 [aweight=wpfinwgt]
tab typrelout23 [aweight=wpfinwgt]
tab typrelout24 [aweight=wpfinwgt]
tab typrelout25 [aweight=wpfinwgt]
tab typrelout26 [aweight=wpfinwgt]
tab typrelout27 [aweight=wpfinwgt]

tab typrelin1  [aweight=wpfinwgt]
tab typrelin2  [aweight=wpfinwgt]
tab typrelin3  [aweight=wpfinwgt]
tab typrelin4  [aweight=wpfinwgt]
tab typrelin5  [aweight=wpfinwgt]
tab typrelin6  [aweight=wpfinwgt]
tab typrelin7  [aweight=wpfinwgt]
tab typrelin8  [aweight=wpfinwgt]
tab typrelin9  [aweight=wpfinwgt]
tab typrelin10  [aweight=wpfinwgt]
tab typrelin11  [aweight=wpfinwgt]
tab typrelin12  [aweight=wpfinwgt]
tab typrelin13  [aweight=wpfinwgt]
tab typrelin14  [aweight=wpfinwgt]
tab typrelin15  [aweight=wpfinwgt]
tab typrelin16  [aweight=wpfinwgt]
tab typrelin17  [aweight=wpfinwgt]
tab typrelin18  [aweight=wpfinwgt]
tab typrelin19  [aweight=wpfinwgt]
tab typrelin20  [aweight=wpfinwgt]
tab typrelin21  [aweight=wpfinwgt]
tab typrelin22  [aweight=wpfinwgt]
tab typrelin23  [aweight=wpfinwgt]
tab typrelin24  [aweight=wpfinwgt]
tab typrelin25  [aweight=wpfinwgt]
tab typrelin26  [aweight=wpfinwgt]
tab typrelin27  [aweight=wpfinwgt]

tab partner_change812  [aweight=wpfinwgt]
tab anybabyin  [aweight=wpfinwgt] 
