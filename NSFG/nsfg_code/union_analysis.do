* Trends in union formation

use "$combined_data\union0615.dta", clear

keep if cycle==7

ltable dur2un everu if !missing(dur2un) [fweight=iweight] , by(bcohort)


use "$combined_data\union0615.dta", clear

keep if cycle==8

ltable dur2un everu if !missing(dur2un) [fweight=iweight] , by(bcohort)

use "$combined_data\union0615.dta", clear

keep if cycle==9

ltable dur2un everu if !missing(dur2un) [fweight=iweight] , by(bcohort)
