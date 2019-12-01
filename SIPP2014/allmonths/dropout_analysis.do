~~~~
<<dd_do>>
use "$SIPP14keep/dropout_month.dta", clear
keep if adj_age >=14 & adj_age <20

*describe
tab panelmonth dropout  [aweight=WPFINWGT], nofreq row 
tab dropout adj_age [aweight=WPFINWGT], col

tab parent_changelag dropout [aweight=WPFINWGT], row
tab sib_changelag dropout [aweight=WPFINWGT], row
tab other_changelag dropout [aweight=WPFINWGT], row

tab biosib_changelag dropout [aweight=WPFINWGT], row
tab halfsib_changelag dropout [aweight=WPFINWGT], row
tab stepsib_changelag dropout [aweight=WPFINWGT], row
<</dd_do>>
~~~~


*model 1
*household composition and dropout
<<dd_do>>
logit dropout i.parcomplag i.sibcomplag i.extendlag i.cpovlag i.adj_age my_sex ib1.par_ed_first ib1.my_racealt, cluster (SSUID)
<</dd_do>>

*model 2
*household composition change and dropout
<<dd_do>>
logit dropout parent_changelag sib_changelag other_changelag i.cpovlag i.adj_age my_sex ib1.par_ed_first ib1.my_racealt, cluster (SSUID)
<</dd_do>>

*model 3
*household composition change and dropout while controling for hh composition
<<dd_do>>
logit dropout parent_changelag sib_changelag other_changelag i.parcomplag i.sibcomplag i.extendlag i.cpovlag i.adj_age my_sex ib1.par_ed_first ib1.my_racealt, cluster (SSUID) 
<</dd_do>>

<<dd_do>>
*model 4
*household composition change in 8 categories
logit dropout i.cchangelag i.parcomplag i.sibcomplag i.extendlag i.cpovlag i.adj_age my_sex ib1.par_ed_first ib1.my_racealt, cluster (SSUID) 
<</dd_do>>

<<dd_do>>
*model 5
*type of sibling change
logit dropout parent_changelag other_changelag biosib_changelag halfsib_changelag stepsib_changelag i.parcomplag i.sibcomplag i.extendlag i.cpovlag i.adj_age my_sex ib1.par_ed_first ib1.my_racealt, cluster (SSUID) 
<</dd_do>>

dyndoc dropoutput.txt, replace

