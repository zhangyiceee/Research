*============================================================*
**       		 Famine workshop  
**Goal		:    清理统计年鉴
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
	cd "/Users/zhangyi/Documents/数据集/年鉴/60统计资料汇编/人口"
	global clean "/Users/zhangyi/Desktop/Famine/clean_data"
	global output "/Users/zhangyi/Desktop/Famine/output"
	global working "/Users/zhangyi/Desktop/Famine/working_data"


	import excel "全国.xlsx", sheet("Sheet1") firstrow  clear
	label var total "万人"
	label var birth_rate "千分之"
	label var death_rate "千分之"
	label var 人口自然增长率 "千分之"

	save "$working/total_year.dta",replace 

	use "$working/total_year.dta",clear

	foreach x of varlist rural death_rate 人口自然增长率{
		replace `x'="." if `x'=="" 
	}
	destring year-人口自然增长率,replace force
	drop number 
	reshape wide total male female urban rural birth_rate death_rate 人口自然增长率 ,i(provience) j(year)

	egen adr54_58=rowmean(death_rate1954 death_rate1955 death_rate1956 death_rate1957 death_rate1958)
	egen adr62_66=rowmean(death_rate1962 death_rate1963 death_rate1964 death_rate1965 death_rate1966)
	gen death6266_5458=adr62_66-adr54_58

	foreach x of numlist 1959 1960 1961 {
		gen pre`x'=adr54_58+((death6266_5458)*(`x'-1958)/4)
	}
	bro provience adr62_66 death6266_5458 adr62_66 adr54_58 pre1959

	reshape long total male female urban rural birth_rate death_rate 人口自然增长率 pre ,i(provience) j(year)
	gen edr=death_rate-pre
	bro provience year edr death_rate pre if year==1959 |year==1960 |year==1961
	replace edr=0 if edr==.

*合并好数据好，根据出生月份调整饥荒程度


