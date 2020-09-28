*============================================================*
**       		
**Goal		:    父母宗教信仰对孩子非认知能力的影响，参考季刊的文章
**Data		:    CFPS2014
**Author	:  	 ZhangYi zhangyiceee@163.com 15592606739
**Created	:  	 20200901
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



*调用2014年成年人数据
	use "CFPS2014/cfps2014adult.dta",clear

	bro qm601a_s_1-qm601a_s_6 
	tab1  qm601a_s_1-qm601a_s_6,m



*调用2012年成年人数据
	use "CFPS2012/cfps2012adult_201906.dta",clear

	*清理思路：先清理宗教信仰的变量，生成一个父母宗教信仰的数据库
	*在数据中克隆两个pid 分别为pid_f 和pid_m 和后面进行合并

	codebook qm601
	tab qm601,m

	drop pid_f pid_m 
	rename * *_f
	keep pid_f qm601_f
	save "$workingdir/cfps_f.dta",replace
	use "CFPS2012/cfps2012adult_201906.dta",clear
	drop pid_f pid_m 
	rename * *_m
	keep pid_m qm601_m

	label data "母亲数据"
	save "$workingdir/cfps_m.dta",replace



	use "CFPS2012/cfps2012adult_201906.dta",clear
	tab qm601,m
	bro  pid pid_f pid_m
	*保留有父母亲样本的数据，和原数据进行匹配
	keep if pid_f!=-8 | pid_m!=-8

	merge m:1 pid_f using "$workingdir/cfps_f.dta"
	drop if _merge==2 //删掉父亲数据中没配上的样本
	rename _merge merge1
	label var  merge1 "孩子与父亲数据进行匹配"

	merge m:1 pid_m using "$workingdir/cfps_m.dta"
	drop if _merge==2 //删掉母亲数据中没配上的样本
	rename _merge merge2
	label var merge2 "与母亲数据进行合并"
	bro qm601_m qm601_f
	tab1 qm601_m qm601_f,m
	codebook qm601_m qm601_f
*生成父母宗教信仰的变量

	gen religion_fa=0
	replace religion_fa=1 if qm601_f>=1 &qm601_f<6
	label var religion_fa "父亲是否有宗教信仰"

	gen religion_mo=0
	replace religion_mo=1 if qm601_m>=1 &qm601_m<6
	label var religion_mo "父亲是否有宗教信仰"
*生成非认知能力的变量
	clonevar cooperation = qz206
	label var cooperation "对调查的配合程度：合作意识"
	clonevar interpersonal =qz208 
	label var interpersonal "待人接物水平：社交能力"

	clonevar curiosity=qz209
	label var curiosity "对调查的兴趣：好奇心和求知欲"

	clonevar credit=qz211
	label var credit "回答的可信程度：信誉水平"

	clonevar expression=qz212
	label var  expression "表达能力"


	foreach x of varlist cooperation-expression iwr  ns_wse {
		reg `x' religion_mo religion_fa
	}




