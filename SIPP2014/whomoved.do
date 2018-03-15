* first stage is to read in data files with information basic demographics and partnerchange

use "$tempdir/demo.dta", clear

merge 1:1 ssuid pnum using "$tempdir/partner_change.dta"
* Note that partner_change.dta has variables describing biological mothers partnership changes
* but only for individuals less than age 18. Created with childrenHH14.do
* Also, partner changes are available only for type 1 biomoms. 

tab biomom8 biomom12

drop _merge

merge 1:1 ssuid pnum using "$tempdir/anydiff812.dta"

drop if tage8 > 17

tab _merge

*keep if _merge==3

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

tab nrelin 
tab nrelout 


sum wpfinwgt

sort raceth


local reltypes "OppositeSexSpouse OppositeSexPartner SameSexSpouse SameSexPartner BioParent StepParent AdoptParent GrandParent BioSib HalfSib StepSib AdopSib OtherSib ParentInLaw SibInLaw AuntUncleNieceNephew OtherRel Foster NonRel Child InfantSib ChildSib YASib OlderSib SibNoAge NRChild NRAdult"

global results "$projdir/Results and Papers/Household Instability (PAA17)"

putexcel set "$results/whomoved.xlsx", sheet(means 2008) replace

forvalues t=1/27 {
local rw=`t'+2
putexcel A`rw'="`=word("`reltypes'",`t')'"
* this syntax is ridiculous
sum typrelout`t' [aweight=wpfinwgt]
putexcel B`rw'=`r(mean)'
putexcel C`rw'=`r(mean)'*_N
sum typrelin`t' [aweight=wpfinwgt]
putexcel D`rw'=`r(mean)'
putexcel E`rw'=`r(mean)'*_N
}


forvalues t=1/27 {
sum typrelin`t' [aweight=wpfinwgt]
*by raceth: sum typrelout`t' [aweight=wpfinwgt]
*by raceth: sum typrelin`t' [aweight=wpfinwgt]
}
tab partner_change812 raceth [aweight=wpfinwgt]
tab anybabyin raceth [aweight=wpfinwgt] 
