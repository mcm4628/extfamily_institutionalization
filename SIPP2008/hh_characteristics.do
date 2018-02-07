use "$tempdir/person_wide_adjusted_ages"

* I am not including weight because I'm going to end up with households, not people
* and I have no idea what to do about that.

* We probably need income but it's not in the dataset I'm using.  Do we have it in the base data?

keep SSUID EPPPNUM SHHADID* adj_age*

reshape long SHHADID adj_age, i(SSUID EPPPNUM) j(SWAVE)


* This just drops people who were not present in a wave.
* The assert confirms that we're not missing any ages when data is present.
assert (missing(SHHADID) == missing(adj_age))
drop if missing(adj_age)


* Now grab the income variable from the base data.  We weren't carrying
* income in our relationships-oriented datasets.
merge 1:1 SWAVE SSUID EPPPNUM using "$tempdir/allwaves", keepusing(THTOTINC)
assert (_merge == 3)
drop _merge



* Count the number of adults and children in each household in each wave.
* Also, retain the income variable (it's the same for all records in a HH
* in any given wave, so we just take the value in the first record.
local max_child_age 16

gen child_flag = (adj_age <= `max_child_age')
gen adult_flag = (adj_age > `max_child_age')

collapse (sum) num_children=child_flag num_adults=adult_flag  (firstnm) THTOTINC, by(SWAVE SSUID SHHADID)

tab num_children
tab num_adults

tab num_children SWAVE
tab num_adults SWAVE

tab num_children num_adults

summ THTOTINC, detail


* Save the household-by-wave data.
save "$tempdir/hh_wave_characteristics", $replace


* Now collapse to one record per household.

* It's OK to count occurrences of num_adults or num_children in order to get a count
* of number of waves of appearance because neither is ever missing.
collapse (median) num_children num_adults  (count) num_waves=num_adults, by(SSUID SHHADID)

tab num_waves

tab num_children
tab num_adults

tab num_children num_waves
tab num_adults num_waves

tab num_children num_adults


* And save the per household results.
save "$tempdir/hh_characteristics", $replace
