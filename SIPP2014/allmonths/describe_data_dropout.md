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

Data for our analysis come from the 2014 panel of the Survey of Income and Program Participation (SIPP). The 2014 panel initiated a redesign of the SIPP where individuals in sampled households are interviewed every year and asked questions about household composition and school enrollment in every month of the previous year, as well as educational attainment at each interview. The first interview was in 2014 and asked questions about 2013; the last interview was in 2018, covering 2017.

~~~~
<<dd_do: quietly>>
*********************************************************************************
* Read in data and describe sample
*********************************************************************************

	 *excute do_all_months.do to create demo_long_interviews_am.dta and HHchangeWithRelationships_am.dta 

	 global data "$SIPP14keep/demo_long_interviews_am.dta" 
	 
	 use "$data", clear

	 * create a unique id for each individual
	 egen id = concat (SSUID PNUM)
	 destring id, gen(idnum)
	 format idnum %20.0f

	 drop id

	 *describe sample
	 sort idnum panelmonth
	 egen tagid = tag(idnum)
	 replace tagid=. if tagid !=1 

	 egen all_p=count(tagid)

	 local allindividuals = all_p

	 drop all_p tagid 

	 * focus on analytic sample
	   * create indicators for wave and month
	   gen swave=floor((panelmonth+11)/12)
	   
	   *indicator of month: Jan-Dec
	   gen month=12-(swave*12-panelmonth)

  keep if adj_age > 15 & adj_age < 20
	 
	 *describe sample
	 sort idnum panelmonth
	 egen tagid = tag(idnum)
	 replace tagid=. if tagid !=1 // set to missing not-tagged observations

	 egen inage=count(tagid)
	 local all1519=inage

	 drop inage tagid

<</dd_do>>
~~~~

The SIPP is a large (N=<<dd_display: %6.0fc `allindividuals'>>), probability sample of the non-institutionalized U.S. population. The focus of this analysis is on individuals who were age 16-19 at any time between January 2013 and December 2017 (N=<<dd_display: %6.0fc `all1519'>>). Most states have compulsory schooling to age 16 and most who will graduate from high school will do so by age 19.

The primary dependent variable is school dropout prior to obtaintaing a high school degree. Many individuals who dropout of school will eventually obtain a diploma or GED, but dropping out of school is a sign of academic trouble that may have lasting consequences even if the person returns to school. 

~~~~
<<dd_do>>

*******************************************************************************
* Create measures of educational attainment
*******************************************************************************
	*fill in missing educ: carry forward education from previous month if education is missing in current month

	xtset idnum panelmonth
	sort idnum panelmonth
	by idnum: replace educ = educ[_n-1] if missing(educ)


	   ************create indicator for high school dropout adjusted for summer *********
	   * Note RENROLL is a Census-constructed variable based on measures of periods of enrollment.
	   gen dropout= (educ==1 & RENROLL==2) if !missing(RENROLL)
	
	   ** now adjusting for summer
	   *recode dropout in summer (6-8) to 0 if they report enrolled in September

	   save "$tempdir/dropout.dta", $replace

	   keep SSUID PNUM panelmonth dropout educ

	   reshape wide dropout educ, i(SSUID PNUM) j(panelmonth)

	   * loop across years
	   forvalues y=1/3{
	   display "processing year `y'"
	   * loop for june, july, and august     
	       forvalues mon=6/8{
               local pm=`y'*12+`mon'
               local september=`y'*12+9
               replace dropout`pm'=0 if dropout`september'==0
    	       }
	   }

	   gen first_dropout_m=.
	   gen first_hsgrad_m=.
	   forvalues m=13/48 {
	   	     replace first_dropout_m=`m' if missing(first_dropout_m) & dropout`m'==1
	   	     replace first_hsgrad_m=`m' if missing(first_hsgrad_m) & educ`m'==2
           }

	   drop educ*

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

	* Identify first observation of the individual.
	bysort idnum: gen count=_n
	bysort idnum: gen dropout_base=1 if count==1 & dropout==1
	bysort idnum: gen hsgrad_base=1 if count==1 & hsgrad==1

	drop count

	gen omit=1 if dropout_base==1 | hsgrad_base==1
	egen omitted=count(omit)
	
	local n_omitted=omitted
	
	sort idnum panelmonth

	* Mark for deletion all observations for individuals that originated as a dropout or high school graduate
	by idnum: carryforward(dropout_base),replace
	by idnum: carryforward(hsgrad_base),replace

 drop if dropout_base==1 | hsgrad_base==1

	drop dropout_base hsgrad_base omit omitted

************************* create indicator of ever dropout and ever grad ***********

	  bysort idnum: egen ever_hsgrad= max(hsgrad)

	  bysort idnum: egen ever_dropout= max(dropout)

	 *describe sample (individuals)
	 sort idnum panelmonth
	 egen tagid = tag(idnum)
	 replace tagid=. if tagid !=1 

	 egen all_p2=count(tagid)

	 local allindividuals2 = all_p2

	 drop tagid all_p2

*************************************************************************
* Section: select person-months at risk of high school dropout or high school graduation
*************************************************************************
         *tag first dropout month 
	  sort idnum panelmonth
	  egen tag_dropout=tag (idnum dropout)
	  replace tag_dropout=0 if tag_dropout==1 & dropout==0
	  tab tag_dropout

         *tag month of high school graduation
	 sort idnum panelmonth
	 egen tag_hsgrad=tag (idnum hsgrad)
	 replace tag_hsgrad=0 if tag_hsgrad==1 & hsgrad==0
	 tab tag_hsgrad

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

	  gen outcome=1 if censormonth==month_firstd
	  replace outcome=2 if censormonth==month_firstg
	  replace outcome=0 if missing(censormonth)

	  drop month_firstg month_firstd

	 *identify cases missing on the outcome
	 gen missing=1 if missing(RENROLL) 

	 tab missing outcome, m

         egen missing_outcome=count(missing)
	 local missing=missing_outcome

 drop if missing==1

	 egen allmonths=count(1)
	 local allmonths2=allmonths

	 drop allmonths missing_outcome missing

	 *check if dropping months eliminated some individuals
	 sort idnum panelmonth
	 egen tagid = tag(idnum)
	 replace tagid=. if tagid !=1 

	 egen all_p3=count(tagid)

	 local allindividuals3 = all_p3

	 drop tagid all_p3

 	 save "$tempdir/hseduc14", replace

	 collapse (count) dropout, by(idnum)

	 tab count

<</dd_do>>
~~~~

We omit from the analysis <<dd_display: %5.0fc `n_omitted'>> individuals age 16-19 who had dropped out of school or had their high school degree at first observation, leaving <<dd_display:%8.0fc `allindividuals2'>> age 16-19. The data are censored at high school graduation or first dropout. In addition, we delete observations missing information on school enrollment, leaving us with <<dd_display: %8.0fc `allmonths2'>> person-months at risk of high school dropout or graduation (<<dd_display: %5.0fc `allindividuals3'>> adolescents). 

~~~~
<<dd_do>>

*************************************************************************
* Section: create independent variables. Doing this before finalizing 
* the sample because lagged variables trim the first panelmonth(s)
*************************************************************************

	use "$SIPP14keep/HHchangeWithRelationships_am.dta", clear
	
	 egen id = concat (SSUID PNUM)
	 destring id, gen(idnum)
	 format idnum %20.0f

	 drop id

         * create indicators for wave and month
	 gen swave=floor((panelmonth+11)/12)
	   
	 *indicator of month: Jan-Dec
	 gen month=12-(swave*12-panelmonth)

	* need to keep younger observations for lagged info on household change. Will trim up later.
	keep if adj_age < 20

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
	local evervar hh_change comp_change bioparent_change parent_change sib_change ///
	biosib_change halfsib_change stepsib_change other_change gp_change ///
	nonrel_change otherrel_change cchange
	
	foreach var in `evervar'{
	    bysort idnum: gen tvnum_`var'= sum(`var')
	    recode tvnum_`var' (1/max=1), gen (tvever_`var')
	}

	* create lagged variables. Because the instability variables are
	* prospective (between this wave and next), we need to lag one month to get household
	* instability measured prior to dropout.
	local cvar hh_change comp_change bioparent_change parent_change sib_change ///
	biosib_change halfsib_change stepsib_change other_change ///
	gp_change nonrel_change otherrel_change cchange parcomp sibcomp extend ///
        tvever_parent_change tvever_biosib_change ///
	cpov tvever_halfsib_change tvever_stepsib_change tvever_sib_change tvever_other_change 
	foreach var in `cvar'{
	    bysort idnum (panelmonth): gen `var'lag=`var'[_n-1]
        }

	save "$tempdir/monthlylagged.dta", replace

	*create variables describing household instability in each calendar year
		collapse (sum) `evervar', by(idnum swave)

		foreach var in `evervar' {
			recode `var' (1/max=1), gen(`var'Y)
			rename `var' `var'C
		}

		replace swave=swave+1

		drop if swave==5 // we don't need measures of instability in the last wave

		save "$tempdir/annual_instability", replace
		
*************************************************************************
* Section: Bring back the education data to merge the household composition
* and instability measures 
*************************************************************************

	use "$tempdir/hseduc14.dta", clear

	* merge last-year's instability onto observation
	merge m:1 idnum swave using "$tempdir/annual_instability.dta"
	
	keep if _merge==1 | _merge==3

 	drop _merge

	* merge in monthly lagged variables
	merge 1:1 SSUID PNUM panelmonth using "$tempdir/monthlylagged.dta"

	* must be in the education sample
	keep if _merge==1 | _merge==3
 	drop _merge
	
*******************************************************************************
* Trim and describe sample
******************************************************************************
   * make sure that merges didn't bring in some 15 year olds
   assert adj_age > 15

   * no information on household instability prior to first obsservation
   bysort idnum: gen count=_n
   drop if count==1

   * tag individuals to count
   sort idnum panelmonth
   egen tagid = tag(idnum)
   replace tagid=. if tagid !=1 

   egen sample_p=count(tagid)
   
   egen sample_m=count(1)

   local analytical_sample_p = sample_p
   local analytical_sample_m = sample_m

   drop sample_p sample_m  

   gen dropouts=1 if dropout==1

   tab tagid
   tab dropouts

   egen ndropouts=count(dropouts)

   egen pdropouts=mean(dropout)

   sum dropouts

   local n_dropouts = ndropouts
   local p_dropouts = 100*pdropouts

   drop ndropouts pdropouts dropouts tagid count // cleanup 

<</dd_do>>
~~~~
Finally, we drop the first observation because we do not have a measure of household instability prior to this point, leaving us with a sample of <<dd_display: %8.0fc `analytical_sample_p'>> individuals and <<dd_display: %8.0fc `analytical_sample_m'>> months. We observe <<dd_display: %5.0fc `n_dropouts'>> individuals (<<dd_display: %2.1f `p_dropouts'>> percent of the sample) dropping out. 

~~~~
<<dd_do: quietly>>

local desc "comp_change parent_change sib_change biosib_change halfsib_change stepsib_change other_change gp_change"
local descY "comp_changeY parent_changeY sib_changeY biosib_changeY halfsib_changeY stepsib_changeY other_changeY gp_changeY"


foreach var in `desc' {
	sum `var'
	egen m_`var'=mean(`var')
	local m_`var'=100*m_`var'
}


foreach var in `descY' {
	sum `var'
	egen m_`var'=mean(`var')
	local m_`var'=100*m_`var'
}

<</dd_do>>
~~~~

Characteristics of person-months
Household instability previous month  Percent <br>
  Any Composition change       <<dd_display: %6.1f `m_comp_change'>> <br>
  Parent	  	       <<dd_display: %6.1f `m_parent_change'>> <br>
  Sibling		       <<dd_display: %6.1f `m_sib_change'>> <br>
    biological		       <<dd_display: %6.1f `m_biosib_change'>> <br>
    half		       <<dd_display: %6.1f `m_halfsib_change'>> <br>
    step		       <<dd_display: %6.1f `m_stepsib_change'>> <br>
  Other			       <<dd_display: %6.1f `m_other_change'>> <br>
    grandparent		       <<dd_display: %6.1f `m_gp_change'>> <br>


Characteristics of person-months
Household instability previous year  Percent <br>
  Any Composition change       <<dd_display: %6.1f `m_comp_changeY'>> <br>
  Parent	  	       <<dd_display: %6.1f `m_parent_changeY'>> <br>
  Sibling		       <<dd_display: %6.1f `m_sib_changeY'>> <br>
    biological		       <<dd_display: %6.1f `m_biosib_changeY'>> <br>
    half		       <<dd_display: %6.1f `m_halfsib_changeY'>> <br>
    step		       <<dd_display: %6.1f `m_stepsib_changeY'>> <br>
  Other			       <<dd_display: %6.1f `m_other_changeY'>> <br>
    grandparent		       <<dd_display: %6.1f `m_gp_changeY'>> <br>

~~~~
<<dd_do: quietly>>

**************************************************************************
* Add labels because they might come in handy later
*************************************************************************
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
