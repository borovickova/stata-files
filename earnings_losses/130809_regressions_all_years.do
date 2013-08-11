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

forval yy = 2005/2007{
	
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
	save "`filepath'/temp_`yy'.dta", replace
	
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
	save "`filepath'/Dtemp_`yy'.dta", replace
	
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


* GENERATE ANNUAL INCOME
forval yy = 2005/2007{
	
	* TREATMENT AND CONTROL IN A GIVEN DISPLACEMENT YEAR
	use "`filepath'/EL_ind_year`yy'.dta"
	drop if income==.
	gen real_annual_income_T = income/30*btag/(cpi/100)
	gen real_annual_income_coded_T = income_coded/30*btag/(cpi/100)

	sort pid year
	by pid year: gen int index = _n
	by pid year: egen real_annual_income = total(real_annual_income_T)
	by pid year: egen real_annual_income_coded = total(real_annual_income_coded_T)
	keep if index == 1
	drop index
	keep year pid real_annual_income real_annual_income_coded day* sex age CG* TG* fid_ML
	gen int year_mass_layoff = `yy'
	save "`filepath'/EL_annual_income_year`yy'.dta", replace
	
	* TREATMENT DAVIS MEASURE
	
	use "`filepath'/EL_Davis_ind_year`yy'.dta", clear
	drop if income==.
	gen real_annual_income_T = income/30*btag/(cpi/100)
	gen real_annual_income_coded_T = income_coded/30*btag/(cpi/100)

	sort pid year
	by pid year: gen int index = _n
	by pid year: egen real_annual_income = total(real_annual_income_T)
	by pid year: egen real_annual_income_coded = total(real_annual_income_coded_T)
	keep if index == 1
	drop index
	keep year pid real_annual_income real_annual_income_coded day* sex age TG* fid_ML year_mass_layoff

	save "`filepath'/EL_Davis_annual_income_year`yy'.dta", replace		
}
	
* CREATE FILES FOR REPLICATING DAVIS REGRESSIONS

forval yy = 2003/2005{	
	* DEAL WITH DUPLICATE OBSERVATIONS - IF A WORKER IS IN MORE THAN ONE TREATMENT/CONTROL GROUP
	
	* CONTROL GROUP
	use "`filepath'/EL_annual_income_year`yy'.dta"
	keep if CG3_men==1 | CG3_women==1
	keep pid CG3*
	by pid: gen int index = _n
	keep if index==1
	drop index
	saveold "`filepath'/EL_pid_CG3`yy'.dta", replace

	* TREATMENT GROUP
	local endy = `yy'+2
	forval yy1 = `yy'/`endy'{
		use "`filepath'/EL_Davis_annual_income_year`yy1'.dta"
		by pid: gen int index = _n
		keep if index == 1
		drop index
		keep pid TG* year_mass_layoff
		saveold "`filepath'/EL_pid_TG`yy1'.dta", replace
	}
	
	use "`filepath'/EL_pid_CG3`yy'.dta", clear
	forval yy1 = `yy'/`endy'{
		append using "`filepath'/EL_pid_TG`yy1'.dta"
	}

	sort pid
	by pid: gen int index = _n
	by pid: egen int maxindex = max(index)
	keep if maxindex>1
	drop index maxindex
	sort pid
	by pid: gen int index = _n
	keep if index==1
	keep pid
	save  "`filepath'/EL_`yy'_todrop.dta", replace

	* CREATE A FILE FOR REGRESSION
	clear
	use "`filepath'/EL_annual_income_year`yy'.dta" 
	keep if CG3_men==1 | CG3_women==1
	forval yy1 = `yy'/`endy'{
		append using "`filepath'/EL_Davis_annual_income_year`yy1'.dta"
	}
	merge m:1 pid using "`filepath'/EL_`yy'_todrop.dta"
	drop if _merge==3
	drop _merge
	save "`filepath'/xregression_annual_income_year`yy'.dta" , replace
}	
/*	
* REGRESSIONS
forval yy = 1976/2004{	 	
	use "`filepath'/regression_annual_income_year`yy'.dta" , clear
	gen byte treatmet =1 if TG4davis_men==1 | TG4davis_women==1
	
	* GENERATE Dtk dummies
	* note: k0 is just to keep the index k non-positive
	
	forval tt = 1972/2007{
		local k0 = (`yy'+2) - `tt'	
		local k  = `tt'- `yy' + `k0'
		local k1 = `tt'-(`yy'+1) + `k0'
		local k2 = `tt'-(`yy'+2) + `k0'
		
		gen byte D_`tt'_`k'  = 0
		gen byte D_`tt'_`k1' = 0
		gen byte D_`tt'_`k2' = 0
		
		local tk  = `tt'-`k' + `k0'
		local tk1 = `tt'-`k1'+ `k0'
		local tk2 = `tt'-`k2'+ `k0'
		
		replace D_`tt'_`k'  = 1 if year==`tt' & year_mass_layoff == `tk'  & treatmet == 1
		replace D_`tt'_`k1' = 1 if year==`tt' & year_mass_layoff == `tk1' & treatmet == 1
		replace D_`tt'_`k2' = 1 if year==`tt' & year_mass_layoff == `tk2' & treatmet == 1
	}

	gen age1 = year - year_mass_layoff + age
	gen age2 = age1^2
	gen age3 = age1^3
	gen age4 = age1^4
	save "`filepath'/regression_annual_income_year`yy'.dta", replace
	
	sort pid year
	xtset pid year
	save "`filepath'/regression_annual_income_year`yy'.dta", replace
	
	xi: xtreg real_annual_income i.year age1 age2 age3 age4 D_1976_2 - D_1976_31 if sex==1, fe
	xi: xtreg real_annual_income_coded i.year age age2 age3 age4 D_1976_2 - D_1976_31 if sex==1, fe
	
	xi: xtreg real_annual_income i.year age1 age2 age3 age4 D_1976_2 - D_1976_31 if sex==2, fe
	xi: xtreg real_annual_income_coded i.year age age2 age3 age4 D_1976_2 - D_1976_31 if sex==2, fe
}	

