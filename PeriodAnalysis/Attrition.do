
* 2001

use "$tempdir/allwaves", clear   // for each panel
egen id=group(SSUID EPPPNUM)
tsset id SWAVE


gen run=.
replace run = cond(L.run == ., 1, L.run + 1)
egen maxrun = max(run), by(id)

sum maxrun


by id, sort: egen in_1 = max(SWAVE == 1)
by id, sort: egen in_2 = max(SWAVE == 2)
by id, sort: egen in_3 = max(SWAVE == 3)
by id, sort: egen in_4 = max(SWAVE == 4)
by id, sort: egen in_5 = max(SWAVE == 5)
by id, sort: egen in_6 = max(SWAVE == 6)
by id, sort: egen in_7 = max(SWAVE == 7)
by id, sort: egen in_8 = max(SWAVE == 8)
by id, sort: egen in_9 = max(SWAVE == 9)


* Data attrition from those in 1sth wave 

tab in_2 if in_1 
tab in_3 if in_1 
tab in_4 if in_1 
tab in_5 if in_1 
tab in_6 if in_1 
tab in_7 if in_1 
tab in_8 if in_1 
tab in_9 if in_1 


* 2004

use "$tempdir/allwaves", clear   // for each panel
egen id=group(SSUID EPPPNUM)
tsset id SWAVE


gen run=.
replace run = cond(L.run == ., 1, L.run + 1)
egen maxrun = max(run), by(id)

sum maxrun


by id, sort: egen in_1 = max(SWAVE == 1)
by id, sort: egen in_2 = max(SWAVE == 2)
by id, sort: egen in_3 = max(SWAVE == 3)
by id, sort: egen in_4 = max(SWAVE == 4)
by id, sort: egen in_5 = max(SWAVE == 5)
by id, sort: egen in_6 = max(SWAVE == 6)
by id, sort: egen in_7 = max(SWAVE == 7)
by id, sort: egen in_8 = max(SWAVE == 8)
by id, sort: egen in_9 = max(SWAVE == 9)
by id, sort: egen in_10 = max(SWAVE == 10)
by id, sort: egen in_11 = max(SWAVE == 11)
by id, sort: egen in_12 = max(SWAVE == 12)


* Data attrition from those in 1sth wave 

tab in_2 if in_1 
tab in_3 if in_1 
tab in_4 if in_1 
tab in_5 if in_1 
tab in_6 if in_1 
tab in_7 if in_1 
tab in_8 if in_1 
tab in_9 if in_1 
tab in_10 if in_1 
tab in_11 if in_1 
tab in_12 if in_1 


* 2008

use "$tempdir/allwaves", clear   // for each panel
egen id=group(SSUID EPPPNUM)
tsset id SWAVE


gen run=.
replace run = cond(L.run == ., 1, L.run + 1)
egen maxrun = max(run), by(id)

sum maxrun


by id, sort: egen in_1 = max(SWAVE == 1)
by id, sort: egen in_2 = max(SWAVE == 2)
by id, sort: egen in_3 = max(SWAVE == 3)
by id, sort: egen in_4 = max(SWAVE == 4)
by id, sort: egen in_5 = max(SWAVE == 5)
by id, sort: egen in_6 = max(SWAVE == 6)
by id, sort: egen in_7 = max(SWAVE == 7)
by id, sort: egen in_8 = max(SWAVE == 8)
by id, sort: egen in_9 = max(SWAVE == 9)
by id, sort: egen in_10 = max(SWAVE == 10)
by id, sort: egen in_11 = max(SWAVE == 11)
by id, sort: egen in_12 = max(SWAVE == 12)
by id, sort: egen in_13 = max(SWAVE == 13)
by id, sort: egen in_14 = max(SWAVE == 14)
by id, sort: egen in_15 = max(SWAVE == 15)



* Data attrition from those in 1sth wave 

tab in_2 if in_1 
tab in_3 if in_1 
tab in_4 if in_1 
tab in_5 if in_1 
tab in_6 if in_1 
tab in_7 if in_1 
tab in_8 if in_1 
tab in_9 if in_1 
tab in_10 if in_1 
tab in_11 if in_1 
tab in_12 if in_1 
tab in_13 if in_1 
tab in_14 if in_1 
tab in_15 if in_1 



