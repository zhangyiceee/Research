*============================================================*
**       		CHNS
**Goal		:  了解中国影响追踪调查数据
**Data		:    CHNS
**Author	:  	 ZhangYi zhangyiceee@163.com 15592606739
**Created	:  	 20201129
**Last Modified: 202009
*============================================================*
	capture	clear
	capture log close
	set	more off
	set scrollbufsize 2048000
	capture log close 
	


	cd "/Users/zhangyi/Desktop/CHNS"

	use "Master_ID_201908/surveys_pub_12.dta",clear



*儿童照管
	use "Master_Childcare_201804/careh_12.dta",clear
	tab WAVE,m
	tostring hhid,replace 

	tab K14_HH,m

	use "Master_Childcare_201804/carec_12.dta",clear

	tab k14a,m


	tab1  k15-k25,m







