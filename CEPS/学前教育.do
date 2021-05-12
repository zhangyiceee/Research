*============================================================*
**       		 peer effect
**Goal		:    班级内部学生接受学前教育的溢出效应
**Data		:    CEPS
**Author	:  	 Yi Zhang zhangyiceee@163.com 15592606739
**CoAuthor	:    Yanan Huo
**Created	:  	 20210511
**Last Modified: 2020
*============================================================*

	capture	clear
	capture log close
	set	more off
	set scrollbufsize 2048000
	capture log close 
*===============*
*YIZHANG DATAdir*
*===============*
	cd "/Users/zhangyi/Documents/data/CEPS"
	global cleandir "/Users/zhangyi/Desktop/CEPS/pre_school/cleandata"
	global outdir "/Users/zhangyi/Desktop/CEPS/pre_school/output"
	global working "/Users/zhangyi/Desktop/CEPS/pre_school/workingdata"

*===============*
*YANAN HUO DATA*
*===============*

	use "2014baseline/CEPS基线调查学校数据.dta",clear 
	tab ple1503,m
	codebook ple1503
	gen random =0
	replace random =1 if ple1503==1 & ple1501 !=1 &  ple1502 !=1 &  ple1504 !=1
	label var random "随机分班=1"
	codebook pla23

	keep schids random pla23


	save "$working/master.dta",replace 

*调用学生数据
	use "2014baseline/CEPS基线调查学生数据.dta",clear 

*年龄
	gen age =2014-a02a
	label var age "年龄"
	tab age,m
*年龄的计算还需要再斟酌
*性别
	tab a01,m
	codebook a01
	gen female =.
	replace female =1 if a01==2
	replace female =0 if a01==1
	label var female "女性"
*户口
	gen rural=.
	codebook a06
	replace rural =1 if a06==1
	replace rural =0 if a06==2 | a06==3 |a06==4
	label var rural "农村户口=1"
*民族
	codebook a03 //有缺失项
	gen minority=0
	replace minority=1 if a03>=2 & a03<=5
	tab minority
	replace minority=. if a03==.
	lab var minority "少数民族"
*父母受教育程度
	*父亲
	codebook stfedu
*小学及以下下
	gen fa_edu_p=0
	replace fa_edu_p =1 if stfedu ==1 | stfedu ==2
	tab fa_edu_p,m
	label var fa_edu_p "小学及以下"
*初中
	gen fa_edu_m=0
	replace fa_edu_m =1 if stfedu ==3
	tab fa_edu_m,m
	label var fa_edu_m "初中"
*高中、技术
	gen fa_edu_h=0
	replace fa_edu_h =1 if stfedu ==4 |  stfedu ==5 | stfedu ==6
	tab fa_edu_h,m
	label var fa_edu_h "高中"
*大学及以上
	gen fa_edu_u=0
	replace fa_edu_u =1 if stfedu ==8 |  stfedu ==9 
	tab fa_edu_u,m
	label var fa_edu_u "大学及以上"
	
	foreach x of varlist  fa_edu_p-fa_edu_u {
		replace `x'=. if stfedu==.
	}

*父亲受教育年限
	gen fa_eduyear=.
	replace fa_eduyear=0  if stfedu==1
	replace fa_eduyear=6  if stfedu==2
	replace fa_eduyear=9  if stfedu==3
	replace fa_eduyear=11 if stfedu==4 
	replace fa_eduyear=11 if stfedu==5 
	replace fa_eduyear=12 if stfedu==6
	replace fa_eduyear=15 if stfedu==7
	replace fa_eduyear=16 if stfedu==8
	replace fa_eduyear=19 if stfedu==9
	label var fa_eduyear "父亲受教育年限"
*父受教育在高中及以上
	gen high_f =.
	replace high_f =0 if stfedu >= 0 & stfedu<6
	replace high_f =1 if stfedu >= 6 & stfedu<=9
	label var high_f "父亲受教育程度在高中及以上"

*母亲
*母亲受教育水平
*小学及以下下
	gen me_edu_p=0
	replace me_edu_p =1 if stmedu ==1 | stmedu ==2
	tab me_edu_p,m
	label var me_edu_p "小学及以下"
*初中
	gen me_edu_m=0
	replace me_edu_m =1 if stmedu ==3
	tab me_edu_m,m
	label var me_edu_m "初中"
*高中、技术
	gen me_edu_h=0
	replace me_edu_h =1 if stmedu ==4 |  stmedu ==5 | stmedu ==6
	tab me_edu_h,m
	label var me_edu_h "高中"
*大学及以上
	gen me_edu_u=0
	replace me_edu_u =1 if stmedu ==8 |  stmedu ==9 
	tab me_edu_u,m

	label var me_edu_u "大学及以上"

*母亲受教育年限
	gen mo_eduyear=.
	replace mo_eduyear=0 if stmedu==1
	replace mo_eduyear=6 if stmedu==2
	replace mo_eduyear=9 if stmedu==3
	replace mo_eduyear=11 if stmedu==4 
	replace mo_eduyear=11 if stmedu==5 
	replace mo_eduyear=12 if stmedu==6
	replace mo_eduyear=15 if stmedu==7
	replace mo_eduyear=16 if stmedu==8
	replace mo_eduyear=19 if stmedu==9
	label var mo_eduyear "母亲受教育年限"
*母亲受教育程度在高中及以上
	gen high_m =.
	replace high_m =0 if stmedu >= 0 & stmedu<6
	replace high_m =1 if stmedu >= 6 & stmedu<=9
	label var high_m "母亲受教育程度在高中及以上"

foreach x of varlist  me_edu_p-me_edu_u {
		replace `x'=. if stmedu==.
	}

 *兄弟姐妹个数
	tab1 b0201  b0202 b0203 b0204,m
 
	foreach x of varlist b0201 b0202 b0203 b0204 {
	replace `x' =0 if `x'==.
	}
 
	gen siblings =b0201+ b0202+ b0203+ b0204
	replace siblings =. if b0201==. & b0202==. & b0203==. & b0204==.
	tab siblings,m
*父母关系
	tab1 b1001-b1003,m
	label list  LABL 
	gen problem_family=0
	replace problem_family=1 if b1001==2 &b1002==2 &b1003==1
	replace problem_family=. if b1003==. |b1002==. |b1001==.
	label var problem_family "问题家庭"
	tab problem_family,m
*家庭收入
	tab steco_3c ,gen(house_income)


*接受学前教育的学生
	codebook c01
	gen pre_school=0
	replace pre_school=1 if  c01==1
	label var pre_school "接受了学前教育"
*留级repeater
	codebook c04
	tab c04,m
	gen repeater=0 
	replace repeater=1 if c04 >=1 & c04!=.
*跳级skip
	gen skip=0 
	replace skip =1 if c03>=1 & c03!=.

*总人数
	egen total = count(clsids),by(clsids)
	label var total "班级总人数"

*班级内部接受学前教育的人数
	egen pre_total = total(pre_school),by(clsids)
	label var pre_total "班级内部接受学前教育的人数"

*除了学生本人外的接受学前教育人数
	gen pre_1 =pre_total- pre_school
	label var pre_1 "除了学生本人外班级内学生接受学前教育的比例"


*除了学生本人外的接受学前教育人数比例
	gen pre_ratio=pre_1/(total-1)
	label var pre_ratio "除了学生本人外的接受学前教育人数比例"
	tab pre_ratio,m
	sum pre_ratio

*非认知能力
*Depressed 
	gen Depressed= a1801
*Blue
	gen blue = a1802
*Unhappy 
	gen unhappy =a1803
*Pessimistic 
	gen Pessimistic=a1805
*School life is fulfilling 
*Confident about future 
	gen cofidence=c25
*Social activities: Public enrichment 

*Social activities: Private recreation

*年级的固定效应变量
	tostring grade9 schids,replace force  
	gen group=schids+grade9
	label var group "学校年级固定效应"
	destring grade9 schids group,replace 


*保存数据，与教师数据合并
	
	merge m:1 schids using "$working/master.dta"
	rename _merge merge1 
	label var merge1 "校长与基线学生数据合并"
	save "$working/master_stubase.dta",replace 

*将教师数据分样本
	use "2014baseline/CEPS基线调查班级数据.dta",clear 

	tab hra01,m
	codebook hra01
	*hrc01 hrc02 hrc03 hrc04 hrc05 hrc06 hrc07 hrc08	
	*如果班主任为英语老师，替换英语老师信息
	foreach   x of numlist 1 2 3 4 5 6 7 8{
		replace engb0`x'=hrc0`x' if hra01==3  & engb0`x'==.
	}
	*如果班主任为语文老师，替换语文老师信息

	foreach   x of numlist 1 2 3 4 5 6 7 8{
		replace chnb0`x'=hrc0`x' if hra01==2  & chnb0`x'==.
	}
	*如果班主任为数学老师，替换数学老师信息

	foreach   x of numlist 1 2 3 4 5 6 7 8{
		replace matb0`x'=hrc0`x' if hra01==1 & chnb0`x'==.
	}
	
	keep clsids schids grade9 engb01 engb02 engb03 engb04 engb05 engb06 engb07 engb08 ///
	matb01 matb02 matb03 matb04 matb05 matb06 matb07 matb08 ///
	chnb01-chnb08 hra01 hra02 hra03 hra04 hra05 hra06 hra07 hra08

	rename engb01 sex_1
	rename engb02 year_1
	rename engb03 marr_1
	rename engb04 xueli_1
	rename engb05 shifan_1
	rename engb06 zgz_1
	rename engb07 ty_1
	rename engb08 jl_1
	rename matb01 sex_2
	rename matb02 year_2
	rename matb03 marr_2
	rename matb04 xueli_2
	rename matb05 shifan_2
	rename matb06 zgz_2
	rename matb07 ty_2
	rename matb08 jl_2
	rename chnb01 sex_3
	rename chnb02 year_3
	rename chnb03 marr_3
	rename chnb04 xueli_3
	rename chnb05 shifan_3
	rename chnb06 zgz_3
	rename chnb07 ty_3
	rename chnb08 jl_3
	rename hra01 sex_4
	rename hra02 year_4
	rename hra03 marr_4
	rename hra04 xueli_4
	rename hra05 shifan_4
	rename hra06 zgz_4
	rename hra07 ty_4
	rename hra08 jl_4


	reshape long sex_ year_ marr_ xueli_ shifan_ zgz_ ty_ jl_,i(clsids) j(a) 

	rename sex_  sex
	rename year_  year
	rename marr_  marr
	rename xueli_  xueli
	rename shifan_  shifan
	rename zgz_  zgz
	rename ty_  ty
	rename jl_ jl

	gen subject =""
	replace subject="英语" if a==1
	replace subject="数学" if a==2
	replace subject="语文" if a==3
	replace subject="班主任" if a==4
*性别
	tab sex,m
	codebook sex
	gen tea_female=.
	replace tea_female=1 if sex==2
	replace tea_female=0 if sex==1

*年龄
	tab year,m
	replace year=. if year<1950
	gen tea_age= 2013-year
	tab tea_age,m

*受教育年限
	tab xueli,m
	codebook xueli
	gen tea_school=.
	replace tea_school=11 if xueli==2
	replace tea_school=15 if xueli==4
	replace tea_school=16 if xueli==5
	replace tea_school=16 if xueli==6
	replace tea_school=19 if xueli==7
	label var tea_school "教师受教育年限"
*婚姻状况的虚拟变量
	codebook marr
	tab marr,gen(tea_marr)

*教龄
	tab ty,m
	rename ty tea_jl
	label var tea_jl "教龄"
*教师资格证
	tab zgz,m
	codebook zgz
	gen tea_zgz=.
	replace tea_zgz=1 if zgz==1
	replace tea_zgz=0 if zgz==2
	label var tea_zgz "有教师资格证"
	tab tea_zgz,m
*是否师范毕业
	tab shifan,m
	codebook shifan
	gen tea_shifan=.
	replace tea_shifan=1 if shifan==1
	replace tea_shifan=0 if shifan==2
	label var tea_shifan "是否师范毕业"

*是否在其他学校经历
	codebook jl
	gen tea_preexperience=.
	replace tea_preexperience=1 if jl==2 
	replace tea_preexperience=0 if jl== 1
	label var tea_preexperience "在其他学校有教育经历"

	keep clsids subject tea_age tea_female tea_jl tea_marr1 tea_marr2 tea_marr3 tea_marr4 tea_preexperience tea_school tea_shifan tea_zgz
	
preserve
*语文
	keep if subject=="语文"
	save "$working/tea_chn.dta",replace 
restore 
*数学
preserve
	keep if subject=="数学"
	save "$working/tea_mat.dta",replace 
restore 
*英语
preserve
	keep if subject=="英语"
	save "$working/tea_eng.dta",replace 
restore
*班主任
preserve
	keep if subject=="班主任"
	save "$working/tea_head.dta",replace 
restore

*将学生的数据和老师的进行合并
	use "$working/master_stubase.dta",clear
	merge m:1 clsids using "$working/tea_chn.dta"
	save "$working/stu_chn.dta",replace 

	use "$working/master_stubase.dta",clear
	merge m:1 clsids using "$working/tea_eng.dta"
	save "$working/stu_eng.dta",replace 

	use "$working/master_stubase.dta",clear
	merge m:1 clsids using "$working/tea_mat.dta"
	save "$working/stu_mat.dta",replace 

	use "$working/master_stubase.dta",clear
	merge m:1 clsids using "$working/tea_head.dta"
	save "$working/stu_head.dta",replace 

	use "$working/stu_mat.dta",clear 
	append using "$working/stu_eng.dta"
	append using "$working/stu_chn.dta"

	gen testscore=.
	replace testscore=stdchn if subject=="语文" 
	replace testscore=stdmat if subject=="数学" 
	replace testscore=stdeng if subject=="英语" 


	sort schids grade9 subject
	by schids grade9 subject :egen x1_mean=mean(testscore)
	by schids grade9 subject :egen x1_sd=sd(testscore)
	gen std_test=(testscore-x1_mean)/x1_sd
	label var std_test "标准化成绩"

*学科固定效应
	gen sub=.
	replace sub=1 if subject=="语文" 
	replace sub=2 if subject=="数学" 
	replace sub=3 if subject=="英语"
	label var sub "科目" 


	save "$working/stu_tea_master.dta",replace
	
	*=====================================================================*
	*==============================Analysis===============================*
	*=====================================================================*
	global stucontrol "age female rural minority repeater skip fa_eduyear mo_eduyear house_income2 house_income3"
	global teacontrol "tea_age tea_female tea_jl tea_school  tea_marr2 tea_zgz tea_shifan tea_preexperience"

*Balance Test  应该在前面做
	use "$working/stu_head.dta",clear
	keep if random==1
	global stucontrol "age female rural minority repeater skip fa_eduyear mo_eduyear house_income2 house_income3"
	global teacontrol "tea_age tea_female tea_jl tea_school  tea_marr2 tea_zgz tea_shifan tea_preexperience"

	iebaltab $stucontrol ,grpvar(pre_school) save($outdir/balance.xlsx) replace
	
	areg pre_ratio pre_school $stucontrol ,absorb(group) cluster(group) r
	outreg2 using "$outdir/balance.doc",   replace  addtext(School-grade FE,YES)  addstat(F-test,e(F),Prob>F,e(p),adjust R2,e(r2_a))
	areg cog3pl pre_ratio pre_school $stucontrol,absorb(group) cluster(clsids) r
	areg cog3pl pre_ratio pre_school $stucontrol,absorb(group) cluster(clsids) r
	outreg2  using "$outdir/cog",adjr2 keep(pre_ratio pre_school) addtext(School-grade FE,YES,Student Controls,Yes) word excel tex replace 
	*areg cog3pl pre_ratio pre_school $stucontrol tea_age tea_female tea_jl tea_school  tea_marr2 tea_zgz tea_shifan tea_preexperience,absorb(group) cluster(clsids) r
	*outreg2  using "$outdir/nocog",adjr2 keep(pre_ratio pre_school) addtext(School-grade FE,YES,Student Controls,Yes) word excel tex replace 
	
	areg Depressed pre_ratio pre_school $stucontrol,absorb(group) cluster(clsids) r
	outreg2  using "$outdir/nocog",adjr2 keep(pre_ratio pre_school) addtext(School-grade FE,YES,Student Controls,Yes) word excel tex replace  
	areg blue pre_ratio pre_school $stucontrol,absorb(group) cluster(clsids) r
	outreg2  using "$outdir/nocog",adjr2 keep(pre_ratio pre_school) addtext(School-grade FE,YES,Student Controls,Yes) word excel tex append 
	areg unhappy pre_ratio pre_school $stucontrol,absorb(group) cluster(clsids) r
	outreg2  using "$outdir/nocog",adjr2 keep(pre_ratio pre_school) addtext(School-grade FE,YES,Student Controls,Yes) word excel tex append 
	areg Pessimistic pre_ratio pre_school $stucontrol,absorb(group) cluster(clsids) r
	outreg2  using "$outdir/nocog",adjr2 keep(pre_ratio pre_school) addtext(School-grade FE,YES,Student Controls,Yes) word excel tex append 
	areg cofidence pre_ratio pre_school $stucontrol,absorb(group) cluster(clsids) r
	outreg2  using "$outdir/nocog",adjr2 keep(pre_ratio pre_school) addtext(School-grade FE,YES,Student Controls,Yes) word excel tex append 


*对考试成绩的影响
	use "$working/stu_tea_master.dta",clear
*保留随机分班样本
	keep if random==1
*学生层面固定效应
	areg std_test pre_ratio pre_school   i.sub ,absorb(group) cluster(clsids) r
	outreg2  using "$outdir/std_test",adjr2 keep(pre_ratio pre_school) addtext(Subject FE,YES,School-grade FE,YES,Student Controls,No,Teacher Controls,No) word excel tex replace 
	areg std_test pre_ratio pre_school $stucontrol  i.sub ,absorb(group) cluster(clsids) r
	outreg2  using "$outdir/std_test",adjr2 keep(pre_ratio pre_school) addtext(Subject FE,YES,School-grade FE,YES,Student Controls,Yes,Teacher Controls,No) word excel tex append
	areg std_test pre_ratio pre_school $stucontrol $teacontrol i.sub ,absorb(group) cluster(clsids) r
	outreg2  using "$outdir/std_test",adjr2 keep(pre_ratio pre_school) addtext(Subject FE,YES,School-grade FE,YES,Student Controls,Yes,Teacher Controls,Yes) word excel tex append 
	


	







