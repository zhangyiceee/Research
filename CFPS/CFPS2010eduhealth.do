*============================================================*
**       		CFPS 
**Goal		:  The impact of parent's education on children's health 
**Data		:    CFPS2014
**Author	:  	 ZhangYi zhangyiceee@163.com 15592606739
**Created	:  	 20200928
**Last Modified: 202009
*============================================================*
	capture	clear
	capture log close
	set	more off
	set scrollbufsize 2048000
	capture log close 
	


	cd "/Users/zhangyi/Documents/data/CFPS/real_cfps"
	global cleandir "/Users/zhangyi/Desktop/CFPS/教育健康/cleandata"
	global outdir "/Users/zhangyi/Desktop/CFPS/教育健康/output"
	global workingdir "/Users/zhangyi/Desktop/CFPS/教育健康/working"


/*------------------------- 
To Do:
1.first  清理孩子的特征变量
出生体重、性别、出生年月、出生地、母亲编码
2.second  清理母亲相关变量
受教育程度、出生年月
3.third  清理父亲的受教育程度
-------------------------*/ 

*调儿童信息数据
	use "CFPS2010/cfps2010child_201906.dta",clear
	tab1  wa102 wa1y wa1m,m
 
*出生年份
	clonevar birth_year =wa1y
 	clonevar birth_month =wa1m
 	replace birth_month=1 if wa1m<0


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

*母亲的编码
	bro fid code_a_m  pid_m
	label list pid_m
	replace pid_m=. if pid_m<0
	tostring  fid code_a_m  pid_m ,replace  force
	replace pid_m=fid+code_a_m if pid_m =="."
	rename pid pid_child
	rename pid_m pid
	destring pid,replace force

	bro fid code_a_m  
	label list pid_m
	replace pid_f=. if pid_f<0
	tostring  code_a_f  pid_f ,replace  force
	replace pid_f=fid + code_a_f if pid_f =="."

	keep pid pid_child pid_f  birth_year birth_month male birth_place birth_weight
	save "$workingdir/child_10.dta",replace 



*成人调用成人母亲数据
	use "CFPS2010/cfps2010adult_201906.dta",clear

	*出生年月
	tab1 qa1y_best qa1m,m
	drop if qa1m <0 //删掉月份缺失的样本

	gen a= qa1y_best
	gen b=qa1m
	tostring a b,replace 
	replace b="jan" if qa1m==1
	replace b="feb" if qa1m==2
	replace b="mar" if qa1m==3
	replace b="apr" if qa1m==4
	replace b="may" if qa1m==5
	replace b="jun" if qa1m==6
	replace b="jul" if qa1m==7
	replace b="aug" if qa1m==8
	replace b="sep" if qa1m==9
	replace b="oct" if qa1m==10
	replace b="nov" if qa1m==11
	replace b="dec" if qa1m==12
	gen birthday = a + b
	bro birthday* a b
	gen birthday_1 = date(birthday,"YM")
	format %td birthday_1
	rename birthday_1 birth_day
	label var birth_day "出生日期"
	tab1 qc1 birth_day,m
	
*户口
	codebook urban


*母亲受教育程度

	tab qc1,m
	label list qc1
	gen eduyear=.
	replace eduyear=0 if qc1==0
	replace eduyear=0 if qc1==1
	replace eduyear=6 if qc1==2
	replace eduyear=9 if qc1==3
	replace eduyear=12 if qc1==4
	replace eduyear=15 if qc1==5
	replace eduyear=16 if qc1==6
	replace eduyear=19 if qc1==7
	replace eduyear=22 if qc1==8
	replace eduyear=26 if qc1==9
	label var eduyear "受教育年限"


	keep pid birth_day urban eduyear qa2 qq601-qq606 qc104 qc105 qc204 qc205 qc304 qc305 qc404 qc405 qc502 qc503
	
preserve
*生成干预状态1
	gen t=1 if birth_day>d(01jan1970) & birth_day<d(01jan1981) 
	replace t=0 if birth_day<d(01jan1990)   & birth_day>=d(01jan1981)
	label var t "干预状态"	
	keep if eduyear >=12 //高中以上学历的样本

	gen a ="1981sep01"
	gen time =date(a,"YMD")
	format %td time
	drop a 
	label var time "政策干预时点"	
	gen time1 = birth_day-time
	label var time1 "时间段"

	keep if birth_day > d(01sep1971) & birth_day < d(01sep1991)
	tab time1,m
	keep if eduyear >=12 & eduyear !=.

	cmogram eduyear time1  if time1>-2000 &time1< 2000 , ///
		scatter cut(0) lineat(0) lfit ci(95) histopts(bin(25))

	binscatter eduyear time1  if time1>-2000 &time1< 2000 ,rd(0) n(100) linetype(lfit)

	label data "按照出生日期计算干预状态"
	save "$workingdir/adult1.dta",replace 

restore

*干预的生成，因为从高中毕业年限进行推断，而不能从生日往前推，应该是具体的高中毕业年份
	tab qc502,m

	keep if qc502 >=1989 & qc502<=2009
	gen t=1 if qc502>=1999
	replace  t=0 if qc502<1999
	label var t "干预状态"
	gen time =qc502-1999
	tab time,m
	label var time "时间段"
	cmogram eduyear time  if time>-10 &time< 10 &urban ==0 , ///
		scatter cut(0) lineat(0) lfit ci(95) histopts(bin(25))




	

	foreach x of numlist 601/606{
		clonevar m`x'=qq`x'
	}

	recode m601 (1=5)(2=4)(3=3)(4=2)(5=1)
	recode m602 (1=5)(2=4)(3=3)(4=2)(5=1)
	recode m603 (1=5)(2=4)(3=3)(4=2)(5=1)
	recode m604 (1=5)(2=4)(3=3)(4=2)(5=1)
	recode m605 (1=5)(2=4)(3=3)(4=2)(5=1)
	recode m606 (1=5)(2=4)(3=3)(4=2)(5=1)

	lowess eduyear 

	cmogram m601 time1  if time1>-2000 &time1< 2000 , ///
		scatter cut(0) lineat(0) lfit ci(95) histopts(bin(25))
	cmogram m602 time1  if time1>-2000 &time1< 2000 , ///
		scatter cut(0) lineat(0) lfit ci(95) histopts(bin(25))
	cmogram m603 time1  if time1>-2000 &time1< 2000 , ///
		scatter cut(0) lineat(0) lfit ci(95) histopts(bin(25))
	cmogram m604 time1  if time1>-2000 &time1< 2000 , ///
		scatter cut(0) lineat(0) lfit ci(95) histopts(bin(25))
	cmogram m605 time1  if time1>-2000 &time1< 2000 , ///
		scatter cut(0) lineat(0) lfit ci(95) histopts(bin(25))
	




	binscatter m601 time1  if time1>-2000 &time1< 2000 ,rd(0) n(100) linetype(lfit)






		














