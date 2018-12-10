* Creating a file describing children's household poverty status at the time of each SIPP interview.
* To do this I need poverty thresholds divided by 12, household size, household income. Drop cases in Alaska and Hawaii

/* Federal Poverty Thresholds (https://aspe.hhs.gov/2008-hhs-poverty-guidelines)
2008 - Wave 1
1	10,400	
2	14,000	
3	17,600	
4	21,200	
5	24,800	
6	28,400	
7	32,000	
8	35,600	
+	3,600	

2009-2010 Waves 2-7
1	10,830
2	14,570
3	18,310
4	22,050
5	25,790
6	29,530
7	33,270
8	37,010
+3740

2011 Waves 8-10

1	10,890	
2	 14,710	 
3	 18,530	 
4	 22,350	 
5	 26,170	 
6	 29,990	 
7	 33,810	 
8	 37,630	 
+3,820	   

2012 Waves 11-13

1	11,170
2	15,130
3	19,090
4	23,050
5	27,010
6	30,970
7	34,930
8	38,890
+ 3960

2013 Waves 14-16
 
1	$11,490
2	15,510
3	19,530
4	23,550
5	27,570
6	31,590
7	35,610
8	39,630
+4020
*/

global incomedata "$SIPP2008/IncomeAndEarnings"

use "$incomedata/sipp08tpearn_all.dta"

sort ssuid shhadid swave

egen hhsize=count(epppnum) by ssuid shhadid swave

******
* Generate Poverty thresholds
*****

local pt08 "10400 14000 17600 21200 24800 28400 32000 35600"

gen admember08=3600

local pt09 "10830 14570 18310 22050 25790 29530 33270 37010"
local pt10 "10830 14570 18310 22050 25790 29530 33270 37010"

gen admember09=3740
gen admember10=3740

local pt11 "10890 14710 18530 22350 26170 29990 33810 37630"

gen admember11=3820

local pt12 "11170 15130 19090 23050 27010 30970 34930 38890"

local pt13 "11490 15510 19530 23550 27570 31590 35610 39630"

gen povthresh=.

forvalues s=1/8 {
	replace povthresh=word `s' of `pt08' if swave==1 if hhsize==`s'
	replace povthresh=word `s' of `pt09' if swave > 1 & swave <=7 & hhsize==`s'
	replace povthresh=word `s' of `pt11' if swave > 8 & swave <=10 & hhsize==`s'
	replace povthresh=word `s' of `pt12' if swave > 11 & swave <=13 & hhsize==`s'
	replace povthresh=word `s' of `pt13' if swave > 14 & swave <=16 & hhsize==`s'
 }

 /*
 forvalues w=1/16{
	forvalues s=9/20 {
		replace povthresh=
 
egen 
