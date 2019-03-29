* This file extracts the needed data from the NBER core data files and formats/harmonizes 
* them for this project, which began with the SIPP2008. The SIPP2008 file had 
* separate files for each wave with one record per wave per person in the household. 
* The SIPP1991 data file started with all waves merged together into a wide file.

* We create a long file with variable names to match those in the SIPP 2008

* Might be better to set a macro for data location.
use "C:\Users\kelly\data\SIPP1991\sip91fp.dta", clear

local panel="91"

keep ms_* ethnicty pnpt_* pnsp_* race rrp_* sex age_* hh_inc* pp_entry pp_id pp_pnum lgtkey* hh_add* pnlwgt fnlwgt* higrade* grd_cmp*

* Rename variables with leading 0 in name before reshaping 
forvalues month=1/32 {
local 0month : display %02.0f `month'
rename ms_`0month' ms_`month'
rename hh_add`0month' hh_add`month'
rename pnpt_`0month' pnpt_`month'
rename pnsp_`0month' pnsp_`month'
rename age_`0month' age_`month'
rename rrp_`0month' rrp_`month'
rename hh_inc`0month' hh_inc`month'
rename lgtkey`0month' lgtkey`month'
}

#delimit ;
label define education   34 "Elementary"
						 38 "High School no degree"
						 39 "High School Graduate"
						 40 "Some College"
						 44 "College Grad"
						 45 "Some Postgraduate ";
							  							  
#delimit cr

* creating a new education variable to more or less match eeduc in SIPP2008
* Naming them for the interview month aligned with the monthly variables (e.g. age_`month')
forvalues wave=1/8{
	local month=`wave'*4
	gen EEDUC`month'=34 if higrade`wave' > 0 & higrade`wave' <= 8
	replace EEDUC`month'=38 if higrade`wave' > 8 & higrade`wave' <= 12 // next line moves hs grads to 39
	replace EEDUC`month'=39 if higrade`wave'==12 & grd_cmp`wave'==1
	replace EEDUC`month'=40 if higrade`wave' > 12 & higrade`wave' <= 24 // next line moves colgrad to 44
	replace EEDUC`month'=44 if higrade`wave'==24 & grd_cmp`wave'==1
	replace EEDUC`month'=45 if higrade`wave' > 24
	label values EEDUC`month' education
}

drop higrade* grd_cmp*

local i_vars "pp_id pp_entry pp_pnum"
local wide_vars "hh_add pnpt_ pnsp_ age_ ms_ rrp_ lgtkey hh_inc EEDUC"

reshape long `wide_vars', i(`i_vars') j(MONTH)

* Whereas later SIPP panels individuals are uniquely identified with SSUID and EPPPNUM (or variants), in the 1991 Panel
* we need entry id as well to uniquely identify individuals. Our code is not written to use that many identifiers
* So, we create a single EPPPNUM variable based on EPPPNUM and Entry ID. 

destring pp_pnum pp_entry, replace

gen EPPPNUM=pp_pnum*100+pp_entry

drop pp_entry

recode rrp_ (5=8)(6=13)(7=14)

recode ethnicty (1/13=2)(14/20=1)(21=2)(30=2)(39=.), gen(EORIGIN)
recode race(1=1)(2=2)(4=3)(3=4), gen(ERACE)
rename pp_id SSUID
rename hh_add SHHADID
rename ms_ EMS
rename pnpt_ EPNPNT
rename pnsp_ EPNSPOUS
rename rrp_ ERRP 
rename sex ESEX
rename age_ TAGE

#delimit ;
label define errp	      0 "not a sample person in this month"
						  1 "Household reference person, w/ rels"
						  2 "Household reference person, no rels"
						  3 "Spouse"
						  4 "Child"
						  5 "Some Postgraduate "
						  8 "Other Relative"
						  13 "Non-Relative";
							  							  
#delimit cr

label values ERRP errp

keep if inlist(MONTH,4,8,12,16,20,24,28,32)

gen SWAVE=MONTH/4

drop MONTH

drop if ERRP==0

destring SHHADID, replace

save "$tempdir/allwaves`panel'", $replace

