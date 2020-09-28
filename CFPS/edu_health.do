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

*2018年数据
*合并多期数据，保证父母出生地的信息完全准确 受教育程度
	use "CFPS2018/cfps2018person_201911.dta",clear  
	tab age,m
	keep pid 


	use "CFPS2018/cfps2018childproxy.dta",clear

*2018年儿童数据库性别、出生年、民族 出生体重 现在的体重
	use "CFPS2018/cfps2018childproxy.dta",clear

	keep pid gender wa701code  birthw wa101 wa104 wa103 bmi ibirthy_update
	foreach v of varlist gender wa701code  birthw wa101 wa104 wa103 bmi ibirthy_update{
		rename `v' `v'_18
	}

	save "$workingdir/cfps2018_child.dta",replace 

*2016年儿童数据库
	use "CFPS2016/cfps2016child_201906.dta",clear
	keep pid cfps_birthy cfps_gender pa101 pa701code wa103 wa104
	foreach v of varlist cfps_birthy cfps_gender pa101 pa701code wa103 wa104{
		rename `v' `v'_16 
	}
	save "$workingdir/cfps2016_child.dta",replace 

*2014年儿童数据库
	use "CFPS2014/cfps2014child.dta",clear
	keep pid cfps_birthy cfps_gender wa102 wa103 wa104	wa6code
	foreach v of varlist cfps_birthy cfps_gender wa102 wa103 wa104 wa6code {
	rename `v' `v'_14
	}
	save "$workingdir/cfps2014_child.dta",replace 
*2012年儿童数据库
	use "CFPS2012/cfps2012child_201906.dta",clear
	keep pid gender2 wa102 cfps_minzu wa103 wa104 cfps2012_birthy_best
	foreach v of varlist gender2 wa102 cfps_minzu wa103 wa104 cfps2012_birthy_best{
		rename `v' `v'_12
	}
	save "$workingdir/cfps2012_child.dta",replace 



*2010年儿童数据库
	use "CFPS2010/cfps2010child_201906.dta",clear
	keep pid wa1y wa1m wa102 wa103 wa104 gender wa6code
	foreach v of varlist wa1y wa1m wa102 wa103 wa104 gender wa6code {
		rename `v' `v'_10
	}

	save "$workingdir/cfps2010_child.dta",replace 

*合并各个年份的数据
	use "$workingdir/cfps2018_child.dta",clear
	foreach x of numlist 6 4 2 0 {
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
	replace male = 1 if gender_18==1
	replace male = 0 if gender_18==5
	foreach x of varlist gender_16 gender_14  gender_12 gender_10 {
		replace male =1 if `x'==1
		replace male =0 if `x'==0
	}
	bro gender*  male
	tab male,m
	label var male "男性=1 女性=0"

*出生年月
	clonevar birth_y18 =ibirthy_update_18
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
	clonevar bw_18 = wa101_18 if wa101_18>0 
	clonevar bw_16 = pa101_16 if pa101_16>0 
	clonevar bw_14 = wa102_14 if wa102_14>0 
	clonevar bw_12 = wa102_12 if wa102_12>0 
	clonevar bw_10 = wa102_10 if wa102_10>0 
	tab1 bw*,m
	bro bw*
	label var bw_18 "出生体重18年"
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
	foreach x of numlist 18 16 14 12 10 {
		replace weight_data=`x' if bw_`x' >0
	}
	label var weight_data  "出生体重数据来源"
	bro bw* birth_weight weight_data

*民族
	bro wa701code pa701code_16 wa6code_14 cfps_minzu_12 wa6code_10
	clonevar newmz_18 = wa701code if wa701code >0
	clonevar newmz_16 = pa701code_16 if pa701code_16 >0
	clonevar newmz_14 = wa6code_14 if wa6code_14 >0
	clonevar newmz_10 = wa6code_10 if wa6code_10 >0

	gen minzu =0
	replace minzu=1 if newmz_18==1 |newmz_16==1 |newmz_14==1 | newmz_10==1
	replace minzu=. if newmz_18==. &newmz_16==. &newmz_14==. & newmz_10==.
	bro newmz* minzu
	save  "$workingdir/cfps_child_all.dta",replace 

*===================合并各个年份的家庭关系库=============*
*===================合并各个年份的家庭关系库=============*
*===================合并各个年份的家庭关系库=============*
	use "CFPS2018/cfps2018famconf_202008.dta" , clear  
	keep pid 

	*出生年月
	gen birth_year18=.
	replace birth_year18 =




	*出生地




	*最高受教育程度






*===================合并各个年份的成人数据库=============*
*===================合并各个年份的成人数据库=============*
*===================合并各个年份的成人数据库=============*
*目的是：构造成年人数据库，出生地出生年月 和 最高受教育程度
	use "CFPS2018/cfps2018person_201911.dta",clear
	rename 


