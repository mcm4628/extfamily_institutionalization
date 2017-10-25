* Boilerplate prolog for ChildHH project.
* This should be executed at least once at the
* beginning of running (sub)project code.

* It assumes a global macro named $logdir that
* specifies the location of log files.

* It takes a single parameter, the basename of the log file.  
* "Basename" just means the name without the .do on the end.


args fname

capture log close
log using "$logdir/`fname'", text $replace


* I would love to turn off line wrap so the state is a single
* continuous string.  This seems not to be possible.  The best
* we can do is set the line length to 255.  That's about 20 times
* too short so why bother.
*
* Also, I considered saving the state as a note in the dataset
* but this generic do file can't assume there is a dataset at all.
display "Starting random number generator state"
display "`c(rngstate)'"


set varabbrev off

macro list

pwd
