* This file extracts the needed data from the NBER core data files and formats 
* for analysis of marriage (and cohabitation) formation.

clear

forvalues wave=1/16{
	clear
	use "$SIPP2008core/sippl08puw`wave'"
	keep tfipsst ems epnspous erace errp efrefper esex tage rhchange eppintvw epppnum tmovrflg ///
	shhadid srefmon srotaton ssuseq swave wpfinwgt ssuid ///
	
	destring epppnum, replace
	rename *, upper

	save "$SIPP08keep/wave`wave'_mar_extract", $replace
}
