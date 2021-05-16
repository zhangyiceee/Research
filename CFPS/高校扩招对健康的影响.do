*============================================================*
**       		CFPS 
**Goal		:  高校扩招对个体的影响
**Data		:    CFPS201
**Author	:  	 ZhangYi zhangyiceee@163.com 15592606739
**Created	:  	 20210106
**Last Modified: 
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



*成人调用成人数据
	use "CFPS2010/cfps2010adult_201906.dta",clear
*哪一年高中毕业？
	tab qc502
	gen high=.
	replace 

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










