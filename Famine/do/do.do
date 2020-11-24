*============================================================*
**       		 Famine workshop  
**Goal		:    清理统计年鉴50年
**Data		:    
**Author	:  	 ZhangYi zhangyiceee@163.com 15592606739
**Created	:  	 20191011  
**Last Modified: 20200421
*============================================================*
	capture	clear
	capture log close
	set	more off
	set scrollbufsize 2048000
	capture log close 
	cd "/Users/zhangyi/Documents/数据集/年鉴/50年统计资料/"
	global clean "/Users/zhangyi/Desktop/Famine/clean_data"
	global output "/Users/zhangyi/Desktop/Famine/output"
	global working "/Users/zhangyi/Desktop/Famine/working_data"
	global dofile "/Users/zhangyi/Documents/GitHub/Research/Famine/do"


	*清理统计年鉴的人口缩减率
	do "$dofile/1_clean_yearbook50.do"

	*清理CFPS数据
	do "$dofile/2_cfps2010.do"


	*合并CFPS和省级层面的数据

	



