*============================================================*
**       		CFPS 
**Goal		:  The impact of parent's education on children's health 
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

*调用父母信息数据
	use "CFPS2012/cfps2012adult_201906.dta",clear