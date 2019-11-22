The purpose of this document is to conduct and present analyses describing differences in children's household instability over time by parental education. 

Start with the 2014 data on all months and select observations who are not adults.

~~~~
<<dd_do: quietly>>

	 use "$SIPP14keep/HHchangeWithRelationships_am.dta", clear

	 global adult_age 18 // set a macro so that we can easily change the age cutoff 
	 local adult_age $adult_age

	 drop if missing(ERESIDENCEID)

	 keep if adj_age < $adult_age

<</dd_do>>
~~~~

We collapse by parental education, age and wave to create a mean number of transitions each panelmonth. The first step estimates weighted rates of transition in each month by wave, which is the same as year in 2014. We keep the second wave because the analysis by trends revealed that it is likely the least downwardly biased. 

<<dd_do: quietly>>

	 gen swave=floor((panelmonth+11)/12)

	 keep if swave==2
	 global swave 2

	 collapse (mean) hh_change comp_change parent_change sib_change other_change nonparent_change gp_change nonrel_change otherrel_change [aweight=WPFINWGT], by(par_ed_first adj_age panelmonth)

<</dd_do>>
~~~~

Next we sum across all months to get an annual transition rate by age for each category of parental education. 

~~~~
<<dd_do: quietly>>

	 gen month=12-($swave*12-panelmonth)

	 collapse (sum) hh_change comp_change parent_change sib_change other_change nonparent_change gp_change nonrel_change otherrel_change, by(par_ed_first adj_age)

<</dd_do>>
~~~~

And then sum across all ages to get a cumulative number of transitions before `adult_age'th bithday by parental_education.

~~~~
<<dd_do: quietly>>

	 collapse (sum) hh_change comp_change parent_change sib_change other_change nonparent_change gp_change nonrel_change otherrel_change, by(par_ed_first)

	 * put result into a matrix so that I can display them
	 mkmat hh_change comp_change parent_change sib_change gp_change nonrel_change, matrix(byed14)

	 matrix rownames byed14 = "< High School" "High School" "Some College" "College Grad+" "Missing"
	 matrix colnames byed14 = "all" "comp" "par" "sib" "grndp" "nonrel" 

<</dd_do>>


~~~~
<<dd_do>>

	matlist byed14, format(%6.1f) title(These are estimates of the amount of instability by `adult_age'th birthday estimated from the 2014 SIPP panel) rowtitle(parent ed)


<</dd_do>>
~~~~


~~~~
<<dd_do: quietly>>

	 * save the data for future use
	 save "$tempdir/ratesbyed14.dta", $replace
	 clear matrix

<</dd_do>>
~~~~

Now do the same for 2008.

~~~~
<<dd_do: quietly>>

	 use "$SIPP08keep/HHchangeWithRelationships_am.dta", clear

	 drop if missing(SHHADID)

	 keep if adj_age < $adult_age

<</dd_do>>
~~~~

We collapse by parent ed, age and wave to create a mean number of transitions by age for each panelmonth. The first step estimates weighted rates of transition in each month.

<<dd_do: quietly>>

	 collapse (mean) hh_change comp_change parent_change sib_change other_change nonparent_change gp_change nonrel_change otherrel_change [aweight=WPFINWGT], by(par_ed_first adj_age panelmonth)

<</dd_do>>
~~~~

Next we sum across all months in each wave and multiply by 3 to get an annual transition rate. There would be an alternative way where we originally sum by year (as we do for 2014). I don't think it will ever make sense to do that by actual calendar year because different rotations have their first observation in different months and there is a tendency to have more instability in the last month of the reference period. Thus we sum by wave to get a four-month estimate of instability. We could sum by a calculated year rather than multiply by three and then aggregate these by year.

~~~~
<<dd_do: quietly>>

	 gen wave=floor((panelmonth+3)/4)
	 gen month=4-(wave*4-panelmonth)

	 * preserve to be able to go back and delete wave 1 because we believe that there is underreporting of household members not still
	 * in the household at the time of the interview and this results in an underestimate of instability in the first year. 
	 preserve

	 collapse (sum) hh_change comp_change parent_change sib_change other_change nonparent_change gp_change nonrel_change otherrel_change, by(par_ed_first adj_age wave)

	 replace hh_change=hh_change*3 // converting 4-month rate to an annual rate
	 replace comp_change=comp_change*3 
	 replace parent_change=parent_change*3 
	 replace sib_change=sib_change*3 
	 replace other_change=other_change*3 
	 replace nonparent_change=nonparent_change*3 
	 replace gp_change=gp_change*3 
	 replace nonrel_change=nonrel_change*3 
	 replace otherrel_change=otherrel_change*3 

	 * Note that this is only an approximation of year since actual calendar month varies by rotation within wave
	 gen year=2008+floor((wave+2)/3)

	 * the trends_analysis showed that wave 1 likely underestimates household instability
	 drop if wave==1

	 keep if year==2009
	 
	 collapse (mean) hh_change comp_change parent_change sib_change other_change nonparent_change gp_change nonrel_change otherrel_change, by(par_ed_first adj_age)

	 collapse (sum) hh_change comp_change parent_change sib_change other_change nonparent_change gp_change nonrel_change otherrel_change, by(par_ed_first)

	 * put result into a matrix so that I can diplay them
	 mkmat hh_change comp_change parent_change sib_change gp_change nonrel_change, matrix(byed08)
	 
	 matrix rownames byed08 = "< High School" "High School" "Some College" "College Grad+" "Missing"
	 matrix colnames byed08 = "all" "comp" "par" "sib" "grndp" "nonrel" 
<</dd_do>>

~~~~
<<dd_do>>

	matlist byed08, format(%6.1f) title(These are estimates of instability by `adult_age'th birthday by parental education estimated from the 2008 panel) rowtitle(year)

	clear matrix

<</dd_do>>
~~~~

~~~~
<<dd_do: quietly>>

	 * save the data for future use
	 save "$tempdir/ratesbyed08.dta", $replace

<</dd_do>>
~~~~

The 2004 panel. 

~~~~
<<dd_do: quietly>>

	 use "$SIPP04keep/HHchangeWithRelationships_am.dta", clear

	 drop if missing(SHHADID)

	 keep if adj_age < $adult_age
<</dd_do>>
~~~~

We collapse by parental education, age and wave to create a mean number of transitions by age for each panelmonth. The first step estimates weighted rates of transition in each month.

~~~~
<<dd_do: quietly>>

	 collapse (mean) hh_change comp_change parent_change sib_change other_change nonparent_change gp_change nonrel_change otherrel_change [aweight=WPFINWGT], by(par_ed_first adj_age panelmonth)

	 gen wave=floor((panelmonth+3)/4)
	 gen month=4-(wave*4-panelmonth)

	 * drop wave 1 because we find evidence again that it underestimates instability
	 drop if wave==1

	 collapse (sum) hh_change comp_change parent_change sib_change other_change nonparent_change gp_change nonrel_change otherrel_change, by(par_ed_first adj_age wave)

	 replace hh_change=hh_change*3 // converting 4-month rate to an annual rate
	 replace comp_change=comp_change*3 
	 replace parent_change=parent_change*3 
	 replace sib_change=sib_change*3 
	 replace other_change=other_change*3 
	 replace nonparent_change=nonparent_change*3 
	 replace gp_change=gp_change*3 
	 replace nonrel_change=nonrel_change*3 
	 replace otherrel_change=otherrel_change*3 

	 *Then create estimates by year. 

	 * Note that this is only an approximation of year since actual calendar month varies by rotation within wave
	 gen year=2004+floor((wave+2)/3)

	 keep if year==2005
	 
	 collapse (mean) hh_change comp_change parent_change sib_change other_change nonparent_change gp_change nonrel_change otherrel_change, by(par_ed_first adj_age)
	 
	 collapse (sum) hh_change comp_change parent_change sib_change other_change nonparent_change gp_change nonrel_change otherrel_change, by(par_ed_first)

	 * put result into a matrix so that I can diplay them
	 mkmat hh_change comp_change parent_change sib_change gp_change nonrel_change, matrix(byed04)

	 matrix rownames byed04 = "< High School" "High School" "Some College" "College Grad+" "Missing"
	 matrix colnames byed04 = "all" "comp" "par" "sib" "grndp" "nonrel" 


<</dd_do>>
~~~~

~~~~
<<dd_do>>

	matlist byed04, format(%6.1f)  title(These are estimates of instability by `adult_age'th birthday by parental education estimated from the 2004 panel)  rowtitle(parent education)

<</dd_do>>
~~~~

~~~~
<<dd_do: quietly>>

	 * save the data for future use
	 save "$tempdir/ratesbyed04.dta", $replace
	 clear matrix

<</dd_do>>
~~~~

~~~~
<<dd_do: quietly>>

	 clear
	 clear matrix

<</dd_do>>
~~~~

The 2001 panel. 

~~~~
<<dd_do: quietly>>

	 use "$SIPP01keep/HHchangeWithRelationships_am.dta", clear
	 
	 drop if missing(SHHADID)

	 keep if adj_age < $adult_age
<</dd_do>>
~~~~

We collapse by parental education, age and wave to create a mean number of transitions by age for each panelmonth. The first step estimates weighted rates of transition in each month.

~~~~
<<dd_do: quietly>>

	 collapse (mean) hh_change comp_change parent_change sib_change other_change nonparent_change gp_change nonrel_change otherrel_change [aweight=WPFINWGT], by(par_ed_first adj_age panelmonth)

	 gen wave=floor((panelmonth+3)/4)
	 gen month=4-(wave*4-panelmonth)

	 * drop wave 1 because we find evidence again that it underestimates instability
	 drop if wave==1

	 collapse (sum) hh_change comp_change parent_change sib_change other_change nonparent_change gp_change nonrel_change otherrel_change, by(par_ed_first adj_age wave)

	 replace hh_change=hh_change*3 // converting 4-month rate to an annual rate
	 replace comp_change=comp_change*3 
	 replace parent_change=parent_change*3 
	 replace sib_change=sib_change*3 
	 replace other_change=other_change*3 
	 replace nonparent_change=nonparent_change*3 
	 replace gp_change=gp_change*3 
	 replace nonrel_change=nonrel_change*3 
	 replace otherrel_change=otherrel_change*3 

	 *Then create estimates by year. 

	 * Note that this is only an approximation of year since actual calendar month varies by rotation within wave
	 gen year=2001+floor((wave+2)/3)

	 keep if year==2002
	 
	 collapse (mean) hh_change comp_change parent_change sib_change other_change nonparent_change gp_change nonrel_change otherrel_change, by(par_ed_first adj_age)

	 collapse (sum) hh_change comp_change parent_change sib_change other_change nonparent_change gp_change nonrel_change otherrel_change, by(par_ed_first)
	 
	 * put result into a matrix so that I can diplay them
	 mkmat hh_change comp_change parent_change sib_change gp_change nonrel_change, matrix(byed01)
	 
	 matrix rownames byed01 = "< High School" "High School" "Some College" "College Grad+" "Missing"	
	 matrix colnames byed01 = "all" "comp" "par" "sib" "grndp" "nonrel" 

<</dd_do>>
~~~~

~~~~
<<dd_do>>

	matlist byed01, format(%6.1f)  title(These are estimates of instability by `adult_age'th birthday by parental education estimated from the 2001 panel)  rowtitle(parental ed)

<</dd_do>>
~~~~

~~~~
<<dd_do: quietly>>

	 * save the data for future use
	 save "$tempdir/ratesbyed01.dta", $replace
	 clear matrix

<</dd_do>>
~~~~

I quietly pull together all the panels for a cross-panel analysis and then graph household instability by parental education by panel.

~~~~
<<dd_do: quietly>>

	 use "$tempdir/ratesbyed01.dta", clear
	 gen year=2002
	 append using "$tempdir/ratesbyed04.dta"
	 replace year=2005 if missing(year)
	 
	 append using "$tempdir/ratesbyed08.dta"
	 replace year=2009 if missing(year)
	 
	 append using "$tempdir/ratesbyed14.dta"
	 replace year=2014 if missing(year)

	 keep if year==2002 | year==2005 | year==2009 | year==2014
	 sort year par_ed_first

	 drop if missing(par_ed_first)

	 reshape wide hh_change comp_change parent_change sib_change other_change nonparent_change gp_change nonrel_change otherrel_change, i(year) j(par_ed_first)

	 local type "hh comp parent sib other nonparent gp nonrel otherrel"

	 foreach t of local type {
	     label variable `t'_change1 "< High School"
	     label variable `t'_change2 "High School"
	     label variable `t'_change3 "Some College"
	     label variable `t'_change4 "College Grad+"
	}

	save "$tempdir/ratesbyedbypanel.dta", $replace

	graph twoway connected hh_change1 hh_change2 hh_change3 hh_change4 year, lpattern(longdash dot solid shortdash) title(Total Household Instability by Year by Parental Education)

<</dd_do>>
~~~~

<<dd_graph:>>

Focusing on the first three panels, we see an increase in household instability in the early 2000s (except for the children of college-educated parents), but instabillity did not continue to rise during the latter part of the naughts. It looks like instability increased for everyone but the least-educated groups in 2014. That may be true, or it may be that the redesign is better at capturing instability of the highly educated. 


Next we take a look at composition change...
~~~~
<<dd_do: quietly>>

	 use "$tempdir/ratesbyedbypanel.dta", clear

	 graph twoway connected comp_change1 comp_change2 comp_change3 comp_change4 year, lpattern(longdash dot solid shortdash) title(Composition Change by Year by Parental Education)

<</dd_do>>
~~~~

<<dd_graph:>>

and find rougly similar patterns.

Finallly, a look at parental change.

~~~~
<<dd_do: quietly>>

	 use "$tempdir/ratesbyedbypanel.dta", clear

	 graph twoway connected parent_change1 parent_change2 parent_change3 parent_change4 year, lpattern(longdash dot solid shortdash) title(Parental Instability by Year by Parental Education)

<</dd_do>>
~~~~

<<dd_graph:>>

The most striking aspect of this graph is that the children of college-educated parents see a rise in parental instability throughout the period of observation, while parental instability is relatively flat for those with a college-degree or less.

We might want to look at trends in the percentage of children living with two parents. It may be that declining proportions of children of less-educated parents live with two parents and this accounts for the stability in parental instability.

To do this, we need to get HHCompasis files up and working for the allmonths datafiles. 

