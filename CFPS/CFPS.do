*============================================================*
**       		CFPS 量表
**Goal		:    熟悉CFPS儿童数据中的一系列量表
**Data		:    CFPS2014
**Author	:  	 ZhangYi zhangyiceee@163.com 15592606739
**Created	:  	 20200616
**Last Modified: 2020
*============================================================*
	capture	clear
	capture log close
	set	more off
	set scrollbufsize 2048000
	capture log close 
	


	cd "/Users/zhangyi/Documents/数据集/CFPS/real_cfps"
	global cleandir "/Users/zhangyi/Desktop/CFPS/cleandata"
	global outdir "/Users/zhangyi/Desktop/CFPS/output"
	global workingdir "/Users/zhangyi/Desktop/CFPS/working"



*调用2014年少儿数据
	use "CFPS2014/cfps2014child.dta",clear

	*自尊量表 wm101m-wm114m
	codebook wm101m //五级量表 ,需要转换,完成后直接加总使用


	*具体积分见CFPS2012心理量表的技术报告,分数越高，自尊程度越大
	foreach zz of varlist wm101m  wm102m wm104m wm106m wm107m wm113m{
		gen n`zz'=`zz'
		recode n`zz' (1=5)(2=4)(3=2)(4=1)(5=3)
		replace n`zz'=. if n`zz'==-8 |n`zz'==-1
	}
codebook wm103m
	foreach zz of  varlist wm103m wm105m wm108m wm110m wm111m wm112m wm114m {
		gen n`zz'=`zz'
		recode n`zz' (3=4)(4=5)(5=3)
		replace n`zz'=. if n`zz'==-8 |n`zz'==-1
	}

	egen zz=rowtotal(nwm101m-nwm114m)   //1000多个样本
	replace zz=. if zz==0

*控制变量
*年龄
	clonevar age = cfps2014_age 
	ta age,m

*性别
	clonevar male  = cfps_gender 
	tab male,m

*户口

	gen rural=.
	replace rural=1 if wa4==1
	replace rural=0 if wa4==3
	label var rural "农村户口=1 ，城市户口=0"
	tab rural,m
*隔代
	gen co_residence_14=0  
 	//比较宽的定义，准确来说cfps是分别不出来完全隔代抚养和部分隔代抚养，
 	//例如，晚上和白天都是祖辈抚养，但是并不能说孩子没和父母在一起
 	replace co_residence_14=1 if wb202_new==2 | wb203_new ==3
 	tab co_residence_14,m
 	

*wm701-wm712 为自控量表
codebook wm701
	foreach zz of  varlist wm701 wm702 wm703 wm704 wm705 wm709 wm710 wm711 wm712{
		gen n`zz'=`zz'
		recode n`zz' (1=5)(2=4)(3=2)(4=1)(5=3)
		replace n`zz'=. if n`zz'==-8 |n`zz'==-1
	}

	*反向计分
	foreach zz of varlist wm706 wm707 wm708{
		gen n`zz'=`zz'
		recode n`zz' (3=4)(4=5)(5=3)
		replace n`zz'=. if n`zz'==-8 |n`zz'==-1
	}

	egen zk = rowtotal(nwm701-nwm708)
	replace zk=. if zk==0
	tab zk,m


*仅包含以下6种心理症状:“紧张”、“没有希望”、“不安或烦躁”、“情绪低落到无论怎么样都没办法让您感到愉快”、“做每一件事都很费劲”与“自己很没用”。其评分标准与K10量表相同, 量表总分为0~24分。其将个体心理健康状况分为2种:“0~12分” (患心理疾患危险性低) 与“13分以上” (患心理疾患危险性高) [16]。
*凯斯勒心理疾患量表
	codebook wq601
	keep if wq601>=1 & wq601<=5
	foreach x of varlist wq601-wq606{
		gen n`x'=`x'
		recode n`x' (1=4)(2=3)(3=2)(4=1)(5=0)
		replace n`x'=. if  n`x'==-8 |n`x'==-1
	}

	egen kessler=rowtotal (nwq601-nwq606)
	tab kessler,m
	*“0~12分” (患心理疾患危险性低) 与“13分以上” (患心理疾患危险性高) 
	gen high=.
	replace high=1 if kessler>=13
	replace high=0 if kessler<13
	tab high,m

	






