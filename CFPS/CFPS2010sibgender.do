*============================================================*
**       		CFPS 
**Goal		:  有兄弟姐妹对孩子认知与非认知的影响 
**Data		:    CFPS2010
**Author	:  	 ZhangYi zhangyiceee@163.com 15592606739
**Created	:  	 20210301
**Last Modified: 202009
*============================================================*
	capture	clear
	capture log close
	set	more off
	set scrollbufsize 2048000
	capture log close 
	


	cd "/Users/zhangyi/Documents/data/CFPS/real_cfps"
	global cleandir "/Users/zhangyi/Desktop/CFPS/兄妹/cleandata"
	global outdir "/Users/zhangyi/Desktop/CFPS/兄妹/output"
	global workingdir "/Users/zhangyi/Desktop/CFPS/兄妹/working"

*调儿童信息数据
	use "CFPS2010/cfps2010child_201906.dta",clear
	tab1  wa102 wa1y wa1m,m
 
*出生年份
	clonevar birth_year =wa1y
 	clonevar birth_month =wa1m
 	replace birth_month=1 if wa1m<0
 	tab birth_year,m

*性别
	codebook gender	
	clonevar male=gender
	label var male "男性=1"

*出生地
	tab wa106,m
	clonevar birth_place=wa107acode
	label var birth_place "出生省份"

*出生体重
	clonevar birth_weight=wa102 if wa102>0
	label var birth_weight "出生体重"


		

use "CFPS2010/cfps2010famconf_report_nat072016.dta",clear
	*家庭关系库，保存女性样本，通过女性来reshape孩子的信息，然后和儿童库匹配起来

	codebook tb2_a_p
	keep if tb2_a_p==0


*保存需要的变量
	keep pid fid cid provcd countyid code_a_p birthy_best code_a_c1-tb5_siops_a_c10

	reshape long alive_a_c code_a_c bio_c co_c pid_c t1_c tb1a_a_c tb1b_a_c tb1m_a_c tb1y_a_c tb2_a_c tb3_a_c tb4_a_c tb501_a_c tb5_code_a_c tb5_isco_a_c tb5_isei_a_c tb5_siops_a_c tb601_a_c tb602acode_a_c tb604_a_c tb6_a_c td7_a_c td7spcode_a_c td8_a_c  ,i(pid) j(j)

	label var j "孩子序号"
	label var code_a_c       "孩子家庭内部编码"
	label var bio_c          "孩子是否是血缘子女"
	label var t1_c           "2010年孩子是否有有效问卷"
	label var pid_c          "2010年孩子样本编码"
	label var tb2_a_c        "孩子性别"
	label var tb1y_a_c       "孩子出生（年）"
	label var tb1m_a_c       "孩子出生（月）"
	label var tb1b_a_c       "2010年孩子年龄"
	label var tb1a_a_c       "孩子属相"
	label var alive_a_c      "2010年孩子是否健在"
	label var tb3_a_c        "2010年孩子婚姻状况"
	label var tb4_a_c        "2010年孩子最高学历"
	label var tb6_a_c        "2010年孩子是否住在家中"
	label var tb604_a_c      "2010年孩子离家时间（月）"
	label var tb601_a_c      "2010年孩子不住在家中原因"
	label var tb602acode_a_c "2010年离家人（孩子）的省国标码"
	label var co_c           "2010年孩子是否同住"
	label var td7_a_c        "2010年孩子（不同住）现居住地"
	label var td7spcode_a_c  "孩子（不同住）外省编码"
	label var td8_a_c        "2010年孩子（不同住）户口类型"
	label var tb5_code_a_c   "2010年孩子主要工作（职业编码）"
	label var tb501_a_c      "2010年孩子有无行政/管理职务"
	label var tb5_isco_a_c   "2010年孩子的职业ISCO88编码"
	label var tb5_isei_a_c   "2010年孩子的职业ISEI得分"
	label var tb5_siops_a_c  "2010年孩子的职业声望得分"



	codebook t1_c
	keep if t1_c==1
	tab tb1y_a_c,m




	sort pid tb1y_a_c
	by pid , sort: gen n1=_n
	rename n1 birth_order
	label var birth_order "出生顺序"

	gen first =0
	replace first =1 if birth_order==1
	label var first "为家中第一个孩子"

	



	reshape wide j-tb5_siops_a_c first ,i(pid) j(birth_order)
	
	gen boy_young =.
	label var boy_young "第一个孩子有1个弟弟"
	replace boy_young=1 if tb2_a_c2==1 | tb2_a_c3==1 | tb2_a_c4==1 | tb2_a_c5==1 | tb2_a_c6==1 | tb2_a_c7==1 | tb2_a_c8==1 | tb2_a_c9==1 
	replace boy_young=0 if tb2_a_c2!=1 & tb2_a_c3!=1 & tb2_a_c4!=1 & tb2_a_c5!=1 & tb2_a_c6!=1 & tb2_a_c7!=1 & tb2_a_c8!=1 & tb2_a_c9!=1

	gen girl_young =.
	label var girl_young "第一个孩子有妹妹"
	replace girl_young=1 if tb2_a_c2==0 | tb2_a_c3==0 | tb2_a_c4==0 | tb2_a_c5==0 | tb2_a_c6==0 | tb2_a_c7==0 | tb2_a_c8==0 | tb2_a_c9==0 
	replace girl_young=0 if tb2_a_c2!=0 & tb2_a_c3!=0 & tb2_a_c4!=0 & tb2_a_c5!=0 & tb2_a_c6!=0 & tb2_a_c7!=0 & tb2_a_c8!=0 & tb2_a_c9!=0


	reshape long alive_a_c code_a_c bio_c co_c pid_c t1_c tb1a_a_c tb1b_a_c tb1m_a_c tb1y_a_c tb2_a_c tb3_a_c tb4_a_c tb501_a_c tb5_code_a_c tb5_isco_a_c tb5_isei_a_c tb5_siops_a_c tb601_a_c tb602acode_a_c tb604_a_c tb6_a_c td7_a_c td7spcode_a_c td8_a_c first  j fid cid provcd countyid code_a_p birthy_best ,i(pid) j(birth_order)
	drop if fid==.

*保留：为家中第一个孩子，且出生年月在儿童样本内
	keep if first==1 & tb1y_a_c>=1995 & tb1y_a_c<=2010 


	rename pid pid_m
	rename pid_c pid 


	merge 1:1 pid using  "CFPS2010/cfps2010child_201906.dta"
	keep if  _merge==3


	tab1 wordtest  boy_young  if gender ==1 //第一个孩子为男性，是否有弟弟
	tab1 wordtest  boy_young  if gender ==0 //第一个孩子为女性，是否有弟弟

	tab1 wordtest  girl_young  if gender ==1 //第一个孩子为男性，是否有妹妹
	tab1 wordtest  girl_young  if gender ==0 //第一个孩子为女性，是否有妹妹


	drop if wordtest==-8
	reg wordtest  boy_young feduc meduc i.countyid if gender ==1
	reg wordtest  boy_young feduc meduc i.countyid if gender ==0

	reg mathtest  boy_young feduc meduc i.countyid if gender ==1
	reg mathtest  boy_young feduc meduc i.countyid if gender ==0

	reg wordtest  girl_young feduc meduc if gender ==1
	reg wordtest  girl_young feduc meduc if gender ==0














