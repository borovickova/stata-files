
set memory 14000m
local filepath "/scratch/kb103/stata/labor_flows"

use "`filepath'/quarterly_emp_hire_sep_ALL_reshaped.dta"

keep fid year quarter empQ
drop if empQ==0
drop if empQ==.

merge m:1 fid using "`filepath'/fid_industry.dta"
keep if _merge==3
keep if quarter ==1

keep year fid empQ ind* 
gen int time = year
xtset fid time
gen lnemp = log(empQ)
gen lnemp_lag = L1.lnemp

gen byte size_cat = .
replace size_cat = 1 if empQ>0   & empQ<=5 
replace size_cat = 2 if empQ>5   & empQ<=20
replace size_cat = 3 if empQ>20  & empQ<=50
replace size_cat = 4 if empQ>50  & empQ<=100
replace size_cat = 5 if empQ>100 & empQ<=500
replace size_cat = 6 if empQ>500 & empQ<=1000
replace size_cat = 7 if empQ>1000

* PLANT AGE
sort fid time
by fid: gen int index = _n
gen int year_start = .
replace year_start = year if index ==1
replace year_start = year_start[_n-1] if fid==fid[_n-1]
gen int plant_age  = .
replace plant_age  = year-year_start+1

gen byte age_cat = .
replace age_cat = 1 if plant_age<=5
replace age_cat = 2 if plant_age>5 & plant_age<=10
replace age_cat = 4 if year_start == 1972
replace age_cat = 3 if plant_age>10

save  "`filepath'/autocorrelation_industry_annual.dta", replace

xi: xtreg lnemp i.industry*lnemp_lag i.time*i.industry i.size_cat i.age_cat, fe

keep if year<1990
xi: xtreg lnemp i.industry*lnemp_lag i.time*i.industry i.size_cat i.age_cat, fe
 
use "`filepath'/autocorrelation_industry_annual.dta",clear
keep if year>1990 
xi: xtreg lnemp i.industry*lnemp_lag i.time*i.industry i.size_cat i.age_cat, fe


