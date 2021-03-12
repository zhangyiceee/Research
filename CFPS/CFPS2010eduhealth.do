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


/*
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

*/
*教育对健康的影响及其机制，参照陆毅老师的文章
	use "CFPS2010/cfps2010adult_201906.dta" , clear  

*middle school
	tab qc1,m
	label list qc1
	gen middle =.
	replace middle=1 if qc1>=3
	replace middle=0 if qc1==1 |qc1==2
	label var middle "是否完成初中"
*Total year of schooling 
	gen eduyear =.
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

*Mental health measure
*Q601 最近 1 个月，您感到情绪沮丧、郁闷、做什么事情都不能振奋的频率？
*Q602 最近 1 个月，您感到精神紧张的频率？
*Q603 最近 1 个月，您感到坐卧不安、难以保持平静的频率？
*Q604 最近 1 个月，您感到未来没有希望的频率？
*Q605 最近 1 个月，您做任何事情都感到困难的频率？
*Q606 最近 1 个月，您认为生活没有意义的频率？
	tab1 qq601-qq606,m
	label list qq601
	clonevar depressed=qq601
	clonevar nervous=qq602
	clonevar restless=qq603
	clonevar hopeless=qq604
	clonevar difficult=qq605
	clonevar meaningless=qq606

	foreach x of varlist depressed-meaningless {
		replace `x'=. if `x'<0
	}
	egen mht_index=rowmean(depressed-meaningless)
	label var mht_index "心理健康指数"

*Physical health measure 



*Predetermined characteristics 
*Gender 
	codebook gender


*民族
	label list qa5code
	tab qa5code,m
	gen han=.
	replace han=1 if qa5code==1
	replace han=0 if qa5code>1
	replace han=. if  qa5code==.
	tab han,m

*family background during culture Revolution
	tab qa6,m
*先搁置，不处理

*3岁的时候生活在出生地
	tab qa3,m
	label list qa3
	codebook qa3
	gen live_birth_3=1 if qa3==1
	replace live_birth_3=0 if qa3==0
	label var live_birth_3 "3岁的时候生活在出生地"
*12岁的时候生活在出生地
	tab qa4,m
	gen live_birth_12=1 if qa4==1
	replace live_birth_12=0 if qa4==0
	label var live_birth_12 "12岁的时候生活在出生地"
	tab1 qa4 live_birth_12,m
*3岁时父亲缺失
	label list qa303
	tab qa303,m
	gen fa_absent_3=.
	replace fa_absent_3=1 if qa303>0
	replace fa_absent_3=0 if qa303==0
	tab fa_absent_3,m
	label var fa_absent_3 "3岁时父亲缺失"

*3岁时母亲缺失
	gen mo_absent_3=.
	replace mo_absent_3=1 if qa304>0
	replace mo_absent_3=0 if qa304==0
	tab mo_absent_3,m
	label var mo_absent_3 "3岁时母亲缺失"


*4-12岁时父亲缺失
	tab qa403,m
	gen fa_absent_12=.
	replace fa_absent_12=1 if qa403>0
	replace fa_absent_12=0 if qa403==0
	tab fa_absent_12,m
	label var fa_absent_12 "4-12岁时父亲缺失"


*4-12岁时母亲缺失
	tab qa404,m
	gen mo_absent_12=.
	replace mo_absent_12=1 if qa404>0
	replace mo_absent_12=0 if qa404==0
	tab mo_absent_12,m
	label var mo_absent_12 "4-12岁时母亲缺失"

*父亲受教育年限
	tab tb4_a_f,m
	gen faeduyear=.
	replace faeduyear=0 if tb4_a_f==1
	replace faeduyear=6 if tb4_a_f==2
	replace faeduyear=9 if tb4_a_f==3
	replace faeduyear=12 if tb4_a_f==4
	replace faeduyear=15 if tb4_a_f==5
	replace faeduyear=16 if tb4_a_f==6
	replace faeduyear=19 if tb4_a_f==7
	replace faeduyear=22 if tb4_a_f==8
	replace faeduyear=26 if tb4_a_f==9
	label var faeduyear "父亲受教育年限"
*母亲受教育年限
	tab tb4_a_m,m
	label list tb4_a_m
	gen moeduyear=.
	replace moeduyear=0 if tb4_a_m==1
	replace moeduyear=6 if tb4_a_m==2
	replace moeduyear=9 if tb4_a_m==3
	replace moeduyear=12 if tb4_a_m==4
	replace moeduyear=15 if tb4_a_m==5
	replace moeduyear=16 if tb4_a_m==6
	replace moeduyear=19 if tb4_a_m==7
	replace moeduyear=22 if tb4_a_m==8
	replace moeduyear=26 if tb4_a_m==9
	label var moeduyear "母亲受教育年限"



*父亲在孩子14岁时候的社会经济地位
*母亲在孩子14岁时候的社会经济地位
*父亲在孩子14岁时是否为党员
*母亲在孩子14岁时是否为党员


*



*生成各个省份的受到干预队列的具体时间
	tab provcd,m
	label list provcd

	gen time_yiwu=""
	replace time_yiwu="1sep1970" if provcd==11 
	replace time_yiwu="1sep1970" if provcd==12 
	replace time_yiwu="1sep1970" if provcd==13 
	replace time_yiwu="1sep1970" if provcd==14 
	replace time_yiwu="1sep1972" if provcd==15 
	replace time_yiwu="1sep1970" if provcd==21 
	replace time_yiwu="1sep1970" if provcd==22 
	replace time_yiwu="1sep1970" if provcd==23 
	replace time_yiwu="1sep1969" if provcd==31 
	replace time_yiwu="1sep1970" if provcd==32 
	replace time_yiwu="1sep1969" if provcd==33 
	replace time_yiwu="1sep1971" if provcd==34 
	replace time_yiwu="1sep1972" if provcd==35 
	replace time_yiwu="1sep1969" if provcd==36 
	replace time_yiwu="1sep1970" if provcd==37 
	replace time_yiwu="1sep1970" if provcd==41 
	replace time_yiwu="1sep1970" if provcd==42 
	replace time_yiwu="1sep1975" if provcd==43 
	replace time_yiwu="1sep1970" if provcd==44 
	replace time_yiwu="1sep1975" if provcd==45 
	replace time_yiwu="1sep1975" if provcd==46 
	replace time_yiwu="1sep1970" if provcd==50 
	replace time_yiwu="1sep1969" if provcd==51 
	replace time_yiwu="1sep1971" if provcd==52 
	replace time_yiwu="1sep1970" if provcd==53 
	replace time_yiwu="1sep1978" if provcd==54 
	replace time_yiwu="1sep1971" if provcd==61 
	replace time_yiwu="1sep1974" if provcd==62 
	replace time_yiwu="1sep1972" if provcd==63 
	replace time_yiwu="1sep1970" if provcd==64 
	replace time_yiwu="1sep1971" if provcd==65 


	gen yiwu_date = date(time_yiwu,"DMY")
	format %td yiwu_date
	drop time_yiwu
	label var yiwu_date "各省义务教育法实施时间"

*成人个体出生时间
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
	drop a b birthday


*保留1943-1994年之间的样本
	keep if birth_day >d(1jan1943) & birth_day <d(1jan1994) 
	gen t=birth_day-yiwu_date
	bro birth_day  yiwu_date t
	tab t,m
	gen treat=1 if t >=0
	replace treat=0 if t<0
	label var treat "是否受到干预"
	label define treat 1"law eligibles"0"law ineligibles"
	label values treat treat
	tab treat,m

	order middle eduyear mht_index depressed nervous restless hopeless difficult meaningless gender han live_birth_3 live_birth_12 fa_absent_3 mo_absent_3 fa_absent_12 mo_absent_12 faeduyear moeduyear,after(treat)

	iebaltab middle eduyear mht_index depressed ///
	nervous restless hopeless difficult meaningless ///
	gender han live_birth_3 live_birth_12 fa_absent_3 ///
	mo_absent_3 fa_absent_12 mo_absent_12 faeduyear moeduyear,grpvar(treat)  control(0)  save($outdir/edu_mht.xlsx) replace












	


