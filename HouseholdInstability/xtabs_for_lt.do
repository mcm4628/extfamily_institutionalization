use "$SIPPshared/threeinterval2014.dta", clear

gen old=0
replace old=1 if biomomcage==5

tab age_start

tab moved
tab in12not8
tab in8not4
tab in4not1

tab age_start in12not8 

keep if age_start < 18

tab age_start in12not8

tab moved in12not8

tab age_start anydiff [aweight=wpfinwgt]

tab age_start moved [aweight=wpfinwgt]

tab age_start anybabyin [aweight=wpfinwgt]

sort interval

by interval: tab age_start partner_change [aweight=wpfinwgt]

drop if interval==14

tab age_start partner_change [aweight=wpfinwgt] 

sort old
by old: tab age_start partner_change [aweight=wpfinwgt]

tab momced

sort momced
by momced: tab age_start partner_change [aweight=wpfinwgt]

sort anydiff
by anydiff: tab relin
by anydiff: tab relout

by anydiff: tab relin relout
