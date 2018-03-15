use "$tempdir/partner_type", clear

tab year adj_age, row nofreq

keep if partner_type==0 & !missing(partrans)

tab year partrans

tab year partrans [aweight=WPFINWGT], nofreq row

keep if adj_age > 19 & adj_age < 25

tab year partrans

tab year partrans [aweight=WPFINWGT]
