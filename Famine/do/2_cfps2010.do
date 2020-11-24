*============================================================*
**       		 Famine workshop  
**Goal		:    清理cfps2010年样本数据，
**Data		:    
**Author	:  	 ZhangYi zhangyiceee@163.com 15592606739
**Created	:  	 20201124 
**Last Modified: 
*============================================================*
	
	global cfps2010 "/Users/zhangyi/Documents/数据集/CFPS/real_cfps/CFPS2010"

*清个体和父母的信息

	use "$cfps2010/cfps2010adult_201906.dta",clear
	
*生成母亲的编码
	rename pid pid_child
	label var pid_child "儿童的编码"
	gen pid=pid_child

	label var pid "个人编码"
*pid_f pid_m
	
	keep  pid_child  pid_m
	rename pid_m pid
	merge m:1 pid using "$cfps2010/cfps2010adult_201906.dta"
	keep if _merge==3

	keep qa102acode  qa301acode qa1y_best qa1m pid_child pid
	rename qa1y_best mom_birth_y 
	rename qa1m		 mom_birth_m
	clonevar mom_birth_site =qa102acode
	rename qa102acode mom_birth_site1
	rename qa301acode mom_3_site
	label var mom_birth_y  		"母亲出生年份"
	label var mom_birth_m 		"母亲出生月份"
	label var mom_birth_site 	"母亲出生地"
	label var mom_3_site 		"母亲3岁居住地"

	rename pid pid_m
	rename pid_child pid //合并孩子的数据

	merge 1:1 pid using  "$cfps2010/cfps2010adult_201906.dta"
	keep if _merge==3
	tab mom_birth_y,m
	*bro if mom_birth_y>1959 &mom_birth_y<1969
	
*母亲出生地、出生年、月
	tab1 mom_birth_y mom_birth_m mom_birth_site,m
	label list qa102acode
*$$$$$$$$$$$
	*bro mom_birth_site
	tostring mom_birth_site ,replace force
	replace mom_birth_site="北京"  if mom_birth_site=="11"
	replace mom_birth_site="天津"  if mom_birth_site=="12"
	replace mom_birth_site="河北"  if mom_birth_site=="13"
	replace mom_birth_site="山西"  if mom_birth_site=="14"
	replace mom_birth_site="内蒙古"  if mom_birth_site=="15"
	replace mom_birth_site="辽宁"  if mom_birth_site=="21"
	replace mom_birth_site="吉林"  if mom_birth_site=="22"
	replace mom_birth_site="黑龙江"  if mom_birth_site=="23"
	replace mom_birth_site="上海"  if mom_birth_site=="31"
	replace mom_birth_site="江苏"  if mom_birth_site=="32"
	replace mom_birth_site="浙江"  if mom_birth_site=="33"
	replace mom_birth_site="安徽"  if mom_birth_site=="34"
	replace mom_birth_site="福建"  if mom_birth_site=="35"
	replace mom_birth_site="江西"  if mom_birth_site=="36"
	replace mom_birth_site="山东"  if mom_birth_site=="37"
	replace mom_birth_site="河南"  if mom_birth_site=="41"
	replace mom_birth_site="湖北"  if mom_birth_site=="42"
	replace mom_birth_site="湖南"  if mom_birth_site=="43"
	replace mom_birth_site="广东"  if mom_birth_site=="44"
	replace mom_birth_site="广西"  if mom_birth_site=="45"
	replace mom_birth_site="海南"  if mom_birth_site=="46"
	replace mom_birth_site="重庆"  if mom_birth_site=="50"
	replace mom_birth_site="四川"  if mom_birth_site=="51"
	replace mom_birth_site="贵州"  if mom_birth_site=="52"
	replace mom_birth_site="云南"  if mom_birth_site=="53"
	replace mom_birth_site="西藏"  if mom_birth_site=="54"
	replace mom_birth_site="陕西"  if mom_birth_site=="61"
	replace mom_birth_site="甘肃"  if mom_birth_site=="62"
	replace mom_birth_site="青海"  if mom_birth_site=="63"
	replace mom_birth_site="宁夏"  if mom_birth_site=="64"
	replace mom_birth_site="新疆"  if mom_birth_site=="65"
	tab mom_birth_site,m

	tab1 qq601-qq606,m
	codebook qq601
	recode qq601 (1=5)(2=4)(3=3)(4=2)(5=1)
	recode qq602 (1=5)(2=4)(3=3)(4=2)(5=1)
	recode qq603 (1=5)(2=4)(3=3)(4=2)(5=1)
	recode qq604 (1=5)(2=4)(3=3)(4=2)(5=1)
	recode qq605 (1=5)(2=4)(3=3)(4=2)(5=1)
	recode qq606 (1=5)(2=4)(3=3)(4=2)(5=1)
	foreach x of varlist qq601-qq606{
		replace `x'=. if `x'<0
	}

	egen mht= rowmean(qq601-qq606) 

	drop _merge

	merge m:1  mom_birth_site  using "$working/nj_1960.dta"
	keep if _merge==3
	
	gen famine=1 if mom_birth_y<=1961
	replace famine =0 if mom_birth_y>1961
	label var famine "母亲是否经历过饥荒"

	gen DF=famine * edr
	label var DF "交互项"
	reg mht  DF i.mom_birth_site1 i.mom_birth_y
	reg mathtest  DF i.mom_birth_site1 i.mom_birth_y
	reg wordtest  DF i.mom_birth_site1 i.mom_birth_y





