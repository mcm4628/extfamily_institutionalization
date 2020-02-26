*Hispanic paper

use "$SIPP01keep/hh_change_am", clear
g panel=2001
append using "$SIPP04keep/hh_change_am"
replace panel=2004 if panel==.
append using "$SIPP08keep/hh_change_am"
replace panel=2008 if panel==.

*keep only hispanic children
keep if my_racealt==3 & adj_age<=17

save "$SIPP08keep/hisp_children", replace

*Trend- panel months 5-16, meaning a year since the second wave:
keep if panelmonth>=5 & panelmonth<=16
collapse (sum)hh_change comp_change addr_change (mean)WPFINWGT, by(SSUID EPPPNUM panel)
tabstat hh_change, by(panel)
tabstat comp_change, by(panel)
tabstat addr_change, by(panel)


*Table 1- changes by parental duration in the US
use "$SIPP08keep/hisp_children", clear

foreach p in mom dad {
g `p'_ymigr=1952 if `p'_tmoveus==1 & panel==2001
replace `p'_ymigr=1955 if `p'_tmoveus==2 & panel==2001
replace `p'_ymigr=1961.5 if `p'_tmoveus==3 & panel==2001
replace `p'_ymigr=1966.5 if `p'_tmoveus==4 & panel==2001
replace `p'_ymigr=1970 if `p'_tmoveus==5 & panel==2001
replace `p'_ymigr=1973 if `p'_tmoveus==6 & panel==2001
replace `p'_ymigr=1976 if `p'_tmoveus==7 & panel==2001
replace `p'_ymigr=1978.5 if `p'_tmoveus==8 & panel==2001
replace `p'_ymigr=1980.5 if `p'_tmoveus==9 & panel==2001
replace `p'_ymigr=1983 if `p'_tmoveus==10 & panel==2001
replace `p'_ymigr=1985.5 if `p'_tmoveus==11 & panel==2001
replace `p'_ymigr=1987.5 if `p'_tmoveus==12 & panel==2001
replace `p'_ymigr=1989.5 if `p'_tmoveus==13 & panel==2001
replace `p'_ymigr=1991.5 if `p'_tmoveus==14 & panel==2001
replace `p'_ymigr=1993.5 if `p'_tmoveus==15 & panel==2001
replace `p'_ymigr=1995 if `p'_tmoveus==16 & panel==2001
replace `p'_ymigr=1996.5 if `p'_tmoveus==17 & panel==2001
replace `p'_ymigr=1998 if `p'_tmoveus==18 & panel==2001
replace `p'_ymigr=1999 if `p'_tmoveus==19 & panel==2001
replace `p'_ymigr=2000 if `p'_tmoveus==20 & panel==2001
replace `p'_ymigr=2001 if `p'_tmoveus==21 & panel==2001
replace `p'_ymigr=1954 if `p'_tmoveus==1 & panel==2004
replace `p'_ymigr=1958 if `p'_tmoveus==2 & panel==2004
replace `p'_ymigr=1964 if `p'_tmoveus==3 & panel==2004
replace `p'_ymigr=1968.5 if `p'_tmoveus==4 & panel==2004
replace `p'_ymigr=1972.5 if `p'_tmoveus==5 & panel==2004
replace `p'_ymigr=1976.5 if `p'_tmoveus==6 & panel==2004
replace `p'_ymigr=1979.5 if `p'_tmoveus==7 & panel==2004
replace `p'_ymigr=1981.5 if `p'_tmoveus==8 & panel==2004
replace `p'_ymigr=1983.5 if `p'_tmoveus==9 & panel==2004
replace `p'_ymigr=1985.5 if `p'_tmoveus==10 & panel==2004
replace `p'_ymigr=1987.5 if `p'_tmoveus==11 & panel==2004
replace `p'_ymigr=1989.5 if `p'_tmoveus==12 & panel==2004
replace `p'_ymigr=1991.5 if `p'_tmoveus==13 & panel==2004
replace `p'_ymigr=1993.5 if `p'_tmoveus==14 & panel==2004
replace `p'_ymigr=1995.5 if `p'_tmoveus==15 & panel==2004
replace `p'_ymigr=1997.5 if `p'_tmoveus==16 & panel==2004
replace `p'_ymigr=1999 if `p'_tmoveus==17 & panel==2004
replace `p'_ymigr=2000 if `p'_tmoveus==18 & panel==2004
replace `p'_ymigr=2001 if `p'_tmoveus==19 & panel==2004
replace `p'_ymigr=2003 if `p'_tmoveus==20 & panel==2004
replace `p'_ymigr=1961 if `p'_tmoveus==1 & panel==2008
replace `p'_ymigr=1964.5 if `p'_tmoveus==2 & panel==2008
replace `p'_ymigr=1971 if `p'_tmoveus==3 & panel==2008
replace `p'_ymigr=1976 if `p'_tmoveus==4 & panel==2008
replace `p'_ymigr=1979.5 if `p'_tmoveus==5 & panel==2008
replace `p'_ymigr=1982 if `p'_tmoveus==6 & panel==2008
replace `p'_ymigr=1984.5 if `p'_tmoveus==7 & panel==2008
replace `p'_ymigr=1987 if `p'_tmoveus==8 & panel==2008
replace `p'_ymigr=1989.5 if `p'_tmoveus==9 & panel==2008
replace `p'_ymigr=1991.5 if `p'_tmoveus==10 & panel==2008
replace `p'_ymigr=1993.5 if `p'_tmoveus==11 & panel==2008
replace `p'_ymigr=1995.5 if `p'_tmoveus==12 & panel==2008
replace `p'_ymigr=1997.5 if `p'_tmoveus==13 & panel==2008
replace `p'_ymigr=1999 if `p'_tmoveus==14 & panel==2008
replace `p'_ymigr=2000 if `p'_tmoveus==15 & panel==2008
replace `p'_ymigr=2001 if `p'_tmoveus==16 & panel==2008
replace `p'_ymigr=2002.5 if `p'_tmoveus==17 & panel==2008
replace `p'_ymigr=2004 if `p'_tmoveus==18 & panel==2008
replace `p'_ymigr=2005 if `p'_tmoveus==19 & panel==2008
replace `p'_ymigr=2006 if `p'_tmoveus==20 & panel==2008
replace `p'_ymigr=2007 if `p'_tmoveus==21 & panel==2008
replace `p'_ymigr=2008.5 if `p'_tmoveus==22 & panel==2008
}
 
g year=2001 if panel==2001 & panelmonth>=1 & panelmonth<=11
replace year=2002 if panel==2001 & panelmonth>=12 & panelmonth<=23
replace year=2003 if panel==2001 & panelmonth>=24 & panelmonth<=35
replace year=2004 if panel==2001 & panelmonth==36
replace year=2004 if panel==2004 & panelmonth>=1 & panelmonth<=11
replace year=2005 if panel==2004 & panelmonth>=12 & panelmonth<=23
replace year=2006 if panel==2004 & panelmonth>=24 & panelmonth<=35
replace year=2007 if panel==2004 & panelmonth>=34 & panelmonth<=47
replace year=2008 if panel==2004 & panelmonth==48
replace year=2008 if panel==2008 & panelmonth>=1 & panelmonth<=4
replace year=2009 if panel==2008 & panelmonth>=5 & panelmonth<=16
replace year=2010 if panel==2008 & panelmonth>=17 & panelmonth<=28
replace year=2011 if panel==2008 & panelmonth>=29 & panelmonth<=40
replace year=2012 if panel==2008 & panelmonth>=41 & panelmonth<=52
replace year=2013 if panel==2008 & panelmonth>=53 & panelmonth<=60

*duration in the US
foreach p in mom dad {
g `p'_duration=year-`p'_ymigr
}

*for parents' duration we use the more recent immigrant:
g parent_duration=mom_duration if mom_duration<dad_duration
replace parent_duration=dad_duration if dad_duration<=mom_duration

*Now, we create a categorical variable for duration- If both parents are native born or the sole parent in the hh duration=5:
g mom_immigrant=(mom_tmoveus>-1)
replace mom_immigrant=. if mom_tmoveus>=9999
g dad_immigrant=(dad_tmoveus>-1)
replace dad_immigrant=. if dad_tmoveus>=9999
g parent_duration_cat=6 if mom_immigrant==0 & dad_immigrant==0
replace parent_duration_cat=6 if mom_immigrant==0 & dad_immigrant==.
replace parent_duration_cat=6 if dad_immigrant==0 & mom_immigrant==.
replace parent_duration_cat=1 if parent_duration<=2 
replace parent_duration_cat=2 if parent_duration>2 & parent_duration<=5
replace parent_duration_cat=3 if parent_duration>5 & parent_duration<=10
replace parent_duration_cat=4 if parent_duration>10 & parent_duration<=20
replace parent_duration_cat=5 if parent_duration>20 & parent_duration!=.

save "$SIPP08keep/hisp_children", replace

*Table 1- for an annual rate the values need to be multiply by 12
tabstat comp_change [aweight=WPFINWGT],by(parent_duration_cat)
tabstat addr_change [aweight=WPFINWGT],by(parent_duration_cat)
tabstat hh_change [aweight=WPFINWGT],by(parent_duration_cat)
*by age 18- need to multiply by 12 and sum:
tabstat hh_change if parent_duration_cat==1 [aweight=WPFINWGT],by(adj_age) 
tabstat hh_change if parent_duration_cat==2 [aweight=WPFINWGT],by(adj_age) 
tabstat hh_change if parent_duration_cat==3 [aweight=WPFINWGT],by(adj_age) 
tabstat hh_change if parent_duration_cat==4 [aweight=WPFINWGT],by(adj_age) 
tabstat hh_change if parent_duration_cat==5 [aweight=WPFINWGT],by(adj_age) 
tabstat hh_change if parent_duration_cat==6 [aweight=WPFINWGT],by(adj_age) 


*HH size:
use "$SIPP01keep/hh_change_am", clear
g panel=2001
append using "$SIPP04keep/hh_change_am"
replace panel=2004 if panel==.
append using "$SIPP08keep/hh_change_am"
replace panel=2008 if panel==.

keep if inmonth==1
g hh_size=1
collapse (sum)hh_size, by(panel panelmonth SSUID SHHADID)
merge 1:m panel panelmonth SSUID SHHADID using "$SIPP08keep/hisp_children"
keep if _merge==3 
drop _merge
tabstat hh_size [aweight=WPFINWGT], by(parent_duration_cat)

*Who responsible for the change?
	use "$SIPP01keep/HHchangeWithRelationships_am", clear
	g panel=2001
	append using "$SIPP04keep/HHchangeWithRelationships_am"
	replace panel=2004 if panel==.
	append using "$SIPP08keep/HHchangeWithRelationships_am"
	replace panel=2008 if panel==.

	keep if my_racealt==3 & adj_age<=17

	foreach p in mom dad {
	g `p'_ymigr=1952 if `p'_tmoveus==1 & panel==2001
	replace `p'_ymigr=1955 if `p'_tmoveus==2 & panel==2001
	replace `p'_ymigr=1961.5 if `p'_tmoveus==3 & panel==2001
	replace `p'_ymigr=1966.5 if `p'_tmoveus==4 & panel==2001
	replace `p'_ymigr=1970 if `p'_tmoveus==5 & panel==2001
	replace `p'_ymigr=1973 if `p'_tmoveus==6 & panel==2001
	replace `p'_ymigr=1976 if `p'_tmoveus==7 & panel==2001
	replace `p'_ymigr=1978.5 if `p'_tmoveus==8 & panel==2001
	replace `p'_ymigr=1980.5 if `p'_tmoveus==9 & panel==2001
	replace `p'_ymigr=1983 if `p'_tmoveus==10 & panel==2001
	replace `p'_ymigr=1985.5 if `p'_tmoveus==11 & panel==2001
	replace `p'_ymigr=1987.5 if `p'_tmoveus==12 & panel==2001
	replace `p'_ymigr=1989.5 if `p'_tmoveus==13 & panel==2001
	replace `p'_ymigr=1991.5 if `p'_tmoveus==14 & panel==2001
	replace `p'_ymigr=1993.5 if `p'_tmoveus==15 & panel==2001
	replace `p'_ymigr=1995 if `p'_tmoveus==16 & panel==2001
	replace `p'_ymigr=1996.5 if `p'_tmoveus==17 & panel==2001
	replace `p'_ymigr=1998 if `p'_tmoveus==18 & panel==2001
	replace `p'_ymigr=1999 if `p'_tmoveus==19 & panel==2001
	replace `p'_ymigr=2000 if `p'_tmoveus==20 & panel==2001
	replace `p'_ymigr=2001 if `p'_tmoveus==21 & panel==2001
	replace `p'_ymigr=1954 if `p'_tmoveus==1 & panel==2004
	replace `p'_ymigr=1958 if `p'_tmoveus==2 & panel==2004
	replace `p'_ymigr=1964 if `p'_tmoveus==3 & panel==2004
	replace `p'_ymigr=1968.5 if `p'_tmoveus==4 & panel==2004
	replace `p'_ymigr=1972.5 if `p'_tmoveus==5 & panel==2004
	replace `p'_ymigr=1976.5 if `p'_tmoveus==6 & panel==2004
	replace `p'_ymigr=1979.5 if `p'_tmoveus==7 & panel==2004
	replace `p'_ymigr=1981.5 if `p'_tmoveus==8 & panel==2004
	replace `p'_ymigr=1983.5 if `p'_tmoveus==9 & panel==2004
	replace `p'_ymigr=1985.5 if `p'_tmoveus==10 & panel==2004
	replace `p'_ymigr=1987.5 if `p'_tmoveus==11 & panel==2004
	replace `p'_ymigr=1989.5 if `p'_tmoveus==12 & panel==2004
	replace `p'_ymigr=1991.5 if `p'_tmoveus==13 & panel==2004
	replace `p'_ymigr=1993.5 if `p'_tmoveus==14 & panel==2004
	replace `p'_ymigr=1995.5 if `p'_tmoveus==15 & panel==2004
	replace `p'_ymigr=1997.5 if `p'_tmoveus==16 & panel==2004
	replace `p'_ymigr=1999 if `p'_tmoveus==17 & panel==2004
	replace `p'_ymigr=2000 if `p'_tmoveus==18 & panel==2004
	replace `p'_ymigr=2001 if `p'_tmoveus==19 & panel==2004
	replace `p'_ymigr=2003 if `p'_tmoveus==20 & panel==2004
	replace `p'_ymigr=1961 if `p'_tmoveus==1 & panel==2008
	replace `p'_ymigr=1964.5 if `p'_tmoveus==2 & panel==2008
	replace `p'_ymigr=1971 if `p'_tmoveus==3 & panel==2008
	replace `p'_ymigr=1976 if `p'_tmoveus==4 & panel==2008
	replace `p'_ymigr=1979.5 if `p'_tmoveus==5 & panel==2008
	replace `p'_ymigr=1982 if `p'_tmoveus==6 & panel==2008
	replace `p'_ymigr=1984.5 if `p'_tmoveus==7 & panel==2008
	replace `p'_ymigr=1987 if `p'_tmoveus==8 & panel==2008
	replace `p'_ymigr=1989.5 if `p'_tmoveus==9 & panel==2008
	replace `p'_ymigr=1991.5 if `p'_tmoveus==10 & panel==2008
	replace `p'_ymigr=1993.5 if `p'_tmoveus==11 & panel==2008
	replace `p'_ymigr=1995.5 if `p'_tmoveus==12 & panel==2008
	replace `p'_ymigr=1997.5 if `p'_tmoveus==13 & panel==2008
	replace `p'_ymigr=1999 if `p'_tmoveus==14 & panel==2008
	replace `p'_ymigr=2000 if `p'_tmoveus==15 & panel==2008
	replace `p'_ymigr=2001 if `p'_tmoveus==16 & panel==2008
	replace `p'_ymigr=2002.5 if `p'_tmoveus==17 & panel==2008
	replace `p'_ymigr=2004 if `p'_tmoveus==18 & panel==2008
	replace `p'_ymigr=2005 if `p'_tmoveus==19 & panel==2008
	replace `p'_ymigr=2006 if `p'_tmoveus==20 & panel==2008
	replace `p'_ymigr=2007 if `p'_tmoveus==21 & panel==2008
	replace `p'_ymigr=2008.5 if `p'_tmoveus==22 & panel==2008
	}
	 
	g year=2001 if panel==2001 & panelmonth>=1 & panelmonth<=11
	replace year=2002 if panel==2001 & panelmonth>=12 & panelmonth<=23
	replace year=2003 if panel==2001 & panelmonth>=24 & panelmonth<=35
	replace year=2004 if panel==2001 & panelmonth==36
	replace year=2004 if panel==2004 & panelmonth>=1 & panelmonth<=11
	replace year=2005 if panel==2004 & panelmonth>=12 & panelmonth<=23
	replace year=2006 if panel==2004 & panelmonth>=24 & panelmonth<=35
	replace year=2007 if panel==2004 & panelmonth>=34 & panelmonth<=47
	replace year=2008 if panel==2004 & panelmonth==48
	replace year=2008 if panel==2008 & panelmonth>=1 & panelmonth<=4
	replace year=2009 if panel==2008 & panelmonth>=5 & panelmonth<=16
	replace year=2010 if panel==2008 & panelmonth>=17 & panelmonth<=28
	replace year=2011 if panel==2008 & panelmonth>=29 & panelmonth<=40
	replace year=2012 if panel==2008 & panelmonth>=41 & panelmonth<=52
	replace year=2013 if panel==2008 & panelmonth>=53 & panelmonth<=60

	*duration in the US
	foreach p in mom dad {
	g `p'_duration=year-`p'_ymigr
	}

	*for parents' duration we use the more recent immigrant:
	g parent_duration=mom_duration if mom_duration<dad_duration
	replace parent_duration=dad_duration if dad_duration<=mom_duration

	*Now, we create a categorical variable for duration- If both parents are native born or the sole parent in the hh duration=5:
	g mom_immigrant=(mom_tmoveus>-1)
	replace mom_immigrant=. if mom_tmoveus>=9999
	g dad_immigrant=(dad_tmoveus>-1)
	replace dad_immigrant=. if dad_tmoveus>=9999
	g parent_duration_cat=6 if mom_immigrant==0 & dad_immigrant==0
	replace parent_duration_cat=6 if mom_immigrant==0 & dad_immigrant==.
	replace parent_duration_cat=6 if dad_immigrant==0 & mom_immigrant==.
	replace parent_duration_cat=1 if parent_duration<=2 
	replace parent_duration_cat=2 if parent_duration>2 & parent_duration<=5
	replace parent_duration_cat=3 if parent_duration>5 & parent_duration<=10
	replace parent_duration_cat=4 if parent_duration>10 & parent_duration<=20
	replace parent_duration_cat=5 if parent_duration>20 & parent_duration!=.

	save "$SIPP08keep/hisp_children_comp", replace

*Figure 3
*Annual rate
collapse (mean)parent_change sib_change gp_change nonrel_change otherrel_change foster_change allelse_change [aweight=WPFINWGT], by(parent_duration_cat)
*By age 18:
use "$SIPP08keep/hisp_children_comp", clear
collapse (mean)parent_change sib_change gp_change nonrel_change otherrel_change foster_change allelse_change [aweight=WPFINWGT], by(parent_duration_cat adj_age)
foreach var in parent_change sib_change gp_change nonrel_change otherrel_change foster_change allelse_change {
g `var'_annual=`var'*12
}
collapse (sum)parent_change_annual sib_change_annual gp_change_annual nonrel_change_annual otherrel_change_annual foster_change_annual allelse_change_annual, by(parent_duration_cat)

*Figure 2- who is in the HH?
use "$SIPP01keep/HHComp_asis_am", clear
g panel=2001
append using "$SIPP04keep/HHComp_asis_am"
replace panel=2004 if panel==.
append using "$SIPP08keep/HHComp_asis_am"
replace panel=2008 if panel==.

keep if my_racealt==3 & adj_age<=17

foreach p in mom dad {
g `p'_ymigr=1952 if `p'_tmoveus==1 & panel==2001
replace `p'_ymigr=1955 if `p'_tmoveus==2 & panel==2001
replace `p'_ymigr=1961.5 if `p'_tmoveus==3 & panel==2001
replace `p'_ymigr=1966.5 if `p'_tmoveus==4 & panel==2001
replace `p'_ymigr=1970 if `p'_tmoveus==5 & panel==2001
replace `p'_ymigr=1973 if `p'_tmoveus==6 & panel==2001
replace `p'_ymigr=1976 if `p'_tmoveus==7 & panel==2001
replace `p'_ymigr=1978.5 if `p'_tmoveus==8 & panel==2001
replace `p'_ymigr=1980.5 if `p'_tmoveus==9 & panel==2001
replace `p'_ymigr=1983 if `p'_tmoveus==10 & panel==2001
replace `p'_ymigr=1985.5 if `p'_tmoveus==11 & panel==2001
replace `p'_ymigr=1987.5 if `p'_tmoveus==12 & panel==2001
replace `p'_ymigr=1989.5 if `p'_tmoveus==13 & panel==2001
replace `p'_ymigr=1991.5 if `p'_tmoveus==14 & panel==2001
replace `p'_ymigr=1993.5 if `p'_tmoveus==15 & panel==2001
replace `p'_ymigr=1995 if `p'_tmoveus==16 & panel==2001
replace `p'_ymigr=1996.5 if `p'_tmoveus==17 & panel==2001
replace `p'_ymigr=1998 if `p'_tmoveus==18 & panel==2001
replace `p'_ymigr=1999 if `p'_tmoveus==19 & panel==2001
replace `p'_ymigr=2000 if `p'_tmoveus==20 & panel==2001
replace `p'_ymigr=2001 if `p'_tmoveus==21 & panel==2001
replace `p'_ymigr=1954 if `p'_tmoveus==1 & panel==2004
replace `p'_ymigr=1958 if `p'_tmoveus==2 & panel==2004
replace `p'_ymigr=1964 if `p'_tmoveus==3 & panel==2004
replace `p'_ymigr=1968.5 if `p'_tmoveus==4 & panel==2004
replace `p'_ymigr=1972.5 if `p'_tmoveus==5 & panel==2004
replace `p'_ymigr=1976.5 if `p'_tmoveus==6 & panel==2004
replace `p'_ymigr=1979.5 if `p'_tmoveus==7 & panel==2004
replace `p'_ymigr=1981.5 if `p'_tmoveus==8 & panel==2004
replace `p'_ymigr=1983.5 if `p'_tmoveus==9 & panel==2004
replace `p'_ymigr=1985.5 if `p'_tmoveus==10 & panel==2004
replace `p'_ymigr=1987.5 if `p'_tmoveus==11 & panel==2004
replace `p'_ymigr=1989.5 if `p'_tmoveus==12 & panel==2004
replace `p'_ymigr=1991.5 if `p'_tmoveus==13 & panel==2004
replace `p'_ymigr=1993.5 if `p'_tmoveus==14 & panel==2004
replace `p'_ymigr=1995.5 if `p'_tmoveus==15 & panel==2004
replace `p'_ymigr=1997.5 if `p'_tmoveus==16 & panel==2004
replace `p'_ymigr=1999 if `p'_tmoveus==17 & panel==2004
replace `p'_ymigr=2000 if `p'_tmoveus==18 & panel==2004
replace `p'_ymigr=2001 if `p'_tmoveus==19 & panel==2004
replace `p'_ymigr=2003 if `p'_tmoveus==20 & panel==2004
replace `p'_ymigr=1961 if `p'_tmoveus==1 & panel==2008
replace `p'_ymigr=1964.5 if `p'_tmoveus==2 & panel==2008
replace `p'_ymigr=1971 if `p'_tmoveus==3 & panel==2008
replace `p'_ymigr=1976 if `p'_tmoveus==4 & panel==2008
replace `p'_ymigr=1979.5 if `p'_tmoveus==5 & panel==2008
replace `p'_ymigr=1982 if `p'_tmoveus==6 & panel==2008
replace `p'_ymigr=1984.5 if `p'_tmoveus==7 & panel==2008
replace `p'_ymigr=1987 if `p'_tmoveus==8 & panel==2008
replace `p'_ymigr=1989.5 if `p'_tmoveus==9 & panel==2008
replace `p'_ymigr=1991.5 if `p'_tmoveus==10 & panel==2008
replace `p'_ymigr=1993.5 if `p'_tmoveus==11 & panel==2008
replace `p'_ymigr=1995.5 if `p'_tmoveus==12 & panel==2008
replace `p'_ymigr=1997.5 if `p'_tmoveus==13 & panel==2008
replace `p'_ymigr=1999 if `p'_tmoveus==14 & panel==2008
replace `p'_ymigr=2000 if `p'_tmoveus==15 & panel==2008
replace `p'_ymigr=2001 if `p'_tmoveus==16 & panel==2008
replace `p'_ymigr=2002.5 if `p'_tmoveus==17 & panel==2008
replace `p'_ymigr=2004 if `p'_tmoveus==18 & panel==2008
replace `p'_ymigr=2005 if `p'_tmoveus==19 & panel==2008
replace `p'_ymigr=2006 if `p'_tmoveus==20 & panel==2008
replace `p'_ymigr=2007 if `p'_tmoveus==21 & panel==2008
replace `p'_ymigr=2008.5 if `p'_tmoveus==22 & panel==2008
}
 
g year=2001 if panel==2001 & panelmonth>=1 & panelmonth<=11
replace year=2002 if panel==2001 & panelmonth>=12 & panelmonth<=23
replace year=2003 if panel==2001 & panelmonth>=24 & panelmonth<=35
replace year=2004 if panel==2001 & panelmonth==36
replace year=2004 if panel==2004 & panelmonth>=1 & panelmonth<=11
replace year=2005 if panel==2004 & panelmonth>=12 & panelmonth<=23
replace year=2006 if panel==2004 & panelmonth>=24 & panelmonth<=35
replace year=2007 if panel==2004 & panelmonth>=34 & panelmonth<=47
replace year=2008 if panel==2004 & panelmonth==48
replace year=2008 if panel==2008 & panelmonth>=1 & panelmonth<=4
replace year=2009 if panel==2008 & panelmonth>=5 & panelmonth<=16
replace year=2010 if panel==2008 & panelmonth>=17 & panelmonth<=28
replace year=2011 if panel==2008 & panelmonth>=29 & panelmonth<=40
replace year=2012 if panel==2008 & panelmonth>=41 & panelmonth<=52
replace year=2013 if panel==2008 & panelmonth>=53 & panelmonth<=60

*duration in the US
foreach p in mom dad {
g `p'_duration=year-`p'_ymigr
}

*for parents' duration we use the more recent immigrant:
g parent_duration=mom_duration if mom_duration<dad_duration
replace parent_duration=dad_duration if dad_duration<=mom_duration

*Now, we create a categorical variable for duration- If both parents are native born or the sole parent in the hh duration=5:
g mom_immigrant=(mom_tmoveus>-1)
replace mom_immigrant=. if mom_tmoveus>=9999
g dad_immigrant=(dad_tmoveus>-1)
replace dad_immigrant=. if dad_tmoveus>=9999
g parent_duration_cat=6 if mom_immigrant==0 & dad_immigrant==0
replace parent_duration_cat=6 if mom_immigrant==0 & dad_immigrant==.
replace parent_duration_cat=6 if dad_immigrant==0 & mom_immigrant==.
replace parent_duration_cat=1 if parent_duration<=2 
replace parent_duration_cat=2 if parent_duration>2 & parent_duration<=5
replace parent_duration_cat=3 if parent_duration>5 & parent_duration<=10
replace parent_duration_cat=4 if parent_duration>10 & parent_duration<=20
replace parent_duration_cat=5 if parent_duration>20 & parent_duration!=.

g gp=(relationship==13 | relationship==14)
g parent=(relationship==1| relationship==4 | relationship==7 | relationship==21 | relationship==30)
g sibling=(relationship==17 | relationship==33)
g other_rel=(relationship==2 | relationship==3| relationship==5 | relationship==6 | relationship==10 | relationship==11 | relationship==12 | relationship==15 | relationship==16 | relationship==18 | (relationship>=23 & relationship<=29) | relationship==35 | relationship==36)
g non_rel=(relationship==20 | relationship==22| relationship==34| relationship==37 | relationship==40)
save "$SIPP08keep/hisp_children_rel", replace

collapse (sum)parent sibling gp other_rel non_rel [aweight=WPFINWGT], by(SSUID EPPPNUM panel panelmonth parent_duration_cat)
collapse (mean)parent sibling gp other_rel non_rel, by(parent_duration_cat)

*Figure 3- Comp+address instability
use "$SIPP08keep/hisp_children", clear
g only_comp=(comp_change==1 & addr_change!=1)
g only_addr=(comp_change!=1 & addr_change==1)
g both_changes=(comp_change==1& addr_change==1)
replace only_addr=. if comp_change==. & addr_change==.
replace only_comp=. if comp_change==. & addr_change==.
replace both_changes=. if comp_change==. & addr_change==.

*by age 18- need to multiply by 12 and sum:
tabstat only_comp if parent_duration_cat==1 [aweight=WPFINWGT],by(adj_age) 
tabstat only_comp if parent_duration_cat==2 [aweight=WPFINWGT],by(adj_age) 
tabstat only_comp if parent_duration_cat==3 [aweight=WPFINWGT],by(adj_age) 
tabstat only_comp if parent_duration_cat==4 [aweight=WPFINWGT],by(adj_age) 
tabstat only_comp if parent_duration_cat==5 [aweight=WPFINWGT],by(adj_age) 
tabstat only_comp if parent_duration_cat==6 [aweight=WPFINWGT],by(adj_age) 
tabstat only_addr if parent_duration_cat==1 [aweight=WPFINWGT],by(adj_age) 
tabstat only_addr if parent_duration_cat==2 [aweight=WPFINWGT],by(adj_age) 
tabstat only_addr if parent_duration_cat==3 [aweight=WPFINWGT],by(adj_age) 
tabstat only_addr if parent_duration_cat==4 [aweight=WPFINWGT],by(adj_age) 
tabstat only_addr if parent_duration_cat==5 [aweight=WPFINWGT],by(adj_age) 
tabstat only_addr if parent_duration_cat==6 [aweight=WPFINWGT],by(adj_age) 
tabstat both_changes if parent_duration_cat==1 [aweight=WPFINWGT],by(adj_age) 
tabstat both_changes if parent_duration_cat==2 [aweight=WPFINWGT],by(adj_age) 
tabstat both_changes if parent_duration_cat==3 [aweight=WPFINWGT],by(adj_age) 
tabstat both_changes if parent_duration_cat==4 [aweight=WPFINWGT],by(adj_age) 
tabstat both_changes if parent_duration_cat==5 [aweight=WPFINWGT],by(adj_age) 
tabstat both_changes if parent_duration_cat==6 [aweight=WPFINWGT],by(adj_age) 
