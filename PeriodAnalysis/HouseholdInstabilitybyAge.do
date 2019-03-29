*************************************************************
* A file to analyze period changes in household instability by age
*************************************************************

use "$SIPP08keep/HHchangeWithRelationships.dta", clear

gen panel=2008

append using "$SIPP04keep/hh_change.dta"
replace panel=2004 if missing(panel)

append using "$SIPP91keep/hh_change.dta"
replace panel=1991 if missing(panel)


gen year=2008 if SWAVE==1 & panel==2008
replace year=2009 if SWAVE >= 2 & SWAVE <= 4 & panel==2008
replace year=2010 if SWAVE >= 5 & SWAVE <= 7 & panel==2008
replace year=2011 if SWAVE >= 8 & SWAVE <= 10 & panel==2008
replace year=2012 if SWAVE >= 11 & SWAVE <= 13 & panel==2008
replace year=2013 if SWAVE >= 14 & SWAVE <= 16 & panel==2008

replace year=2004 if SWAVE <= 3 & panel==2004 
replace year=2005 if SWAVE >=4 & SWAVE <=6 & panel==2004
replace year=2006 if SWAVE >=7 & SWAVE <=9 & panel==2004
replace year=2007 if SWAVE >=10 & SWAVE <=12 & panel==2004

replace year=1991 if SWAVE <=3 & panel==1991
replace year=1992 if SWAVE >= 4 & SWAVE <=6 & panel==1991
replace year=1993 if SWAVE >= 7 & SWAVE <=8 & panel==1991

keep if adj_age >=0 & adj_age <=75

tab year hh_change, nofreq row



