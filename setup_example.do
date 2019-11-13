* This is the base directory with the setup files.
* It is the directory you should change into before executing any files
global childhh_base_code "$homedir/github/childhh"

* 2014 Macros
* This is the location of the SIPP original data
global SIPP2014 "/data/sipp/2014"
global sipp2014_code "$childhh_base_code/SIPP2014/allmonths"

*This is the location of the SIPP Extracts and analysis files
global SIPP14keep "$homedir/data/SIPP2014"

* This is where logfiles produced by stata will go
global sipp2014_logs "$homedir/projects/childhh/logs"

* 2008 Macros

* This is the location of the SIPP original data
global SIPP2008core "/data/sipp/2008_Core/StataData"
global SIPP2008tm "/data/sipp/2008_TM/StataData"

* This is the location of the SIPP Extracts for the childhh project
global SIPP2008 "$homedir/data/SIPP2008/childhh"

* This is the location of the do files.  
global sipp2008_code "$childhh_base_code/SIPP2008"

* This is where logfiles produced by stata will go
global sipp2008_logs "$homedir/projects/childhh/logs"

* This is where data will put data files that are used in the analysis
global SIPP08keep "$homedir/projects/childhh/data/keep/2008"

* 2004 Macros

* This is the location of the SIPP original data
global SIPP2004core "/data/sipp/2004_Core/StataData"
global SIPP2004tm "/data/sipp/2004_TM/StataData"

* This is the location of the SIPP Extracts for the childhh project
global SIPP2004 "$homedir/data/SIPP2004/childhh"

* This is the location of the do files.  
global sipp2004_code "$childhh_base_code/SIPP2004"

* This is where logfiles produced by stata will go
global sipp2004_logs "$homedir/projects/childhh/logs"

* This is where data will put data files that are used in the analysis
global SIPP04keep "$homedir/projects/childhh/data/keep/2004"

* 2001 Macros

* This is the location of the SIPP original data
global SIPP2001Core "/data/sipp/2001_Core/StataData"
global SIPP2001tm "/data/sipp/2001_TM/StataData"

* This is the location of the SIPP Extracts for the childhh project
global SIPP2001 "$homedir/data/SIPP2001/childhh"

* This is the location of the do files.  
global sipp2001_code "$childhh_base_code/SIPP2001"

* This is where logfiles produced by stata will go
global sipp2001_logs "$homedir/projects/childhh/logs"

* This is where data will put data files that are used in the analysis
global SIPP01keep "$homedir/projects/childhh/data/keep/2001"

* Cross-panel macros

* This is where .xlxs and .doc files produced by stata will go
global results "$homedir/projects/childhh/results"

* This is where temporary data files produced by stata will go
global tempdir "$homedir/projects/childhh/data/tmp"

* If you change "replace" to " " the code will generally avoid overwriting any 
* existing data files including those in the temp directory.
global replace "replace"



