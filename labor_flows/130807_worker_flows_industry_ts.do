set memory 14000m
local filepath "/scratch/kb103/stata/labor_flows"
use "`filepath'/quarterly_emp_hire_sep_ALL_reshaped.dta"

drop if empQ==.
drop if empQ==0

merge m:1 fid using "`filepath'/fid_industry.dta"
keep if _merge==3

gen int time = (year-1972)*4+quarter
xtset fid time
gen Z = 0.5*(empQ+L1.empQ)

sort year quarter industry
by year quarter industry: egen emp_tot = total(empQ)
by year quarter industry: egen Z_tot = total(Z)
by year quarter industry: egen hire_tot = total(hireQ)
by year quarter industry: egen hire1st_tot = total(hire1stQ)
by year quarter industry: egen sep_tot = total(sepQ)
by year quarter industry: egen sepLast_tot = total(sepLastQ)
by year quarter industry: egen hirefromE_tot = total(hirefromEMPQ )
by year quarter industry: egen hirefromENTER_tot = total(hirefromENTERDATAQ )
by year quarter industry: egen septoE_tot = total(septoEMPQ )
by year quarter industry: egen septoRETIR_tot = total(septoRETIRQ )

by year quarter industry: gen index = _n
keep if index==1
drop index

save worker_flows_industry_ts.dta,replace
