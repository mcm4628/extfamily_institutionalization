
use "$SIPP08keep/faminst_analysis.dta", clear

drop if missing(comp_changey)

putexcel set "$results/InstitutionalizedExtension", sheet(descriptives08) replace
putexcel A1:T1= "Descriptive Statistics for analytical sample", merge border(bottom)
putexcel B2:D2 = ("Total") F2:H2 = ("Non-Hispanic White") J2:L2 = ("Black") N2:P2 = ("Hispanic") R2:T2 = ("Asian"), merge border(bottom) 
putexcel B3 = ("weighted proportion") D3 = ("N") F3 = ("weighted proportion") H3 = ("N") J3 = ("weighted proportion") L3 = ("N") N3 = ("weighted proportion") P3 = ("N") R3 = ("weighted proportion") T3 = ("N"), border(bottom)
putexcel A4="Household Extension"
putexcel A5=" any grandparent"
putexcel A6=" any aunt or uncle"
putexcel A7=" any other relative"
putexcel A8=" any non-relative"
putexcel A9="Race/Ethnicity"
putexcel A10=" Non-Hispanice White"
putexcel A11=" Black"
putexcel A12=" Non-Black Hispanic"
putexcel A13=" Asian"
putexcel A14=" Other, including multi-racial"
putexcel A15="Parent Immigrant"
putexcel A16=" Yes"
putexcel A17="Parental Education"
putexcel A18=" less than High School"
putexcel A19=" diploma or GED"
putexcel A20=" some college"
putexcel A21=" College Grad"
putexcel A22=" unknown"
putexcel A23="Parent"
putexcel A24=" 2 bio"
putexcel A25=" 1 bio, nostep"
putexcel A26=" stepparent"
putexcel A27=" no parent"
putexcel A28="Household Change"
putexcel A29="Household Split"

// fill in the proportion column

local anyrel "anygp anyauntuncle anyother anynonrel"
local redummies "nhwhite black hispanic asian otherr"
local paredummies "plths phs pscol pcolg pedmiss" 
local parcomp "twobio singlebio stepparent noparent"
local hhchange "comp_changey hhsplity"

keep if adj_age < 15

svyset [pweight=WPFINWGT]

* relatives
forvalues d=1/4{
	local row=`d'+4
	local var:word `d' of `anyrel'
	svy: mean `var' 
	matrix mr`d' = e(b)
	putexcel B`row' = matrix(mr`d'), nformat(#.##)
	count if `var'==1
    putexcel D`row' = `r(N)'
}

* race-ethnicity
forvalues r=1/5{
	local row=`r'+9
	local var:word `r' of `redummies'
	svy: mean `var' 
	matrix mre`r' = e(b)
	putexcel B`row' = matrix(mre`r'), nformat(#.##)
	count if `var'==1
    putexcel D`row' = `r(N)'
}

* parent immigrant

svy: mean pimmigrant
matrix mpi=e(b)
putexcel B16 = matrix(mpi), nformat(#.##)
count if pimmigrant == 1
putexcel D16 = `r(N)'


* parent education
forvalues pe=1/5{
	local row=`pe'+17
	local var:word `pe' of `paredummies'
	svy: mean `var' 
	matrix mpe`pe' = e(b)
	putexcel B`row' = matrix(mpe`pe'), nformat(#.##)
	count if `var'==1
    putexcel D`row' = `r(N)'
}

*parent composition	
forvalues p=1/4{
	local row=`p'+23
	local var:word `p' of `parcomp'
	svy: mean `var' 
	matrix mp`p' = e(b)
	putexcel B`row' = matrix(mp`p'), nformat(#.##)
	count if `var'==1
    putexcel D`row' = `r(N)'
}

*comp change
forvalues h=1/2{
	local row=`h'+27
	local var:word `h' of `hhchange'
	svy: mean `var' 
	matrix mh`h' = e(b)
	putexcel B`row' = matrix(mh`h'), nformat(#.##)
	count if `var'==1
    putexcel D`row' = `r(N)'
}

* By Race/Ethnicity

local columns "F G H I J K L M N O P Q R S T"

forvalues re=1/4{
	local pcol=(`re'-1)*4+1
	local propcol: word `pcol' of `columns'
	local addtwo = `pcol'+2
	local ncol: word `addtwo' of `columns'
    display "relatives"
	* relatives
	forvalues d=1/4{
		local row=`d'+4
		local var:word `d' of `anyrel'
		svy, subpop(if my_racealt==`re'): mean `var' 
		matrix mr`d'`re' = e(b)
		putexcel `propcol'`row' = matrix(mr`d'`re'), nformat(#.##)
		count if `var'==1 & my_racealt==`re'
		putexcel `ncol'`row' = `r(N)'
	}
	
	svy, subpop(if my_racealt==`re'): mean pimmigrant
	matrix mpi`re'=e(b)
	putexcel `propcol'16 = matrix(mpi`re'), nformat(#.##)
	count if pimmigrant == 1 & my_racealt==`re'
	putexcel `ncol'16 = `r(N)'
	display "parent education"
* parent education
	forvalues pe=1/5{
		local row=`pe'+17
		local var:word `pe' of `paredummies'
		svy, subpop(if my_racealt==`re'): mean `var' 
		matrix mpe`pe'`re' = e(b)
		putexcel `propcol'`row' = matrix(mpe`pe'`re'), nformat(#.##)
		count if `var'==1 & my_racealt==`re'
		putexcel `ncol'`row' = `r(N)'
	}
	display "parent composition"
*parent composition	
	forvalues p=1/4{
		local row=`p'+23
		local var:word `p' of `parcomp'
		svy, subpop(if my_racealt==`re'): mean `var' 
		matrix mp`p'`re' = e(b)
		putexcel `propcol'`row' = matrix(mp`p'`re'), nformat(#.##)
		count if `var'==1 & my_racealt==`re'
		putexcel `ncol'`row' = `r(N)'
	}
	*household change
	forvalues h=1/2{
		local row=`h'+27
		local var:word `h' of `hhchange'
		svy, subpop(if my_racealt==`re'): mean `var'  
		matrix mh`h'`re' = e(b)
		putexcel `propcol'`row' = matrix(mh`h'`re'), nformat(#.##)
		count if `var'==1 & my_racealt==`re'
		putexcel `ncol'`row' = `r(N)'
	}
}
* Regression analysis

local baseline "i.year adj_age i.par_ed_first i.parentcomp mom_age mom_age2 hhsize b2.chhmaxage hhmaxage"

svy: logit hhsplity i.my_racealt pimmigrant
outreg2 using "$results/InstExtReg14.xls", replace ctitle(Model 1) 

svy: logit hhsplity i.my_racealt pimmigrant `baseline' 
outreg2 using "$results/InstExtReg08.xls", replace ctitle(Model 2) 

svy: logit hhsplity i.my_racealt pimmigrant `baseline' `anyrel' 
outreg2 using "$results/InstExtReg08.xls", append ctitle(Model 3)

forvalues r=1/5{
	svy, subpop(if my_racealt==`r'):logit hhsplity pimmigrant `baseline' `anyrel' 
	outreg2 using "$results/InstExtReg08.xls", append ctitle(re=`r')
}

/*
Need to figure out a way to compare the effect of gp vs aunt/uncle vs other rel vs non-rel net of age of the person. Clearly older relatives run a higher
risk of dying.

