set memory 14000m
local filepath "/scratch/kb103/stata/labor_flows"
/*
use "`filepath'/quarterly_emp_hire_sep_ALL_reshaped.dta"

keep fid year quarter empQ
drop if empQ==0
drop if empQ==.

keep if _merge==3
gen int time = (year-1972)*4+quarter
xtset fid time

gen dEMP = empQ-L1.empQ
gen Z = 0.5*(empQ+L1.empQ)
gen emp_growth = dEMP/Z

gen int obs_num = 1
gen Z_sum = Z

forval i =1/12{
	replace Z_sum = Z_sum + L`i'.Z if L`i'.Z~=.
	replace obs_num = obs_num + 1 if L`i'.Z~=.
	
	replace Z_sum = Z_sum + F`i'.Z if F`i'.Z~=.
	replace obs_num = obs_num +1 if F`i'.Z~=. 
}
gen K = obs_num/Z_sum

gen emp_growth_av = Z*emp_growth/Z_sum

forval i =1/12{
	replace emp_growth_av = emp_growth_av + L`i'.Z*L`i'.emp_growth/Z_sum if L`i'.Z~=.
	replace emp_growth_av = emp_growth_av + F`i'.Z*F`i'.emp_growth/Z_sum if F`i'.Z~=.
}

gen dev_mean_av = K*Z*(emp_growth-emp_growth_av)^2

forval i =1/12{
	replace dev_mean_av = dev_mean_av + K*L`i'.Z*(L`i'.emp_growth-emp_growth_av)^2 if L`i'.Z~=.
	replace dev_mean_av = dev_mean_av + K*F`i'.Z*(F`i'.emp_growth-emp_growth_av)^2 if F`i'.Z~=.
}

gen sigma_et = (dev_mean_av/(obs_num-1))^0.5

sort time
by time: egen std_year = sd(sigma_et)

save  "`filepath'/standard_devation_davis.dta"

sort time
by time: gen index = _n
keep if index == 1
save  "`filepath'/standard_devation_davis_time_series.dta"
*/

use "`filepath'/standard_devation_davis.dta"
merge m:1 fid using "`filepath'/fid_industry.dta"
sort industry time
by industry time: egen std_year_industry = sd(sigma_et)
by industry time: gen index1=_n
keep if index==1
save "`filepath'/standard_devation_davis_ts_industry.dta"




