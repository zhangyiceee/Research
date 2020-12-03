/* 
This .do file contains programs that replicate
the tables and figures in AEJApp-2008-0129.R1.

Please use the -cd- commands to set your working 
directory.
*/

/* ---------------------------------------
Start of Figure 2 program
----------------------------------------------- */

# delimit;

capture program drop figure2;
program figure2;

	clear; set matsize 2000;

	args parent;	

	cd "/Users/zhangyi/Desktop/可重复/edu_health/TaiwanProgs/" ;
	use intensity.dta;
	
	gen cum_newsch73 =  sch_new_1968 + sch_new_1969 + sch_new_1970 
		+ sch_new_1971 + sch_new_1972 + sch_new_1973;
		
	replace cum_newsch73 = 1000*(cum_newsch73/popn1214_1973);
	
	keep county cum_newsch73;
	rename county cnty_`parent';
	save cum_newsch73, replace;
	
	joinby cnty_`parent' using TaiwanEd_`parent'_agg.dta;
	keep cnty_`parent' cum_newsch73 educ_`parent' cnty_`parent' cohort_`parent'
			year jhr_`parent' agric_`parent' treat0_12_`parent' births;
			
	gen jhrXtreat_`parent' =  jhr_`parent'* treat0_12_`parent';
	gen agricXtreat_`parent' =  agric_`parent'* treat0_12_`parent';
	
	/* replicate original */
			if "`parent'"=="m" {;
				char cohort_`parent'[omit] 20;
			};
			if "`parent'"=="f" {;
				char cohort_`parent'[omit] 25;
			};
			char cnty_`parent'[omit] 24;
			char year[omit] 1999;
	/* run regs */

	xi, pre(_73) i.cohort_`parent'|cum_newsch73;
	xi, pre(_I1) i.cnty_`parent'*i.cohort_`parent';
	xi, pre(_I2) i.year*i.cnty_`parent';
	xi, pre(_I3) i.cohort_`parent'|jhr_`parent';
	xi, pre(_I4) i.cohort_`parent'|agric_`parent';	

	gen cntyXcohort_`parent'=(1000*cnty_`parent')+cohort_`parent';

/* %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% */
/* *** No cluster--Robust SE *** */
	reg educ_`parent'  _73cohXcum* _I1cnty* _I1cohort* _I2year* _I2yeaXcnt*
		_I3cohXjhr* _I4cohXagri*  [aw=births], robust;
	
	outreg2 _73cohXcum* using May09plots_`parent'_withAJ_68pop.xls, 
		bracket tstat nocons bdec(4) ct(No clustering);
end;

figure2 m;
figure2 f;



/* ------------------------------------------------
Start of Table 2 Program
--------------------------------------------------*/

# delimit;

capture program drop table2;
program table2;

	args parent sample;

	clear; set mem 200m; set matsize 800; set more off;

	cd "/Users/zhangyi/Desktop/可重复/edu_health/TaiwanProgs/";

	use TaiwanEd_`parent'_agg.dta;

	char cohort_`parent'[omit] 20;
	char cnty_`parent'[omit] 24;
	char year[omit] 1999;

	xi, pre(_I0) i.cohort_`parent'|mschnew68_73;

	xi, pre(_I1) i.cnty_`parent'*i.cohort_`parent';
	xi, pre(_I2) i.year*i.cnty_`parent';

	xi, pre(_I3) i.cohort_`parent'|jhr_`parent';
	xi, pre(_I4) i.cohort_`parent'|agric_`parent';

	global testlist "_I0cohXmsch_0 _I0cohXmsch_1 _I0cohXmsch_2 _I0cohXmsch_3
		_I0cohXmsch_4 _I0cohXmsch_5 _I0cohXmsch_6 _I0cohXmsch_7
		_I0cohXmsch_8 _I0cohXmsch_9 _I0cohXmsch_10 _I0cohXmsch_11
		_I0cohXmsch_12";

	/* --1-- */
	reg educ_`parent' _I0cohXmsch_0-_I0cohXmsch_12 _I1cnty* 
		_I1cohort* _I2year* _I2yeaXcnt*
		  _I3cohXjhr__0-_I3cohXjhr__12  _I4cohXagri_0-_I4cohXagri_12
		[aw=births], cluster(cnty_`parent');

	test $testlist;
	
	outreg2 _I0cohXmsch_0-_I0cohXmsch_12 using table2_model1_May09.xls,
		title(table2) bdec(3) tdec(3) bracket se nocons addstat(Fstat, r(F));


end;

table2 m agg;
table2 f agg;

/* ------------------------------------------------------------------
Start of Table 3 Program
-------------------------------------------------------------------*/

capture program drop table3;
program table3;

	args parent;
	clear; 

	cd "/Users/zhangyi/Desktop/可重复/edu_health/TaiwanProgs/";
	use TaiwanEd_`parent'_agg.dta;
	
	sum educ_`parent' treat0_12_`parent' jhr_`parent' agric_`parent' neom2 
		infm2 [aw=births];
	sum lbw2 [aw=lbw_weight];
	sum pneom2 [aw=pneom_weight];
	
end;

*table3 m;
*table3 f;


/* ------------------------------------------------------------------
Start of Table 4 Program
-------------------------------------------------------------------*/

# delimit;

capture program drop table4;
program table4;

args parent;
	clear;
	cd "/Users/zhangyi/Desktop/可重复/edu_health/TaiwanProgs/";
	use TaiwanEd_`parent'_agg.dta;

	xi, pre(_I1) i.cohort_`parent';
	xi, pre(_I2) i.year*i.cnty_`parent';
	
	gen n=.;
	gen d=.;
	gen MODweight=.;

	foreach outcome in lbw neom pneom infm {;	
		gen educ_`parent'_`outcome'_2=.;
		gen MOD`outcome'=.;
		gen `outcome'3=.;

		if  "`outcome'"=="infm" | "`outcome'"=="neom" {;
			replace n=births;
			replace d=`outcome';
			replace educ_`parent'_`outcome'_2=educ_`parent';
		};
	
		if "`outcome'"=="lbw" {;
			replace n=lbw_weight;
			replace d=lbw;
			local w "l";
			replace educ_`parent'_`outcome'_2 =educ_lbw_`parent';
		};
		
		if "`outcome'"=="pneom" {;
			replace n=pneom_weight;
			replace d=pneom;

			local w "p";
			replace educ_`parent'_`outcome'_2 =educ_pneom_`parent';
		};
	
		replace MOD`outcome'=ln((d+0.5)/(n-d+0.5)); 
		/*LOR modified to include cells with 0 outcome*/
		replace `outcome'3=MOD`outcome';
	
		replace MODweight=.;
		di "change modweight >>>>>>>>>>>>>>>>>>>>> ";
		replace MODweight=(n*(d+1)*(n-d+1))/((n+1)*(n+2)); 
		/*modified weights based on actual values*/

		sum `outcome' MODweight;

		reg educ_`parent'_`outcome'_2
 			`parent'_mschnew68_73Xtreat0_12
			_I1*
			_I2*
			 `parent'_jhrXtreat0_12
			`parent'_agricXtreat0_12[aw=MODweight],
			robust cluster(cnty_`parent');
				
		outreg2 `parent'_mschnew68_73Xtreat0_12 using table4_withAgric.xls, 
			bdec(3) tdec(3) bracket se nocons;		
	};

end;

*table4 m;
*table4 f;

/*------------------------------------------------------
Start of Table 5 and 6 A Program
---------------------------------------------------- */


# delimit;

capture program drop table5_6a;
program table5_6a;
args parent;

	cd "/Users/zhangyi/Desktop/可重复/edu_health/TaiwanProgs/";
	clear; set mem 400m; set matsize 6000; set more off;
	
	use TaiwanEd_`parent'_agg.dta;

	gen n=.;
	gen d=.;

	gen MODweight=.;
	foreach x in lbw neom pneom infm {;
		gen MOD`x'=.;
	};
	
	gen cntyXcohort_`parent'=(1000*cnty_`parent')+cohort_`parent';
	
	/* replicate original */
	if "`parent'"=="f" {;
		char cohort_`parent'[omit] 25;;
	};
	if "`parent'"=="m" {;
		char cohort_`parent'[omit] 20;
	};
	char cnty_`parent'[omit] 24;
	char year[omit] 1999;
	
	/* run regs */
	foreach outcome in lbw neom pneom infm {;
		foreach instr in mschnew68_73 {;
			
		if  "`outcome'"=="infm" | "`outcome'"=="neom" {;
			replace n=births;
			replace d=`outcome';
		};
			
		if "`outcome'"=="lbw" {;
			replace n=lbw_weight;
			replace d=lbw;
		};
				
		if "`outcome'"=="pneom" {;
			replace n=pneom_weight;
			replace d=pneom;
		};
		
		if "`instr'"=="mstockt" {;
			local i=1;
		};
			
		else if "`instr'"=="mschnew68_73" {;
			local i=2;
		};
		
		replace MOD`outcome'=ln((d+0.5)/(n-d+0.5)); 
		/*LOR modified to include cells with 0 outcome*/
		*replace `outcome'=MOD`outcome';
		
		replace MODweight=(n*(d+1)*(n-d+1))/((n+1)*(n+2)); 
		/*modified weihgts based on actual values*/
		replace MODweight=.000001 if MODweight==0;
			
		/* RUN REDUCED FORM REGRESSIONS*/
				
		reg MOD`outcome' `parent'_`instr'Xtreat0_12 _`parent'1cohort_`parent'_* 
			_`parent'2cnty_`parent'_*
			_Iyear_* _`parent'2cntXyea_* `parent'_jhrXtreat0_12 
			`parent'_agricXtreat0_12 [aweight=MODweight], robust 
			cl(cnty_`parent');
		
		outreg2 `parent'_`instr'Xtreat0_12 
			using Table5_6aMay_`parent'.xls, bracket se nocons bdec(3);
							
		};
	};


end;



*table5_6a m;
*table5_6a f ;



/*-----------------------------------------
Table5_6B
--------------------------------------- */


# delimit;

capture program drop Table5_6B;
program Table5_6B;

	args parent;
	clear; set mem 400m; set matsize 6000; set more off;

	cd "/Users/zhangyi/Desktop/可重复/edu_health/TaiwanProgs/";
	*use agg_`parent'_`age'_neweduc.dta;
	use TaiwanEd_`parent'_agg.dta;
	
	gen n=.;
	gen d=.;
		
	gen MODeduc=.;
	gen MODweight=.;
	foreach x in lbw neom pneom infm {;
		gen MOD`x'=.;
	};
	
	gen cntyXcohort_`parent'=(1000*cnty_`parent')+cohort_`parent';

	/* replicate original */
	if "`parent'"=="f" {;
		char cohort_`parent'[omit] 25;;
	};
	if "`parent'"=="m" {;
		char cohort_`parent'[omit] 20;
	};
	

	char cnty_`parent'[omit] 24;
	char year[omit] 1999;
	/* run regs */
	foreach outcome in lbw neom pneom infm {;
				
		if  "`outcome'"=="infm" | "`outcome'"=="neom" {;
			replace n=births;
			replace d=`outcome';
			replace MODeduc = educ_`parent';
		};

		if "`outcome'"=="lbw" {;
			replace n=lbw_weight;
			replace d=lbw;
			replace MODeduc = educ_lbw_`parent';
		};

		if "`outcome'"=="pneom" {;
			replace n=pneom_weight;
			replace d=pneom;
			replace MODeduc = educ_pneom_`parent' ;
		};

		replace MOD`outcome'=ln((d+0.5)/(n-d+0.5)); 
		/*LOR modified to include cells with 0 outcome*/
		*replace `outcome'=MOD`outcome';
		
		replace MODweight=(n*(d+1)*(n-d+1))/((n+1)*(n+2)); 
		/*modified weihgts based on actual values*/
		replace MODweight=.000001 if MODweight==0;
				
		/* RUN OLS REGRESSIONS */
				
		reg MOD`outcome' MODeduc _`parent'1cohort_`parent'_* 
			_`parent'2cnty_`parent'_*
			_Iyear_* _`parent'2cntXyea_* `parent'_jhrXtreat0_12 
			`parent'_agricXtreat0_12 [aweight=MODweight], 
			robust cl(cnty_`parent');
		
		outreg2 MODeduc
			using Table5_6B_May09_`parent'.xls, bracket se nocons bdec(3);		
	};

end;

*Table5_6B m;
*Table5_6B f;

/* ------------------------------------------
table5_6c
------------------------------------------------------- */

# delimit;

capture program drop _all;
program table5_6c;

	args parent;
	clear; set mem 400m; set matsize 6000; set more off;

	cd "/Users/zhangyi/Desktop/可重复/edu_health/TaiwanProgs/";
	use TaiwanEd_`parent'_agg.dta;
	
	gen n=.;
	gen d=.;
	
	gen MODeduc_`parent'=.;
	gen MODweight=.;
	foreach x in lbw infm neom pneom {;
		gen MOD`x'=.;
	};
	
	gen cntyXcohort_`parent'=(1000*cnty_`parent')+cohort_`parent';
	
	/* replicate original */
	if "`parent'"=="f" {;
		char cohort_`parent'[omit] 25;;
	};
	if "`parent'"=="m" {;
		char cohort_`parent'[omit] 20;
	};
	char cnty_`parent'[omit] 24;
	char year[omit] 1999;
	/* run regs */
	foreach outcome in lbw /*neom pneom infm */{;
		foreach instr in mschnew68_73 {;
		
		if  "`outcome'"=="infm" | "`outcome'"=="neom" {;
				replace n=births;
				replace d=`outcome';
				replace MODeduc_`parent'=educ_`parent';
			};
			
		if "`outcome'"=="lbw" {;
			replace n=lbw_weight;
			replace d=lbw;
			replace MODeduc_`parent'=educ_lbw_`parent';
		};
				
		if "`outcome'"=="pneom" {;
			replace n=pneom_weight;
			replace d=pneom;
			replace MODeduc_`parent'=educ_pneom_`parent';
		};
		
		if "`instr'"=="mstockt" {;
			local i=1;
		};
			
		else if "`instr'"=="mschnew68_73" {;
			local i=2;
		};
		
		replace MOD`outcome'=ln((d+0.5)/(n-d+0.5)); 
		/*LOR modified to include cells with 0 outcome*/
		*replace `outcome'=MOD`outcome';
		
		replace MODweight=(n*(d+1)*(n-d+1))/((n+1)*(n+2)); 
		/*modified weihgts based on actual values*/
		replace MODweight=.000001 if MODweight==0;
		
		/* RUN TSLS REGRESSIONS*/
			
		ivreg MOD`outcome' (MODeduc_`parent'=`parent'_`instr'Xtreat0_12) 
			_`parent'1cohort_`parent'_* _`parent'2cnty_`parent'_* _Iyear_* 
			_`parent'2cntXyea_* `parent'_jhrXtreat0_12 
			`parent'_agricXtreat0_12 [aweight=MODweight], 
			robust cl(cnty_`parent');
			
		outreg2 MODeduc_`parent' 
			using Table5_6C_may09_`parent'.xls, bracket se nocons bdec(3);
			
	};
	};

end;

*table5_6c m;
*table5_6c f;

/* --------------------------------------
table 5 and 6 wu hausman test stats
-------------------------------------------*/

# delimit;

capture program drop _all;
program table5_6cWH;

	args parent;
	
	clear; set mem 400m; set matsize 6000; set more off	;
	args parent;
	cd "/Users/zhangyi/Desktop/可重复/edu_health/TaiwanProgs/";
	use TaiwanEd_`parent'_agg.dta;
	
	gen n=.;
	gen d=.;
	
	gen MODeduc_`parent'=.;
	gen MODweight=.;
	foreach x in lbw infm neom pneom {;
		gen MOD`x'=.;
	};
	
	gen cntyXcohort_f=(1000*cnty_`parent')+cohort_`parent';
	
	
	/* replicate original */
	if "`parent'"=="f" {;
		char cohort_`parent'[omit] 25;
	};
	if "`parent'"=="m" {;
		char cohort_`parent'[omit] 20;
	};
	char cnty_`parent'[omit] 24;
	char year[omit] 1999;
	/* run regs */
	foreach outcome in lbw neom pneom infm {;
	foreach instr in mschnew68_73 {;
		
		if  "`outcome'"=="infm" | "`outcome'"=="neom" {;
			replace n=births;
			replace d=`outcome';
			replace MODeduc_`parent'=educ_`parent';
		};
			
		if "`outcome'"=="lbw" {;
			replace n=lbw_weight;
			replace d=lbw;
			replace MODeduc_`parent'=educ_lbw_`parent';
		};
				
		if "`outcome'"=="pneom" {;
			replace n=pneom_weight;
			replace d=pneom;
			replace MODeduc_`parent'=educ_pneom_`parent';
		};
		
		if "`instr'"=="mstockt" {;
			local i=1;
		};
			
		else if "`instr'"=="mschnew68_73" {;
			local i=2;
		};
		
		replace MOD`outcome'=ln((d+0.5)/(n-d+0.5)); 
		/*LOR modified to include cells with 0 outcome*/
		*replace `outcome'=MOD`outcome';
		
		replace MODweight=(n*(d+1)*(n-d+1))/((n+1)*(n+2)); 
		/*modified weihgts based on actual values*/
		replace MODweight=.000001 if MODweight==0;
			

		ivreg MOD`outcome' (MODeduc_`parent'=`parent'_`instr'Xtreat0_12) 
			_`parent'1cohort_`parent'_* _`parent'2cnty_`parent'_* _Iyear_* 
			_`parent'2cntXyea_* `parent'_jhrXtreat0_12 
			`parent'_agricXtreat0_12 [aweight=MODweight], 
			robust cl(cnty_`parent');
						
		reg MODeduc_`parent' `parent'_`instr'Xtreat0_12 
			_`parent'1cohort_`parent'_* 
			_`parent'2cnty_`parent'_* _Iyear_* 
			_`parent'2cntXyea_* `parent'_jhrXtreat0_12 
			`parent'_agricXtreat0_12 [aweight=MODweight];
		predict resid_`parent'_`outcome', r;
			
		testparm `parent'_`instr'Xtreat0_12;
			
		sca fstat=r(F);
		sca prob=r(p);
			
		reg MOD`outcome' resid_`parent'_`outcome' MODeduc_`parent' 
			_`parent'1cohort_`parent'_* _`parent'2cnty_`parent'_* 
			_Iyear_* 
			_`parent'2cntXyea_* `parent'_jhrXtreat0_12 
			`parent'_agricXtreat0_12 [aweight=MODweight], 
			robust cl(cnty_`parent');
			
			
		matrix coefs=e(b);
		matrix variance=e(V);
		sca resid_var_`parent'_`outcome' =el(variance,1,1);
		sca resid_coef_`parent'_`outcome' =el(coefs,1,1);
		sca whF=(resid_coef_`parent'_`outcome' /resid_var_`parent'_`outcome' ^.5)^2;
		di whF;
			
		outreg2 resid_`parent'_`outcome'  MODeduc_`parent' using WH_TEST.xls, 
			nocons addstat(WuHausF, whF) excel bracket se tdec(3);
				
				

		};
	};
		
end;


*table5_6cWH m;
*table5_6cWH f;
