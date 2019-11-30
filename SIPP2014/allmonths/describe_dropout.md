This is a preliminary analysis looking at the association between household composition and risk of high school dropout. The data file, created by dropout.do has one observation per wave (swave) (December). There is a variable cdony that indicates whether the individual had dropped out in the December after this one. This measure captures any non-summer month dropout, even if the person re-enrolled in school.


First, we describe children's household composition in December of each wave. Household composition has three dimensions:
1. The composition of parents == two original, single parent, two w/ step, and no parents
2. siblings = no siblings, bio only, at least some step/half
3. extension == not extended, grandparent only, other relatives or non-relatives

~~~~
<<dd_do>>

use "$SIPP14keep/HHComp_pm.dta", clear
keep if adj_age >=14 & adj_age <=20

merge 1:1 SSUID PNUM panelmonth using "$SIPP14keep/dropout.dta"

keep if inlist(panelmonth,12,24,36,48)

assert _merge==3
drop _merge

drop if adj_age==20

* restrict sample to those enrolled now and not missing next wave
keep if cdo==0 & !missing(cdony)

tab parcomp swave [aweight=WPFINWGT], nofreq col

<</dd_do>>
~~~~

About half of the sample is in two original parent households while about a third are living with a single parent. Just over 10% are in step-paren households and 5 percent live with neither parent. The proportion in two bio-parent households increases by wave, most likely because of sample selection. 

~~~~
<<dd_do>>

tab sibcomp swave [aweight=WPFINWGT], nofreq col 

<</dd_do>>
~~~~

Between a fifth and a quarter of the sample lives with sibglings. About one out of six lives with step or half siblings.

~~~~
<<dd_do>>


tab extend swave [aweight=WPFINWGT], nofreq col 

<</dd_do>>
~~~~

Household extension is common. About 20 percent of adolescents live with non-nuclear kin. Living with non-grandparent kin is most common in the first wave, suggesting that there might be differential attrition by household complexity that is not accounted for by the weights.


Describe the risk of dropping out by age and by wave

~~~~
<<dd_do>>

tab cdony swave [aweight=WPFINWGT], nofreq col 

tab cdony adj_age [aweight=WPFINWGT], col

<</dd_do>>
~~~~

At age 17 the risk of earning a diploma or GED (cdony==3) increases sharply, as we would expect. The sample size shrinks substantially so that few are left in the analysis at age 19. This is what we expect. Few 19 year olds are still in school without a high school degree.

There's no clear pattern of graduation or dropout by wave. New individuals are aging into the analysis in each wave and so the sample is not
necessarily getting older by wave.

OK, now a quick look at the association between household composition and risk of dropping out

~~~~
<<dd_do>>

tab parcomp cdony [aweight=WPFINWGT], row
tab sibcomp cdony [aweight=WPFINWGT], row
tab extend cdony [aweight=WPFINWGT], row

<</dd_do>>
~~~~

If there is an association between parental composition and risk of dropping out, it isn't strong. Living with step or half sibling is associated with an increased risk of dropping out. Horizontal extension is also associated with a greater risk of dropping out.

~~~~
<<dd_do>>


mlogit cdony i.adj_age i.my_sex i.my_race i.parcomp 
mlogit cdony i.adj_age i.my_sex i.my_race i.sibcomp 
mlogit cdony i.adj_age i.my_sex i.my_race i.extend

<</dd_do>>
~~~~

Children living with a single parent or no parent are less likely to earn a high school degree the next year.

Thos with step/half siblings are marginally more likely to dropout and less likely to earn a high school degree. Those in extended households are more likely to dropout, especially non-grandparental extended kin. It would probably be good to check that this result is not about own children or partners.

A bigger next step is to evaluate household instability's relationship with high school drop out. I'm especially interested to know whether sibling change is associated with high school drop out and whether this association depends on whether it is a step or half sibling.


