set memory 14000m
local filepath "/scratch/kb103/stata/labor_flows"
use "`filepath'/quarterly_emp_hire_sep_ALL_reshaped.dta"
/*
sort year quarter
  foreach var of varlist empQ - sepLasttoRETIRQ {
	by year quarter: egen `var'_tot = total(`var')                
	drop `var'
}

by year quarter: gen int index = _n
keep if index ==1
drop index fid
save emp_hire_sep_time_series.dta
*/

keep fid year quarter empQ
sort fid year quarter
gen int time = (year-1972)*4+ quarter
sort fid time
xtset fid time
gen dEMP = empQ-L1.empQ
gen Z = 0.5*(empQ+L1.empQ)
gen JC = 0
replace JC = dEMP if dEMP>0
gen JD = 0
replace JD = -dEMP if dEMP<0
sort time
foreach var of varlist Z JC JD{
	by time: egen `var'_tot = total(`var')               
}
sort time
by time: gen int index = _n
keep if index ==1
keep year quarter Z_tot JC_tot JD_tot
save JC_JD_time_series.dta, replace
