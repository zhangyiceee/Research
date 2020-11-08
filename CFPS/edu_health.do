*============================================================*
**       		CFPS 
**Goal		:  The impact of parent's education on children's health
**Data		:    CFPS2010-CFPS2018
**Author	:  	 ZhangYi zhangyiceee@163.com 15592606739
**Created	:  	 20200026
**Last Modified: 20200926
*============================================================*
	capture	clear
	capture log close
	set	more off
	set scrollbufsize 2048000
	capture log close 
	


	cd "/Users/zhangyi/Documents/数据集/CFPS/real_cfps"
	global cleandir "/Users/zhangyi/Desktop/CFPS/教育健康/cleandata"
	global outdir "/Users/zhangyi/Desktop/CFPS/教育健康/output"
	global workingdir "/Users/zhangyi/Desktop/CFPS/教育健康/working"




*2016年儿童数据库
	use "CFPS2016/cfps2016child_201906.dta",clear

	keep pid cfps_birthy cfps_gender pa101 pa701code wa103 wa104 pid_m
	foreach v of varlist cfps_birthy cfps_gender pa101 pa701code wa103 wa104{
		rename `v' `v'_16 
	}
	save "$workingdir/cfps2016_child.dta",replace 

*2014年儿童数据库
	use "CFPS2014/cfps2014child.dta",clear
	keep pid cfps_birthy cfps_gender wa102 wa103 wa104	wa6code pid_m
	foreach v of varlist cfps_birthy cfps_gender wa102 wa103 wa104 wa6code {
	rename `v' `v'_14
	}
	save "$workingdir/cfps2014_child.dta",replace 
*2012年儿童数据库
	use "CFPS2012/cfps2012child_201906.dta",clear
	keep pid gender2 wa102 cfps_minzu wa103 wa104 cfps2012_birthy_best pid_m
	foreach v of varlist gender2 wa102 cfps_minzu wa103 wa104 cfps2012_birthy_best{
		rename `v' `v'_12
	}
	save "$workingdir/cfps2012_child.dta",replace 


*2010年儿童数据库
	use "CFPS2010/cfps2010child_201906.dta",clear
	keep pid wa1y wa1m wa102 wa103 wa104 gender wa6code pid_m
	foreach v of varlist wa1y wa1m wa102 wa103 wa104 gender wa6code {
		rename `v' `v'_10
	}

	save "$workingdir/cfps2010_child.dta",replace 

*合并各个年份的数据
	use "$workingdir/cfps2016_child.dta",clear
	foreach x of numlist  4 2 0 {
		merge 1:1 pid using "$workingdir/cfps201`x'_child.dta"
		rename _merge merge`x'
	}

*清理性别变量	
	
	rename cfps_gender_16 gender_16
	rename cfps_gender_14  gender_14
	rename gender2_12  gender_12

*2018年性别编码是：1男 5女
*2016、14、12、10年性别编码是：1男 0女
	gen male =.
	foreach x of varlist gender_16 gender_14  gender_12 gender_10 {
		replace male =1 if `x'==1
		replace male =0 if `x'==0
	}
	bro gender*  male
	tab male,m
	label var male "男性=1 女性=0"

*出生年月
	clonevar birth_y16 =cfps_birthy_16
	clonevar birth_y14 =cfps_birthy_14
	clonevar birth_y12 =cfps2012_birthy_best
	clonevar birth_y10 =wa1y_10

*合并出生年份 在回归中加入年份固定效应
	gen birth_y =.
	foreach x of varlist birth_y* {
		replace birth_y=`x' if `x' !=. & birth_y==.
	}
	tab birth_y,m

*出生体重

	clonevar bw_16 = pa101_16 if pa101_16>0 
	clonevar bw_14 = wa102_14 if wa102_14>0 
	clonevar bw_12 = wa102_12 if wa102_12>0 
	clonevar bw_10 = wa102_10 if wa102_10>0 
	tab1 bw*,m
	bro bw*

	label var bw_16 "出生体重16年"
	label var bw_14 "出生体重14年"
	label var bw_12 "出生体重12年"
	label var bw_10 "出生体重10年"
	foreach x of varlist bw* {
		replace `x'=0 if `x' < 0 |`x' == .
	}
	egen birth_weight=rowtotal(bw*)
	replace birth_weight = . if birth_weight==0
	label var birth_weight "出生体重"
	tab birth_weight,m
	sort birth_weight
	gen weight_data=.
	foreach x of numlist  16 14 12 10 {
		replace weight_data=`x' if bw_`x' >0
	}
	label var weight_data  "出生体重数据来源"
	bro bw* birth_weight weight_data

*民族
	bro  pa701code_16 wa6code_14 cfps_minzu_12 wa6code_10
	clonevar newmz_16 = pa701code_16 if pa701code_16 >0
	clonevar newmz_14 = wa6code_14 if wa6code_14 >0
	clonevar newmz_10 = wa6code_10 if wa6code_10 >0

	gen minzu =0
	replace minzu=1 if newmz_16==1 |newmz_14==1 | newmz_10==1
	replace minzu=. if newmz_16==. &newmz_14==. & newmz_10==.
	bro newmz* minzu

*把孩子的出生年月确定下来
	save  "$workingdir/cfps_child_all.dta",replace 


	use  "$workingdir/cfps_child_all.dta",clear 
	keep  pid birth_weight weight_data minzu male
	merge 1:1 pid using "CFPS2016/cfps2016famconf_201804.dta"
	keep if _merge==3
	keep pid pid_m pid_f male minzu tb1y_a_p tb1m_a_p birth_weight weight_data tb1y_a_m tb1m_a_m tb4_a16_m
	rename tb1y_a_m b_m_y
	rename tb1m_a_m b_m_m
	rename tb4_a16_m mo_eu
	
	keep if b_m_y!=. & birth_weight!=. & mo_eu>0 

	gen d=1981 
	gen t=b_m_y-1981
	tab t,m

	tab mo_eu,m
	label list tb4_a16_m
	gen mo_eu_year=.
	replace mo_eu_year =0 if mo_eu==1
	replace mo_eu_year =6 if mo_eu==2
	replace mo_eu_year =9 if mo_eu==3
	replace mo_eu_year =12 if mo_eu==4
	replace mo_eu_year =15 if mo_eu==5
	replace mo_eu_year =16 if mo_eu==6
	replace mo_eu_year =19 if mo_eu==7
	replace mo_eu_year =22 if mo_eu==8
	tab mo_eu_year,m

	*2500克至4000克
	gen low=0
	replace low=1 if birth_weight <5
	gen high=0 
	replace high=1 if birth_weight >8
	tab1 high low

	keep if mo_eu_year>=12
	reg birth_weight mo_eu_year 
	ivreg2 birth_weight male  (mo_eu_year= t) if t<=8 & t>=-8
	ivreg2 low male  (mo_eu_year= t) if t<=8 & t>=-8



	save "$workingdir/family_guanxi.dta",replace


*合并10-16年成人数据库
	*母亲的信息		
	use "CFPS2010/cfps2010adult_201906.dta",clear
	keep pid  qa1y_best qa1m qc1 male 

	rename qa1y_best b_y_10
	rename qa1m b_m_10
	rename qc1 edu_10
	save "$workingdir/adult10.dta",replace


	use "CFPS2012/cfps2012adult_201906.dta",clear
	keep pid cfps2011_latest_edu 
	rename cfps2011_latest_edu edu_12
	save "$workingdir/adult12.dta",replace
	

	use "CFPS2014/cfps2014adult.dta",clear
	keep pid 


