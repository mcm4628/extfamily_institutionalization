use "$tempdir/person_wide_adjusted_ages"

* I am not including weight because I'm going to end up with households, not people
* and I have no idea what to do about that.

* We probably need income but it's not in the dataset I'm using.  Do we have it in the base data?

keep SSUID EPPPNUM SHHADID* adj_age*

reshape long SHHADID adj_age, i(SSUID EPPPNUM) j(SWAVE)

assert (missing(SHHADID) == missing(adj_age))

drop if missing(adj_age)

local max_child_age 16

gen child_flag = (adj_age <= `max_child_age')
gen adult_flag = (adj_age > `max_child_age')

collapse (sum) num_children=child_flag num_adults=adult_flag, by(SWAVE SSUID SHHADID)


tab num_children
tab num_adults

tab num_children SWAVE
tab num_adults SWAVE

tab num_children num_adults


save "$tempdir/hh_wave_characteristics", $replace


* It's OK to count occurrences of num_adults or num_children in order to get a count
* of number of waves of appearance because neither is ever missing.
collapse (median) num_children num_adults  (count) num_waves=num_adults, by(SSUID SHHADID)

tab num_waves

tab num_children
tab num_adults

tab num_children num_waves
tab num_adults num_waves

tab num_children num_adults


save "$tempdir/hh_characteristics", $replace
