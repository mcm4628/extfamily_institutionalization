* This file extracts the needed data from the NBER core data files and formats 
* them for this project, which originally used a data file extracted directly 
* from Census using data ferrett (with capitalized variable names, for example)



* Core questions:
forvalues wave=1/9{
	clear
	use "$SIPP2001/l01puw`wave'"
	keep tftotinc thtotinc tfipsst ems eorigin epndad epnmom epnspous ///
	erace errp esex etypdad etypmom tage uentmain ulftmain ehhnumpp eoutcome ///
	rhchange rhnf thtotinc eentaid eppintvw epppnum lgtkey tmovrflg rhcalyr ///
	shhadid srefmon srotaton ssuseq swave wpfinwgt eeducate ssuid renroll ///
	eenrlm eenlevel
	
	destring eentaid, replace
	destring epppnum, replace
	destring lgtkey, replace
	rename *, upper
	
	 rename SWAVE swave
     gen SWAVE=.
     replace SWAVE=1 if swave==1 & SREFMON==1
     replace SWAVE=2 if swave==1 & SREFMON==2
     replace SWAVE=3 if swave==1 & SREFMON==3
	 replace SWAVE=4 if swave==1 & SREFMON==4
	 
	 replace SWAVE=5 if swave==2 & SREFMON==1
     replace SWAVE=6 if swave==2 & SREFMON==2
     replace SWAVE=7 if swave==2 & SREFMON==3
	 replace SWAVE=8 if swave==2 & SREFMON==4
	 
	 replace SWAVE=9  if swave==3 & SREFMON==1
     replace SWAVE=10 if swave==3 & SREFMON==2
     replace SWAVE=11 if swave==3 & SREFMON==3
	 replace SWAVE=12 if swave==3 & SREFMON==4

	 replace SWAVE=13 if swave==4 & SREFMON==1
     replace SWAVE=14 if swave==4 & SREFMON==2
     replace SWAVE=15 if swave==4 & SREFMON==3
	 replace SWAVE=16 if swave==4 & SREFMON==4
	 
	 replace SWAVE=17 if swave==5 & SREFMON==1
     replace SWAVE=19 if swave==5 & SREFMON==3
     replace SWAVE=18 if swave==5 & SREFMON==2
	 replace SWAVE=20 if swave==5 & SREFMON==4
	 
	 replace SWAVE=21 if swave==6 & SREFMON==1
     replace SWAVE=22 if swave==6 & SREFMON==2
     replace SWAVE=23 if swave==6 & SREFMON==3
	 replace SWAVE=24 if swave==6 & SREFMON==4
	 
	 replace SWAVE=25 if swave==7 & SREFMON==1
     replace SWAVE=26 if swave==7 & SREFMON==2
     replace SWAVE=27 if swave==7 & SREFMON==3
	 replace SWAVE=28 if swave==7 & SREFMON==4
	 
	 replace SWAVE=29 if swave==8 & SREFMON==1
     replace SWAVE=30 if swave==8 & SREFMON==2
     replace SWAVE=31 if swave==8 & SREFMON==3
	 replace SWAVE=32 if swave==8 & SREFMON==4
	 
	 replace SWAVE=33 if swave==9 & SREFMON==1
     replace SWAVE=34 if swave==9 & SREFMON==2
     replace SWAVE=35 if swave==9 & SREFMON==3
	 replace SWAVE=36 if swave==9 & SREFMON==4
	 

	save "$SIPP01keep/wave`wave'_extract", $replace
}
