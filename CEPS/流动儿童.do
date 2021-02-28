*============================================================*
**       		 peer effect
**Goal		:    班级内部流动儿童比例对学生健康危险行为的影响
**Data		:    CEPS
**Author	:  	 Yi Zhang zhangyiceee@163.com 15592606739
**CoAuthor	:    Yanan Huo
**Created	:  	 20210228
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
	global cleandir "/Users/zhangyi/Desktop/CEPS/problem_family/cleandata"
	global outdir "/Users/zhangyi/Desktop/CEPS/problem_family/output"
	global working "/Users/zhangyi/Desktop/CEPS/problem_family/workingdata"

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
	*bro  clsids total
	
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
	replace migrant=1 if a05==2 
	replace migrant=. if a05==. 
	label var migrant "流动儿童"
	egen mig_total = count(migrant),by(clsids)
	label var mig_total "班级内流动儿童的人数"
*除学生本人外流动儿童的比例
	gen mig_minus_self=mig_total-migrant
	label var mig_minus_self "除学生本人外流动儿童的人数"


	gen mig_ratio =mig_total/total
	label var mig_ratio "班级内流动儿童比例"
	tab mig_ratio,m

	gen mig_minus_self_ratio =mig_minus_self/(total-1)
	label var mig_minus_self_ratio "除学生本人外流动儿童的比例"

*五个朋友中流动儿童
	gen fre_mig=0
	replace fre_mig=1 if c20c1==2 |c20c2==2 |c20c3==2 |c20c4==2 |c20c5==2
	replace fre_mig=. if c20c1==. &c20c2==. &c20c3==. &c20c4==. &c20c5==2
	label var fre_mig "五个好朋友中有流动儿童"


	merge m:1 schids using "$working/master.dta"
	rename _merge merge1 
	label var merge1 "校长与基线学生数据合并"
	save "$working/master_stubase.dta",replace 

	use "2015年/cepsw2studentCN.dta" , clear  
	/*打架*/
   	gen fight=w2d0203
	recode fight(1=0)(2=1)(3=1)(4=1)(5=1)
	label var fight "打架"
	ta fight,mi

	 
	/*抽烟、喝酒*/
    gen drink=w2d0209
	recode drink(1=0)(2=1)(3=1)(4=1)(5=1)
	label var drink "吸烟喝酒"
	ta drink,mi
	
	***欺负弱小同学（0=无 1=有）
    tab w2d0204,m
    tab w2d0204,nolabel

    gen beh_qifu=w2d0204
    replace beh_qifu=0 if w2d0204==1
    replace beh_qifu=1 if w2d0204==2 | w2d0204==3 | w2d0204==4 | w2d0204==5
	
	/*出入网吧、游戏厅*/
    gen go_webcafes=w2d0210
	recode go_webcafes (1=0)(2=1)(3=1)(4=1)(5=1)
	label var go_webcafes "出入网吧和游戏厅"
	ta go_webcafes,m
	
	
	/*接吻及更亲密的异性身体接触行为*/
	gen body_contact=.
	replace body_contact=0 if w2d0602==0 | w2d0603==0
	replace body_contact=1 if w2d0602==1 | w2d0603==1
	label var body_contact "接吻及更亲密的接触行为"
	ta body_contact,m

    /*谈恋爱行为*/
	
	gen love=.
	replace love=0 if w2d05==2
	replace love=1 if w2d05==1
	label var love "早恋"
	ta love,m	


	keep ids fight-love
	save "$working/stu_end.dta",replace 

	merge 1:1 ids using "$working/master_stubase.dta"

*保留merge上的样本、随机分班的样本
	keep if _merge==3 & random==1

*张：你跑一下结果，我自己感觉结果并不是很好




