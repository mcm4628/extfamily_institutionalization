use "$tempdir/poverty_survival", clear

rename ssuid SSUID
rename epppnum EPPPNUM 

merge 1:1 SSUID EPPPNUM using "$SIPP08keep/demo_wide"

keep if adj_age1 < 15

*******************************************************************************
* Section: lifetable for risk of entry into poverty over the panel
*******************************************************************************

gen dur2pov=.
gen enterpov=0
gen turn18=.
gen firstmis=.
forvalues w=1/15 {
	replace dur2pov=`w' if missing(dur2pov) & poverty`w'==1 & adj_age`w' < 18
	replace enterpov=1 if enterpov==0 & poverty`w'==1 & evermis`w'==0 & adj_age`w' < 18
	replace turn18=`w' if missing(turn18) & adj_age`w'==18
	replace firstmis=`w' if missing(firstmis) & evermis`w'==1 & adj_age`w' < 18
}

gen survival=dur2pov if enterpov==1
replace survival=15 if enterpov==0 & missing(turn18) & missing(firstmis)
replace survival=turn18 if enterpov==0 & !missing(turn18)
replace survival=firstmis if enterpov==0 & !missing(firstmis)

tab poverty

keep SSUID EPPPNUM my_racealt my_sex poverty* adj_age* enterpov dur2pov survival turn18 firstmis

ltable survival enterpov



/*

*******************************************************************************
* Section: Preparing data for mslt
*******************************************************************************

use "$tempdir/poverty_transitions", clear

rename ssuid SSUID
rename epppnum EPPPNUM 
rename swave SWAVE

merge 1:1 SSUID EPPPNUM SWAVE using "$tempdir/demo_long_all"

keep if adj_age >= 0 & adj_age < 18

tab adj_age poverty

transition rates have not been adjusted to account for the fact that they are
4-month rates, not annual rates

Also, would like to be able to do this my manipulating the matrix rather than
putting data into excel

tab adj_age transtype if transtype < 5, nofreq row

putexcel set "$logdir/transitions.xlsx", sheet(poverty) modify

tab adj_age transtype if inlist(transtype,1,2), nofreq row matcell(inpov)
mata: st_matrix("inpov", (st_matrix("inpov")  :/ rowsum(st_matrix("inpov"))))

putexcel A1=("Age") B1=("p11") C1=("p12") D1=("p21") E1=("p22") F1=("race")   
putexcel B2=matrix(inpov)

tab adj_age transtype if inlist(transtype,3,4), nofreq row matcell(outpov)
mata: st_matrix("outpov", (st_matrix("outpov")  :/ rowsum(st_matrix("outpov"))))
putexcel D2=matrix(outpov)

forvalues rr=2/19 {
	putexcel A`rr'=formula(+`rr'-2)
	putexcel F`rr'=0
}

forvalues r=1/5 {
	local rw=(`r')*20+4
	tab adj_age transtype if inlist(transtype,1,2) & my_racealt==`r', nofreq row matcell(inpov`r')
	mata: st_matrix("inpov`r'", (st_matrix("inpov`r'")  :/ rowsum(st_matrix("inpov`r'"))))
	putexcel B`rw'=matrix(inpov`r')
  
	tab adj_age transtype if inlist(transtype,3,4) & my_racealt==`r', nofreq row matcell(outpov`r')
	mata: st_matrix("outpov`r'", (st_matrix("outpov`r'")  :/ rowsum(st_matrix("outpov`r'"))))
	putexcel D`rw'=matrix(outpov`r')
	forvalues rr=0/17 {
		local arw=`rw'+`rr'
		putexcel A`arw'=`rr'
		putexcel F`arw'=`r'
  }
}
