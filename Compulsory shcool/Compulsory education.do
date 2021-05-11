*============================================================*
**       		 
**Goal		:    生成县级层面义务教育普及数据
**Data		:    
**Author	:  	 ZhangYi zhangyiceee@163.com 15592606739
**Created	:  	 20201009
**Last Modified: 20200
*============================================================*
	capture	clear
	capture log close
	set	more off
	set scrollbufsize 2048000
	capture log close 
	


	cd "/Users/zhangyi/Desktop/义务教育/map_data/"

 	use county_gis.dta,clear
 	*keep _ID CENTROID_X CENTROID_Y  NAME99
 	
 	duplicates tag _ID ,gen(a)
 	drop if a!=0
	gen x = uniform()
	format x %9.3g
	spmap x using "countycoordinates.dta", /// 
 	id(_ID) label(label(_ID) xcoord(CENTROID_X) ycoord(CENTROID_Y) size(*.66))

	spmap x using "countycoordinates.dta", /// 
 	id(_ID) fcolor(red)

 	use county_gis.dta,clear
 	merge m:m _ID using countycoordinates.dta



 	