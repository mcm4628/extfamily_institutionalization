~~~~
<<dd_do>>
use "$SIPP14keep/dropout_month.dta", clear
<</dd_do>>
~~~~


*describe
~~~~
<<dd_do>>
tab panelmonth dropout [aweight=WPFINWGT], nofreq row 
tab dropout adj_age [aweight=WPFINWGT], col

tab tvever_parent_changelag [aweight=WPFINWGT]
tab tvever_sib_changelag [aweight=WPFINWGT]
tab tvever_other_changelag [aweight=WPFINWGT]

tab tvever_parent_changelag dropout [aweight=WPFINWGT], row
tab tvever_sib_changelag dropout [aweight=WPFINWGT], row
tab tvever_other_changelag dropout [aweight=WPFINWGT], row

tab tvever_biosib_changelag dropout [aweight=WPFINWGT], row
tab tvever_halfsib_changelag dropout [aweight=WPFINWGT], row
tab tvever_stepsib_changelag dropout [aweight=WPFINWGT], row
<</dd_do>>
~~~~

*model 1
*household composition and dropout
~~~~
<<dd_do>>
logit dropout i.parcomplag i.sibcomplag i.extendlag i.cpovlag i.adj_age my_sex ib1.par_ed_first ib1.my_racealt i.month, cluster (SSUID)
<</dd_do>>
~~~~

*model 2
*household composition change and dropout
~~~~
<<dd_do>>
logit dropout tvever_parent_changelag tvever_sib_changelag tvever_other_changelag i.cpovlag i.adj_age my_sex ib1.par_ed_first ib1.my_racealt i.month, cluster (SSUID)
<</dd_do>>
~~~~

*model 3
*household composition change and dropout while controling for hh composition
~~~~
<<dd_do>>
logit dropout tvever_parent_changelag tvever_sib_changelag tvever_other_changelag i.parcomplag i.sibcomplag i.extendlag i.cpovlag i.adj_age my_sex ib1.par_ed_first ib1.my_racealt i.month, cluster (SSUID) 
<</dd_do>>
~~~~

*model 4
*type of sibling change
~~~~
<<dd_do>>
logit dropout tvever_parent_changelag tvever_other_changelag tvever_biosib_changelag tvever_halfsib_changelag tvever_stepsib_changelag i.parcomplag i.sibcomplag i.extendlag i.cpovlag i.adj_age my_sex ib1.par_ed_first ib1.my_racealt i.month, cluster (SSUID) 
<</dd_do>>
~~~~

