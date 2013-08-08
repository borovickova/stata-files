set memory 14000m
local filepath "/scratch/kb103/stata/labor_flows"

use "`filepath'/quarterly_emp_hire_sep_ALL_reshaped.dta"

keep fid year quarter empQ
drop if empQ==0
drop if empQ==.

merge m:1 fid using "`filepath'/fid_industry.dta"
keep if _merge==3

gen int time = (year-1972)*4+quarter
xtset fid time

gen dEMP = empQ-L1.empQ
gen Z = 0.5*(empQ+L1.empQ)
gen emp_growth = dEMP/Z

gen JC = 0
replace JC = dEMP if dEMP>0
gen JD = 0
replace JD = -dEMP if dEMP<0

sort industry time
by industry time: egen JC_total = sum(JC)
by industry time: egen JD_total = sum(JD)
by industry time: egen Z_total = sum(Z)
by industry time: gen index1=_n
keep if index1==1

gen JCrate = JC_total/Z_total
gen JDrate = JD_total/Z_total

save  "`filepath'/jc_jd_industry_.dta"
