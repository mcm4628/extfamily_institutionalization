The purppose of this document is to conduct and present analyses describing children's household instability over time. These analysis will describe overall trends. A separate analysis will investigate variation by "parental" education and race-ethnicity.

A presentation of trends is complicated by a couple of concerns. First, there is substantial sample attrition as panels age and we suspect that this attrition is more severe for individuals with a greater tendency for household instability. Thus we must conduct within panel analyses to evaluate this possibility. Second, the 2014 panel uses an innovative approach that could affect the quality of measurement of children's household instability. We address these potential measurement concerns first because they affect our approach to describing trends over time.

The first order of business is to evaluate data from the 2004, 2008, and 2014 panels independently to see if we find evidence that instability declines systematically as panels age. If we find that sort of trend, it could suggest that sample attrition downwardly biases estimates of children's household instability. But it might not be error; it could be that children's household instability is really declining over time. 

We start with the 2014 data on all months and select observations less than age 18.

~~~~
<<dd_do: quietly>>

use "$SIPP14keep/HHchangeWithRelationships_am.dta", clear

drop if missing(ERESIDENCEID)

keep if adj_age < 18

<</dd_do>>
~~~~

We collapse by age and wave to create a mean number of transitions by age for each panelmonth. The first step estimates weighted rates of transition in each month by wave, which is the same as year in 2014.

<<dd_do: quietly>>

gen swave=floor((panelmonth+11)/12)

collapse (mean) hh_change comp_change parent_change sib_change other_change nonparent_change gp_change nonrel_change otherrel_change [aweight=WPFINWGT], by(adj_age panelmonth swave)

<</dd_do>>
~~~~

Next we sum across all months in each wave to get an annual transition rate. 

~~~~
<<dd_do: quietly>>

gen month=12-(swave*12-panelmonth)

collapse (sum) hh_change comp_change parent_change sib_change other_change nonparent_change gp_change nonrel_change otherrel_change, by(adj_age swave)

<</dd_do>>
~~~~

And then sum across all ages to get a cumulative number of transitions before 18th bithday.

~~~~
<<dd_do: quietly>>

collapse (sum) hh_change comp_change parent_change sib_change other_change nonparent_change gp_change nonrel_change otherrel_change, by(swave)

* put result into a matrix so that I can display them
mkmat hh_change comp_change parent_change sib_change gp_change nonrel_change, matrix(byear14)

matrix rownames byear14 = "2013" "2014" "2015" "2016"
matrix colnames byear14 = "all" "comp" "par" "sib" "grndp" "nonrel" 
<</dd_do>>

~~~~
<<dd_do>>

matlist byear14, format(%6.1f) title(These are estimates of the total amount of instability by 18th birthday estimated from the 2014 SIPP panel) rowtitle(year)


<</dd_do>>
~~~~

Instability rates are highest in 2014. We expected this. Household composition in 2013 is captured in the first (wave 1) interview conducted in 2014. During the interview individuals are asked about people they lived with throughout the year, not just those they are coresiding with at the time of the interview. Former household members present during the reference period but not in the household at the time of the interview are called "type 2" individuals. They don't have their own record in the data, but we capture their coming and going as they appear on strings of household members. An initial analysis of these data showed more people coming into the house over the year than leaving, which suggests that type 2 people are underreported. This would mean that measures of household instability in the first wave/year are downwardly biased. The second wave might also be downwardly biased, but at least we have a record of who was in the household at the start of the year and we count them as contributing to household instability over the year if they aren't recorded in the household during the wave 2 reference period (i.e. in 2014). After the second wave, selective sample attrition likely downwardly biases the measure of household instability even further. 

~~~~
<<dd_do: quietly>>

* save the data for future use
save "$tempdir/rates14.dta", $replace
clear matrix

<</dd_do>>
~~~~

Now do the same for 2008.

~~~~
<<dd_do: quietly>>

use "$SIPP08keep/HHchangeWithRelationships_am.dta", clear

drop if missing(SHHADID)

keep if adj_age < 18
<</dd_do>>
~~~~

We collapse by age and wave to create a mean number of transitions by age for each panelmonth. The first step estimates weighted rates of transition in each month.

<<dd_do: quietly>>

collapse (mean) hh_change comp_change parent_change sib_change other_change nonparent_change gp_change nonrel_change otherrel_change [aweight=WPFINWGT], by(adj_age panelmonth)

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

collapse (sum) hh_change comp_change parent_change sib_change other_change nonparent_change gp_change nonrel_change otherrel_change, by(adj_age wave)

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
gen year=2008+floor((wave+2)/3)

collapse (mean) hh_change comp_change parent_change sib_change other_change nonparent_change gp_change nonrel_change otherrel_change, by(adj_age year)

collapse (sum) hh_change comp_change parent_change sib_change other_change nonparent_change gp_change nonrel_change otherrel_change, by(year)

* put result into a matrix so that I can diplay them
mkmat hh_change comp_change parent_change sib_change gp_change nonrel_change, matrix(byear08)

matrix rownames byear08 = "~2009" "~2010" "~2011" "~2012"
matrix colnames byear08 = "all" "comp" "par" "sib" "grndp" "nonrel" 
<</dd_do>>

~~~~
<<dd_do>>

matlist byear08, format(%6.1f) title(These are estimates of the total amount of instability by 18th birthday estimated from the 2008 panel) rowtitle(year)

clear matrix

<</dd_do>>
~~~~

After the first year there is a clear decline in instability as year increases within the 2008 panel. But why is the first year lower? We think it might be because of underestimates of household instability in the first wave similar to what we saw in the 2014 panel. Thus, we redo the analysis dropping wave 1.

~~~~
<<dd_do: quietly>>

restore

drop if wave==1

collapse (sum) hh_change comp_change parent_change sib_change other_change nonparent_change gp_change nonrel_change otherrel_change, by(adj_age wave)

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
gen year=2008+floor((wave+2)/3)

collapse (mean) hh_change comp_change parent_change sib_change other_change nonparent_change gp_change nonrel_change otherrel_change, by(adj_age year)

collapse (sum) hh_change comp_change parent_change sib_change other_change nonparent_change gp_change nonrel_change otherrel_change, by(year)

* put result into a matrix so that I can diplay them
mkmat hh_change comp_change parent_change sib_change gp_change nonrel_change, matrix(byear08r)

matrix rownames byear08r = "~2009" "~2010" "~2011" "~2012"
matrix colnames byear08r = "all" "comp" "par" "sib" "grndp" "nonrel" 
<</dd_do>>

~~~~
<<dd_do>>

matlist byear08r, format(%6.1f) title(These are revised estimates of the total amount of instability by 18th birthday estimated from the 2008 panel) rowtitle(year)

clear matrix

<</dd_do>>
~~~~

~~~~
<<dd_do: quietly>>

* save the data for future use
save "$tempdir/rates08.dta", $replace

<</dd_do>>
~~~~


OK, so now do the 2004 panel. 

~~~~
<<dd_do: quietly>>

use "$SIPP04keep/HHchangeWithRelationships_am.dta", clear

drop if missing(SHHADID)

keep if adj_age < 18
<</dd_do>>
~~~~

We collapse by age and wave to create a mean number of transitions by age for each panelmonth. The first step estimates weighted rates of transition in each month.

~~~~
<<dd_do: quietly>>

collapse (mean) hh_change comp_change parent_change sib_change other_change nonparent_change gp_change nonrel_change otherrel_change [aweight=WPFINWGT], by(adj_age panelmonth)

gen wave=floor((panelmonth+3)/4)
gen month=4-(wave*4-panelmonth)

* drop wave 1 because we find evidence again that it underestimates instability
drop if wave==1

collapse (sum) hh_change comp_change parent_change sib_change other_change nonparent_change gp_change nonrel_change otherrel_change, by(adj_age wave)

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

tab year

collapse (mean) hh_change comp_change parent_change sib_change other_change nonparent_change gp_change nonrel_change otherrel_change, by(adj_age year)

collapse (sum) hh_change comp_change parent_change sib_change other_change nonparent_change gp_change nonrel_change otherrel_change, by(year)

* put result into a matrix so that I can diplay them
mkmat hh_change comp_change parent_change sib_change gp_change nonrel_change, matrix(byear04)

matrix rownames byear04 = "~2005" "~2006" "~2007" "~2008"
matrix colnames byear04 = "all" "comp" "par" "sib" "grndp" "nonrel" 
<</dd_do>>

~~~~
<<dd_do>>

matlist byear04, format(%6.1f)  title(These are estimates of the total amount of instability by 18th birthday estimated from the 2004 panel)  rowtitle(year)

<</dd_do>>
~~~~

~~~~
<<dd_do: quietly>>

* save the data for future use
save "$tempdir/rates04.dta", $replace
clear matrix

<</dd_do>>
~~~~

We found the same pattern of underestimation in wave 1 in the 2004 panel as we did in the 2008 and 2014 panels and so we dropped wave 1. The table above shows that similar to previous panels, there's a pattern of declining instability as the panel ages.
It looks like, aside from wave 1, the first year of data produces the best estimates. A comparison across time should focus on this year. Here are the relevant results

~~~~
<<dd_do: quietly>>

clear
clear matrix

<</dd_do>>
~~~~

Finally?, the 2001 panel. 

~~~~
<<dd_do: quietly>>

use "$SIPP01keep/HHchangeWithRelationships_am.dta", clear

drop if missing(SHHADID)

keep if adj_age < $adult_age
<</dd_do>>
~~~~

We collapse by age and wave to create a mean number of transitions by age for each panelmonth. The first step estimates weighted rates of transition in each month.

~~~~
<<dd_do: quietly>>

collapse (mean) hh_change comp_change parent_change sib_change other_change nonparent_change gp_change nonrel_change otherrel_change [aweight=WPFINWGT], by(adj_age panelmonth)

gen wave=floor((panelmonth+3)/4)
gen month=4-(wave*4-panelmonth)

* drop wave 1 because we find evidence again that it underestimates instability
drop if wave==1

collapse (sum) hh_change comp_change parent_change sib_change other_change nonparent_change gp_change nonrel_change otherrel_change, by(adj_age wave)

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

tab year

collapse (mean) hh_change comp_change parent_change sib_change other_change nonparent_change gp_change nonrel_change otherrel_change, by(adj_age year)

collapse (sum) hh_change comp_change parent_change sib_change other_change nonparent_change gp_change nonrel_change otherrel_change, by(year)

* put result into a matrix so that I can diplay them
mkmat hh_change comp_change parent_change sib_change gp_change nonrel_change, matrix(byear01)

matrix rownames byear01 = "~2002" "~2003" "~2004" 
matrix colnames byear01 = "all" "comp" "par" "sib" "grndp" "nonrel" 
<</dd_do>>

~~~~
<<dd_do>>

matlist byear01, format(%6.1f)  title(These are estimates of the total amount of instability by 18th birthday estimated from the 2001 panel)  rowtitle(year)

<</dd_do>>
~~~~

~~~~
<<dd_do: quietly>>

* save the data for future use
save "$tempdir/rates01.dta", $replace
clear matrix

<</dd_do>>
~~~~
~~~~
<<dd_do: quietly>>

use "$tempdir/rates14.dta", clear
gen year=2014 if swave==2
drop if missing(year)
drop swave
append using "$tempdir/rates08.dta"
append using "$tempdir/rates04.dta"
append using "$tempdir/rates01.dta"

keep if year==2002 | year==2005 | year==2010 | year==2014
sort year

mkmat hh_change comp_change parent_change sib_change gp_change nonrel_change, matrix(byear)
matrix rownames byear = "~2002" "~2005" "~2010" "2014" 
matrix colnames byear = "all" "comp" "par" "sib" "grndp" "nonrel" 

<</dd_do>>
~~~~

~~~~
<<dd_do>>

matlist byear, format(%6.1f)  title(These are estimates of trends in instability by 18th birthday estimated from the 2001, 2004, 2008, and 2014 panel)  rowtitle(year)

<</dd_do>>
~~~~

The results in the table above suggest that there might have been some overall increase in children's household instability from 2005 to 2014, but we can't know for sure because of the redesign in 2014. Although there is less frequent measurement in 2014, which might reduce our estimates of household instability, the redesign allowed us to measure instability caused by individuals who are in the household during the reference period but not during interview.

~~~~
<<dd_do: quietly>>
clear
clear matrix
<</dd_do>>