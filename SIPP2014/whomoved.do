*Stack two intervals to see "Who Moved"

* first stage is to read in data files with information basic demographics and partnerchange

use "$tempdir/demo.dta", clear


merge 1:1 ssuid pnum using "$tempdir/partner_change.dta"
* Note that partner_change.dta has variables describing biological mothers partnership changes
* but only for individuals less than age 18. Created with childrenHH14.do

keep if _merge==3

tab biomom8 biomom12

drop _merge

merge 1:1 ssuid pnum using "$tempdir/anydiff812.dta"

keep if _merge==3

drop _merge

*gen mom_educ=biomomeduc12
*recode mom_educ (31/38=1)(39=2)(40/43=3)(44/47=4), gen (momced)
* this variable is on longbiomom, but now I'm troubleshooting and don't care

gen raceth=4
replace raceth=1 if erace==1 & eorigin==2
replace raceth=2 if erace==2
replace raceth=3 if erace !=2 & eorigin==1
replace raceth=4 if erace==3

*recode biomomeduc (31/38=1)(39=2)(40/42=3)(43/46=4)

tab anydiff812 moved812

tab Compchange anyparent
tab anyparent partner_change812

tab typrelout27 partner_change812
tab partner_change812

/*

tab typrelout1 raceth
tab typrelout2 raceth
tab typrelout3 raceth
tab typrelout4 raceth
tab typrelout5 raceth
tab typrelout6 raceth
tab typrelout7 raceth
tab typrelout8 raceth
tab typrelout9 raceth
tab typrelout10 raceth
tab typrelout11 raceth
tab typrelout12 raceth
tab typrelout13 raceth
tab typrelout14 raceth
tab typrelout15 raceth
tab typrelout16 raceth
tab typrelout17 raceth
tab typrelout18 raceth
tab typrelout19 raceth
tab typrelout20 raceth
tab typrelout21 raceth
tab typrelout22 raceth
tab typrelout23 raceth
tab typrelout24 raceth
tab typrelout25 raceth
tab typrelout26 raceth
tab typrelout27 raceth

tab typrelin1 raceth
tab typrelin2 raceth
tab typrelin3 raceth
tab typrelin4 raceth
tab typrelin5 raceth
tab typrelin6 raceth
tab typrelin7 raceth
tab typrelin8 raceth
tab typrelin9 raceth
tab typrelin10 raceth
tab typrelin11 raceth
tab typrelin12 raceth
tab typrelin13 raceth
tab typrelin14 raceth
tab typrelin15 raceth
tab typrelin16 raceth
tab typrelin17 raceth
tab typrelin18 raceth
tab typrelin19 raceth
tab typrelin20 raceth
tab typrelin21 raceth
tab typrelin22 raceth
tab typrelin23 raceth
tab typrelin24 raceth
tab typrelin25 raceth
tab typrelin26 raceth
tab typrelin27 raceth
