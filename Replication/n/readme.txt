All analyses were done in Stata version 10. Raw data files come from ECLS-K Longitudinal K-3 public use data 
file (NCES 2004-089), available at http://www.edpubs.gov/Product_Detail.aspx?SearchTerm=ED001011C (as of 5/13/10).

raw ECLS-K data:
----------------
Pull raw ascii data from ECLS-K. This automatically provides do-file and dct-file. Run each of the following do-files 
to put data into Stata format:
1) mainfile.do - bulk of ecls data
2) classmeasures.do - data on teacher chars, class chars, plus some others for grade K
3) classmeasures2.do - data on teacher chars, class chars, plus some others for grades 1 & 3
4) parenting.do - data on parent reports of behavior

data processing:
----------------
Once raw files are read in to Stata format, run the following programs to prepare data for analysis:
1) procecls.do - clean & process main ecls data
2) procecls2.do - like 1 but adds grades 1 & 3 teacher chars
3) setupd.do - sets up data for regression, including imputation
4) setupd2.do - like 1 but adds grades 1 & 3 teacher chars
NOTE: for setup(2) to run, must install user-written stata command 'ice' (type 'ssc install ice' at stata prompt)

analysis:
---------
Run each tableX.do where X corresponds to the table number in final text. When tables are split into multiple 
programs, the first commented line in each do-file notes the relevant part of the table.
NOTE: before running each do-file, must add sub-directory 'tableX', which stores regression results in tab-delimited 
format.