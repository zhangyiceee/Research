* 数据用PSM.dta(基础回归用PSM 2010-2013.dta，稳健性检验分别用PSM 2010-2012(稳健性检验).dta和PSM 2010-2011(稳健性检验).dta)
* 协变量为2009年，输出变量loan10、npl10、roa10则是2010年的相应指标。

set seed 10101
gen ranorder=runiform()
sort ranorder

psmatch2 treat cap lpr lev ldr loan npl roa,outcome(loan10) kernel  ate ties common
pstest  cap lpr  lev ldr loan npl roa,both graph
psgraph


psmatch2 treat cap lpr lev ldr loan npl roa,outcome(npl10) kernel  ate ties common
pstest  cap lpr  lev ldr loan npl roa,both graph
psgraph


psmatch2 treat cap lpr lev ldr loan npl roa,outcome(roa10) kernel  ate ties common
pstest  cap lpr  lev ldr loan npl roa,both graph
psgraph
