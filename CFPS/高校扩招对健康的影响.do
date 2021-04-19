*============================================================*
**       		CFPS 
**Goal		:  高校扩招对健康的影响
**Data		:    CFPS2010
**Author	:  	 ZhangYi zhangyiceee@163.com 15592606739
**Created	:  	 20210106
**Last Modified: 
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
	*bro birthday* a b
	gen birthday_1 = date(birthday,"YM")
	format %td birthday_1
	rename birthday_1 birth_day
	label var birth_day "出生日期"
	tab1 qc1 birth_day,m
	drop a b
*户口
	codebook urban


*受教育程度

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


*干预的生成，因为从高中毕业年限进行推断，而不能从生日往前推，应该是具体的高中毕业年份
	tab qc502,m

	keep if qc502 >=1989 & qc502<=2009
	gen t=1 if qc502>=1999
	replace  t=0 if qc502<1999
	label var t "干预状态"
	gen time =qc502-1999
	tab time,m
	label var time "时间段"
	cmogram eduyear time  if time>-5 &time< 5  , ///
		scatter cut(0) lineat(0) lfit ci(95) histopts(bin(25))
，



	

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





		














