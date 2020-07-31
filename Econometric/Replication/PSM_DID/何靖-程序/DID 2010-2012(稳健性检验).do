
**** 数据用 DID 2010-2012(稳健性检验).dta


***** 第一步：进行psm（已经进行：利用PSM2010-2012(稳健性检验).dta进行PSM，然后根据PSM结果整理得到 DID 2010-2012(稳健性检验).dta）


***** 第二步：检验延付高管薪酬对银行收益波动性的影响。

***** （1）检验2010-2012年的平均处理效应

gen gd= t* treated
xtset i year

* VNIM     结果发现，交互项的系数显著为负，符合预期
gen vnimw= vnim* _weight
xtreg vnimw gd t dumy2 dumy3,fe
     est store vnim_fe
xtreg vnimw gd t treated loang cap size lpr  ldr gdpg lev roe dumy2 dumy3,fe
     est store vnim_fecon
	 
est table vnim_*,b(%7.3f)  star(0.1 0.05 0.01)
est table vnim_*,b(%7.3f) t(%7.3f) 


**** VEBTP     

gen vebtpw= vebtp * _weight

xtreg vebtpw gd t dumy2 dumy3,fe
     est store vebtp_fe
xtreg vebtpw gd t treated loang cap size lpr  ldr gdpg lev roe dumy2 dumy3,fe
     est store vebtp_fecon
	 
est table vebtp_*,b(%7.3f)  star(0.1 0.05 0.01)
est table vebtp_*,b(%7.3f) t(%7.3f) 


  **** zscore     
gen zscorew= zscore * _weight
xtreg zscorew gd t dumy2 dumy3,fe
     est store zscore_fe
xtreg zscorew gd t treated loang cap size lpr  ldr gdpg lev roe dumy2 dumy3,fe
     est store zscore_fecon
	 
est table zscore_*,b(%7.3f)  star(0.1 0.05 0.01)
est table zscore_*,b(%7.3f) t(%7.3f)






**** （2）动态边际效应的检验

gen gd2= dumy2* treated
gen gd3= dumy3* treated


**** VNIM     
xtreg vnimw gd2 gd3 dumy2 dumy3 treated ,fe
     est store vnim_fe
xtreg vnimw gd2 gd3 dumy2 dumy3 treated loang cap size lpr ldr gdpg lev roe gdpg,fe
     est store vnim_fecon
	 
est table vnim_*,b(%7.3f)  star(0.1 0.05 0.01)
est table vnim_*,b(%7.3f) t(%7.3f) 


**** VEBTP     

xtreg vebtpw gd2 gd3 dumy2 dumy3 treated ,fe
     est store vebtp_fe
xtreg vebtpw gd2 gd3 dumy2 dumy3  treated loang  cap size lpr ldr gdpg lev roe,fe
     est store vebtp_fecon
	 
est table vebtp_*,b(%7.3f)  star(0.1 0.05 0.01)
est table vebtp_*,b(%7.3f) t(%7.3f) 


  **** zscore     

xtreg zscorew gd2 gd3 dumy2 dumy3  treated ,fe
     est store zscore_fe
xtreg zscorew gd2 gd3 dumy2 dumy3  treated loang cap size lpr ldr gdpg lev roe,fe
     est store zscore_fecon
	 
est table zscore_*,b(%7.3f)  star(0.1 0.05 0.01)
est table zscore_*,b(%7.3f) t(%7.3f)






	 


**** 第三步：检验盈余管理行为

**** （1）检验平均处理效应


gen llpw= llp* _weight
gen t_ebtp=t*ebtp
gen tre_ebtp=treated*ebtp
gen gd_ebtp=t*treated*ebtp


xtreg llpw ebtp t treated t_ebtp tre_ebtp gd gd_ebtp dumy2 dumy3,fe
     est store llp_fe
	 
xtreg llpw ebtp t treated t_ebtp tre_ebtp gd gd_ebtp rp1 rp2 sign lco npl chnpl loan loang gdpg dumy2 dumy3,fe
     est store llp_fecon

	 
****  （2）考虑动态性


gen dumy2_ebtp=dumy2*ebtp
gen dumy3_ebtp=dumy3*ebtp
gen gd2_ebtp=gd2*ebtp
gen gd3_ebtp=gd3*ebtp


xtreg llpw ebtp dumy2 dumy3 dumy2_ebtp dumy3_ebtp treated tre_ebtp gd2 gd3  gd2_ebtp gd3_ebtp ,fe 
     est store llp_fedt
xtreg llpw ebtp dumy2 dumy3 dumy2_ebtp dumy3_ebtp treated tre_ebtp gd2 gd3  gd2_ebtp gd3_ebtp rp1 rp2 sign lco npl chnpl loan loang gdpg,fe
     est store llp_fedtcon

	 
est table llp_*,b(%7.3f)  star(0.1 0.05 0.01)
est table llp_*,b(%7.3f) t(%7.3f) 




