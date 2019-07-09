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

	save "$SIPP01keep/wave`wave'_extract", $replace
}
