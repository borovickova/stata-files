* CREATE FILES FOR THE REGRESSION
* CHOOSE THE CONTROL AND TREATMENT GROUPS, MATCH THEM WITH THE HISTORY

local filepath "/scratch/kb103/stata/earnings_losses"

***** CREATE FILES****************************************
/*
use "`filepath'/control_Davis_ind_1.dta"
forval ii = 2/10{
	append using "`filepath'/control_Davis_ind_`ii'.dta"
}
gen int year_mass_layoff = year+1
save "`filepath'/control_Davis_ind_all.dta", replace

clear

use "`filepath'/control_treatment_ind_1.dta"
forval ii = 2/10{
	append using "`filepath'/control_treatment_ind_`ii'.dta"
}
gen int year_mass_layoff = year
save "`filepath'/control_treatment_ind_all.dta", replace

clear
use "`filepath'/control_Davis_ind_all.dta"
append using "`filepath'/control_treatment_ind_all.dta"
save "`filepath'/control_treatment_all_measures.dta"

clear

use "`filepath'/employed_UStype_1_0.dta"
append using "`filepath'/employed_UStype_1_1.dta"
forval ii = 2/10{
	append using "`filepath'/employed_UStype_`ii'_0.dta"
	append using "`filepath'/employed_UStype_`ii'_1.dta"
}
save "`filepath'/employed_UStype_all.dta", replace

*/

/*
***** THIS IS JUST A TESTING SAMPLE ******************************

use "`filepath'/employed_UStype_1_1.dta"
gen double r=runiform()
keep if r<0.1
saveold "`filepath'/employed_UStype_1_1_sample.dta", replace

use  "`filepath'/control_treatment_ind_all.dta", replace
keep if year_mass_layoff==1982
saveold "`filepath'/control_treatment_ind_all_1982.dta", replace

*/

***** CREATE FILES FOR EACH YEAR ******************************
/*
forval yy = 1982/1985{
	
	* TREATMENT AND CONTROL IN A GIVEN DISPLACEMENT YEAR
	use "`filepath'/control_treatment_ind_all.dta", clear
	keep if year_mass_layoff ==`yy'
	sort pid fid days_worked_beginning
	drop if days_worked_beginning==.
	drop if days_worked_beginning<100
	by pid fid: gen int index = _n
	keep if index ==1
	drop index
	by pid: gen int index = _n
	by pid: egen int index2 = max(index)
	save "`filepath'/temp_`yy'.dta"
	
	drop if index2>1
	drop index index2
	rename fid fid_ML 
	drop year
	save "`filepath'/control_treatment_ind_year`yy'.dta", replace
	
	use "`filepath'/temp_`yy'.dta", clear
	keep if index2>1
	rename fid fid_ML 
	drop year
	save "`filepath'/control_treatment_ind_multi_year`yy'.dta", replace
	
	* DAVIS MEASURE
	use "`filepath'/control_Davis_ind_all.dta", clear
	keep if year_mass_layoff ==`yy'
	sort pid fid days_worked_beginning
	drop if days_worked_beginning==.
	drop if days_worked_beginning<100
	by pid fid: gen int index = _n
	keep if index ==1
	drop index
	by pid: gen int index = _n
	by pid: egen int index2 = max(index)
	save "`filepath'/Dtemp_`yy'.dta"
	
	drop if index2>1
	drop index index2
	rename fid fid_ML 
	drop year
	save "`filepath'/control_Davis_ind_year`yy'.dta", replace
	
	use "`filepath'/Dtemp_`yy'.dta", clear
	keep if index>1
	rename fid fid_ML 
	drop year
	save "`filepath'/control_Davis_ind_multi_year`yy'.dta", replace

	* MERGE WITH EMPLOYMENT SPELLS
	use "`filepath'/employed_UStype_all.dta", clear
	merge m:1 pid using "`filepath'/control_treatment_ind_year`yy'.dta", keep(match)
	save "`filepath'/EL_ind_year`yy'.dta", replace
	
	* MERGE WITH EMPLOYMENT SPELLS
	use "`filepath'/employed_UStype_all.dta", clear
	merge m:1 pid using "`filepath'/control_Davis_ind_year`yy'.dta", keep(match)
	save "`filepath'/EL_Davis_ind_year`yy'.dta", replace
	
}


* consider the year 1982; include also 1982, 1983; control group is CG3from the file
* annual inceom histories

* GENERATE ANNUAL INCOME
	use "`filepath'/EL_ind_year1982.dta"
	drop if income==.
	gen real_annual_income_T = income/30*btag/cpi
	gen real_annual_income_coded_T = income_coded/30*btag/cpi

	sort pid year
	by pid year: gen int index = _n
	by pid year: egen real_annual_income = total(real_annual_income_T)
	by pid year: egen real_annual_income_coded = total(real_annual_income_coded_T)
	keep if index == 1
	drop index
	keep year pid real_annual_income real_annual_income_coded day* sex age CG* TG* fid_ML
	gen int year_mass_layoff = 1982
	save "`filepath'/EL_annual_income_year1982.dta", replace
	
* control group DAVIS
forval yy=1982/1985{
	use "`filepath'/EL_Davis_ind_year`yy'.dta", clear
	drop if income==.
	gen real_annual_income_T = income/30*btag/cpi
	gen real_annual_income_coded_T = income_coded/30*btag/cpi

	sort pid year
	by pid year: gen int index = _n
	by pid year: egen real_annual_income = total(real_annual_income_T)
	by pid year: egen real_annual_income_coded = total(real_annual_income_coded_T)
	keep if index == 1
	drop index
	keep year pid real_annual_income real_annual_income_coded day* sex age TG* fid_ML year_mass_layoff

	save "`filepath'/EL_Davis_annual_income_year`yy'.dta", replace	
}


use "`filepath'/EL_annual_income_year1982.dta"
keep if CG3_men==1 | CG3_women==1
keep pid CG3*
by pid: gen int index = _n
keep if index==1
drop index
saveold "`filepath'/EL_pid_CG31982.dta", replace

forval yy = 1982/1985{
	use "`filepath'/EL_Davis_annual_income_year`yy'.dta"
	by pid: gen int index = _n
	keep if index==1
	drop index
	keep pid TG* year_mass_layoff
	saveold "`filepath'/EL_pid_TG`yy'.dta", replace
}

	use "`filepath'/EL_pid_CG31982.dta", clear
	append using "`filepath'/EL_pid_TG1982.dta"
	append using "`filepath'/EL_pid_TG1983.dta"
	append using "`filepath'/EL_pid_TG1984.dta"
	sort pid
	by pid: gen int index = _n
	by pid: egen int maxindex = max(index)
	keep if maxindex>1
	drop index maxindex
	sort pid
	by pid: gen int index = _n
	keep if index==1
	keep pid
	save  "`filepath'/EL_1982_todrop.dta", replace

* REGRESSIONS
	clear
	use "`filepath'/EL_annual_income_year1982.dta" 
	keep if CG3_men==1 | CG3_women==1
	append using "`filepath'/EL_Davis_annual_income_year1982.dta"
	append using "`filepath'/EL_Davis_annual_income_year1983.dta"
	append using "`filepath'/EL_Davis_annual_income_year1984.dta"
	merge m:1 pid using "`filepath'/EL_1982_todrop.dta"
	drop if _merge==3
	drop _merge
	save "`filepath'/regression_annual_income_year1982.dta" , replace
	
	
	use "`filepath'/regression_annual_income_year1982.dta" , clear
	drop D_*
	
	gen int current_year = .
	local maxround = 2007-1982
	
	forval kk = -6/`maxround'{
		
		replace current_year = year_mass_layoff +`kk' 
		
		local kx = `kk' + 6
		
		gen byte D_`kx' = 0
		replace D_`kx' = 1 if treatmet == 1 & year == current_year
			
	}
	drop current_year
	
	sort pid year
	save "`filepath'/2regression_annual_income_year1982.dta", replace
*/	
	
	use "`filepath'/2regression_annual_income_year1982.dta", clear
	
	local maxround = 2007-1982
	local lastD = `maxround'+6
	
	xi: xtreg real_annual_income i.year age1 age2 age3 age4 D_0 - D_`lastD' if sex==1, fe
	xi: xtreg real_annual_income_coded i.year age1 age2 age3 age4 D_0 - D_`lastD' if sex==1, fe
	
