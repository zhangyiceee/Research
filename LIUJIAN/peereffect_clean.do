 *** Step 1. Prepare vars
global dtadir     "/Users/zhangyi/Desktop/Peer effectt/程序/raw"
global workingdir "/Users/zhangyi/Desktop/Peer effectt/程序/working"
global savedir    "/Users/zhangyi/Desktop/Peer effectt/程序/output"
cd "$workingdir"
use "$dtadir/teacher_training_2014_b_stu_tch_prin_e_stu_tch deid.dta",clear

* 剔除不能用的数据
tab merge_baseline_endline,m
codebook merge_baseline_endline
drop if merge_baseline_endline == 2 //35个空白数据
//list classid if merge_baseline_endline != 3

*生成县编码
codebook stu_e_14_stdid //无缺失
tostring stu_e_14_stdid,replace
generate countyid = substr(stu_e_14_stdid,1,3)
destring countyid,replace 
label var countyid "县"

*生成班级编码
generate classid = substr(stu_e_14_stdid,1,6)
destring classid,replace
label var classid "班级"
//destring classid,replace

*生成学校编码
tostring classid,replace
generate schoolid = substr(classid,1,4)
codebook schoolid 
label var schoolid "学校"
//destring schoolid,replace 

* grade
tab stu_b_14_grade,m //无缺失
gen grade=stu_b_14_grade
destring grade,replace
label var grade "年级"


* rural school
gen rural = 1 //无缺失
replace rural = 0 if stu_b_14_town == ""  
drop if rural==0 //分析时去掉城镇小学
tab schoolid if rural == 0 //8个学校
label var rural "学校类型"
codebook rural
	
* boarding
tab stu_b_14_zhuxiao,m //有1个缺失值
//br school class stu_b_14_zhuxiao if school=="1022"|school=="1053"
replace stu_b_14_zhuxiao=0 if stu_b_14_zhuxiao==.&school=="1022" //该校无住宿学生
replace stu_b_14_zhuxiao=0 if stu_b_14_zhuxiao==.&school=="1053" //该校几乎无住宿学生
gen boarding=stu_b_14_zhuxiao
	recode boarding (2=0)
label var boarding "Boarding student (1=yes; 0=no)"
tab boarding,m 

* female
gen female=stu_b_14_gender
tab female,m //1缺失
*br stu_e_14_stdid stu_b_14_gender stu_b_14_t_0_1 stu_e_14_t_0_1 if female ==. //核对所有性别的题目
replace female = 1 if stu_e_14_stdid =="10533146" //从别的问卷判断性别
label var female "Female (1=yes; 0=no)" 
recode female (1=0)(2=1)	
		

*age //2014年10月基线 2015年1月评估

codebook stu_e_14_birthyear
replace stu_e_14_birthyear=. if stu_e_14_birthyear==.o
codebook stu_e_14_birthmon
tab stu_e_14_birthmon,m
replace stu_e_14_birthmon=. if stu_e_14_birthmon==.o
//br school class stu_e_14_birthyear stu_e_14_birthmon if stu_e_14_birthyear==.|stu_e_14_birthmon==.
replace stu_e_14_birthmon=6 if stu_e_14_birthmon==.&stu_e_14_birthyear!=. //知道年份不知道月份按照6月计算
tab stu_e_14_birthyear classid if classid=="103151"|classid=="104151"|classid=="104251"|classid=="105161"|classid=="105162"|classid=="107141"|classid=="111532"|classid=="112161"|classid=="201131"|classid=="205132"|classid=="206151"|classid=="208161" ,m  //知道月份，不知道年份的取众数
replace stu_e_14_birthyear=2004 if classid=="103151"&stu_e_14_birthyear==.&stu_e_14_birthmon!=.
replace stu_e_14_birthyear=2003 if classid=="104151"&stu_e_14_birthyear==.
replace stu_e_14_birthyear=2004 if classid=="104251"&stu_e_14_birthyear==.
replace stu_e_14_birthyear=2003 if classid=="105161"&stu_e_14_birthyear==.
replace stu_e_14_birthyear=2003 if classid=="105162"&stu_e_14_birthyear==.
replace stu_e_14_birthyear=2005 if classid=="107141"&stu_e_14_birthyear==.
replace stu_e_14_birthyear=2006 if classid=="111532"&stu_e_14_birthyear==.
replace stu_e_14_birthyear=2003 if classid=="112161"&stu_e_14_birthyear==.
replace stu_e_14_birthyear=2006 if classid=="201131"&stu_e_14_birthyear==.
replace stu_e_14_birthyear=2006 if classid=="205132"&stu_e_14_birthyear==.
replace stu_e_14_birthyear=2004 if classid=="206151"&stu_e_14_birthyear==.
replace stu_e_14_birthyear=2003 if classid=="208161"&stu_e_14_birthyear==.

tab classid
*br * if classid=="201431" //90余名学生
gen age1=2013-stu_e_14_birthyear+(22-stu_e_14_birthmon)/12
tab classid if age1==.
by classid,sort : egen ageo=mean(age1)
replace age1=ageo if age1==. //不知道出生年份的按照班级平均年龄计算

gen age2=age1+0.25

tab age1 //无缺失
tab age2 //无缺失
label var age1 "基线年龄"
label var age2 "评估年龄"
 
 
*共计2637名学生
 
/*********************以下处理家庭相关变量*********************/

* left_behind children
tab stu_b_14_12,m //11缺失 父亲外出务工
replace stu_b_14_12 =. if stu_b_14_12 ==.o
tab stu_b_14_14,m //21缺失 母亲外出务工
replace stu_b_14_14 =. if stu_b_14_14 ==.n

gen mig_father = 1 if stu_b_14_12 == 2
	replace mig_father = 0 if stu_b_14_12 == 1

gen mig_mother = 1 if stu_b_14_14 == 2
	replace mig_mother = 0 if stu_b_14_14 == 1

gen lbc = 1 if stu_b_14_12 == 2 | stu_b_14_14 == 2
    replace lbc = 0 if stu_b_14_12 ==1 & stu_b_14_14 ==1 
tab mig_father,m //11缺失值
tab mig_mother,m //19缺失值
tab lbc,m //18缺失
replace lbc=1 if lbc==.  //其他情况

* household asset(主成分分析)
foreach num of numlist 15/21 {
   recode stu_b_14_`num' (2=0)
}
polychoricpca stu_b_14_15-stu_b_14_21,score(stu_ys_eco) nscore(1)
ren stu_ys_eco stu_asset
		label var stu_asset "asset"
		tab stu_asset,m  //12缺失
drop __ttstu_b_14_15-__ttstu_b_14_21
by classid,sort : egen stu_asseto=mean(stu_asset)
replace stu_asset=stu_asseto if stu_asset==. //未填写按照班级平均水平计算
		
* education of parents（是否具有高中及以上学历）
tab stu_b_14_9,m //20缺失
	replace stu_b_14_9 = . if stu_b_14_9 == .o | stu_b_14_9 == .n
tab stu_b_14_10,m //37缺失
	replace stu_b_14_10 = . if stu_b_14_10 == .o | stu_b_14_10 == .n
sum stu_b_14_9 stu_b_14_10,d

gen edu_father = 1 if stu_b_14_9 !=. 
    replace edu_father = 0 if stu_b_14_9 < 5 & stu_b_14_9 !=.
gen edu_mother = 1 if stu_b_14_10 !=. 
    replace edu_mother = 0 if stu_b_14_10 < 5 & stu_b_14_10 !=. 
gen edu_father_year=0 if stu_b_14_9==0
    replace edu_father_year=3    if stu_b_14_9==1
	replace edu_father_year=6    if stu_b_14_9==2
	replace edu_father_year=7.5  if stu_b_14_9==3
	replace edu_father_year=9    if stu_b_14_9==4
	replace edu_father_year=10.5 if stu_b_14_9==5
	replace edu_father_year=12   if stu_b_14_9==6
	replace edu_father_year=13.5 if stu_b_14_9==7
	replace edu_father_year=15   if stu_b_14_9==8
	replace edu_father_year=14   if stu_b_14_9==9
	replace edu_father_year=16   if stu_b_14_9==10
gen edu_mother_year=0 if stu_b_14_10==0
    replace edu_mother_year=3    if stu_b_14_10==1
	replace edu_mother_year=6    if stu_b_14_10==2
	replace edu_mother_year=7.5  if stu_b_14_10==3
	replace edu_mother_year=9    if stu_b_14_10==4
	replace edu_mother_year=10.5 if stu_b_14_10==5
	replace edu_mother_year=12   if stu_b_14_10==6
	replace edu_mother_year=13.5 if stu_b_14_10==7
	replace edu_mother_year=15   if stu_b_14_10==8
	replace edu_mother_year=14   if stu_b_14_10==9
	replace edu_mother_year=16   if stu_b_14_10==10
	
tab edu_father,m //20missing
tab edu_mother,m //34missing
tab edu_father_year,m //20missing
tab edu_mother_year,m //34missing
by classid,sort : egen edu_father_yearo=mean(edu_father_year)
replace edu_father_year=edu_father_yearo if edu_father_year==. //未填写按照班级平均水平计算
by classid,sort : egen edu_mother_yearo=mean(edu_mother_year)
replace edu_mother_year=edu_mother_yearo if edu_mother_year==. 



****父母对学生学习的关注度
tab stu_b_14_22
forvalue i=22/25 {
    recode stu_b_14_`i' (1=5)(2=4)(4=2)(5=1) ,gen(t`i')
}
egen att=rowmean(t22-t25)
tab att,m
//tab att lbc
drop t22-t25
polychoricpca stu_b_14_22-stu_b_14_25,score(attention) nscore(1)
tab attention,m //7个缺失值
drop __ttstu_b_14_22-__ttstu_b_14_25
by classid,sort : egen at1=mean(attention)
replace attention=at1 if attention==. //均值替代
sum attention if lbc==0
sum attention if lbc==1
sum att if lbc==0
sum att if lbc==1


/**********************以下处理教师相关变量**********************/

* 教师知识水平
tab tea_b_14_t_a_score,m
tab tea_b_14_t_b_score,m
count if tea_b_14_t_a_score == . & tea_b_14_t_b_score == . //57个缺失
list classid tea_b_14_t_a_score tea_b_14_t_b_score if tea_b_14_t_a_score == . & tea_b_14_t_b_score == .
tab classid if tea_b_14_t_a_score == . & tea_b_14_t_b_score == . //2名老师未填
egen tea_score_a = std(tea_b_14_t_a_score)
egen tea_score_b = std(tea_b_14_t_b_score)
gen z_tea_math = tea_score_a if tea_score_a != .
    replace z_tea_math = tea_score_b if tea_score_b != .
codebook z_tea_math //57缺失 缺失值填补
replace z_tea_math=.2088844 if classid=="111131"
replace z_tea_math=-.9544249 if classid=="112261"
/*keep z_tea_math-tea_computer rural classid
duplicates drop
reg z_tea_math tea_age1 tea_female edu_tea_year tea_major rural tea_hukou  
predict z_tea_math3,xb
list classid z_tea_math z_tea_math3 if z_tea_math==.
*/
/*
     +--------------------------------+
     | classid   z_tea_~h   z_tea_m~3 |
     |--------------------------------|
 37. |  111131          .    .2088844 |
 61. |  112261          .   -.9544249 |
     +--------------------------------+
*/

* teacher's age
codebook tea_b_14_birthyear
destring tea_b_14_birthyear,replace
codebook tea_b_14_birthmon
destring tea_b_14_birthmon,replace
gen tea_age1=2013-tea_b_14_birthyear+(22-tea_b_14_birthmon)/12
gen tea_age2=2014-tea_b_14_birthyear+(13-tea_b_14_birthmon)/12
codebook tea_age1 //无缺失
label var tea_age1 "基线年龄"
label var tea_age2 "评估年龄"

* teacher's gender
codebook tea_b_14_gender //无缺失
gen tea_female = tea_b_14_gender
recode tea_female (1=0)(2=1)
tab tea_female,m
    label var tea_female "Female teacher (1=yes; 0=no)" 
	
/* 教师是否是本地人
tab tea_b_14_local,m
gen tea_local = 0 if tea_b_14_local == 2
	replace tea_local = 1 if tea_b_14_local == 1
	tab tea_local,m //无缺失
	label var tea_local "本地人"

* 教师的户口类型
tab tea_b_14_register,m //无缺失
gen tea_hukou = 0 if tea_b_14_register == 1 //rural
	replace tea_hukou = 1 if tea_b_14_register == 2 //urban 
*/ 
* 教师的全日制学历(是否有全日制专科及以上学历)
tab tea_b_14_6,m  //无缺失 1=小学毕业 2=初中毕业 3=中专、中技、职高毕业 4=普通高中毕业 5=大专毕业 6=师范类大学本科毕业 7=一般高校本科毕业 8=硕士研究生毕业
gen edu_tea = 0 
	replace edu_tea = 1 if tea_b_14_6 > 4  //大专及以上	
gen edu_tea_year=9 if  tea_b_14_6==2
	replace edu_tea_year=12 if  tea_b_14_6==3
	replace edu_tea_year=12 if  tea_b_14_6==4
	replace edu_tea_year=15 if  tea_b_14_6==5
	replace edu_tea_year=16 if  tea_b_14_6==6
	replace edu_tea_year=16 if  tea_b_14_6==7
tab edu_tea,m 
tab edu_tea_year,m 

* 教师的职称
tab tea_b_14_15,m
tab tea_b_14_15a,m
gen zhicheng=0 if tea_b_14_15==0
replace zhicheng=1 if tea_b_14_15==1 //三级
replace zhicheng=2 if tea_b_14_15==2|tea_b_14_15a=="中学二级" //二级
replace zhicheng=3 if tea_b_14_15==3
gen tea_gaoji = 0 
	replace tea_gaoji = 1 if tea_b_14_15 == 3
* 教龄
tab tea_b_14_20,m //无缺失
sum tea_b_14_20,d
gen teaching_age=tea_b_14_20
tab teaching_age,m


/* 教师是否数学专业
tab tea_b_14_7,m  //无缺失
tab tea_b_14_12,m  
codebook tea_b_14_7	
gen tea_major = 0 
    replace tea_major = 1 if tea_b_14_7 == 2  //数学专业
    tab tea_major,m 
    label var tea_major "Teacher's major(1=Math; 0=Non-math)" 
replace tea_major=1 if tea_b_14_12==2 //继续进修专业为数学

* 公办教师
tab tea_b_14_13,m //公办3102 非公办154 

* 教师资格证
tab tea_b_14_14,m //均有

* 校外兼职
tab tea_b_14_16,m //71

* 班主任经历
tab tea_b_14_17,m //无缺失
gen bzr=tea_b_14_17

* 教师除了教学以外是否有其他职务
tab tea_b_14_18a,m //少先队辅导员
tab tea_b_14_18b,m //教研组长
tab tea_b_14_18c,m //教导主任
tab tea_b_14_18d,m //校长
tab tea_b_14_18e,m //其他
gen tea_qitazhiwu = 0 //0missing
	replace tea_qitazhiwu = 1 if tea_b_14_18a == 1 | tea_b_14_18b == 1 | tea_b_14_18c == 1 | tea_b_14_18d == 1 | tea_b_14_18e == 1
tab tea_qitazhiwu,m
*/

/* 薪水
tab tea_b_14_21,m //19缺失值，待填补
gen salary=tea_b_14_21
tab tea_b_14_6
list salary tea_b_14_6 teaching_age if teaching_age<3
list salary tea_b_14_6 teaching_age if tea_b_14_6==6
replace salary=2600 if salary==. //邻近值
tab salary,m
* 是否利用网络资源
tab tea_e_14_26a,m
gen tea_internet = 0 if tea_e_14_26a == 2
	replace tea_internet = 1 if tea_e_14_26a == 1 
list tea_b_14_26a tea_e_14_26a tea_e_14_68a if tea_e_14_68a==.
    replace tea_internet=0 if tea_internet == .
tab tea_internet,m //无缺失missing
* 是否计算机教学
tab tea_e_14_68a,m
gen tea_computer=0
    replace tea_computer=1 if tea_e_14_68a == 1
tab tea_computer,m

* 两学期是否同一个数学老师
tab stu_b_14_80,m
gen tea_sameone = 0 if stu_b_14_80 == 2
	replace tea_sameone = 1 if stu_b_14_80 == 1
	tab tea_sameone,m //2缺失
list tea_sameone classid if tea_sameone==.
list tea_sameone classid if classid=="102131"
replace tea_sameone=1 if classid=="102131"&tea_sameone==.
list tea_sameone classid if classid=="111362"
replace tea_sameone=0 if classid=="111362"&tea_sameone==.
tab tea_sameone,m

****老师给多少个班上课
des tea_b_14_72_1-tea_b_14_73_5
rename tea_b_14_72_* tb*
rename tea_b_14_73_* tk*
gen tea_daiban=0
gen tea_daike=0
forvalue i=1/5 {
    forvalue j=2/5 {
		replace tb`j'="" if tb`i'==tb`j'&`i'<`j'
		replace tk`j'="" if tk`i'==tk`j'&`i'<`j'
		}
	replace tea_daiban=tea_daiban+1 if tb`i'!=""
	replace tea_daike=tea_daike+1 if tk`i'!=""
}
tab tea_daiban,m
tab tea_daike,m
tab tea_daike tea_daiban
//list tk1 tk2 tk3 tk4 tk5 if tea_daike==5
//list tb1 tb2 tb3 tb4 tb5 if tea_daiban==5

**des tea_b_14_59
tab tea_b_14_59,m 
gen tea_hour=tea_b_14_59 
sum tea_hour
replace tea_hour=8.5 if tea_hour==. //空缺值用均值替代
tab tea_hour
label var tea_hour "每天工作时间"
*/

*******************以下处理学校相关变量**********************/		
* 学生人数
tab prin_b_14_16,m //学校小学阶段有多少个学生
gen stu_num= prin_b_14_16
* 老师人数
tab prin_b_14_17,m	//学校小学阶段有多少个教师
gen tea_num= prin_b_14_16
* 师生比
gen shishengbi = prin_b_14_17/prin_b_14_16
//replace guimo=ln(guimo)
//replace shishengbi=ln(shishengbi) 
*班级规模
codebook classid
egen newid=group(classid)
tab newid,m
codebook newid
gen classsize=0
foreach i of numlist 1/84 {
sum newid if newid==`i'
replace classsize=r(N) if newid==`i'
}
tab classsize,m

/*流动率
tab prin_b_14_17,m //总数
tab prin_b_14_24,m //新进
tab prin_b_14_25,m //流出
gen xjl=prin_b_14_24/prin_b_14_17
gen lcl=prin_b_14_25/prin_b_14_17
tab xjl,m
tab lcl,m

/*距乡镇政府的距离
tab prin_b_14_4,m
sum prin_b_14_4,d
gen juli = 0 if prin_b_14_4 <= 1 & prin_b_14_4 != .
	replace juli = 1 if prin_b_14_4 > 1 & prin_b_14_4 != .
	tab juli,m
	list schoolid if prin_b_14_4 == .

tab prin_b_14_7,m
	
* 覆盖了多少行政村	
tab prin_b_14_2,m
sum prin_b_14_2,d
gen xingzhengcun = 0 if prin_b_14_2 <=7 & prin_b_14_2 != .
	replace xingzhengcun = 1 if prin_b_14_2 > 7 & prin_b_14_2 != .
	tab xingzhengcun,m

* 跟班制度
tab prin_b_14_31,m
gen genban = 0 if prin_b_14_31 == 2
	replace genban = 1 if prin_b_14_31 == 1
	tab genban,m
	
* 图书室
tab prin_b_14_10,m //0缺失
codebook prin_b_14_10
gen library = prin_b_14_10
recode library (2=0)

gen shishengbi_1 = 1
    replace shishengbi_1 = 0 if shishengbi < .0613636
	tab shishengbi_1,m

/*食堂*/
tab prin_b_14_13,m //0缺失
codebook prin_b_14_13
gen resturant = prin_b_14_13
recode resturant (2=0)

/*机房*/
tab prin_b_14_14,m //0缺失
codebook prin_b_14_14
gen computer = prin_b_14_14
recode computer (2=0)
*/
*/
* 学生成绩
tab stu_b_14_t_g3_total_score,m 
tab stu_b_14_t_g4_total_score,m  
tab stu_b_14_t_g5_total_score,m  
tab stu_b_14_t_g6_total_score,m 
gen bz_stu_math = .
gen ez_stu_math = .
foreach i in b e {
	forvalue j=3/6 {
		egen std_score = std(stu_`i'_14_t_g`j'_total_score)
		replace `i'z_stu_math = std_score if grade==`j'
		drop std_score
	}
}
tab bz_stu_math,m
tab ez_stu_math,m
*br * if ez_stu_math==.
by classid,sort : egen ez_stu_matho=mean(ez_stu_math)
replace ez_stu_math=ez_stu_matho if ez_stu_math==. //均值替代
label var ez_stu_math "学生标准化数学成绩"
/*
egen std_score_3 = std(stu_b_14_t_g3_total_score)
egen std_score_4 = std(stu_b_14_t_g4_total_score)
egen std_score_5 = std(stu_b_14_t_g5_total_score)
egen std_score_6 = std(stu_b_14_t_g6_total_score)
gen z_stu_math = std_score_3 if grade==3
    replace z_stu_math = std_score_4 if grade==4
	replace z_stu_math = std_score_5 if grade==5
	replace z_stu_math = std_score_6 if grade==6
egen estd_score_3 = std(stu_e_14_t_g3_total_score)
egen estd_score_4 = std(stu_e_14_t_g4_total_score)
egen estd_score_5 = std(stu_e_14_t_g5_total_score)
egen estd_score_6 = std(stu_e_14_t_g6_total_score)
gen ez_stu_math = estd_score_3 if grade==3
    replace ez_stu_math = estd_score_4 if grade==4
	replace ez_stu_math = estd_score_5 if grade==5
	replace ez_stu_math = estd_score_6 if grade==6
codebook ez_stu_math
//drop std_score_3-std_score_6 estd_score_3-estd_score_6
*/
rename stu_e_14_codelearnmath_* stu_e_14_codelearnmath*
rename stu_e_14_codefriend_* stu_e_14_codefriend*
keep stu_e_14_stdid  stu_b_14_codelearnmath1-stu_b_14_codefriend5 stu_e_14_codelearnmath1-stu_e_14_codefriend5 countyid-ez_stu_math attention //stu_*_14_t_g*_total_score

save "peereffect_clean.dta",replace
