global replace "replace"

global logdir "$homedir/stata_logs"
global tempdir "$homedir/stata_tmp"


global boxdir "$homedir/Box Sync"
global projdir "$boxdir/SIPP"
global projcode "t:\GitHub\ChildHH"
global SIPP2014data "$projdir/data/SIPP2014"
global SIPP2008data "$projdir/data/SIPP2008"
global SIPPshared "$projdir/data/shared"

global first_wave 1
global final_wave 15
global second_wave = ${first_wave} + 1
global penultimate_wave = ${final_wave} - 1

global adult_age 18

global refmon 4


*overall "named" log


cd "$boxdir"

