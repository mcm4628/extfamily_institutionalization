*Stack two intervals to see "Who Moved"

use "$tempdir/longbiomom.dta", clear

sort ssuid pnum monthcode

keep if monthcode==8

merge 1:1 ssuid pnum using "$tempdir/demo.dta"
keep if _merge==3

drop _merge

save "$tempdir/longbiomom8.dta", replace

use "$tempdir/longbiomom.dta", clear

sort ssuid pnum monthcode

keep if monthcode==4

merge 1:1 ssuid pnum using "$tempdir/demo.dta"

keep if _merge==3

drop _merge

save "$tempdir/longbiomom4.dta", replace

merge 1:1 ssuid pnum using "$tempdir/anydiff48.dta"

save "$tempdir/anyd48biomom.dta", replace

use "$tempdir/anydiff812.dta", clear

sort ssuid pnum 

merge 1:1 ssuid pnum using "$tempdir/longbiomom8.dta"

drop _merge

gen anydiff=anydiff812

gen moved=moved812

append using "$tempdir/anyd48biomom.dta"

drop _merge

merge m:1 ssuid pnum using "$tempdir/partner_change.dta

keep if _merge==3

drop _merge

gen partner_change=partner_change48 if monthcode==4
replace partner_change=partner_change812 if monthcode==8

gen mom_educ=biomomeduc12
recode mom_educ (31/38=1)(39=2)(40/43=3)(44/47=4), gen (momced)

gen raceth=4
replace raceth=1 if erace==1 & eorigin==2
replace raceth=2 if erace==2
replace raceth=3 if erace !=2 & eorigin==1
replace raceth=4 if erace==3

recode biomomeduc (31/38=1)(39=2)(40/42=3)(43/46=4)

replace anydiff=anydiff48 if missing(anydiff)
replace tage=tage4 if missing(tage)
replace moved=moved48 if missing(moved)

keep if tage < 17

there's a problem. Sometimes biological parent moves out or in and partner_change==0

tab Compchange biomomeduc
tab Compchange raceth

tab anydiff moved

tab typrelout5 partner_change
tab typrelout6 partner_change
tab typrelout7 partner_change

tab typrelout27 partner_change
tab partner_change

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
