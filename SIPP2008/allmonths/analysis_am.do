use "$SIPP08keep/HHchangeWithRelationships_am.dta", clear

gen wave=floor((panelmonth+3)/4)
gen month=4-(wave*4-panelmonth)

tab month hh_change, nofreq row

drop if missing(SHHADID)

collapse (mean)hh_change, by(adj_age month)
collapse (sum)hh_change, by(adj_age)

replace hh_change=hh_change*3 // converting 4-month rate to an annual rate

// list adj_age hh_change

keep if adj_age < 18

collapse (sum) hh_change


/*
forvalues a=0/17 {
    gen trichange`a'=0 if adj_age==`a'
    forvalues m=1/4 {
        replace trichange`a'=trichange`a'+hh_change if month==`m' & adj_age==`a'
    }
}

