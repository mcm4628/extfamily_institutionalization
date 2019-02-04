* This file extracts the needed data from the NBER core data files and formats 
* them for this project, which originally used a data file extracted directly 
* from Census using data ferrett (with capitalized variable names, for example)


forvalues wave=1/16{
	clear
	use "$SIPP2008/FullFile/sippl08puw`wave'"

	keep ebornus ems eorigin epndad epnmom epnspous erace errp esex etypdad etypmom tage uentmain ulftmain ehhnumpp eoutcome rhchange rhnf thtotinc eentaid eppintvw epppnum lgtkey tmovrflg rhcalyr shhadid srefmon srotaton ssuseq swave wpfinwgt eeducate ssuid

	destring eentaid, replace
	destring epppnum, replace
	destring lgtkey, replace
	rename *, upper

	save "$SIPP2008/wave`wave'_extract", $replace
}
