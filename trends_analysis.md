The overarching aim of this document is to conduct and present analyses describing children's household instability over time. These analysis will describe overall trends as well as variation by "parental" education and race-ethnicity.

But a presentation of trends is complicated by a couple of concerns. First, there is substantial sample attrition as panels age and we suspect that this attrition is more severe for individuals with a greater tendency for household instability. Thus we must conduct within panel analyses to evaluate this possibility. Second, the 2014 panel uses an innovative approach that could affect the quality of measurement of children's household instability. We address these potential measurement concerns first because they affect our approach to describing trends over time.

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

* put result into a matrix so that I can place specific numbers in text
mkmat hh_change comp_change parent_change sib_change other_change nonparent_change gp_change nonrel_change otherrel_change, matrix(byear)

<</dd_do>>
~~~~

These are estimates of the total amount of instability by 18th birthday estimated from the whole 2008 panel
           all comp parent sibling other nonparent grand nonrel otherrel
2013     <<dd_display: %4.1f byear[1,1]>> <<dd_display: %4.1f byear[1,2]>> <<dd_display: %4.1f byear[1,3]>>  <<dd_display:%4.1f byear[1,4]>>     <<dd_display: %4.1f byear[1,5]>>   <<dd_display: %4.1f byear[1,6]>>  <<dd_display: %4.1f byear[1,7]>>    <<dd_display: %4.1f byear[1,8]>>   <<dd_display: %4.1f byear[1,9]>> 
2014     <<dd_display: %4.1f byear[2,1]>> <<dd_display: %4.1f byear[2,2]>> <<dd_display: %4.1f byear[2,3]>>  <<dd_display:%4.1f byear[2,4]>>     <<dd_display: %4.1f byear[2,5]>>   <<dd_display: %4.1f byear[2,6]>>  <<dd_display: %4.1f byear[2,7]>>    <<dd_display: %4.1f byear[2,8]>>   <<dd_display: %4.1f byear[2,9]>> 
2015     <<dd_display: %4.1f byear[3,1]>> <<dd_display: %4.1f byear[3,2]>> <<dd_display: %4.1f byear[3,3]>>  <<dd_display:%4.1f byear[3,4]>>     <<dd_display: %4.1f byear[3,5]>>   <<dd_display: %4.1f byear[3,6]>>  <<dd_display: %4.1f byear[3,7]>>    <<dd_display: %4.1f byear[3,8]>>   <<dd_display: %4.1f byear[3,9]>> 
2016     <<dd_display: %4.1f byear[4,1]>> <<dd_display: %4.1f byear[4,2]>> <<dd_display: %4.1f byear[4,3]>>  <<dd_display:%4.1f byear[4,4]>>     <<dd_display: %4.1f byear[4,5]>>   <<dd_display: %4.1f byear[4,6]>>  <<dd_display: %4.1f byear[4,7]>>    <<dd_display: %4.1f byear[4,8]>>   <<dd_display: %4.1f byear[4,9]>>

Instability rates are highest in 2014. We expected this. Household composition in 2013 is captured in the first (wave 1) interview conducted in 2014. During the interview individuals are asked about people they lived with throughout the year, not just those they are coresiding with at the time of the interview. Former household members present during the reference period but not in the household at the time of the interview are called "type 2" individuals. They don't have their own record in the data, but we capture their coming and going as they appear on strings of household members. An initial analysis of these data showed more people coming into the house over the year than leaving, which suggests that type 2 people are underreported. This would mean that measures of household instability in the first wave/year are downwardly biased. The second wave might also be downwardly biased, but at least we have a record of who was in the household at the start of the year and we count them as contributing to household instability over the year if they aren't recorded in the household during the wave 2 reference period (i.e. in 2014). After the second wave, selective sample attrition likely downwardly biases the measure of household instability even further. 

Note: Parent instability appears to be broken. 

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

<</dd_do>>
~~~~

Then create estimates by year. 

~~~~
<<dd_do: quietly>>

* Note that this is only an approximation of year since actual calendar month varies by rotation within wave
gen year=2008+floor((wave+2)/3)

collapse (mean) hh_change comp_change parent_change sib_change other_change nonparent_change gp_change nonrel_change otherrel_change, by(adj_age year)

collapse (sum) hh_change comp_change parent_change sib_change other_change nonparent_change gp_change nonrel_change otherrel_change, by(year)

* put result into a matrix so that I can place specific numbers in text
mkmat hh_change comp_change parent_change sib_change other_change nonparent_change gp_change nonrel_change otherrel_change, matrix(byear)

<</dd_do>>
~~~~

These are estimates of the total amount of instability by 18th birthday estimated from the whole 2008 panel

           all comp parent sibling other nonparent grand nonrel otherrel
2009     <<dd_display: %4.1f byear[1,1]>> <<dd_display: %4.1f byear[1,2]>> <<dd_display: %4.1f byear[1,3]>>  <<dd_display:%4.1f byear[1,4]>>     <<dd_display: %4.1f byear[1,5]>>   <<dd_display: %4.1f byear[1,6]>>  <<dd_display: %4.1f byear[1,7]>>    <<dd_display: %4.1f byear[1,8]>>   <<dd_display: %4.1f byear[1,9]>> 
2010     <<dd_display: %4.1f byear[2,1]>> <<dd_display: %4.1f byear[2,2]>> <<dd_display: %4.1f byear[2,3]>>  <<dd_display:%4.1f byear[2,4]>>     <<dd_display: %4.1f byear[2,5]>>   <<dd_display: %4.1f byear[2,6]>>  <<dd_display: %4.1f byear[2,7]>>    <<dd_display: %4.1f byear[2,8]>>   <<dd_display: %4.1f byear[2,9]>> 
2011     <<dd_display: %4.1f byear[3,1]>> <<dd_display: %4.1f byear[3,2]>> <<dd_display: %4.1f byear[3,3]>>  <<dd_display:%4.1f byear[3,4]>>     <<dd_display: %4.1f byear[3,5]>>   <<dd_display: %4.1f byear[3,6]>>  <<dd_display: %4.1f byear[3,7]>>    <<dd_display: %4.1f byear[3,8]>>   <<dd_display: %4.1f byear[3,9]>> 
2012     <<dd_display: %4.1f byear[4,1]>> <<dd_display: %4.1f byear[4,2]>> <<dd_display: %4.1f byear[4,3]>>  <<dd_display:%4.1f byear[4,4]>>     <<dd_display: %4.1f byear[4,5]>>   <<dd_display: %4.1f byear[4,6]>>  <<dd_display: %4.1f byear[4,7]>>    <<dd_display: %4.1f byear[4,8]>>   <<dd_display: %4.1f byear[4,9]>>
	   

There is a clear decline in instability as year increases within the 2008 panel. The estimates of instability are lower in the 2008 panel than the 2014 panel. I might expect the estimates in 2014 be lower because of the less-frequent data collection, but this might be partly made up for by the ability to report type 2 people in 2014. 