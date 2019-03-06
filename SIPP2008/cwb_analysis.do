* Note that Wave 4 was conducted September to December 09.
* Wave 10 was collected September to December 11 (i.e. two years later)

local cwbw4 "ehltstat elivapat etvrules etimestv ehoustv eeatbkf eeatdinn edadbrkf edaddinn efarscho edadfar ethinksc erepgrad"
* measures of child well being. The health question was ask of all respondents and respondent's children.
* tvrules are asked for children age 2 to 17 in families with a designated parent or guardian with one or more children
* eeatbkf and eeatdinn, "In a typical week last month, how many days did designated parent eat breakfast/dinner with child. 
* meals questions are asked of all children age 0-17 in families with a designated parent or guardian.
* grade repeating is asked of children age 5-17.

local gwbw4 "ecounton etrustoe"
* Questions asked of all desgnated parents/guardians or spouse proxies"

local cwbw10 "ehltstatw10 elivapatw10 etvrulesw10 etimestvw10 ehoustvw10 eeatbkfw10 eeatdinnw10 edadbrkfw10 edaddinnw10 efarschow10 edadfarw10 ethinkscw10 erepgradw10"

foreach v in `cwbw4' {
replace `v'=. if `v' < 0
tab `v'
}

foreach v in `cwbw10' {
replace `v'=. if `v' < 0
tab `v'
}

* crosstab of each wave 10 variable by wave 4 variable
tab ehltstatw10 ehltstat
tab etvrulesw10 etvrules
tab eeatdinnw10 eeatdinn
tab erepgradw10 erepgrad

** The main question I want to answer is whether household instability is associated with declines in child well being and whether
** household instability due to other adults moving into or out of the household has a similar association as parents moving in or out.

** The strategy is to build a model starting with the sample eligible in wave 4 and predicting the outcome (health, tv, meals, repeat grade)
** at wave 10 controlling for the outcome at Wave 4, parental education, race, child age. 

local basemodel "adj_age4 i.par_ed_first i.my_racealt"

****
* health. Note that this variable is reverse coded so that higher values indicate poorer health
****

regress ehltstatw10 ehltstat `basemodel'
regress ehltstatw10 ehltstat `basemodel' b2.parentsw10 anyotheradultsw10 // household structure //
regress ehltstatw10 ehltstat `basemodel' parent_change otheradult_change // household change //
regress ehltstatw10 ehltstat `basemodel' b2.parentsw10 anyotheradultsw10 parent_change otheradult_change // household structure //

****
* eat dinner. Note that family change variables cover a 2-year period. Do we really think the effects of family change will be long-lasting?
****

regress eeatdinnw10 eeatbkf `basemodel'
regress eeatdinnw10 eeatbkf `basemodel' b2.parentsw10 anyotheradultsw10 // household structure //
regress eeatdinnw10 eeatbkf `basemodel' parent_change otheradult_change // household change //
regress eeatdinnw10 eeatbkf `basemodel' b2.parentsw10 anyotheradultsw10 parent_change otheradult_change // household structure //

***
* tv rules. Again, not sure that the effect should be long-lasting.
***

regress etvrulesw10 etvrules `basemodel'
regress etvrulesw10 etvrules `basemodel' b2.parentsw10 anyotheradultsw10 // household structure //
regress etvrulesw10 etvrules `basemodel' parent_change otheradult_change // household change //
regress etvrulesw10 etvrules `basemodel' b2.parentsw10 anyotheradultsw10 parent_change otheradult_change // household structure //

***
* repeating a grade. Like health status, this is something slow-developing and so this could indicate longer-term consequences
* but also the wave 4 measure is a weak control.
***

regress erepgradw10 erepgrad `basemodel'
regress erepgradw10 erepgrad `basemodel' b2.parentsw10 anyotheradultsw10 // household structure //
regress erepgradw10 erepgrad `basemodel' parent_change otheradult_change // household change //
regress erepgradw10 erepgrad `basemodel' b2.parentsw10 anyotheradultsw10 parent_change otheradult_change // household structure //
