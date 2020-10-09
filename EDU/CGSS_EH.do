*============================================================*
**       		CGSS 
**Goal		:  The impact of education on people's health-高校扩招的证据
**Data		:    CFPS2010-CFPS2018
**Author	:  	 ZhangYi zhangyiceee@163.com 15592606739
**Created	:  	 20201009
**Last Modified: 20200
*============================================================*
	capture	clear
	capture log close
	set	more off
	set scrollbufsize 2048000
	capture log close 
	


	cd "/Users/zhangyi/Documents/数据集/CGSS"
	global outdir "/Users/zhangyi/Desktop/EDU_HEALTH/output"
	global workingdir "/Users/zhangyi/Desktop/EDU_HEALTH/working"


