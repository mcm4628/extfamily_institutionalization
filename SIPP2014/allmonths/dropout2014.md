I look at association between household composition change and high school dropout risk by month. The outcome variable dropout (0/1) was created using monthly enrollment indicator and EEDUC. I filled in missing EEDUC first because only people age 15 and older had answers for this question. I also adjusted dropout measure in summer because more children report "not enrolled" in June- August. I recoded dropout measure of those not enrolled in summer but then report enrolled in September to 0. Children aged 14-20 without a high school diploma are considered at risk of high school dropout. I dropped observations marked as already dropped out at baseline and created a censored sample of first high school dropout. 

~~~~
. use "$SIPP14keep/dropout_month.dta", clear

. keep if adj_age >=14 & adj_age <20
(796 observations deleted)

~~~~


*describe
~~~~
. tab panelmonth dropout [aweight=WPFINWGT], nofreq row 

           |   RECODE of RENROLL
           |  (Recode for monthly
           |  enrollment status)
panelmonth |         0          1 |     Total
-----------+----------------------+----------
         1 |    100.00       0.00 |    100.00 
         2 |     99.89       0.11 |    100.00 
         3 |     99.86       0.14 |    100.00 
         4 |     99.47       0.53 |    100.00 
         5 |     99.94       0.06 |    100.00 
         6 |     99.23       0.77 |    100.00 
         7 |     99.07       0.93 |    100.00 
         8 |    100.00       0.00 |    100.00 
         9 |     99.96       0.04 |    100.00 
        10 |     99.86       0.14 |    100.00 
        11 |     99.95       0.05 |    100.00 
        12 |     99.91       0.09 |    100.00 
        13 |     96.10       3.90 |    100.00 
        14 |     99.81       0.19 |    100.00 
        15 |     99.09       0.91 |    100.00 
        16 |     98.86       1.14 |    100.00 
        17 |     97.60       2.40 |    100.00 
        18 |     97.31       2.69 |    100.00 
        19 |     97.48       2.52 |    100.00 
        20 |     99.86       0.14 |    100.00 
        21 |     99.83       0.17 |    100.00 
        22 |     99.78       0.22 |    100.00 
        23 |     99.92       0.08 |    100.00 
        24 |     99.98       0.02 |    100.00 
        25 |     93.49       6.51 |    100.00 
        26 |     99.85       0.15 |    100.00 
        27 |     97.79       2.21 |    100.00 
        28 |     97.97       2.03 |    100.00 
        29 |     98.32       1.68 |    100.00 
        30 |     97.88       2.12 |    100.00 
        31 |     98.09       1.91 |    100.00 
        32 |     99.93       0.07 |    100.00 
        33 |     99.85       0.15 |    100.00 
        34 |     99.68       0.32 |    100.00 
        35 |     99.91       0.09 |    100.00 
        36 |     99.92       0.08 |    100.00 
        37 |     93.50       6.50 |    100.00 
        38 |     99.95       0.05 |    100.00 
        39 |    100.00       0.00 |    100.00 
        40 |     99.93       0.07 |    100.00 
        41 |     95.11       4.89 |    100.00 
        42 |     96.48       3.52 |    100.00 
        43 |     98.06       1.94 |    100.00 
        44 |     99.45       0.55 |    100.00 
        45 |     99.68       0.32 |    100.00 
        46 |     99.84       0.16 |    100.00 
        47 |    100.00       0.00 |    100.00 
-----------+----------------------+----------
     Total |     98.91       1.09 |    100.00 

. tab dropout adj_age [aweight=WPFINWGT], col

+-------------------+
| Key               |
|-------------------|
|     frequency     |
| column percentage |
+-------------------+

 RECODE of |
   RENROLL |
   (Recode |
       for |
   monthly |
enrollment |                       Cleaned age variable
   status) |        14         15         16         17         18         19 |     Total
-----------+------------------------------------------------------------------+----------
         0 | 18,125.68  29,508.15  29,436.07  26,779.94  13,937.75  2,053.981 | 119,841.6 
           |     99.41      99.15      99.09      98.63      98.46      95.30 |     98.91 
-----------+------------------------------------------------------------------+----------
         1 | 108.47148  251.89057 269.425288  371.88913   218.3834  101.37517 | 1,321.435 
           |      0.59       0.85       0.91       1.37       1.54       4.70 |      1.09 
-----------+------------------------------------------------------------------+----------
     Total |18,234.149  29,760.04  29,705.49  27,151.83  14,156.14  2,155.356 |   121,163 
           |    100.00     100.00     100.00     100.00     100.00     100.00 |    100.00 

. 
. tab parent_changelag dropout [aweight=WPFINWGT], row

+----------------+
| Key            |
|----------------|
|   frequency    |
| row percentage |
+----------------+

           |   RECODE of RENROLL
           |  (Recode for monthly
parent_cha |  enrollment status)
    ngelag |         0          1 |     Total
-----------+----------------------+----------
         0 |   113,827  1,271.134 | 115,098.1 
           |     98.90       1.10 |    100.00 
-----------+----------------------+----------
         1 | 518.89161  19.022391 |   537.914 
           |     96.46       3.54 |    100.00 
-----------+----------------------+----------
     Total | 114,345.8 1,290.1561 |   115,636 
           |     98.88       1.12 |    100.00 

. tab sib_changelag dropout [aweight=WPFINWGT], row

+----------------+
| Key            |
|----------------|
|   frequency    |
| row percentage |
+----------------+

           |   RECODE of RENROLL
           |  (Recode for monthly
sib_change |  enrollment status)
       lag |         0          1 |     Total
-----------+----------------------+----------
         0 | 113,142.9   1,242.59 | 114,385.5 
           |     98.91       1.09 |    100.00 
-----------+----------------------+----------
         1 | 1,202.935 47.5661854 | 1,250.502 
           |     96.20       3.80 |    100.00 
-----------+----------------------+----------
     Total | 114,345.8 1,290.1561 |   115,636 
           |     98.88       1.12 |    100.00 

. tab other_changelag dropout [aweight=WPFINWGT], row

+----------------+
| Key            |
|----------------|
|   frequency    |
| row percentage |
+----------------+

           |   RECODE of RENROLL
           |  (Recode for monthly
other_chan |  enrollment status)
     gelag |         0          1 |     Total
-----------+----------------------+----------
         0 | 112,725.7 1,232.1787 | 113,957.9 
           |     98.92       1.08 |    100.00 
-----------+----------------------+----------
         1 | 1,620.146  57.977401 | 1,678.123 
           |     96.55       3.45 |    100.00 
-----------+----------------------+----------
     Total | 114,345.8 1,290.1561 |   115,636 
           |     98.88       1.12 |    100.00 

. 
. tab biosib_changelag dropout [aweight=WPFINWGT], row

+----------------+
| Key            |
|----------------|
|   frequency    |
| row percentage |
+----------------+

           |   RECODE of RENROLL
           |  (Recode for monthly
biosib_cha |  enrollment status)
    ngelag |         0          1 |     Total
-----------+----------------------+----------
         0 | 113,811.5  1,264.221 | 115,075.7 
           |     98.90       1.10 |    100.00 
-----------+----------------------+----------
         1 | 534.34248  25.935173 | 560.27765 
           |     95.37       4.63 |    100.00 
-----------+----------------------+----------
     Total | 114,345.8 1,290.1561 |   115,636 
           |     98.88       1.12 |    100.00 

. tab halfsib_changelag dropout [aweight=WPFINWGT], row

+----------------+
| Key            |
|----------------|
|   frequency    |
| row percentage |
+----------------+

           |   RECODE of RENROLL
           |  (Recode for monthly
halfsib_ch |  enrollment status)
   angelag |         0          1 |     Total
-----------+----------------------+----------
         0 | 113,907.2   1,283.12 | 115,190.3 
           |     98.89       1.11 |    100.00 
-----------+----------------------+----------
         1 | 438.64177  7.0365532 |445.678322 
           |     98.42       1.58 |    100.00 
-----------+----------------------+----------
     Total | 114,345.8 1,290.1561 |   115,636 
           |     98.88       1.12 |    100.00 

. tab stepsib_changelag dropout [aweight=WPFINWGT], row

+----------------+
| Key            |
|----------------|
|   frequency    |
| row percentage |
+----------------+

           |   RECODE of RENROLL
           |  (Recode for monthly
stepsib_ch |  enrollment status)
   angelag |         0          1 |     Total
-----------+----------------------+----------
         0 | 114,278.7  1,287.451 | 115,566.2 
           |     98.89       1.11 |    100.00 
-----------+----------------------+----------
         1 | 67.119406  2.7055295 | 69.824935 
           |     96.13       3.87 |    100.00 
-----------+----------------------+----------
     Total | 114,345.8 1,290.1561 |   115,636 
           |     98.88       1.12 |    100.00 

~~~~


*model 1
*household composition and dropout
~~~~
. logit dropout i.parcomplag i.sibcomplag i.extendlag i.cpovlag i.adj_age my_sex ib1.par_ed_first ib1.my_racealt, cluster (S
> SUID)

Iteration 0:   log pseudolikelihood = -5807.9316  
Iteration 1:   log pseudolikelihood = -5707.3481  
Iteration 2:   log pseudolikelihood = -5688.0378  
Iteration 3:   log pseudolikelihood = -5687.7894  
Iteration 4:   log pseudolikelihood = -5687.7894  

Logistic regression                             Number of obs     =    108,487
                                                Wald chi2(23)     =     261.40
                                                Prob > chi2       =     0.0000
Log pseudolikelihood = -5687.7894               Pseudo R2         =     0.0207

                                       (Std. Err. adjusted for 4,042 clusters in SSUID)
---------------------------------------------------------------------------------------
                      |               Robust
              dropout |      Coef.   Std. Err.      z    P>|z|     [95% Conf. Interval]
----------------------+----------------------------------------------------------------
           parcomplag |
       single parent  |   .0389401   .0854415     0.46   0.649    -.1285222    .2064023
         step parent  |   .2335808   .1142537     2.04   0.041     .0096478    .4575139
           no parent  |   .2592634    .230979     1.12   0.262    -.1934472    .7119739
                      |
           sibcomplag |
        only biosibs  |   .1472608   .0901534     1.63   0.102    -.0294367    .3239583
      step/half sibs  |   .2683935   .1068642     2.51   0.012     .0589436    .4778434
                      |
            extendlag |
         grandparent  |   .2387729   .1453796     1.64   0.101    -.0461658    .5237116
horizontal extension  |   .1174624    .089869     1.31   0.191    -.0586775    .2936024
                      |
              cpovlag |
                Poor  |  -.1221354   .1457241    -0.84   0.402    -.4077493    .1634785
           Near Poor  |  -.0101115   .1292196    -0.08   0.938    -.2633772    .2431543
            Not Poor  |   .0038193   .1245998     0.03   0.976    -.2403918    .2480305
                      |
              adj_age |
                  15  |   .3389762   .1312393     2.58   0.010     .0817518    .5962005
                  16  |   .4981234   .1283981     3.88   0.000     .2464677    .7497791
                  17  |   .8980125   .1244162     7.22   0.000     .6541613    1.141864
                  18  |   1.000863   .1343061     7.45   0.000     .7376283    1.264099
                  19  |   2.088403   .1657753    12.60   0.000     1.763489    2.413316
                      |
               my_sex |    .011449   .0632094     0.18   0.856    -.1124392    .1353372
                      |
         par_ed_first |
             HS Grad  |  -.1049475   .1032922    -1.02   0.310    -.3073965    .0975014
        Some College  |  -.1924504   .1045817    -1.84   0.066    -.3974267    .0125258
        College Grad  |  -.2170833   .1190365    -1.82   0.068    -.4503906     .016224
                      |
           my_racealt |
            NH black  |  -.1075961     .10118    -1.06   0.288    -.3059053     .090713
            Hispanic  |   .0336441   .0873346     0.39   0.700    -.1375285    .2048168
            NH Asian  |  -.2938599   .2189407    -1.34   0.180    -.7229757     .135256
            NH Other  |  -.0833725    .157797    -0.53   0.597    -.3926489     .225904
                      |
                _cons |   -5.35657   .2168673   -24.70   0.000    -5.781622   -4.931518
---------------------------------------------------------------------------------------

~~~~

*model 2
*household composition change and dropout
~~~~
. logit dropout parent_changelag sib_changelag other_changelag i.cpovlag i.adj_age my_sex ib1.par_ed_first ib1.my_racealt, c
> luster (SSUID)

Iteration 0:   log pseudolikelihood = -5990.1577  
Iteration 1:   log pseudolikelihood =  -5856.261  
Iteration 2:   log pseudolikelihood = -5836.7981  
Iteration 3:   log pseudolikelihood = -5836.6601  
Iteration 4:   log pseudolikelihood = -5836.6601  

Logistic regression                             Number of obs     =    110,545
                                                Wald chi2(19)     =     354.59
                                                Prob > chi2       =     0.0000
Log pseudolikelihood = -5836.6601               Pseudo R2         =     0.0256

                                  (Std. Err. adjusted for 4,102 clusters in SSUID)
----------------------------------------------------------------------------------
                 |               Robust
         dropout |      Coef.   Std. Err.      z    P>|z|     [95% Conf. Interval]
-----------------+----------------------------------------------------------------
parent_changelag |   .9332439   .2445754     3.82   0.000     .4538848    1.412603
   sib_changelag |   .6209648   .2136306     2.91   0.004     .2022565    1.039673
 other_changelag |   .9505143   .1816264     5.23   0.000     .5945331    1.306495
                 |
         cpovlag |
           Poor  |  -.0906072   .1449067    -0.63   0.532    -.3746191    .1934046
      Near Poor  |  -.0150614   .1274115    -0.12   0.906    -.2647834    .2346606
       Not Poor  |    .005468   .1202121     0.05   0.964    -.2301434    .2410794
                 |
         adj_age |
             15  |   .3247611   .1294153     2.51   0.012     .0711119    .5784104
             16  |   .4876461   .1258587     3.87   0.000     .2409676    .7343246
             17  |   .8599712   .1221956     7.04   0.000     .6204723     1.09947
             18  |   .9701177   .1319264     7.35   0.000     .7115467    1.228689
             19  |   2.087163   .1629703    12.81   0.000     1.767748    2.406579
                 |
          my_sex |   .0133345   .0624543     0.21   0.831    -.1090738    .1357427
                 |
    par_ed_first |
        HS Grad  |  -.0805465   .1007304    -0.80   0.424    -.2779745    .1168815
   Some College  |  -.1778107   .1024536    -1.74   0.083    -.3786161    .0229947
   College Grad  |  -.2308267    .116059    -1.99   0.047    -.4582982   -.0033552
                 |
      my_racealt |
       NH black  |  -.0682258   .0967664    -0.71   0.481    -.2578845    .1214329
       Hispanic  |   .0832992   .0855001     0.97   0.330    -.0842778    .2508763
       NH Asian  |  -.2459442   .2068021    -1.19   0.234    -.6512688    .1593803
       NH Other  |   -.084711    .154694    -0.55   0.584    -.3879058    .2184837
                 |
           _cons |  -5.177301   .1922159   -26.93   0.000    -5.554037   -4.800565
----------------------------------------------------------------------------------

~~~~

*model 3
*household composition change and dropout while controling for hh composition
~~~~
. logit dropout parent_changelag sib_changelag other_changelag i.parcomplag i.sibcomplag i.extendlag i.cpovlag i.adj_age my_
> sex ib1.par_ed_first ib1.my_racealt, cluster (SSUID) 

Iteration 0:   log pseudolikelihood = -5807.9316  
Iteration 1:   log pseudolikelihood = -5684.1178  
Iteration 2:   log pseudolikelihood = -5664.7305  
Iteration 3:   log pseudolikelihood = -5664.5462  
Iteration 4:   log pseudolikelihood = -5664.5462  

Logistic regression                             Number of obs     =    108,487
                                                Wald chi2(26)     =     325.36
                                                Prob > chi2       =     0.0000
Log pseudolikelihood = -5664.5462               Pseudo R2         =     0.0247

                                       (Std. Err. adjusted for 4,042 clusters in SSUID)
---------------------------------------------------------------------------------------
                      |               Robust
              dropout |      Coef.   Std. Err.      z    P>|z|     [95% Conf. Interval]
----------------------+----------------------------------------------------------------
     parent_changelag |   .4833684   .3254647     1.49   0.138    -.1545306    1.121267
        sib_changelag |   .5334456   .2417568     2.21   0.027     .0596109     1.00728
      other_changelag |   .9403589   .1929055     4.87   0.000     .5622711    1.318447
                      |
           parcomplag |
       single parent  |   .0367286    .085041     0.43   0.666    -.1299486    .2034059
         step parent  |   .2155261   .1142348     1.89   0.059      -.00837    .4394223
           no parent  |   .1659578   .2333907     0.71   0.477    -.2914797    .6233952
                      |
           sibcomplag |
        only biosibs  |   .1365996   .0896445     1.52   0.128    -.0391005    .3122997
      step/half sibs  |   .2517483   .1068326     2.36   0.018     .0423603    .4611364
                      |
            extendlag |
         grandparent  |   .2053455   .1458344     1.41   0.159    -.0804846    .4911756
horizontal extension  |   .0298623   .0911315     0.33   0.743    -.1487521    .2084767
                      |
              cpovlag |
                Poor  |  -.1141589   .1463311    -0.78   0.435    -.4009626    .1726449
           Near Poor  |  -.0077134   .1296958    -0.06   0.953    -.2619126    .2464858
            Not Poor  |   .0108339   .1253576     0.09   0.931    -.2348624    .2565303
                      |
              adj_age |
                  15  |   .3299717   .1314345     2.51   0.012     .0723649    .5875785
                  16  |   .4843402   .1284637     3.77   0.000      .232556    .7361244
                  17  |   .8792876   .1244991     7.06   0.000     .6352739    1.123301
                  18  |   .9892591   .1343027     7.37   0.000     .7260307    1.252487
                  19  |    2.08597   .1655255    12.60   0.000     1.761546    2.410394
                      |
               my_sex |   .0101638   .0632865     0.16   0.872    -.1138756    .1342031
                      |
         par_ed_first |
             HS Grad  |  -.0991946    .103428    -0.96   0.338    -.3019098    .1035207
        Some College  |  -.1926334    .104594    -1.84   0.066    -.3976339    .0123671
        College Grad  |  -.2101425   .1188869    -1.77   0.077    -.4431565    .0228716
                      |
           my_racealt |
            NH black  |  -.0915624   .1011194    -0.91   0.365    -.2897527     .106628
            Hispanic  |   .0421595   .0873812     0.48   0.629    -.1291044    .2134235
            NH Asian  |  -.2895005   .2187462    -1.32   0.186    -.7182352    .1392342
            NH Other  |  -.0877655   .1579589    -0.56   0.578    -.3973593    .2218284
                      |
                _cons |   -5.36261   .2166956   -24.75   0.000    -5.787325   -4.937894
---------------------------------------------------------------------------------------

~~~~

*model 4
*household composition change in 8 categories
~~~~
. logit dropout i.cchangelag i.parcomplag i.sibcomplag i.extendlag i.cpovlag i.adj_age my_sex ib1.par_ed_first ib1.my_raceal
> t, cluster (SSUID) 

note: 8.cchangelag != 0 predicts failure perfectly
      8.cchangelag dropped and 52 obs not used

Iteration 0:   log pseudolikelihood = -5807.4369  
Iteration 1:   log pseudolikelihood = -5674.5989  
Iteration 2:   log pseudolikelihood = -5654.2604  
Iteration 3:   log pseudolikelihood =  -5654.071  
Iteration 4:   log pseudolikelihood =  -5654.071  

Logistic regression                             Number of obs     =    108,435
                                                Wald chi2(29)     =     329.40
                                                Prob > chi2       =     0.0000
Log pseudolikelihood =  -5654.071               Pseudo R2         =     0.0264

                                       (Std. Err. adjusted for 4,042 clusters in SSUID)
---------------------------------------------------------------------------------------
                      |               Robust
              dropout |      Coef.   Std. Err.      z    P>|z|     [95% Conf. Interval]
----------------------+----------------------------------------------------------------
           cchangelag |
  only parent change  |   .9770283   .3890555     2.51   0.012     .2144936    1.739563
      par&sib change  |   1.436617   .5300156     2.71   0.007     .3978056    2.475429
    par&other change  |   1.401689   .6079508     2.31   0.021     .2101273    2.593251
     only sib change  |   .9926319   .2335987     4.25   0.000     .5347869    1.450477
    sib&other change  |   .4408915   .5870386     0.75   0.453     -.709683    1.591466
   only other change  |   1.220536   .1806129     6.76   0.000     .8665414    1.574531
           3 changes  |          0  (empty)
                      |
           parcomplag |
       single parent  |   .0330951   .0851136     0.39   0.697    -.1337246    .1999147
         step parent  |    .213932   .1142027     1.87   0.061    -.0099012    .4377653
           no parent  |   .1796479   .2317756     0.78   0.438    -.2746239    .6339197
                      |
           sibcomplag |
        only biosibs  |   .1385582   .0897003     1.54   0.122    -.0372513    .3143676
      step/half sibs  |   .2497411    .106747     2.34   0.019     .0405208    .4589613
                      |
            extendlag |
         grandparent  |   .2045519   .1458603     1.40   0.161     -.081329    .4904328
horizontal extension  |   .0320177   .0909338     0.35   0.725    -.1462093    .2102446
                      |
              cpovlag |
                Poor  |  -.1118199   .1463172    -0.76   0.445    -.3985963    .1749566
           Near Poor  |  -.0064072   .1298329    -0.05   0.961     -.260875    .2480607
            Not Poor  |   .0070562   .1254423     0.06   0.955    -.2388062    .2529186
                      |
              adj_age |
                  15  |   .3295897   .1314589     2.51   0.012      .071935    .5872443
                  16  |   .4825244   .1284454     3.76   0.000     .2307761    .7342727
                  17  |   .8817792   .1244669     7.08   0.000     .6378285     1.12573
                  18  |   .9881396   .1342849     7.36   0.000     .7249461    1.251333
                  19  |    2.08586     .16558    12.60   0.000     1.761329    2.410391
                      |
               my_sex |   .0071341   .0633426     0.11   0.910    -.1170153    .1312834
                      |
         par_ed_first |
             HS Grad  |   -.102535   .1032343    -0.99   0.321    -.3048704    .0998005
        Some College  |  -.1960239   .1045353    -1.88   0.061    -.4009092    .0088615
        College Grad  |    -.21349    .118891    -1.80   0.073    -.4465121    .0195321
                      |
           my_racealt |
            NH black  |  -.0930295   .1008981    -0.92   0.357    -.2907862    .1047272
            Hispanic  |   .0376731    .087427     0.43   0.667    -.1336807    .2090269
            NH Asian  |  -.2996855   .2197957    -1.36   0.173    -.7304771    .1311061
            NH Other  |  -.0914861   .1581333    -0.58   0.563    -.4014217    .2184495
                      |
                _cons |  -5.364038   .2170116   -24.72   0.000    -5.789373   -4.938703
---------------------------------------------------------------------------------------

~~~~

*model 5
*type of sibling change
~~~~
. logit dropout parent_changelag other_changelag biosib_changelag halfsib_changelag stepsib_changelag i.parcomplag i.sibcomp
> lag i.extendlag i.cpovlag i.adj_age my_sex ib1.par_ed_first ib1.my_racealt, cluster (SSUID) 

Iteration 0:   log pseudolikelihood = -5807.9316  
Iteration 1:   log pseudolikelihood = -5677.8574  
Iteration 2:   log pseudolikelihood = -5657.0511  
Iteration 3:   log pseudolikelihood = -5656.8638  
Iteration 4:   log pseudolikelihood = -5656.8637  

Logistic regression                             Number of obs     =    108,487
                                                Wald chi2(28)     =     344.02
                                                Prob > chi2       =     0.0000
Log pseudolikelihood = -5656.8637               Pseudo R2         =     0.0260

                                       (Std. Err. adjusted for 4,042 clusters in SSUID)
---------------------------------------------------------------------------------------
                      |               Robust
              dropout |      Coef.   Std. Err.      z    P>|z|     [95% Conf. Interval]
----------------------+----------------------------------------------------------------
     parent_changelag |   .5632957   .3168819     1.78   0.075    -.0577815    1.184373
      other_changelag |   .9641473   .1881066     5.13   0.000     .5954652    1.332829
     biosib_changelag |   1.163959   .2581908     4.51   0.000     .6579144    1.670004
    halfsib_changelag |  -.9748403    .605512    -1.61   0.107    -2.161622    .2119414
    stepsib_changelag |  -.2406742   1.016755    -0.24   0.813    -2.233477    1.752128
                      |
           parcomplag |
       single parent  |   .0443447   .0851747     0.52   0.603    -.1225946     .211284
         step parent  |   .2302231   .1144327     2.01   0.044     .0059391    .4545072
           no parent  |   .1648838   .2339202     0.70   0.481    -.2935914     .623359
                      |
           sibcomplag |
        only biosibs  |   .1339836    .089626     1.49   0.135    -.0416801    .3096473
      step/half sibs  |   .2737203   .1066769     2.57   0.010     .0646374    .4828033
                      |
            extendlag |
         grandparent  |   .2100348   .1459165     1.44   0.150    -.0759564     .496026
horizontal extension  |   .0324842   .0907865     0.36   0.720    -.1454541    .2104226
                      |
              cpovlag |
                Poor  |  -.1129698   .1464507    -0.77   0.440    -.4000079    .1740684
           Near Poor  |  -.0034395   .1298464    -0.03   0.979    -.2579337    .2510547
            Not Poor  |   .0138781   .1254726     0.11   0.912    -.2320438    .2597999
                      |
              adj_age |
                  15  |   .3289008    .131373     2.50   0.012     .0714145    .5863871
                  16  |   .4816945   .1284946     3.75   0.000     .2298498    .7335392
                  17  |   .8810411   .1245268     7.08   0.000     .6369731    1.125109
                  18  |   .9893094   .1342482     7.37   0.000     .7261878    1.252431
                  19  |   2.084726   .1652445    12.62   0.000     1.760852    2.408599
                      |
               my_sex |   .0073174   .0633255     0.12   0.908    -.1167983    .1314331
                      |
         par_ed_first |
             HS Grad  |  -.1025857   .1035025    -0.99   0.322    -.3054469    .1002755
        Some College  |  -.1948538   .1046035    -1.86   0.062    -.3998728    .0101652
        College Grad  |  -.2145202   .1190041    -1.80   0.071     -.447764    .0187235
                      |
           my_racealt |
            NH black  |  -.0935074    .101134    -0.92   0.355    -.2917264    .1047116
            Hispanic  |   .0417884   .0875542     0.48   0.633    -.1298147    .2133915
            NH Asian  |  -.2881069   .2188137    -1.32   0.188    -.7169739    .1407601
            NH Other  |  -.0822444   .1578781    -0.52   0.602    -.3916797    .2271909
                      |
                _cons |  -5.367065   .2167794   -24.76   0.000    -5.791944   -4.942185
---------------------------------------------------------------------------------------

