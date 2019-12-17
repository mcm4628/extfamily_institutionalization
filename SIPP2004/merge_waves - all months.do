//====================================================================//
//===== Children's Household Instability Project                    
//===== Dataset: SIPP2004                                           
//===== Purpose: This code append all waves of SIPP2008 original data into a long form dataset. 
//               It keeps only observations in the reference month (4).  
//=====================================================================//

** Import first wave. 
use "$SIPP04keep/wave${first_wave}_extract", clear 


** Append the first wave with waves from the second to last, also keep only observations from the reference month. 
forvalues wave = $second_wave/$final_wave {
    append using "$SIPP04keep/wave`wave'_extract"
}

rename SWAVE swave
gen SWAVE=.
     replace SWAVE=1 if swave==1 & SREFMON==1
     replace SWAVE=2 if swave==1 & SREFMON==2
     replace SWAVE=3 if swave==1 & SREFMON==3
	 replace SWAVE=4 if swave==1 & SREFMON==4
	 
	 replace SWAVE=5 if swave==2 & SREFMON==1
     replace SWAVE=6 if swave==2 & SREFMON==2
     replace SWAVE=7 if swave==2 & SREFMON==3
	 replace SWAVE=8 if swave==2 & SREFMON==4
	 
	 replace SWAVE=9  if swave==3 & SREFMON==1
     replace SWAVE=10 if swave==3 & SREFMON==2
     replace SWAVE=11 if swave==3 & SREFMON==3
	 replace SWAVE=12 if swave==3 & SREFMON==4

	 replace SWAVE=13 if swave==4 & SREFMON==1
     replace SWAVE=14 if swave==4 & SREFMON==2
     replace SWAVE=15 if swave==4 & SREFMON==3
	 replace SWAVE=16 if swave==4 & SREFMON==4
	 
	 replace SWAVE=17 if swave==5 & SREFMON==1
     replace SWAVE=19 if swave==5 & SREFMON==3
     replace SWAVE=18 if swave==5 & SREFMON==2
	 replace SWAVE=20 if swave==5 & SREFMON==4
	 
	 replace SWAVE=21 if swave==6 & SREFMON==1
     replace SWAVE=22 if swave==6 & SREFMON==2
     replace SWAVE=23 if swave==6 & SREFMON==3
	 replace SWAVE=24 if swave==6 & SREFMON==4
	 
	 replace SWAVE=25 if swave==7 & SREFMON==1
     replace SWAVE=26 if swave==7 & SREFMON==2
     replace SWAVE=27 if swave==7 & SREFMON==3
	 replace SWAVE=28 if swave==7 & SREFMON==4
	 
	 replace SWAVE=29 if swave==8 & SREFMON==1
     replace SWAVE=30 if swave==8 & SREFMON==2
     replace SWAVE=31 if swave==8 & SREFMON==3
	 replace SWAVE=32 if swave==8 & SREFMON==4
	 
	 replace SWAVE=33 if swave==9 & SREFMON==1
     replace SWAVE=34 if swave==9 & SREFMON==2
     replace SWAVE=35 if swave==9 & SREFMON==3
	 replace SWAVE=36 if swave==9 & SREFMON==4
	 
	 replace SWAVE=37 if swave==10 & SREFMON==1
     replace SWAVE=38 if swave==10 & SREFMON==2
     replace SWAVE=39 if swave==10 & SREFMON==3
	 replace SWAVE=40 if swave==10 & SREFMON==4
	 
	 replace SWAVE=41 if swave==11 & SREFMON==1
     replace SWAVE=42 if swave==11 & SREFMON==2
     replace SWAVE=43 if swave==11 & SREFMON==3
	 replace SWAVE=44 if swave==11 & SREFMON==4
	 
	 replace SWAVE=45 if swave==12 & SREFMON==1
     replace SWAVE=46 if swave==12 & SREFMON==2
     replace SWAVE=47 if swave==12 & SREFMON==3
	 replace SWAVE=48 if swave==12 & SREFMON==4

** allwaves.dta is a long-form datasets include all the waves from SIPP2004, month 4 data. 
save "$tempdir/allwaves", $replace
