
**** 数据用  DID 2010-2011(稳健性检验).dta


***** 第一步：进行psm（已经进行：利用PSM2010-2011(稳健性检验).dta进行PSM，然后根据PSM结果整理得到DID 2010-2011(稳健性检验).dta）


***** 第二步：检验延付高管薪酬对银行收益波动性的影响。

*****  由于只有2010-2011年数据，因此平均处理效应和动态边际效应的结果相同。

xtset i t
gen gd= t* treated

* VNIM     结果发现，交互项的系数显著为负，符合预期
gen vnimw= vnim* _weight
xtreg vnimw gd t ,fe
     est store vnim_fe
xtreg vnimw gd t treated loang cap size lpr  ldr gdpg lev roe,fe
     est store vnim_fecon
	 
est table vnim_*,b(%7.3f)  star(0.1 0.05 0.01)
est table vnim_*,b(%7.3f) t(%7.3f) 


**** VEBTP     
gen vebtpw= vebtp * _weight
xtreg vebtpw gd t ,fe
     est store vebtp_fe
xtreg vebtpw gd t treated loang cap size lpr  ldr gdpg lev roe,fe
     est store vebtp_fecon
	 
est table vebtp_*,b(%7.3f)  star(0.1 0.05 0.01)
est table vebtp_*,b(%7.3f) t(%7.3f) 


  **** zscore     
gen zscorew= zscore * _weight
xtreg zscorew gd t ,fe
     est store zscore_fe
xtreg zscorew gd t treated loang cap size lpr  ldr gdpg lev roe,fe
     est store zscore_fecon
	 
est table zscore_*,b(%7.3f)  star(0.1 0.05 0.01)
est table zscore_*,b(%7.3f) t(%7.3f)







**** 检验盈余管理行为
gen llpw= llp* _weight
gen t_ebtp=t*ebtp
gen tre_ebtp=treated*ebtp
gen gd_ebtp=t*treated*ebtp


xtreg llpw ebtp t treated t_ebtp tre_ebtp gd gd_ebtp,fe
     est store llp_fe	 
xtreg llpw ebtp t treated t_ebtp tre_ebtp gd gd_ebtp rp1 rp2 sign lco npl chnpl loan loang gdpg,fe
     est store llp_fecon
	 
est table llp_*,b(%7.3f)  star(0.1 0.05 0.01)
est table llp_*,b(%7.3f) t(%7.3f) 




