*============================================================*
**       		 Famine workshop  
**Goal		:    清理统计年鉴50年
**Data		:    
**Author	:  	 ZhangYi zhangyiceee@163.com 15592606739
**Created	:  	 20191011  
**Last Modified: 20200421
*============================================================*
	

	import excel "汇总.xlsx", sheet("Sheet1") firstrow  clear
	label var total "万人"
	label var birth_rate "千分之"
	label var death_rate "千分之"
	label var 人口自然增长率 "千分之"

	save "$working/total_year_50.dta",replace 

	use "$working/total_year_50.dta",clear
	destring year-人口自然增长率,replace force
	keep if year>=1954 & year<=1966 //某些省份的样本由公安和抽样构成，目前先不放进去
	
	drop number 
	duplicates list provience year
	reshape wide total male female rural urban birth_rate death_rate 人口自然增长率 ,i(provience) j(year)

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

	save "$working/nj.dta",replace 

	keep if year==1960 
	rename provience mom_birth_site
	save "$working/nj_1960.dta",replace


