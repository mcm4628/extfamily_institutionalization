* This file is to create measures of marital status transitions across the 2008 SIPP panel

* This is an interesting problem. I can examine marital status change within wave and then across waves or I can
* create a very wide panel and examine marital status change within the panel. The latter seems less error prone.

clear

use "$tempdir/allmonths"

gen panel_month=(SWAVE-1)*4+SREFMON

tab panel_month
assert panel_month > 0

reshape wide TFIPSST EMS EPNSPOUS ERACE ERRP EFREFPER ESEX TAGE RHCHANGE EPPINTVW TMOVRFLG SHHADID WPFINWGT SWAVE SREFMON SSUSEQ, i(SSUID EPPPNUM) j(panel_month)

forvalues m=1/63{
  local n=`m'+1
  gen married`m'=1 if EMS`m'==6 & inlist(EMS`n',1,2) 
  gen split`m'=1 if inlist(EMS`m',1,2) & inlist(EMS`n',3,4)
  gen widowed`m'=1 if inlist(EMS`m',1,2) & inlist(EMS`n',5)
  gen error`m'=1 if EMS`m'==1 & EMS`n'==6
  gen observed`m'=1 if !missing(EMS`m') & !missing(EMS`n')
  replace married`m'=0 if missing(married`m') & observed`m'==1
  replace split`m'=0 if missing(split`m') & observed`m'==1
  replace widowed`m'=0 if missing(widowed`m') & observed`m'==1
  replace error`m'=0 if missing(error`m') & observed`m'==1
}

gen anymar=0
gen anysplit=0
gen anywid=0
gen anyerror=0
gen nobs=0
forvalues m=1/63{
  replace anymar=anymar+1 if married`m'==1
  replace anysplit=anysplit+1 if split`m'==1
  replace anywid=anywid+1 if widowed`m'==1
  replace anyerror=anyerror+1 if error`m'==1
  replace nobs=nobs+1 if observed`m'==1
}

tab anymar
tab anysplit
tab anywid
tab anyerror
tab nobs

exit

