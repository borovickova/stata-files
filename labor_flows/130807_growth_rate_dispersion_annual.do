set memory 14000m
local filepath "/scratch/kb103/stata/labor_flows"
use "`filepath'/quarterly_emp_hire_sep_ALL_reshaped.dta"

keep if quarter==1
keep fid year empQ
drop if empQ==.
drop if empQ==0

gen int time = year
xtset fid time

gen dEMP = empQ-L1.empQ
gen Z = 0.5*(empQ+L1.empQ)
gen emp_growth = dEMP/Z

gen emp_growth_sum = emp_growth
gen int obs_num = 1

forval i =1/3{
	replace emp_growth_sum = emp_growth_sum + L`i'.emp_growth if L`i'.emp_growth~=.
	replace obs_num = obs_num +1 if L`i'.emp_growth~=.
	
	replace emp_growth_sum = emp_growth_sum + F`i'.emp_growth if F`i'.emp_growth~=.
	replace obs_num = obs_num +1 if F`i'.emp_growth~=. 
}

gen emp_growth_av = emp_growth_sum/7

keep if obs_num ==7

gen dev_mean = (emp_growth - emp_growth_av)^2

gen dev_mean_sum = dev_mean
forval i =1/12{
	replace dev_mean_sum = dev_mean_sum+ L`i'.dev_mean if L`i'.dev_mean~=.
	replace dev_mean_sum = dev_mean_sum+ F`i'.dev_mean if F`i'.dev_mean~=.
}

gen sigma_et = (dev_mean_sum/7)^0.5
drop if sigma_et==.

sort time
by time: egen std_year = sd(sigma_et)

save  "`filepath'/standard_devation_annual.dta"

by time: gen index = _n
keep if index==1

save  "`filepath'/standard_devation_annual_time_series.dta"
