~~~~
<<dd_do: quietly>>

*******************************************************************************
* Does household instability predict high school dropout and/or high school graduation?
* This file creates variables describing (first) transition to dropout or high school graduation
* and produces the description of the data and variables to be included in the paper. 
*******************************************************************************

* !!!! NOTE: ssc install carryforward prior to running

<</dd_do>>
~~~~

Data for our analysis come from the 2014 panel of the Survey of Income and Program Participation (SIPP). The 2014 panel initiated a redesign of the SIPP where individuals in sampled households are interviewed every year and asked questions about household composition in every month of the previous year as well as about school enrollment in each month and educational attainment at the time of the interview. The first interview was in 2014 and asked questions about 2013; the last interview was in 2018, covering 2017.

~~~~
<<dd_do: quietly>>

*excute do_all_months.do to create HHchangeWithRelationships_am.dta 
use "$SIPP14keep/HHchangeWithRelationships_am.dta", clear

duplicates drop SSUID PNUM, force

egen all=count(1)
local allindividuals = all

use "$SIPP14keep/HHchangeWithRelationships_am.dta", clear

keep if adj_age > 14 & adj_age < 20

preserve

	duplicates drop SSUID PNUM, force

	egen all=count(1)
	local all1419=all

restore

<</dd_do>>
~~~~

The SIPP is a large (N=<<dd_display: %6.0fc `allindividuals'>>), probability sample of the non-institutionalized U.S. population. The focus of this analysis is on individuals who were age 14-19 at any time between January 2013 and December 2017 (N=<<dd_display: %6.0fc `all1419'>>).

The primary dependent variable is school dropout prior to obtaintaing a high school degree. Many individuals who dropout of school will eventually obtain a diploma or GED, but dropping out of school is a sign of academic trouble that may have lasting consequences even if the person returns to school to earn a degree. 

~~~~
<<dd_do: quietly>>

*******************************************************************************
* Create measures of educational attainment
*******************************************************************************
	*assuming all children under age 15 have less than a high school degree
	replace educ=1 if adj_age<15 

	*fill in missing educ: carry forward education from previous month if education is missing in current month
	egen id = concat (SSUID PNUM)
	destring id, gen(idnum)
	format idnum %20.0f
	
	xtset idnum panelmonth
	sort idnum panelmonth
	by idnum: replace educ = educ[_n-1] if missing(educ)

	tab panelmonth

	   ************create indicator for high school dropout adjusted for summer *********
	   gen dropout= (educ==1 & RENROLL==2) if !missing(RENROLL)
	
	   * create indicators for wave and month
	   gen swave=floor((panelmonth+11)/12)
	   
	   *indicator of month: Jan-Dec
	   gen month=12-(swave*12-panelmonth)

	   ** now adjusting for summer
	   *recode dropout in summer (6-8) to 0 if they report enrolled in September

	   save "$tempdir/dropout.dta", $replace

	   keep SSUID PNUM panelmonth dropout 

	   reshape wide dropout, i(SSUID PNUM) j(panelmonth)

	   * loop across years
	   forvalues y=0/3{
	   * loop for june, july, and august     
	       forvalues mon=6/8{
               local pm=`y'*12+`mon'
               local september=`y'*12+9
               replace dropout`pm'=0 if dropout`september'==0
    	       }
	   }

	   reshape long dropout, i(SSUID PNUM) j(panelmonth)

	   save "$tempdir/dropout_adjust.dta", $replace

	   use "$tempdir/dropout.dta", clear
	   drop dropout 

	   merge 1:1 SSUID PNUM panelmonth using "$tempdir/dropout_adjust.dta"

	   keep if _merge==3
	   drop _merge

	*********** create indicator of high school graduation *********
	gen hsgrad= (educ==2) if !missing(educ)
	*********** identify and drop individuals that have dropped out or graduated at first observation **

	xtset idnum panelmonth

	* Identify first observation of the individual. (Note that this is not always January 2013).
	bysort idnum: gen count=_n
	bysort idnum: gen dropout_base=1 if count==1 & dropout==1
	bysort idnum: gen hsgrad_base=1 if count==1 & hsgrad==1

	gen omit=1 if dropout_base==1 | hsgrad_base==1
	egen omitted=count(omit)
	
	local n_omitted=omitted
	
	sort idnum panelmonth

	* Mark for deletion all observations for individuals that originated as a dropout or high school graduate
	by idnum: carryforward(dropout_base),replace
	by idnum: carryforward(hsgrad_base),replace

	drop if dropout_base==1 | hsgrad_base==1

<</dd_do>>
~~~~

We omit from the analysis <<dd_display: %3.0fc `n_omitted'>> individuals who had dropped out of school or had their high school degree at first observation.

~~~~
<<dd_do>>

************************* create indicator of ever dropout***********
         *tag first dropout month 
	  sort idnum panelmonth
	  egen tag_dropout=tag (idnum dropout)
	  replace tag_dropout=0 if tag_dropout==1 & dropout==0
	  tab tag_dropout
			  
	  bysort idnum: egen ever_dropout= max(dropout)

	  gen everdrop = 1 if ever_dropout==1 // need only valid values for dropouts

	  egen ndropouts=count(everdrop)
	  egen pdropout=mean(ever_dropout)
	  local n_dropouts = ndropouts
	  local p_dropouts = 100*pdropout

************************* create indicator of ever hs graduate***********

         *tag month of high school graduation
	 sort idnum panelmonth
	 egen tag_hsgrad=tag (idnum hsgrad)
	 replace tag_hsgrad=0 if tag_hsgrad==1 & hsgrad==0
	 tab tag_hsgrad

	 bysort idnum: egen ever_hsgrad= max(hsgrad)

<</dd_do>>
~~~~

We observe <<dd_display: %3.0fc `n_dropouts'>> individuals (<<dd_display: %2.1f `p_dropouts'>> percent of the sample) dropping out.

~~~~
<<dd_do: quietly>>

*************************************************************************
* Section: select person-months at risk of high school dropout or high school graduation
*************************************************************************

*identify panelmonth of first dropout and carry forward/backward
	  sort idnum panelmonth 
	  gen month_firstd = panelmonth if tag_dropout==1
	  by idnum: carryforward(month_firstd), replace	
	  gsort idnum -panelmonth 
	  by idnum: carryforward(month_firstd), replace	
	  sort idnum panelmonth

*identify panelmonth of first hsgrad and carry forward/backward
	  gen month_firstg = panelmonth if tag_hsgrad==1
	  by idnum: carryforward(month_firstg), replace	
	  gsort idnum -panelmonth 
	  by idnum: carryforward(month_firstg), replace	
	  sort idnum panelmonth
	  
	gen censormonth=min(month_firstg, month_firstd)

	*drop months that come after the first dropout or hsgrad (create a censored sample)
	keep if panelmonth<=censormonth

*describe sample

	  egen sample=count(1)

	  local analytical_sample_m = sample

	  preserve

		duplicates drop idnum, force

		egen uniqueid=count(1)

	 	 local analytical_sample_p = uniqueid
		 
	  restore

<</dd_do>>
~~~~
Our analytical sample is <<dd_display: %8.0fc `analytical_sample_m'>> person-months at risk of high school graduation (<<dd_display: %5.0fc `analytical_sample_p'>> adolescents.


7,071   children, 136,519  observations

~~~~
<<dd_do>>

*************************************************************************
* Section: create independent variables
*************************************************************************

*household composition changes (8 categories just in case)
gen cchange=.
replace cchange=1 if parent_change==0 & sib_change==0 & other_change==0 //no change
replace cchange=2 if parent_change==1 & sib_change==0 & other_change==0 //only parent change
replace cchange=3 if parent_change==1 & sib_change==1 & other_change==0 //parent change & sibling change
replace cchange=4 if parent_change==1 & sib_change==0 & other_change==1 //parent change & other change
replace cchange=5 if parent_change==0 & sib_change==1 & other_change==0 //only sibling change
replace cchange=6 if parent_change==0 & sib_change==1 & other_change==1 //sibling change & other change
replace cchange=7 if parent_change==0 & sib_change==0 & other_change==1 //only other change
replace cchange=8 if parent_change==1 & sib_change==1 & other_change==1 //3 change

*create poverty status
gen cpov=.
replace cpov=1 if THINCPOVT2 <= .5
replace cpov=2 if THINCPOVT2 > .5 &  THINCPOVT2 <=1
replace cpov=3 if THINCPOVT2 > 1 &  THINCPOVT2 <=2
replace cpov=4 if THINCPOVT2 >2

*merge in hh composition
merge 1:1 SSUID PNUM panelmonth using "$SIPP14keep/HHComp_pm.dta", keepusing (parcomp sibcomp extend WPFINWGT)

keep if _merge==3 | _merge==1
drop _merge


*create ever variables
local evervar comp_change bioparent_change parent_change sib_change biosib_change ///
 halfsib_change stepsib_change other_change gp_change nonrel_change otherrel_change cchange
foreach var in `evervar'{
 bysort idnum (panelmonth): gen tvnum_`var'=sum(`var')
 recode tvnum_`var' (1/max=1), gen (tvever_`var')
 }
 
 *create lagged variables 
local cvar comp_change bioparent_change parent_change sib_change biosib_change ///
 halfsib_change stepsib_change other_change gp_change nonrel_change otherrel_change cchange ///
 parcomp sibcomp extend RHNUMPERWT2 RHNUMU18WT2 cpov tvever_parent_change tvever_biosib_change ///
 tvever_halfsib_change tvever_stepsib_change tvever_sib_change tvever_other_change 
foreach var in `cvar'{
 bysort idnum (panelmonth): gen `var'lag=`var'[_n-1]
}

 
label values parcomplag parcomp
label values sibcomplag sibcomp
label values extendlag extend

label define edu 1 "Less than HS" 2"HS Grad" 3"Some College" 4"College Grad"
label values par_ed_first edu

label define poverty 1 "Deep poverty" 2"Poor" 3"Near Poor" 4"Not Poor"
label values cpov poverty
label values cpovlag poverty

label define cchange 1 "no change" 2 "only parent change" 3 "par&sib change" 4 "par&other change" 5 "only sib change" 6 "sib&other change" 7 "only other change" 8 "3 changes"
label values cchange cchange
label values cchangelag cchange

save "$SIPP14keep/dropout_month.dta", $replace
