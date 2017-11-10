*Stack two intervals to see "Who Moved"

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

*gen mom_educ=biomomeduc12
*recode mom_educ (31/38=1)(39=2)(40/43=3)(44/47=4), gen (momced)
* this variable is on longbiomom, but now I'm troubleshooting and don't care

gen raceth=4
replace raceth=1 if erace==1 & eorigin==2
replace raceth=2 if erace==2
replace raceth=3 if erace !=2 & eorigin==1
replace raceth=4 if erace==3

tab raceth

*recode biomomeduc (31/38=1)(39=2)(40/42=3)(43/46=4)

tab anydiff812 moved812

tab Compchange anyparent
tab anyparent partner_change812

tab typrelout27 partner_change812
tab partner_change812

tab typrelout1 raceth [aweight=wpfinwgt]
tab typrelout2 raceth [aweight=wpfinwgt]
tab typrelout3 raceth [aweight=wpfinwgt]
tab typrelout4 raceth [aweight=wpfinwgt]
tab typrelout5 raceth [aweight=wpfinwgt]
tab typrelout6 raceth [aweight=wpfinwgt]
tab typrelout7 raceth [aweight=wpfinwgt]
tab typrelout8 raceth [aweight=wpfinwgt]
tab typrelout9 raceth [aweight=wpfinwgt]
tab typrelout10 raceth [aweight=wpfinwgt]
tab typrelout11 raceth [aweight=wpfinwgt]
tab typrelout12 raceth [aweight=wpfinwgt]
tab typrelout13 raceth [aweight=wpfinwgt]
tab typrelout14 raceth [aweight=wpfinwgt]
tab typrelout15 raceth [aweight=wpfinwgt]
tab typrelout16 raceth [aweight=wpfinwgt]
tab typrelout17 raceth [aweight=wpfinwgt]
tab typrelout18 raceth [aweight=wpfinwgt]
tab typrelout19 raceth [aweight=wpfinwgt]
tab typrelout20 raceth [aweight=wpfinwgt]
tab typrelout21 raceth [aweight=wpfinwgt]
tab typrelout22 raceth [aweight=wpfinwgt]
tab typrelout23 raceth [aweight=wpfinwgt]
tab typrelout24 raceth [aweight=wpfinwgt]
tab typrelout25 raceth [aweight=wpfinwgt]
tab typrelout26 raceth [aweight=wpfinwgt]
tab typrelout27 raceth [aweight=wpfinwgt]

tab typrelin1 raceth [aweight=wpfinwgt]
tab typrelin2 raceth [aweight=wpfinwgt]
tab typrelin3 raceth [aweight=wpfinwgt]
tab typrelin4 raceth [aweight=wpfinwgt]
tab typrelin5 raceth [aweight=wpfinwgt]
tab typrelin6 raceth [aweight=wpfinwgt]
tab typrelin7 raceth [aweight=wpfinwgt]
tab typrelin8 raceth [aweight=wpfinwgt]
tab typrelin9 raceth [aweight=wpfinwgt]
tab typrelin10 raceth [aweight=wpfinwgt]
tab typrelin11 raceth [aweight=wpfinwgt]
tab typrelin12 raceth [aweight=wpfinwgt]
tab typrelin13 raceth [aweight=wpfinwgt]
tab typrelin14 raceth [aweight=wpfinwgt]
tab typrelin15 raceth [aweight=wpfinwgt]
tab typrelin16 raceth [aweight=wpfinwgt]
tab typrelin17 raceth [aweight=wpfinwgt]
tab typrelin18 raceth [aweight=wpfinwgt]
tab typrelin19 raceth [aweight=wpfinwgt]
tab typrelin20 raceth [aweight=wpfinwgt]
tab typrelin21 raceth [aweight=wpfinwgt]
tab typrelin22 raceth [aweight=wpfinwgt]
tab typrelin23 raceth [aweight=wpfinwgt]
tab typrelin24 raceth [aweight=wpfinwgt]
tab typrelin25 raceth [aweight=wpfinwgt]
tab typrelin26 raceth [aweight=wpfinwgt]
tab typrelin27 raceth [aweight=wpfinwgt]

tab partner_change812 raceth [aweight=wpfinwgt]
tab anybabyin raceth [aweight=wpfinwgt] 
