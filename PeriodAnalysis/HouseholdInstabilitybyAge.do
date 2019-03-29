*************************************************************
* A file to analyze period changes in household instability by age
*************************************************************

use "$SIPP08keep/HHchangeWithRelationships.dta", clear

gen year=2008 if SWAVE==1
replace year=2009 if SWAVE >= 2 & SWAVE <= 4
replace year=2010 if SWAVE >= 5 & SWAVE <= 7
replace year=2011 if SWAVE >= 8 & SWAVE <= 10
replace year=2012 if SWAVE >= 11 & SWAVE <= 13
replace year=2013 if SWAVE >= 14 & SWAVE <= 16

keep if adj_age >=0 & adj_age <=75

tab year hh_change [aweight=WPFINWGT]
