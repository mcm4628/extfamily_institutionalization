* Creating a file describing children's household poverty status at the time of each SIPP interview
* and transition rates into and out of poverty.
* To do this I need poverty thresholds divided by 12, household size, household income. Need to drop cases in Alaska and Hawaii

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

*************************************************************
* Read in poverty thresholds for households size 8 or smaller
*************************************************************

global incomedata "$SIPP2008/IncomeAndEarnings"

/*
import delimited using "$SIPP2008/povertyline", varnames(1)

save "$SIPP2008/povertyline.dta", $replace
*/

********************************************************************************
* read in sipp data with income and prepare to merge w/ poverty thresholds
********************************************************************************

use "$incomedata/sipp08tpearn_all.dta", clear

sort ssuid shhadid swave

egen hhsize_full=count(epppnum), by(ssuid shhadid swave)

gen hhsize=hhsize_full
replace hhsize=8 if hhsize > 8

gen year=8 if swave==1
replace year=9 if swave > 1 & swave <=3
replace year=9 if swave > 3 & swave <=7 /* poverty thresholds did not change */
replace year=11 if swave > 7 & swave <=10 
replace year=12 if swave > 10 & swave <=13 
replace year=13 if swave > 13 & swave <=16 

merge m:1 hhsize year using "$SIPP2008/povertyline.dta"

drop _merge
********************************************************************************
* Create poverty thresholds for larger households
********************************************************************************

gen over8=hhsize_full-8
replace over8=0 if hhsize_full <= 8

replace amount=amount+over8*3600 if over8 > 0 & year==8
replace amount=amount+over8*3740 if over8 > 0 & year==9
replace amount=amount+over8*3820 if over8 > 0 & year==11
replace amount=amount+over8*3960 if over8 > 0 & year==12
replace amount=amount+over8*4020 if over8 > 0 & year==13

gen monthpt=amount/12

gen income=thothinc+thearn

gen poverty=0 if income > monthpt
replace poverty=1 if income <= monthpt

tab poverty

drop hhsize over8 v4 year

reshape wide monthpt amount shhadid hhsize_full thearn thothinc tpearn income poverty, i(ssuid epppnum) j(swave)

gen numpov=0
gen numobs=0

forvalues i=1/14{
	gen transtype`i'=0
	gen everpov`i'=0
	gen evermis`i'=0
}

forvalues i=1/14{
	local j=`i'+1
	replace transtype`i'=1 if poverty`i'==0 & poverty`j'==0
	replace transtype`i'=2 if poverty`i'==0 & poverty`j'==1
	replace transtype`i'=3 if poverty`i'==1 & poverty`j'==0
	replace transtype`i'=4 if poverty`i'==1 & poverty`j'==1
	replace transtype`i'=5 if missing(poverty`i') & !missing(poverty`j')
	replace transtype`i'=6 if !missing(poverty`i') & missing(poverty`j')
	replace transtype`i'=. if missing(poverty`i') & missing(poverty`j')
	
	replace numpov=numpov+1 if poverty`i'==1
	replace numobs=numobs+1 if !missing(poverty`i')
	
	replace everpov`i'=1 if poverty`i'==1
	replace evermis`i'=1 if missing(poverty`i')
}

save "$tempdir/poverty_survival", $replace

tab numpov
tab numobs
tab transtype1

reshape long monthpt amount shhadid hhsize_full thearn thothinc tpearn income poverty transtype everpov evermis, i(ssuid epppnum) j(swave)

#delimit ;

label define transtype   1 "Not in poverty"
						 2 "Into poverty"
						 3 "Out of Poverty"
						 4 "In poverty"
						 5 "from missing"
						 6 "to missing";										  								  
#delimit cr

label values transtype transtype

tab transtype

save "$tempdir/poverty_transitions", $replace
