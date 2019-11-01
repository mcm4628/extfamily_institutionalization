* This file extracts the needed data from the NBER core data files and formats 
* them for this project, which originally used a data file extracted directly 
* from Census using data ferrett (with capitalized variable names, for example)


* 2014 is too heavy - so we have to create extracts one by one
* Core questions:

* Wave 1 
	clear
	set maxvar 5500
	use "$SIPP2014/pu2014w1_compressed"
	keep tftotinc thtotinc tst_intv ems eorigin epnpar1 epnpar2 epnspouse ///
	erace erelrp esex epar1typ epar1typ epar2typ  tage  rhnumperwt2  ///
	rfamrefwt2 thtotinc eresidenceid einttype pnum  ///
	shhadid monthcode aroutingsrop swave wpfinwgt eeduc ssuid rged ///
	renroll eedgrade 
	
	
	destring pnum, replace
	rename *, upper
	
     rename SWAVE swave
     gen panelmonth=MONTHCODE

	save "$SIPP14keep/wave1_extract", $replace

* Wave 2
	clear
	set maxvar 5500
	use "$SIPP2014/pu2014w2_compressed"
	keep tftotinc thtotinc tst_intv ems eorigin epnpar1 epnpar2 epnspouse ///
	erace erelrp esex epar1typ epar2typ  tage renterreason  rhnumperwt2 ///
	rfamrefwt2 thtotinc eresidenceid einttype pnum tmover  ///
	shhadid monthcode aroutingsrop swave wpfinwgt eeduc ssuid rged ///
	renroll eedgrade 
	
	
	destring pnum, replace
	rename *, upper

    rename SWAVE swave
    gen SWAVE=.
     gen panelmonth=MONTHCODE+12
	
	save "$SIPP14keep/wave2_extract", $replace

* Wave 3
	clear
	set maxvar 5500
	use "$SIPP2014/pu2014w3_compressed"
	keep tftotinc thtotinc tst_intv ems eorigin epnpar1 epnpar2 epnspouse ///
	erace erelrp esex epar1typ epar2typ  tage renterreason  rhnumperwt2 ///
	rfamrefwt2 thtotinc eresidenceid einttype pnum tmover  ///
	shhadid monthcode aroutingsrop swave wpfinwgt eeduc ssuid rged ///
	renroll eedgrade 
	
	
	destring eresidenceid, replace
	destring pnum, replace
	rename *, upper
	
    rename SWAVE swave
    gen SWAVE=.
     gen panelmonth=MONTHCODE+24

	save "$SIPP14keep/wave3_extract", $replace

* Wave 4
	clear
	set maxvar 5500
	use "$SIPP2014/pu2014w4_compressed"
	keep tftotinc thtotinc tst_intv ems eorigin epnpar1 epnpar2 epnspouse ///
	erace erelrp esex epar1typ epar2typ  tage renterreason  rhnumperwt2 ///
	rfamrefwt2 thtotinc eresidenceid einttype pnum tmover  ///
	shhadid monthcode aroutingsrop swave wpfinwgt eeduc ssuid rged ///
	renroll eedgrade 
	
	
	destring eresidenceid, replace
	destring pnum, replace
	rename *, upper
	
    rename SWAVE swave
    gen SWAVE=.
     gen panelmonth=MONTHCODE+36

	save "$SIPP14keep/wave4_extract", $replace

