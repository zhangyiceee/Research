*============================================================*
**       		CFPS 
**Goal		:  The impact of parent's education on people's health 
**来自高校扩招的证据
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
	


	cd "/Users/zhangyi/Documents/数据集/CFPS/real_cfps"
	global cleandir "/Users/zhangyi/Desktop/CFPS/教育健康/cleandata"
	global outdir "/Users/zhangyi/Desktop/CFPS/教育健康/output"
	global workingdir "/Users/zhangyi/Desktop/CFPS/教育健康/working"

*调信息数据
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
	
	gen birthday=a + b
	bro birthday* a b
	gen birthday_1=date(birthday,"YM")
	format %td birthday_1
	rename birthday_1 birth_day
	label var birth_day "出生日期"
	keep if birth_day > d(01sep1971) & birth_day < d(01sep1991)
	tab qc1,m














