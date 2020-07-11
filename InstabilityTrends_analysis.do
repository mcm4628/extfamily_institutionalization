//==============================================================================
//===== Children's Household Instability Project                                                    
//==============================================================================

* check out setup_example for information on macro locations

* First run scripts to annualize the data

do "$sipp2004_code/annualize.do"
do "$sipp2008_code/annualize.do"
do "$sipp2014_code/annualize.do"

*  https://www.census.gov/programs-surveys/sipp/data/2004-panel.html
* Wave 1 was February 2004 to May 2004; Wave 12 ended January 2007.
* So "years" don't correspond to actual calendar years. 

use "$SIPP04keep/annualized_change04.dta", clear

putexcel set "$results/instabilitytrends", sheet(Lifetable) replace

/* First just create the table shell (without any results)*/
putexcel A1:M1 = "Household Composition Instability from 2004 to ", merge border(bottom)
putexcel B2 = ("2004") C2 = ("2005") D2 = ("2006") E2 = ("2007"), border(bottom)
putexcel A3 = ("Maternal Ed") 
putexcel B3:M3 =("Age 0-17"), merge
putexcel A4 = "Less than High School"
putexcel A5 = "High School"
putexcel A6 = "Some College"
putexcel A7 = "College Grad"

putexcel B8:I8 = "Age 0-4", merge
putexcel A9 = "Less than High School"
putexcel A10 = "High School"
putexcel A11 = "Some College"
putexcel A12 = "College Grad"

local colheads "B C D E"

keep if adj_age <18	

local row = 4

forvalues me = 1/4 {
	forvalues y=1/4{
		local col: word `y' of `colheads'
		mean anychange_c [pweight=WPFINWGT] if year == `y' & par_ed_first==`me'
		matrix cc`y'_`me' = e(b)
		putexcel `col'`row' = matrix(cc`y'_`me'), nformat(number_d2)
	}
	local row = `row' + 1
}

keep if adj_age < 5	

local row = 9

forvalues me = 1/4 {
	forvalues y=1/4{
		local col: word `y' of `colheads'
		mean anychange_c [pweight=WPFINWGT] if year == `y' & par_ed_first==`me'
		matrix cc`y'_`me' = e(b)
		putexcel `col'`row' = matrix(cc`y'_`me'), nformat(number_d2)
	}
	local row = `row' + 1
}

clear matrix

********************************************************************************
*                                 2008
********************************************************************************

*https://www.census.gov/programs-surveys/sipp/data/2008-panel.html
* Wave 1 of the 2008 SIPP was between Setpember and December of 2008
* Thus the bulk of the first year of the 2008 panel occured in 2009


use "$SIPP08keep/annualized_change08.dta", clear

putexcel F2 = ("2009") G2 = ("2010") H2 = ("2011") I2 = ("2012") J2 = ("2013"), border(bottom)

local colheads "F G H I J"

keep if adj_age <18	

local row = 4

forvalues me = 1/4 {
	forvalues y=1/5{
		local col: word `y' of `colheads'
		mean anychange_c [pweight=WPFINWGT] if year == `y' & par_ed_first==`me'
		matrix cc`y'_`me' = e(b)
		putexcel `col'`row' = matrix(cc`y'_`me'), nformat(number_d2)
	}
	local row = `row' + 1
}

keep if adj_age < 5	

local row = 9

forvalues me = 1/4 {
	forvalues y=1/5{
		local col: word `y' of `colheads'
		mean anychange_c [pweight=WPFINWGT] if year == `y' & par_ed_first==`me'
		matrix cc`y'_`me' = e(b)
		putexcel `col'`row' = matrix(cc`y'_`me'), nformat(number_d2)
	}
	local row = `row' + 1
}

clear matrix

********************************************************************************
*                                 2014
********************************************************************************

*https://www.census.gov/programs-surveys/sipp/data/2008-panel.html
* Wave 1 of the 2008 SIPP was between Setpember and December of 2008
* Thus the bulk of the first year of the 2008 panel occured in 2009


use "$SIPP14keep/annualized_change14.dta", clear

putexcel K2 = ("2013") L2 = ("2014") M2 = ("2015") N2 = ("2016"), border(bottom)

local colheads "K L M N O"

keep if adj_age <18	

local row = 4

forvalues me = 1/4 {
	forvalues y=1/4{
		local col: word `y' of `colheads'
		mean anychange_c [pweight=WPFINWGT] if year == `y' & par_ed_first==`me'
		matrix cc`y'_`me' = e(b)
		putexcel `col'`row' = matrix(cc`y'_`me'), nformat(number_d2)
	}
	local row = `row' + 1
}

keep if adj_age < 5	

local row = 9

forvalues me = 1/4 {
	forvalues y=1/4{
		local col: word `y' of `colheads'
		mean anychange_c [pweight=WPFINWGT] if year == `y' & par_ed_first==`me'
		matrix cc`y'_`me' = e(b)
		putexcel `col'`row' = matrix(cc`y'_`me'), nformat(number_d2)
	}
	local row = `row' + 1
}
