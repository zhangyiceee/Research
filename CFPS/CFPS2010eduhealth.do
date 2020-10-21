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
	


	cd "/Users/zhangyi/Documents/数据集/CFPS/real_cfps"
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


	bro fid code_a_m  pid_m
	label list pid_m
	replace pid_f=. if pid_f<0
	tostring  code_a_f  pid_f ,replace  force
	replace pid_f=fid + code_a_f if pid_f =="."




*成人调用母亲数据
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
	tab qc1,m
























