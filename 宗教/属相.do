*============================================================*
**       		
**Goal		:    属相不合的影响
**Data		:    CFPS2014
**Author	:  	 ZhangYi zhangyiceee@163.com 15592606739
**Created	:  	 20200918
**Last Modified: 2020
*============================================================*
	capture	clear
	capture log close
	set	more off
	set scrollbufsize 2048000
	capture log close 
	


	cd "/Users/zhangyi/Documents/数据集/CFPS/real_cfps"
	global cleandir "/Users/zhangyi/Desktop/CFPS/属相/cleandata"
	global outdir "/Users/zhangyi/Desktop/CFPS/属相/output"
	global workingdir "/Users/zhangyi/Desktop/CFPS/属相/working"


*夫妻属相的经济学分析
	/*
	分为三类：大吉、忌配、

	
	*/
	use "CFPS2014/cfps2014famconf.dta",clear
	codebook tb1a_a_f tb1a_a_m
	keep if  tb1a_a_f>0 & tb1a_a_m>0
	gen fa_sx="."
	replace fa_sx="鼠" if tb1a_a_f== 1
	replace fa_sx="牛" if tb1a_a_f== 2
	replace fa_sx="虎" if tb1a_a_f== 3
	replace fa_sx="兔" if tb1a_a_f== 4
	replace fa_sx="龙" if tb1a_a_f== 5
	replace fa_sx="蛇" if tb1a_a_f== 6
	replace fa_sx="马" if tb1a_a_f== 7
	replace fa_sx="羊" if tb1a_a_f== 8
	replace fa_sx="猴" if tb1a_a_f== 9
	replace fa_sx="鸡" if tb1a_a_f==10
	replace fa_sx="狗" if tb1a_a_f==11
	replace fa_sx="猪" if tb1a_a_f==12

	gen mo_sx="."
	replace mo_sx="鼠" if tb1a_a_m== 1
	replace mo_sx="牛" if tb1a_a_m== 2
	replace mo_sx="虎" if tb1a_a_m== 3
	replace mo_sx="兔" if tb1a_a_m== 4
	replace mo_sx="龙" if tb1a_a_m== 5
	replace mo_sx="蛇" if tb1a_a_m== 6
	replace mo_sx="马" if tb1a_a_m== 7
	replace mo_sx="羊" if tb1a_a_m== 8
	replace mo_sx="猴" if tb1a_a_m== 9
	replace mo_sx="鸡" if tb1a_a_m==10
	replace mo_sx="狗" if tb1a_a_m==11
	replace mo_sx="猪" if tb1a_a_m==12


	gen jx="." 
	label var jx "婚配是否吉祥"
	replace jx="大吉" if fa_sx=="鼠" & mo_sx=="龙"
	replace jx="大吉" if fa_sx=="鼠" & mo_sx=="猴"
	replace jx="大吉" if fa_sx=="鼠" & mo_sx=="牛"
	replace jx="大忌" if fa_sx=="鼠" & mo_sx=="马"
	replace jx="大忌" if fa_sx=="鼠" & mo_sx=="兔"
	replace jx="大吉" if fa_sx=="牛" & mo_sx=="鼠"
	replace jx="大吉" if fa_sx=="牛" & mo_sx=="蛇"
	replace jx="大吉" if fa_sx=="牛" & mo_sx=="鸡"
	replace jx="大忌" if fa_sx=="牛" & mo_sx=="马"
	replace jx="大忌" if fa_sx=="牛" & mo_sx=="羊"
	replace jx="大忌" if fa_sx=="牛" & mo_sx=="狗"
	replace jx="大吉" if fa_sx=="虎" & mo_sx=="马"
	replace jx="大吉" if fa_sx=="虎" & mo_sx=="狗"
	replace jx="大吉" if fa_sx=="虎" & mo_sx=="猪"
	replace jx="大忌" if fa_sx=="虎" & mo_sx=="蛇"
	replace jx="大忌" if fa_sx=="虎" & mo_sx=="猴"
	replace jx="大吉" if fa_sx=="兔" & mo_sx=="羊"
	replace jx="大吉" if fa_sx=="兔" & mo_sx=="狗"
	replace jx="大吉" if fa_sx=="兔" & mo_sx=="猪"
	replace jx="大忌" if fa_sx=="兔" & mo_sx=="龙"
	replace jx="大忌" if fa_sx=="兔" & mo_sx=="鼠"
	replace jx="大忌" if fa_sx=="兔" & mo_sx=="鸡"
	replace jx="大吉" if fa_sx=="龙" & mo_sx=="鼠"
	replace jx="大吉" if fa_sx=="龙" & mo_sx=="猴"
	replace jx="大吉" if fa_sx=="龙" & mo_sx=="鸡"
	replace jx="大忌" if fa_sx=="龙" & mo_sx=="狗"
	replace jx="大忌" if fa_sx=="龙" & mo_sx=="兔"
	replace jx="大吉" if fa_sx=="蛇" & mo_sx=="猴"
	replace jx="大吉" if fa_sx=="蛇" & mo_sx=="牛"
	replace jx="大吉" if fa_sx=="蛇" & mo_sx=="鸡"
	replace jx="大忌" if fa_sx=="蛇" & mo_sx=="猪"
	replace jx="大忌" if fa_sx=="蛇" & mo_sx=="虎"
	replace jx="大吉" if fa_sx=="马" & mo_sx=="羊"
	replace jx="大吉" if fa_sx=="马" & mo_sx=="虎"
	replace jx="大吉" if fa_sx=="马" & mo_sx=="狗"
	replace jx="大忌" if fa_sx=="马" & mo_sx=="鼠"
	replace jx="大忌" if fa_sx=="马" & mo_sx=="牛"
	replace jx="大吉" if fa_sx=="羊" & mo_sx=="兔"
	replace jx="大吉" if fa_sx=="羊" & mo_sx=="羊"
	replace jx="大吉" if fa_sx=="羊" & mo_sx=="猪"
	replace jx="大吉" if fa_sx=="羊" & mo_sx=="猴"
	replace jx="大忌" if fa_sx=="羊" & mo_sx=="牛"
	replace jx="大忌" if fa_sx=="羊" & mo_sx=="狗"
	replace jx="大吉" if fa_sx=="猴" & mo_sx=="鼠"
	replace jx="大吉" if fa_sx=="猴" & mo_sx=="蛇"
	replace jx="大吉" if fa_sx=="猴" & mo_sx=="龙"
	replace jx="大吉" if fa_sx=="猴" & mo_sx=="狗"
	replace jx="大忌" if fa_sx=="猴" & mo_sx=="虎"
	replace jx="大忌" if fa_sx=="猴" & mo_sx=="猪"
	replace jx="大吉" if fa_sx=="鸡" & mo_sx=="牛"
	replace jx="大吉" if fa_sx=="鸡" & mo_sx=="龙"
	replace jx="大吉" if fa_sx=="鸡" & mo_sx=="蛇"
	replace jx="大忌" if fa_sx=="鸡" & mo_sx=="兔"
	replace jx="大吉" if fa_sx=="狗" & mo_sx=="虎"
	replace jx="大吉" if fa_sx=="狗" & mo_sx=="兔"
	replace jx="大吉" if fa_sx=="狗" & mo_sx=="马"
	replace jx="大忌" if fa_sx=="狗" & mo_sx=="羊"
	replace jx="大忌" if fa_sx=="狗" & mo_sx=="龙"
	replace jx="大忌" if fa_sx=="狗" & mo_sx=="牛"
	replace jx="大吉" if fa_sx=="猪" & mo_sx=="羊"
	replace jx="大吉" if fa_sx=="猪" & mo_sx=="兔"
	replace jx="大吉" if fa_sx=="猪" & mo_sx=="虎"
	replace jx="大忌" if fa_sx=="猪" & mo_sx=="猴"
	replace jx="大忌" if fa_sx=="猪" & mo_sx=="蛇"
	replace jx="中" if jx=="."
	tab jx,m

	label list tb4_a14_p

	tab jx ,gen(a)













