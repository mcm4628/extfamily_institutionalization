* This file extracts the needed data from the NBER core data files and formats 
* them for this project, which originally used a data file extracted directly 
* from Census using data ferrett (with capitalized variable names, for example)


* 2014 is too heavy - so we have to create extracts one by one
* Core questions:

* Wave 1
	clear
	set maxvar 32000
	use "$SIPP2014/pu2014w1"
	keep tftotinc thtotinc tst_intv ems eorigin EPNPAR1 EPNPAR2 epnspouse ///
	erace erelrp esex EPAR1TYP EPAR2TYP  tage  RHNUMPERWT2  ///
	RFAMREFWT2 thtotinc eresidenceid einttype pnum  ///
	shhadid monthcode aroutingsrop swave wpfinwgt eeduc ssuid rged ///
	renroll eedgrade 
	
	
	destring pnum, replace
	rename *, upper
	
	* Adapt SWAVE (month 4th of 2014w1 is SWAVE 1, month 8th SWAVE 2, month 12th  SWAVE 3)
     rename SWAVE swave
     gen SWAVE=.
     replace SWAVE=1 if swave==1 & MONTHCODE==4
     replace SWAVE=2 if swave==1 & MONTHCODE==8
     replace SWAVE=3 if swave==1 & MONTHCODE==12


	save "$SIPP14keep/wave1_extract" if swave==1 & MONTHCODE==4, $replace

* Wave 2
	clear
	set maxvar 32000
	use "$SIPP2014/pu2014w2"
	keep tftotinc thtotinc tst_intv ems eorigin epnpar1 epnpar2 epnspouse ///
	erace erelrp esex epar1typ epar2typ  tage renterreason  rhnumperwt2 ///
	rfamrefwt2 thtotinc eresidenceid einttype pnum tmover  ///
	shhadid monthcode aroutingsrop swave wpfinwgt eeduc ssuid rged ///
	renroll eedgrade 
	
	
	destring pnum, replace
	rename *, upper

	* Adapt SWAVE (month 4th of 2014w2 is SWAVE 4, month 8th SWAVE 5, month 12th  SWAVE 6)
    rename SWAVE swave
    gen SWAVE=.
    replace SWAVE=4 if swave==2 & MONTHCODE==4
    replace SWAVE=5 if swave==2 & MONTHCODE==8
    replace SWAVE=6 if swave==2 & MONTHCODE==12

	
	save "$SIPP14keep/wave2_extract", $replace

* Wave 3
	clear
	set maxvar 32000
	use "$SIPP2014/pu2014w3"
	keep tftotinc thtotinc tst_intv ems eorigin epnpar1 epnpar2 epnspouse ///
	erace erelrp esex epar1typ epar2typ  tage renterreason  rhnumperwt2 ///
	rfamrefwt2 thtotinc eresidenceid einttype pnum tmover  ///
	shhadid monthcode aroutingsrop swave wpfinwgt eeduc ssuid rged ///
	renroll eedgrade 
	
	
	destring eresidenceid, replace
	destring pnum, replace
	rename *, upper
	
	* Adapt SWAVE (month 4th of 2014w3 is SWAVE 7, month 8th SWAVE 8, month 12th  SWAVE 9)
    rename SWAVE swave
    gen SWAVE=.
    replace SWAVE=7 if swave==3 & MONTHCODE==4
    replace SWAVE=8 if swave==3 & MONTHCODE==8
    replace SWAVE=9 if swave==3 & MONTHCODE==12


	save "$SIPP14keep/wave3_extract", $replace


/* List of variables missing/different:
1. tfipsst -  
			  State of residence for the interview address
              TST_INTV: 1-61 (states, puerto rico and islands, foreign country)
			  
			  			  
			  
2. epndad & epnmom - 
                     Person number parent 1 and 2
                     epnpar1 epnpar2: 101:499. Person number 
									  9999. No parent 1 in household
                            
							OR
                     Shows whether a respondent is a parent (biological, step, or adoptive):
					 epar_scrnr: 1. Yes
                                 2. No
					 
3. etypdad & etypmom - 
					Type of relationship to parent 1 & 2
			        EPAR1TYP EPAR2TYP: 	1. Biological
										2. Step
										3. Adopted

4. uentmain -   Reason entered household (Wave 2 & 3 only)
				renterreason: 0. Not Answered
							  1. Birth
                              2. Marital Status Reasons (e.g., marriage, separation or divorce)
                              3. Returned to Household After Missing One or More Waves
                              4. Other Family Changes (e.g., change in custody, adoption or parent/child joins the household)
                              5. From an Institution or Other Group Quarters (e.g., nursing home, hospital, or correctional facility)
                              6. From Armed Forces Barracks
                              7. From Outside the U.S.
                              8. Should have been Listed as a Household Member in Wave 1
                              9. Job-Related Reasons
                              10. Lived at this Address Before Sample Person(s) Entered
                              11. Other
 
5. ulftmain - no variable found

6. ehhnumpp - 
              Number of persons in household this month
			  RHNUMPER: 1:20
			  
			   OR
			   Number of persons in household this month (with Type 2 persons)
			   RHNUMPERWT2: 1:22
			   
7. eoutcome -  not found
             
					   
8. rhchange -  not found

9.rhnf - not found but can be recontructed using RFAMNUMWT2
			Monthly family number for individuals in households (with Type 2 persons) 
			RFAMNUMWT2: 1:9o


10. eentaid - 
			This field stores a unique six-digit identifier for residence addresses
			ERESIDENCEID: 100001:400999
			
						OR
			Interview address ERESIDENCEID
			EHRESIDENCID: 100001:400999
PS: how is eentaid different from shhadid?

11. eppintvw 
			Type of interview
			EINTTYPE: 1. Self-reported
					  2. Proxy
                      3. Type Z (imputed)
					  
12. epppnum 
			Person number
			PNUM: 101:499
13. lgtkey
			Person number for monthly relationship
			RREL_PNUM(1 a 18): 60:499

14. tmovrflg
			Recoded variable indicating mover status
			TMOVER:
			1. Same house in the U.S. (non-mover)
			2. Different house in the U.S., same state and county
			3. Different house in the U.S., same state, different county
			4. Different house in the U.S., different state in the Northeast
			5. Different house in the U.S., different state in the Midwest
			6. Different house in the U.S., different state in the South
			7. Different house in the U.S., different state in the West
			
15. rhcalyr - not found (each wave refers to a certain year)
			
16. ssuseq - not found

17. eenrlm 
		  Recode for monthly enrollment status
		  RENROLL: 1. Yes, Enrolled at some time
				   2. No, Not enrolled at some time
				   
18. eenlevel
            Grade level of spell of enrollment
			EEDGRADE: 1. 1st
						2. 2nd
						3. 3rd
						4. 4th
						5. 5th
						6. 6th
						7. 7th
						8. 8th
						9. 9th
						10. 10th
						11. 11th
						12. 12th
						13. College year 1 (Freshman)
						14. College year 2 (Sophomore)
						15. College year 3 (Junior)
						16. College year 4 (Senior)
						17. College year 5 (First year graduate or professional school)
						18. College year 6+ (Second year or higher in graduate or professional school)
						19. Enrolled in college, but not working towards degree
						20. Vocational, technical, or business school beyond high school level
						21. Nursery school or preschool
						22. Kindergarten
						
						* IMMIGRATION - in case wanna use it *

19. tmoveus
			When did ... come to live in the U.S.?
			TYRENTRY: 1962. Recode for year less than or equal to 1962
					1969. Recode for year 1963 to 1969
					1973. Recode for year 1970 to 1973
					1977. Recode for year 1974 to 1977
					1980. Recode for year 1978 to 1980
					1983. Recode for year 1981 to 1983
					1985. Recode for year 1984 to 1985
					1987. Recode for year 1986 to 1987
					1989. Recode for year 1988 to 1989
					1991. Recode for year 1990 to 1991
					1993. Recode for year 1992 to 1993
					1995. Recode for year 1994 to 1995
					1997. Recode for year 1996 to 1997
					1998. Year
					1999. Year
					2000. Year
					2001. Year
					2003. Recode for year 2002 to 2003
					2004. Year
					2005. Year
					2007. Recode for year 2006 to 2007
					2009. Recode for year 2008 to 2009
					2010. Year
					2012. Recode for year 2011 to 2012
					2016. Recode for year 2013 to 2016

20. tbrstate
			Recoded Place of Birth
			TBORNPLACE: 01. Alabama
						02. Alaska
						04. Arizona
						05. Arkansas
						06. California
						08. Colorado
						09. Connecticut
						10. Delaware
						11. District of Columbia
						12. Florida
						13. Georgia
						15. Hawaii
						16. Idaho
						17. Illinois
						18. Indiana
						19. Iowa
						20. Kansas
						21. Kentucky
						22. Louisiana
						23. Maine
						24. Maryland
						25. Massachusetts
						26. Michigan
						27. Minnesota
						28. Mississippi
						29. Missouri
						30. Montana
						31. Nebraska
						32. Nevada
						33. New Hampshire
						34. New Jersey
						35. New Mexico
						36. New York
						37. North Carolina
						38. North Dakota
						39. Ohio
						40. Oklahoma
						41. Oregon
						42. Pennsylvania
						44. Rhode Island
						45. South Carolina
						46. South Dakota
						47. Tennessee
						48. Texas
						49. Utah
						50. Vermont
						51. Virginia
						53. Washington
						54. West Virginia
						55. Wisconsin
						56. Wyoming
						60. Puerto Rico and Island Areas
						61. Europe
						62. Asia and Pacific Islands
						63. Americas and Caribbean
						64. Africa
						65. Oceania
						66. Other
						
21. ebornus (same name in SIPP 2014)

*/
 
