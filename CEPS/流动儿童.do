*============================================================*
**       		 peer effect
**Goal		:    parent's job loss on children's academic performence
**Data		:    CEPS
**Author	:  	 ZhangYi zhangyiceee@163.com 15592606739
**Created	:  	 20201011
**Last Modified: 2020
*============================================================*

	capture	clear
	capture log close
	set	more off
	set scrollbufsize 2048000
	capture log close 
	

*具体文章信息DOI：10.1016/j.econlet.2015.10.025
	cd "/Users/zhangyi/Documents/数据集/CEPS"
	global cleandir "/Users/zhangyi/Desktop/CEPS/problem_family/cleandata"
	global outdir "/Users/zhangyi/Desktop/CEPS/problem_family/output"
	global working "/Users/zhangyi/Desktop/CEPS/problem_family/workingdata"



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
	gen  age =2014-a02a
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
	replace fa_eduyear=0 if stfedu==1
	replace fa_eduyear=6 if stfedu==2
	replace fa_eduyear=9 if stfedu==3
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

*总人数
	egen total = count(clsids),by(clsids)
	label var total "班级总人数"
	bro  clsids total
	
*问题家庭人数
	egen pro_total = count(problem_family),by(clsids)
	label var pro_total "问题家庭数量"
	gen ratio =pro_total/total
	label var ratio "问题家庭比例"

	gen fix_grade= schids + grade9

*流动儿童比例
	tab a05 if total <=20
	tab a05 if total <=30 & total>20
	tab a05 if total <=40 & total>30
	tab a05 if total <=50 & total>40
	tab a05 if total <=60 & total>50
	tab a05 if total >=60


	codebook a05
	gen migrant=0
	replace migrant=1 if a05==2 & rural==1
	replace migrant=. if a05==. 
	label var migrant "流动儿童"
	egen mig_total = count(migrant),by(clsids)
	label var mig_total "班级内流动儿童的人数"

	gen mig_ratio =mig_total/total
	label var mig_ratio "班级内流动儿童比例"
	tab mig_ratio,m

	merge m:1 schids using "$working/master.dta"
	
	codebook pla23

	keep if random==1 & (pla23==1|pla23==2)

	egen miss=rowmiss(  mig_ratio age female rural minority fa_eduyear mo_eduyear siblings house_income1  schids)
	tab miss
	keep if miss==0



*班级内流动儿童比例对认知的影响
	areg stdchn mig_ratio age female rural minority fa_eduyear mo_eduyear siblings house_income1 ,absorb(fix_grade) cluster(schids) r
	areg stdmat mig_ratio age female rural minority fa_eduyear mo_eduyear siblings house_income1 ,absorb(fix_grade) cluster(schids) r
	areg stdeng mig_ratio age female rural minority fa_eduyear mo_eduyear siblings house_income1 ,absorb(fix_grade) cluster(schids) r
	areg cog3pl mig_ratio age female rural minority fa_eduyear mo_eduyear siblings house_income1 ,absorb(fix_grade) cluster(schids) r




*问题家庭比例的影响
	tab ratio,m
	areg stdchn ratio age female rural minority fa_eduyear mo_eduyear siblings ,absorb(fix_grade) cluster(schids) r
	areg stdmat ratio age female rural minority fa_eduyear mo_eduyear siblings ,absorb(fix_grade) cluster(schids) r
	areg stdeng ratio age female rural minority fa_eduyear mo_eduyear siblings ,absorb(fix_grade) cluster(schids) r
	areg cog3pl ratio age female rural minority fa_eduyear mo_eduyear siblings ,absorb(fix_grade) cluster(schids) r


