use "$combined_data\pyunion0615.dta", clear

recode year (70/89=0)(90/94=1)(95/99=2)(100/104=3)(105/109=4)(110/115=5), gen(catyear)

keep if catyear > 0
drop if year==115

global results "$nsfg_base/results"
putexcel set "$results/unionrates_period.xlsx", sheet(by_age) replace

sort dur catyear


forvalues cy=1/5{
 local g=`cy'*10
 forvalues d=15/24{
  local rw=`d'-8+`g'
  putexcel A`rw'="`cy'"
  putexcel B`rw'="`d'"
  sum union if dur==`d' & catyear==`cy' [aweight=weight]
  putexcel C`rw'=`r(mean)'
  sum union if dur==`d' & catyear==`cy' & MOMDEGRE < 3 [aweight=weight]
  putexcel E`rw'=`r(mean)'
 }
}

drop if dur > 25

logit union ib20.dur i.catyear [pweight=iweight]
logit union ib20.dur ib105.year [pweight=iweight]
logit union ib20.dur ib105.year i.cycle [pweight=iweight]
logit union ib20.dur ib105.year i.cycle [pweight=iweight] if MOMDEGRE < 3
/* 


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
