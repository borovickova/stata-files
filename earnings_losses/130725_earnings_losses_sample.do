* EARNINGS LOSSES OF DISPLACED WORKERS
* IDENTIFY CONTROL AND TREATMENT GROUP EXACTLY AS IN DAVIS AND VON WACHTER

local filepath "/scratch/kb103/stata/earnings_losses"
/*
use "`filepath'/130508_firms_stats_EL_merged_25.dta", clear

replace firm_exit =. if year == 2007
replace mass_layoff_indic =. if firm_exit == 1

gen int year2 = year-1
rename year year_actual
rename year2 year

save "`filepath'/130508_firms_stats_EL_merged_25_shifted.dta", replace

keep if mass_layoff_indic == 1
save  "`filepath'/130508_firms_stats_EL_merged_25_shifted_MLonly.dta", replace
*/

forval ii = 1/10{

	use "`filepath'/130508employed_UStype_EL_`ii'_0.dta", clear
	append using "`filepath'/130508employed_UStype_EL_`ii'_1.dta"		
	merge m:1 fid year using "`filepath'/130508_firms_stats_EL_merged_25_shifted_MLonly.dta", keep(match)

	*keep if _merge==3
	*drop _merge

	gen byte A1=0
	replace A1 = 1 if age<=50 & age>=16

	gen byte T4= 0
	replace T4 = 1 if FEyM1==1 & FEyM2==1

	* control and treatment group
	
	gen byte sepD = 1 if FEyP1~= 1 & edate~=17531
	
	
	* control and treatment group
	drop if emp==.
	* treatment group
	gen byte TG4davis_men = 1 if A1==1 & sex==1 & T4==1 & sepD==1 & mass_layoff_indic ==1
	gen byte TG4davis_women = 1 if A1==1 & sex==2 & T4==1 & sepD==1 & mass_layoff_indic ==1
	
	keep if TG4davis_men == 1 | TG4davis_women == 1
	
	keep year pid fid age sex FE* days* T* days_worked_beginning days_worked_break
	compress
	save  "`filepath'/control_Davis_ind_`ii'.dta", replace
	clear
}

