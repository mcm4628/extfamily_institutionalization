use "$SIPP14keep/allmonths14_type2", clear

keep SSUID PNUM ERESIDENCEID RREL* RREL_PNUM* TAGE swave panelmonth // using all panel months

tab RREL1

****************************************************
* count the number of other people in the household
*

gen countall=0
gen countother=0

 forvalues p=1/30 {
  replace countother=countother+1 if RREL`p'!=. & RREL_PNUM`p' !=99
  replace countall=countall+1 if RREL`p' !=.
 }
 
 tab countall 
 tab countother

rename PNUM relfrom

reshape long RREL RREL_PNUM, i(SSUID relfrom panelmonth) j(pn)

rename RREL_PNUM relto

tab RREL

drop if relto==.

destring relfrom, replace

drop if relfrom==relto

save "$SIPP14keep/relationship_matrix", $replace

use "$SIPP14keep/relationship_pairs_bymonth"


rename from_num relfrom
rename to_num relto

save "$SIPP14keep/relationship_pairs_bymonth", $replace

merge 1:1 SSUID panelmonth relto relfrom using "$SIPP14keep/relationship_matrix"


putexcel set "$results/compare_relationships.xlsx", sheet(checkrels) modify

tab relationship RREL, matcell(checkrels)

putexcel C3=matrix(checkrels)


