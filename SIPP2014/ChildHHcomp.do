use "$SIPP2014/selected.dta", clear

drop if monthcode !=12

drop if tage > 17

local rellist "bioparent parent sibling fullsib spartner nonrel grandparent auncleniece other_rel nonnuke"

foreach v in `rellist'{
 gen `v'=0
 }


forvalues r=1/30{
	replace bioparent=bioparent+1 if rrel`r'==5
	replace parent=parent+1 if inlist(rrel`r',5,6,7,18)
	replace sibling=sibling+1 if inlist(rrel`r',9,10,11,12,13)
	replace fullsib=fullsib+1 if rrel`r'==9
	replace spartner=spartner+1 if inlist(rrel`r',1,2,3,4)
	replace nonrel=nonrel+1 if rrel`r'==19 
	replace grandparent=grandparent+1 if rrel`r'==8
	replace auncleniece=auncleniece+1 if rrel`r'==16
	replace other_rel=other_rel+1 if inlist(rrel`r',14,15,16,17)
	replace nonnuke=nonnuke+1 if nonrel==1 | grandparent==1 | auncleniece==1 | other_rel==1
}

foreach v in `rellist'{
	tab `v' [aw=wpfinwgt]
}

recode nonnuke (0=0)(1/30=1), gen(anynonuke)
recode nonrel (0=0)(1/30=1), gen(anynonrel)
recode grandparent (0=0)(1/30=1), gen(anygp)
recode other_rel (0=0)(1/30=1), gen(anyother)

local anyrel "anynonuke anynonrel anygp anyother"

foreach v in `anyrel'{
tab `v' [aw=wpfinwgt]
}
