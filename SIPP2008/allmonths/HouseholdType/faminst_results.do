
use "$SIPP08keep/faminst_analysis.dta", clear

gen parentcomp=1 if bioparent==2
replace parentcomp=2 if bioparent==1 & parent==1
replace parentcomp=3 if parent > bioparent
replace parentcomp=4 if parent==0

label define parentcomp 1 "two bio parent" 2 "single bioparent" 3 "stepparent" 4 "noparent"

* mean-center mom_age
mean mom_age
replace mom_age=mom_age-37 
replace mom_age=0 if missing(mom_age)

gen mom_age2=mom_age*mom_age

* dummy indicators for demographics
gen black= my_racealt==2
gen nhwhite= my_racealt==1
gen hispanic= my_racealt==3
gen asian= my_racealt==4
gen otherr=my_racealt==5

gen plths=par_ed_first==1
gen phs=par_ed_first==2
gen pscol=par_ed_first==3
gen pcolg=par_ed_first==4
gen pedmiss= missing(par_ed_first)

gen twobio=parentcomp==1
gen singlebio=parentcomp==2
gen stepparent=parentcomp==3
gen noparent=parentcomp==4

putexcel set "$results/InstitutionalizedExtension", sheet(descriptives) replace
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
putexcel A15="Parental Education"
putexcel A16=" less than High School"
putexcel A17=" diploma or GED"
putexcel A18=" some college"
putexcel A19=" College Grad"
putexcel A20=" unknown"
putexcel A21="Parent"
putexcel A22=" 2 bio"
putexcel A23=" 1 bio, nostep"
putexcel A24=" stepparent"
putexcel A25=" no parent"

// fill in the proportion column

local anyrel "anygp anyauntuncle anyother anynonrel"
local redummies "nhwhite black hispanic asian otherr"
local paredummies "plths phs pscol pcolg pedmiss" 
local parcomp "twobio singlebio stepparent noparent"

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

* parent education
forvalues pe=1/5{
	local row=`pe'+15
	local var:word `pe' of `paredummies'
	svy: mean `var' 
	matrix mpe`pe' = e(b)
	putexcel B`row' = matrix(mpe`pe'), nformat(#.##)
	count if `var'==1
    putexcel D`row' = `r(N)'
}

*parent composition	
forvalues p=1/4{
	local row=`p'+21
	local var:word `p' of `parcomp'
	svy: mean `var' 
	matrix mp`p' = e(b)
	putexcel B`row' = matrix(mp`p'), nformat(#.##)
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
     display "parent education"
* parent education
	forvalues pe=1/5{
		local row=`pe'+15
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
		local row=`p'+21
		local var:word `p' of `parcomp'
		svy, subpop(if my_racealt==`re'): mean `var' 
		matrix mp`p'`re' = e(b)
		putexcel `propcol'`row' = matrix(mp`p'`re'), nformat(#.##)
		count if `var'==1 & my_racealt==`re'
		putexcel `ncol'`row' = `r(N)'
	}
}
* Regression analysis

local baseline "i.adj_age i.par_ed_first i.parentcomp mom_age mom_age2"

svy: logit comp_change `baseline' i.my_racealt
outreg2 using "$results/InstExtReg.xls", replace ctitle(Model 1) 

svy: logit comp_change `baseline' i.my_racealt anygp anyauntuncle anyother anynonrel
outreg2 using "$results/InstExtReg.xls", append ctitle(Model 2)

forvalues r=1/5{
	svy, subpop(if my_racealt==`r'):logit comp_change `baseline' anygp anyauntuncle anyother anynonrel
	outreg2 using "$results/InstExtReg.xls", append ctitle(re=`r')
}

Need to figure out a way to compare the effect of gp vs aunt/uncle vs other rel vs non-rel net of age of the person. Clearly older relatives run a higher
risk of dying.

must control for household size!!