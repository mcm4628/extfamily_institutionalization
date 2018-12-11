clear

log using "$logdir/poverty_mslt.log", $replace

import delimited using "$logdir/transitions", varnames(1)

drop if missing(age)

forvalues r=0/5{

	preserve

	keep if race==`r'

	lxpct_2, i(2) d(0)
	
	restore
}

log close
