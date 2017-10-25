*** First off we just combine all the waves using 'append'.

use "$SIPP2008/wave${first_wave}_extract"

keep if SREFMON == ${refmon}

forvalues wave = $second_wave/$final_wave {
    append using "$SIPP2008/wave`wave'_extract"
    keep if SREFMON == ${refmon}
}

save "$tempdir/allwaves", $replace
