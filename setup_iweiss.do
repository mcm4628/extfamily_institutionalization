cd
global replace "replace"
global projdir "D:/Projects/SIPP"


* This is the base directory with the setup files.
* It is the directory you should change into before executing any files


* Where "original" data sits
global SIPP2014 "$projdir/stata_data/2014"
global SIPP2008core "$projdir/stata_data/2008"
global SIPP2008tm "$projdir/stata_data/2008"
global SIPP2004 "$projdir/stata_data/2004"
global SIPP2001 "$projdir/stata_data/2001"

* where "codes" are located:
global childhh_base_code "$T/github/ChildHH"
global sipp2014_code "$childhh_base_code/SIPP2014"
global sipp2008_code "$childhh_base_code/SIPP2008"
global sipp2004_code "$childhh_base_code/SIPP2004"
global sipp2001_code "$childhh_base_code/SIPP2001"


* created data files
global created_data "$T/Projects/ChildHH/data"
global SIPP14keep "$created_data/SIPP14"
global SIPP08keep "$created_data/SIPP08"
global SIPP04keep "$created_data/SIPP04"
global SIPP01keep "$created_data/SIPP01"


* results
global results "$T/Projects/ChildHH/results"

* logs
global logdir "$T/Projects/ChildHH/logs"
global sipp2014_logs "$logdir/SIPP2014"
global sipp2008_logs "$logdir/SIPP2008"
global sipp2004_logs "$logdir/SIPP2004"
global sipp2001_logs "$logdir/SIPP2001"


* temporary data files (they get deleted without a second thought)
global tempdir "$T/Projects/ChildHH/temp"

