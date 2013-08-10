/*
set memory 14000m
local filepath "/scratch/kb103/stata/labor_flows"
use "`filepath'/quarterly_emp_hire_sep_ALL_reshaped.dta"

drop if empQ==.
drop if empQ==0
keep if quarter==1

keep fid year empQ
sort fid year
gen int x1 = 0
replace x1 = 1 if empQ > 30
by fid: egen s30 = total(x1)

keep if x1>10

merge m:1 fid using "`filepath'/fid_industry.dta"
keep if _merge==3

save "/scratch/kb103/stata/rigid_wages/sample_firm.dta", replace
*/
set memory 14000m
local filepath "/scratch/kb103/stata/earnings_losses"
local filepath2 "/scratch/kb103/stata/rigid_wages"

forval jj = 1/1{
forval ii = 6/10{
	use "`filepath'/employed_UStype_`ii'_`jj'.dta", clear
	sort fid year
	merge m:1 fid year using "`filepath2'/firm_selection_firms.dta"
	keep if _merge==3
	keep pid
	sort pid
	by pid: gen index = _n
	keep if index==1
	drop index
	save "`filepath2'/_select_pidonly_`ii'_`jj'.dta", replace
	
	use "`filepath'/employed_UStype_`ii'_`jj'.dta", clear
	merge m:1 pid using "`filepath2'/_select_pidonly_`ii'_`jj'.dta"
	keep if _merge==3
	drop _merge
	save "`filepath2'/indiv_select_`ii'_`jj'.dta", replace
}
}

use "`filepath2'/indiv_select_1_0.dta"
append using "`filepath2'/indiv_select_1_1.dta"	
forval jj = 0/1{
forval ii = 2/10{
 append using "`filepath2'/indiv_select_`ii'_`jj'.dta"
}
}

save "`filepath2'/indiv_select_all.dta", replace
