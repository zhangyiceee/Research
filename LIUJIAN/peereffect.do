***之前分析数据时标准化成绩后删掉城镇学生，现在改成删除城镇学生后在标准化，同时对学生数据空缺值进行了填补，进而导致数据结果和小论文不同，但结论依然成立

*********************************************
************同伴效应分析*********************
*********************************************
global dtadir     "/Users/zhangyi/Desktop/Peer effectt/程序/raw"
global workingdir "/Users/zhangyi/Desktop/Peer effectt/程序/working"
global savedir    "/Users/zhangyi/Desktop/Peer effectt/程序/output"
cd "$workingdir"
use "peereffect_clean.dta",clear
*剔除重复
foreach i in stu_b_14_codelearnmath stu_b_14_codefriend stu_e_14_codelearnmath stu_e_14_codefriend  {
  forvalue j= 1/4  {  
    forvalue k= 2/5 {
      replace `i'`k'="" if `i'`j'==`i'`k'&`j'<`k'
    }
  }
}

*同伴数量并生成同伴编码
tab stu_e_14_codelearnmath1,m
foreach i in b e {
  foreach j in codelearnmath codefriend {
      gen `i'`j'_n=0
    forvalue k=1/5 {
      replace `i'`j'_n=`i'`j'_n+1 if stu_`i'_14_`j'`k'!=""
      gen `i'`j'`k'=substr(stu_e_14_stdid,1,6)+stu_`i'_14_`j'`k' if stu_`i'_14_`j'`k'!="" //为空不生成编码
    }
  }
} 

***同伴信息（成绩、父母受教育程度、同伴个数）计算   （稳健性检验跑第37行命令，改变同伴定义）
gen bpeermath=.
gen epeermath=.
gen peergs=.
gen peer_edufather=.
gen peer_edumother=.
gen ship=0
forvalue g=1/2673 {
  forvalue i=1/5 {
    replace ship=1 if ecodefriend`i'[`g']==stu_e_14_stdid //自选择（只运行该行命令是，为学生自我报告同伴）
    //replace ship=ship+2 if ecodefriend`i'==stu_e_14_stdid[`g'] //被选择，ship=1,为单向自选择同伴（非互惠型）、ship=2,为被选型同伴（追随型）、ship=3,为互相选择同伴（互惠型）,可做稳健性检验
  }       
  sum bz_stu_math if ship==1
    replace bpeermath=r(mean) if stu_e_14_stdid==stu_e_14_stdid[`g']
    replace peergs=r(N) if stu_e_14_stdid==stu_e_14_stdid[`g']
  sum ez_stu_math if ship==1
    replace epeermath=r(mean) if stu_e_14_stdid==stu_e_14_stdid[`g']
  sum edu_father_year if ship==1
    replace peer_edufather=r(mean) if stu_e_14_stdid==stu_e_14_stdid[`g']
  sum edu_mother_year if ship==1
    replace peer_edumother=r(mean) if stu_e_14_stdid==stu_e_14_stdid[`g']
  replace ship=0
} 

***变量描述以及对比***
sum ez_stu_math epeermath peergs bz_stu_math age2 female boarding edu_father_year edu_mother_year lbc stu_asset teaching_age tea_female edu_tea tea_gaoji classsize 
ttest ez_stu_math, by(lbc)
ttest bz_stu_math, by(lbc)
ttest peermath, by(lbc)
ttest peer_edufather, by(lbc)
ttest peer_edumother, by(lbc)
ttest peergs, by(lbc)
ttest age2, by(lbc)
ttest female, by(lbc)
ttest boarding, by(lbc)
ttest edu_father_year, by(lbc)
ttest edu_mother_year, by(lbc)
ttest stu_asset, by(lbc)
ttest teaching_age, by(lbc)
ttest tea_female, by(lbc)
ttest edu_tea, by(lbc)
ttest tea_gaoji, by(lbc)
ttest classize, by(lbc)

***ols回归
xi:reg ez_stu_math epeermath peergs bz_stu_math age2 female boarding edu_father_year edu_mother_year lbc stu_asset teaching_age tea_female edu_tea tea_gaoji classsize i.grade i.schoolid 
xi:reg ez_stu_math epeermath peergs bz_stu_math age2 female boarding edu_father_year edu_mother_year lbc stu_asset teaching_age tea_female edu_tea tea_gaoji classsize i.grade i.schoolid if lbc==0
xi:reg ez_stu_math epeermath peergs bz_stu_math age2 female boarding edu_father_year edu_mother_year lbc stu_asset teaching_age tea_female edu_tea tea_gaoji classsize i.grade i.schoolid if lbc==1


***2sls回归（弱工具变量检验、过度识别检验回归方程中报告）
xi:ivreg2 ez_stu_math (epeermath=peer_edufather peer_edumother) peergs bz_stu_math age2 female boarding edu_father_year edu_mother_year lbc stu_asset teaching_age tea_female edu_tea tea_gaoji classsize i.grade i.schoolid    
xi:ivreg2 ez_stu_math (epeermath=peer_edufather peer_edumother) peergs bz_stu_math age2 female boarding edu_father_year edu_mother_year stu_asset teaching_age tea_female edu_tea tea_gaoji classsize i.grade i.schoolid if lbc==0
xi:ivreg2 ez_stu_math (epeermath=peer_edufather peer_edumother) peergs bz_stu_math age2 female boarding edu_father_year edu_mother_year stu_asset teaching_age tea_female edu_tea tea_gaoji classsize i.grade i.schoolid if lbc==1
//xi:ivreg2 ez_stu_math (bpeermath=peer_edufather peer_edumother) peergs bz_stu_math age2 female boarding edu_father_year edu_mother_year lbc stu_asset teaching_age tea_female edu_tea tea_gaoji classsize i.grade i.schoolid
//xi:ivreg2 ez_stu_math (bpeermath=peer_edufather peer_edumother) peergs bz_stu_math age2 female boarding edu_father_year edu_mother_year stu_asset teaching_age tea_female edu_tea tea_gaoji classsize i.grade i.schoolid if lbc==0
//xi:ivreg2 ez_stu_math (bpeermath=peer_edufather peer_edumother) peergs bz_stu_math age2 female boarding edu_father_year edu_mother_year stu_asset teaching_age tea_female edu_tea tea_gaoji classsize i.grade i.schoolid if lbc==1

***内生性检验（杜宾-豪斯曼检验）
*全样本
xi:reg ez_stu_math epeermath peergs bz_stu_math age2 female boarding edu_father_year edu_mother_year lbc stu_asset teaching_age tea_female edu_tea tea_gaoji classsize i.grade i.schoolid 
estimates store ols
xi:ivregress 2sls ez_stu_math (epeermath=peer_edufather peer_edumother) peergs bz_stu_math age2 female boarding edu_father_year edu_mother_year lbc stu_asset teaching_age tea_female edu_tea tea_gaoji classsize i.grade i.schoolid 
estimates store iv
hausman iv ols,constant sigmamore
estat endogenous
*留守儿童样本（留守儿童内生性检验显著，即模型存在内生性）
xi:reg ez_stu_math epeermath peergs bz_stu_math age2 female boarding edu_father_year edu_mother_year lbc stu_asset teaching_age tea_female edu_tea tea_gaoji classsize i.grade i.schoolid if lbc==1
estimates store ols
xi:ivregress 2sls ez_stu_math (epeermath=peer_edufather peer_edumother) peergs bz_stu_math age2 female boarding edu_father_year edu_mother_year lbc stu_asset teaching_age tea_female edu_tea tea_gaoji classsize i.grade i.schoolid if lbc==1
estimates store iv
hausman iv ols,constant sigmamore
estat endogenous
*非留守儿童样本
xi:reg ez_stu_math epeermath peergs bz_stu_math age2 female boarding edu_father_year edu_mother_year lbc stu_asset teaching_age tea_female edu_tea tea_gaoji classsize i.grade i.schoolid if lbc==0
estimates store ols
xi:ivregress 2sls ez_stu_math (epeermath=peer_edufather peer_edumother) peergs bz_stu_math age2 female boarding edu_father_year edu_mother_year lbc stu_asset teaching_age tea_female edu_tea tea_gaoji classsize i.grade i.schoolid if lbc==0
estimates store iv
hausman iv ols,constant sigmamore
estat endogenous

***留守儿童与非留守儿童组间同伴系数差异检验
//bdiff, group(lbc) model(xi:reg ez_stu_math epeermath peergs peergs bz_stu_math age2 female boarding edu_father_year edu_mother_year lbc stu_asset teaching_age tea_female edu_tea tea_gaoji classsize i.grade i.schoolid) reps(1000) detail //费舍尔组间差异检验
bdiff, group(lbc) model(xi:ivreg2 ez_stu_math (epeermath=peer_edufather peer_edumother) peergs bz_stu_math age2 female boarding edu_father_year edu_mother_year lbc stu_asset teaching_age tea_female edu_tea tea_gaoji classsize i.schoolid) reps(1000) detail
/*
-Permutaion (1000 times)- Test of Group (lbc 0 v.s 1) coeficients difference
   Variables |      b0-b1    Freq     p-value
-------------+-------------------------------
   epeermath |     -0.544     920       0.080     //同伴效应系数检验结果（>0.9或者<0.1均为显著，但方向不同）
      peergs |      0.021     285       0.285
 bz_stu_math |      0.014     389       0.389
        age2 |      0.024     319       0.319
      female |      0.019     375       0.375
    boarding |     -0.023     582       0.418
edu_father~r |      0.001     465       0.465
edu_mother~r |      0.002     409       0.409
         lbc |      0.000     524       0.476
   stu_asset |      0.064      39       0.039
teaching_age |     -0.011     722       0.278
  tea_female |      0.185     232       0.232
     edu_tea |      0.171     154       0.154
   tea_gaoji |      0.136     235       0.235
   classsize |      0.007     304       0.304
       _cons |     -0.940     848       0.152
---------------------------------------------

--------------------------------------------
                      (1)             (2)   
                    lbc_0           lbc_1   
--------------------------------------------
epeermath           0.135           0.678** 
                   (0.58)          (2.19)   
peergs            -0.0106         -0.0314   
                  (-0.42)         (-1.17)   
bz_stu_math         0.499***        0.485***
                  (17.94)         (16.23)   
age2               -0.140***       -0.164***
                  (-4.01)         (-4.10)   
female            -0.0231         -0.0424   
                  (-0.54)         (-0.93)   
boarding          -0.0392         -0.0165   
                  (-0.46)         (-0.19)   
edu_father~r      0.00211        0.000668   
                   (0.27)          (0.08)   
edu_mother~r      0.00894         0.00645   
                   (1.21)          (0.87)      
stu_asset         0.00607         -0.0582** 
                   (0.24)         (-2.11)   
teaching_age      -0.0137        -0.00263   
                  (-1.00)         (-0.19)   
tea_female          0.114         -0.0715   
                   (0.59)         (-0.51)   
edu_tea            0.0609          -0.110   
                   (0.58)         (-0.86)   
tea_gaoji          0.0905         -0.0451   
                   (0.66)         (-0.31)   
classsize         0.00306        -0.00370   
                   (0.36)         (-0.28)   
_cons               0.951           1.891***
                   (1.56)          (2.80)   
--------------------------------------------
r2                  0.447           0.401   
N                    1291            1313   
--------------------------------------------
t statistics in parentheses
* p<0.1, ** p<0.05, *** p<0.01
*/

***留守儿童同伴效应机制分析
sum att if lbc==0
sum att if lbc==1
sum att,d
gen atta=(att>4)
tab atta
reg att lbc
tab att
xi:ivreg2 ez_stu_math (epeermath=peer_edufather peer_edumother) peergs bz_stu_math age2 female boarding edu_father_year edu_mother_year stu_asset teaching_age tea_female edu_tea zhicheng classsize i.grade i.schoolid if atta==0&lbc==1
xi:ivreg2 ez_stu_math (epeermath=peer_edufather peer_edumother) peergs bz_stu_math age2 female boarding edu_father_year edu_mother_year stu_asset teaching_age tea_female edu_tea zhicheng classsize i.grade i.schoolid if atta==1&lbc==1
