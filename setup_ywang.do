global replace "replace"

global homedir "D:/Projects/SIPP"
global projdir "D:/Projects/SIPP"

global logdir "$projdir/ywang/childhh/stata_logs"
global tempdir "$projdir/ywang/stata_data/stata_tmp"

* Where "original" data sits
global SIPP2014 "$projdir/stata_data/2014"
global SIPP2008core "$projdir/stata_data/2008"
global SIPP2008tm "$projdir/stata_data/2008"
global SIPP2004 "$projdir/stata_data/2004"
global SIPP2001 "$projdir/stata_data/2001"

* location of code directory
global childhh_base_code "T:/GitHub/ChildHH"


* 2014 Macros
global sipp2014_code "$childhh_base_code/SIPP2014/allmonths"

*This is the location of the SIPP Extracts and analysis files
global SIPP14keep "$homedir/ywang/stata_data/SIPP14/keep"

* This is where logfiles produced by stata will go
global sipp2014_logs "$homedir/ywang/childhh/logs"
