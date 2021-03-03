We start with data on all months and select observations less than age 18.

~~~~
<<dd_do: quietly>>
global SIPP08results "~/projects/childhh/results/2008"

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
Next we sum across all months in each wave and multiply by 3 to get an annual transition rate. There would be an alternative way where we originally sum by year. I don't think it will ever make sense to do that by actual calendar year because different rotations have their first observation in different months and there is a tendency to have more instability in the last month of the reference period. Thus we sum by wave to get a four-month estimate of instability. We could sum by a calculated year rather than multiply by three and then aggregate these by year.

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
Let's first create estimates using something close to the original approach, where all waves are multiplied by 3 to create annual measures and then averaged to reflect the entire 2008 panel period. 

~~~~
<<dd_do: quietly>>

preserve

collapse (mean) hh_change comp_change parent_change sib_change other_change nonparent_change gp_change nonrel_change otherrel_change, by(adj_age)

collapse (sum) hh_change comp_change parent_change sib_change other_change nonparent_change gp_change nonrel_change otherrel_change

* put result into a matrix so that I can place specific numbers in text
mkmat hh_change comp_change parent_change sib_change other_change nonparent_change gp_change nonrel_change otherrel_change, matrix(all)

<</dd_do>>
~~~~

These are estimates of the total amount of instability by 18th birthday estimated from the whole 2008 panel

           all comp parent sibling other nonparent grand nonrel otherrel
Total     <<dd_display: %4.1f all[1,1]>> <<dd_display: %4.1f all[1,2]>> <<dd_display: %4.1f all[1,3]>>   <<dd_display: %4.1f all[1,4]>>     <<dd_display: %4.1f all[1,5]>>   <<dd_display: %4.1f all[1,6]>>    <<dd_display: %4.1f all[1,7]>>    <<dd_display: %4.1f all[1,8]>>   <<dd_display: %4.1f all[1,9]>> 


Next create estimates by year. No doubt we will find a decline in instability as the panel gets older.

~~~~
<<dd_do: quietly>>

restore
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
2013     <<dd_display: %4.1f byear[5,1]>> <<dd_display: %4.1f byear[5,2]>> <<dd_display: %4.1f byear[5,3]>>  <<dd_display:%4.1f byear[5,4]>>     <<dd_display: %4.1f byear[5,5]>>   <<dd_display: %4.1f byear[5,6]>>  <<dd_display: %4.1f byear[5,7]>>    <<dd_display: %4.1f byear[5,8]>>   <<dd_display: %4.1f byear[5,9]>> 

There is a clear decline in instability as year increases. 