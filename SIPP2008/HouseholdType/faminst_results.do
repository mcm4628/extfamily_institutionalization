
use "$SIPP08keep/faminst_analysis.dta", clear

drop if missing(comp_changey)

putexcel set "$results/InstitutionalizedExtension", sheet(descriptives08) replace
putexcel A1:T1= "Descriptive Statistics for analytical sample", merge border(bottom)
putexcel B2:D2 = ("Total") F2:H2 = ("Non-Hispanic White") J2:L2 = ("Black") N2:P2 = ("Hispanic") R2:T2 = ("Asian"), merge border(bottom) 
putexcel B3 = ("weighted proportion") D3 = ("N") F3 = ("weighted proportion") H3 = ("N") J3 = ("weighted proportion") L3 = ("N") N3 = ("weighted proportion") P3 = ("N") R3 = ("weighted proportion") T3 = ("N"), border(bottom)
putexcel A4="Household Extension"
putexcel A5=" only grandparent"
putexcel A6=" any other relative, no nonrel"
putexcel A7=" only non-relative"
putexcel A8=" relatives and non-relatives"
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

local redummies "nhwhite black hispanic asian otherr"
local paredummies "plths phs pscol pcolg pedmiss" 
local parcomp "twobio singlebio stepparent noparent"
local hhchange "comp_changey hhsplity"

keep if adj_age < 15

svyset [pweight=WPFINWGT]

* relatives
forvalues d=1/4{
	local row=`d'+4
	svy: mean hhtype_`d' 
	matrix mr`d' = e(b)
	putexcel B`row' = matrix(mr`d'), nformat(#.##)
	count if hhtype_`d'==1
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
		svy, subpop(if my_racealt==`re'): mean `var' 
		matrix mr`d'`re' = e(b)
		putexcel `propcol'`row' = matrix(mr`d'`re'), nformat(#.##)
		count if hhtype_`d'==1 & my_racealt==`re'
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

local anyrel `anygp nongprel anynonrel'
local relwords "Grandarent OtherRelative NonRelative"

// Note that these are a set of not mutually exclusive categories for basic description
svy: logit hhsplity anygp
outreg2 using "$results/InstExtReg08.xls", replace ctitle(Model grandparent)
svy: logit hhsplity nongprel
outreg2 using "$results/InstExtReg08.xls", append ctitle(Model other_rel)
svy: logit hhsplity anynonrel
outreg2 using "$results/InstExtReg08.xls", append ctitle(Model non_rel) 


// setting up multi-variate models

local baseline "i.year adj_age i.par_ed_first i.parentcomp mom_age mom_age2 hhsize b2.chhmaxage hhmaxage"

svy: logit hhsplity i.my_racealt pimmigrant `baseline' 
outreg2 using "$results/InstExtReg08.xls", append ctitle(Model 2) 

// in contrast to the descriptive bivariate analysis above, these models 
*  have mutually-exclusive household type cateogires

svy: logit hhsplity i.my_racealt pimmigrant `baseline' b0.hhtype
outreg2 using "$results/InstExtReg08.xls", append ctitle(Model 3)

forvalues r=1/5{
	local re : word `r' of `redummies'
	svy, subpop(if my_racealt==`r'):logit hhsplity pimmigrant `baseline' b0.hhtype 
	outreg2 using "$results/InstExtReg08.xls", append ctitle(re=`re')
	margins hhtype, subpop(if my_racealt==`r') saving(file`r', replace)
}


// Graphs
combomarginsplot file1 file2 file3 file4 file5, ylabel(0(.1).8) ysc(r(0 .8)) scheme(s1color) aspectratio(.5) ///
labels(White Black Hispanic Asian Other) xscale(r(0 1)) xtitle(“Race”)
combomarginsplot file1 file2, ylabel(0(.1).8) ysc(r(0 .8)) scheme(s1color) aspectratio(.5) ///
labels(White Black) xscale(r(0 1)) xtitle(“Race”)
combomarginsplot file1 file3, ylabel(0(.1).8) ysc(r(0 .8)) scheme(s1color) aspectratio(.5) ///
labels(White Hispanic) xscale(r(0 1)) xtitle(“Race”)
combomarginsplot file1 file4, ylabel(0(.1).8) ysc(r(0 .8)) scheme(s1color) aspectratio(.5) ///
labels(White Asian) xscale(r(0 1)) xtitle(“Race”)
combomarginsplot file1 file5, ylabel(0(.1).8) ysc(r(0 .8)) scheme(s1color) aspectratio(.5) ///
labels(White Other) xscale(r(0 1)) xtitle(“Race”)


log using tests, replace
set logtype text

// Tests - Models with interactions

local baseline "i.year adj_age i.par_ed_first i.parentcomp mom_age mom_age2 hhsize b2.chhmaxage hhmaxage"
svy: logit hhsplity pimmigrant `baseline' b0.hhtype##my_racealt
outreg2 using "$results/Interaction08.xls", append ctitle(Model with interactions)


* Test 1 
contrast hhtype##my_racealt, effects
/* Support that some extended ararngemenst are associated with less instability
for Black ans Hispanic hildren when compared o NH White. Asians are not different. 
*/

* Test 2: grandparent relationships are stronger than other relationships? 
contrast {hhtype 0 1 -1 0 0}, effects // gp vs other relatives, no non-relatives s
contrast {hhtype 0 1 0 -1 0}, effects // gp vs only non-relatives 
contrast {hhtype 0 1 0 0 -1}, effects // gp vs relative & non-relatives 
/* supports that gp relationships are stronger than other extented arrangements
*/

* Test 3: boundary between grandparents and non-kin is especially strong among Asian and Hispanic children’s 
contrast {hhtype 0 1 -1 0 0}#g.my_racealt, effects
contrast {hhtype 0 1 0 -1 0}#g.my_racealt, effects
contrast {hhtype 0 1 0 0 -1}#g.my_racealt, effects
/* overall does not provide support that gp arrangenets vs other types ard particularly different
among Hispanic and Asians - yet some support that gp vs complex is different than means for Hispanics
Asians and also Black children
*/

* Test 4: any extension less associated with instability for Black children than for White children, particularly other kin
contrast {my_racealt 1 -1 -0 0 0}@i1.hhtype, effects
contrast {my_racealt 1 -1 -0 0 0}@i2.hhtype, effects
contrast {my_racealt 1 -1 -0 0 0}@i3.hhtype, effects
contrast {my_racealt 1 -1 -0 0 0}@i4.hhtype, effects
/* partial support, differences not significant for gp arrangements  
*/


* Graph
margins hhtype##my_racealt 
marginsplot, ylabel(0(.1).8) ysc(r(0 .8)) scheme(s1color) aspectratio(.5)

log close
